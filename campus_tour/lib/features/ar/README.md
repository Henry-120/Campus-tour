# AR feature

This feature keeps the Apple and Android AR implementations separate:

- `pages/ios/` contains the ARKit placement and fairy-control pages.
- `pages/android/`, `services/android/`, `controllers/android/`, and
  `widgets/android/` contain the ARCore support gate and native scene bridge.
- `widgets/shared/` contains Flutter-only controls shared by both platforms.
- Code outside this feature should import only `ar.dart`.

Android-native AR code lives under
`android/app/src/main/kotlin/com/example/campus_tour/ar/`. Android GLB assets
live in the install-time Play Asset Pack under
`android/ar_model_pack/src/main/assets/ar/`; Apple USDZ assets remain under
`ios/`. The asset pack preserves the `ar/...` AssetManager paths used by the
native model catalog and SceneView loader.

The Android model catalog currently maps `squirrel.usdz` to the bundled
`squirrel.glb`. Add both the GLB and a catalog entry before exposing another
monster on Android. Android checks ARCore support and camera permission before
creating an AR session; iOS retains the original direct ARKit flow.
