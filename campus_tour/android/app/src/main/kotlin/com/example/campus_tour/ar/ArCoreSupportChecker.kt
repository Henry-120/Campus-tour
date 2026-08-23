package com.example.campus_tour.ar

import android.app.Activity
import com.google.ar.core.ArCoreApk

/** Small wrapper around the ARCore availability and install APIs. */
class ArCoreSupportChecker(private val activity: Activity) {
    fun checkAvailability(): String =
        ArCoreApk.getInstance().checkAvailability(activity).name

    fun requestInstall(): String =
        ArCoreApk.getInstance().requestInstall(activity, true).name
}
