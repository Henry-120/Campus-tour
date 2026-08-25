package com.example.campus_tour.ar

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.view.MotionEvent
import android.view.View
import androidx.activity.ComponentActivity
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.key
import androidx.compose.runtime.mutableStateListOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.ComposeView
import com.google.ar.core.Anchor
import com.google.ar.core.Config
import com.google.ar.core.Frame
import com.google.ar.core.Plane
import com.google.ar.core.Session
import com.google.ar.core.TrackingState
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import io.github.sceneview.SurfaceType
import io.github.sceneview.ar.ARSceneView
import io.github.sceneview.ar.ActivityARPermissionHandler
import io.github.sceneview.math.Position
import io.github.sceneview.math.Scale
import io.github.sceneview.rememberEngine
import io.github.sceneview.rememberMaterialLoader
import io.github.sceneview.rememberModelInstance
import io.github.sceneview.rememberModelLoader
import io.github.sceneview.rememberOnGestureListener

/**
 * Native ARCore scene used by the Flutter Android placement page.
 *
 * A tap is hit-tested against a tracked horizontal plane. The selected model is
 * parented to an ARCore Anchor at that hit pose, so its position follows the
 * real surface instead of the phone's height at session start.
 */
class CampusArPlatformView(
    context: Context,
    activity: ComponentActivity,
    viewId: Int,
    binaryMessenger: BinaryMessenger,
) : PlatformView, MethodChannel.MethodCallHandler {

    private val mainHandler = Handler(Looper.getMainLooper())
    private val channel = MethodChannel(binaryMessenger, "$CHANNEL_PREFIX$viewId")
    private val modelCatalog = ArModelCatalog(context)
    private val anchors = mutableStateListOf<Anchor>()
    private val selectedModel = mutableStateOf<AndroidArModelConfig?>(null)
    private var latestFrame: Frame? = null
    private var hasReportedPlane = false
    private val permissionHandler = ActivityARPermissionHandler(activity)

    private val composeView = ComposeView(context).apply {
        setContent {
            val engine = rememberEngine()
            val modelLoader = rememberModelLoader(engine)
            val materialLoader = rememberMaterialLoader(engine)

            ARSceneView(
                modifier = Modifier.fillMaxSize(),
                surfaceType = SurfaceType.TextureSurface,
                engine = engine,
                modelLoader = modelLoader,
                materialLoader = materialLoader,
                permissionHandler = permissionHandler,
                planeRenderer = true,
                sessionConfiguration = { _: Session, config: Config ->
                    config.planeFindingMode = Config.PlaneFindingMode.HORIZONTAL
                    config.lightEstimationMode = Config.LightEstimationMode.ENVIRONMENTAL_HDR
                },
                onSessionCreated = { emit("onReady") },
                onSessionUpdated = { session, frame ->
                    latestFrame = frame
                    if (!hasReportedPlane && session.getAllTrackables(Plane::class.java).any {
                            it.type == Plane.Type.HORIZONTAL_UPWARD_FACING &&
                                it.trackingState == TrackingState.TRACKING
                        }
                    ) {
                        hasReportedPlane = true
                        emit("onPlaneDetected")
                    }
                },
                onSessionFailed = { error ->
                    emit("onError", error.message ?: error.javaClass.simpleName)
                },
                onGestureListener = rememberOnGestureListener(
                    onSingleTapConfirmed = { event: MotionEvent, node ->
                        if (node != null) return@rememberOnGestureListener
                        placeModel(event)
                    },
                ),
            ) {
                val activeModel = selectedModel.value
                anchors.forEach { anchor ->
                    key(anchor, activeModel?.assetPath) {
                        AnchorNode(anchor = anchor) {
                            activeModel?.let { model ->
                                val instance = rememberModelInstance(
                                    modelLoader,
                                    model.assetPath,
                                )
                                instance?.let {
                                    ModelNode(
                                        modelInstance = it,
                                        scale = Scale(model.scale),
                                        position = Position(model.centeredX, 0f, 0f),
                                        autoAnimate = true,
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    init {
        channel.setMethodCallHandler(this)
    }

    private fun placeModel(event: MotionEvent) {
        if (selectedModel.value == null) {
            emit("onError", "MODEL_NOT_SELECTED")
            return
        }
        val frame = latestFrame ?: return
        if (frame.camera.trackingState != TrackingState.TRACKING) return

        val hit = frame.hitTest(event).firstOrNull { result ->
            val plane = result.trackable as? Plane ?: return@firstOrNull false
            plane.type == Plane.Type.HORIZONTAL_UPWARD_FACING &&
                plane.trackingState == TrackingState.TRACKING &&
                plane.isPoseInPolygon(result.hitPose) &&
                result.distance <= MAX_PLACEMENT_DISTANCE_METERS
        } ?: return

        clearAnchors()
        anchors.add(hit.createAnchor())
        emit("onModelPlaced")
    }

    private fun clearAnchors() {
        anchors.forEach { anchor -> runCatching { anchor.detach() } }
        anchors.clear()
    }

    private fun emit(method: String, argument: Any? = null) {
        mainHandler.post { channel.invokeMethod(method, argument) }
    }

    override fun getView(): View = composeView

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "setModel" -> {
                val arRef = call.argument<String>("arRef")
                val model = modelCatalog.resolve(arRef)
                if (model == null) {
                    result.error(
                        "UNSUPPORTED_MODEL",
                        "No Android AR asset is mapped for $arRef",
                        arRef,
                    )
                    return
                }
                clearAnchors()
                selectedModel.value = model
                result.success(true)
            }

            "clearModel" -> {
                clearAnchors()
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }

    override fun dispose() {
        clearAnchors()
        latestFrame = null
        channel.setMethodCallHandler(null)
        composeView.disposeComposition()
        (composeView.parent as? android.view.ViewGroup)?.removeView(composeView)
    }

    companion object {
        const val CHANNEL_PREFIX = "campus_tour/arcore_scene_"
        private const val MAX_PLACEMENT_DISTANCE_METERS = 5f
    }
}
