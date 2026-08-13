package tw.edu.ncu.campustour

import android.os.Handler
import android.os.Looper
import com.example.campus_tour.ar.ArCoreChannelHandler
import com.example.campus_tour.ar.CampusArPlatformViewFactory
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.IOException
import java.util.concurrent.Executors

// FlutterFragmentActivity provides the lifecycle/saved-state owners required by
// the Compose-based SceneView embedded in the AR PlatformView.
class MainActivity : FlutterFragmentActivity() {
    companion object {
        private const val CHANNEL = "tw.edu.ncu.campustour/pad_audio"
        private const val PREPARE_AUDIO_ASSET = "prepareAudioAsset"
    }

    private val ioExecutor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())
    private var arCoreChannelHandler: ArCoreChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val binaryMessenger = flutterEngine.dartExecutor.binaryMessenger
        flutterEngine.platformViewsController.registry.registerViewFactory(
            CampusArPlatformViewFactory.VIEW_TYPE,
            CampusArPlatformViewFactory(
                activity = this,
                binaryMessenger = binaryMessenger,
            ),
        )
        arCoreChannelHandler?.dispose()
        arCoreChannelHandler = ArCoreChannelHandler(this, binaryMessenger)

        MethodChannel(binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method != PREPARE_AUDIO_ASSET) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }

                val assetPath = call.argument<String>("assetPath")
                if (!isValidMusicPath(assetPath)) {
                    result.error(
                        "INVALID_AUDIO_PATH",
                        "assetPath 必須是 music/ 底下的相對路徑",
                        assetPath,
                    )
                    return@setMethodCallHandler
                }

                ioExecutor.execute {
                    try {
                        val cachedFile = copyAssetToCache(assetPath!!)
                        mainHandler.post { result.success(cachedFile.absolutePath) }
                    } catch (exception: IOException) {
                        mainHandler.post {
                            result.error(
                                "PAD_AUDIO_NOT_FOUND",
                                "無法從 music_pack 讀取 $assetPath",
                                exception.message,
                            )
                        }
                    } catch (exception: SecurityException) {
                        mainHandler.post {
                            result.error(
                                "INVALID_AUDIO_PATH",
                                exception.message,
                                assetPath,
                            )
                        }
                    }
                }
            }
    }

    private fun isValidMusicPath(assetPath: String?): Boolean {
        if (assetPath == null || !assetPath.startsWith("music/")) return false

        val segments = assetPath.split('/')
        return segments.none { it.isEmpty() || it == "." || it == ".." }
    }

    @Throws(IOException::class)
    private fun copyAssetToCache(assetPath: String): File {
        // lastUpdateTime 讓 app 更新後使用新的快取目錄，避免讀到舊版音樂。
        val lastUpdateTime = packageManager.getPackageInfo(packageName, 0).lastUpdateTime
        val cacheRoot = File(cacheDir, "pad_audio/$lastUpdateTime")
        val relativePath = assetPath.removePrefix("music/")
        val targetFile = File(cacheRoot, relativePath)

        val canonicalRoot = cacheRoot.canonicalFile
        val canonicalTarget = targetFile.canonicalFile
        if (!canonicalTarget.path.startsWith(canonicalRoot.path + File.separator)) {
            throw SecurityException("音樂路徑超出允許的快取目錄")
        }

        if (canonicalTarget.isFile && canonicalTarget.length() > 0L) {
            return canonicalTarget
        }

        canonicalTarget.parentFile?.mkdirs()
        val temporaryFile = File(canonicalTarget.parentFile, "${canonicalTarget.name}.tmp")

        try {
            // install-time asset pack 會合併到 app 的 AssetManager。
            assets.open(assetPath).use { input ->
                temporaryFile.outputStream().use { output -> input.copyTo(output) }
            }

            if (!temporaryFile.renameTo(canonicalTarget)) {
                temporaryFile.copyTo(canonicalTarget, overwrite = true)
                temporaryFile.delete()
            }
        } finally {
            if (temporaryFile.exists()) temporaryFile.delete()
        }

        return canonicalTarget
    }

    override fun onDestroy() {
        arCoreChannelHandler?.dispose()
        arCoreChannelHandler = null
        ioExecutor.shutdown()
        super.onDestroy()
    }
}
