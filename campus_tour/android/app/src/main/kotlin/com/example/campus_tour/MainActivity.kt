package com.example.campus_tour

import com.example.campus_tour.ar.ArCoreChannelHandler
import com.example.campus_tour.ar.CampusArPlatformViewFactory
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterFragmentActivity() {
    private var arCoreChannelHandler: ArCoreChannelHandler? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        flutterEngine.platformViewsController.registry.registerViewFactory(
            CampusArPlatformViewFactory.VIEW_TYPE,
            CampusArPlatformViewFactory(this, messenger),
        )
        arCoreChannelHandler?.dispose()
        arCoreChannelHandler = ArCoreChannelHandler(this, messenger)
    }

    override fun onDestroy() {
        arCoreChannelHandler?.dispose()
        arCoreChannelHandler = null
        super.onDestroy()
    }
}
