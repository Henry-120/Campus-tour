package com.example.campus_tour.ar

import android.content.Context
import androidx.activity.ComponentActivity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory

class CampusArPlatformViewFactory(
    private val activity: ComponentActivity,
    private val binaryMessenger: BinaryMessenger,
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {

    override fun create(context: Context, viewId: Int, args: Any?): PlatformView =
        CampusArPlatformView(
            context = context,
            activity = activity,
            viewId = viewId,
            binaryMessenger = binaryMessenger,
        )

    companion object {
        const val VIEW_TYPE = "campus_tour/arcore_scene"
    }
}
