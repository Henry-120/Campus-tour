package com.example.campus_tour.ar

import android.app.Activity
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/** Bridges ARCore support/install checks to the Flutter support gate. */
class ArCoreChannelHandler(
    activity: Activity,
    binaryMessenger: BinaryMessenger,
) : MethodChannel.MethodCallHandler {
    private val checker = ArCoreSupportChecker(activity)
    private val channel = MethodChannel(binaryMessenger, CHANNEL)

    init {
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "checkAvailability" -> result.success(checker.checkAvailability())
                "requestInstall" -> result.success(checker.requestInstall())
                else -> result.notImplemented()
            }
        } catch (error: Exception) {
            result.error(
                "ARCORE_${call.method.uppercase()}",
                error.message ?: "ARCore request failed",
                error.javaClass.simpleName,
            )
        }
    }

    fun dispose() {
        channel.setMethodCallHandler(null)
    }

    companion object {
        const val CHANNEL = "campus_tour/arcore_support"
    }
}
