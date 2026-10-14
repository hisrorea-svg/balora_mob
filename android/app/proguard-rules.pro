# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# ML Kit and CameraX (Used by mobile_scanner)
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.** { *; }
-keep class androidx.camera.** { *; }
-keep class dev.steenbakker.mobile_scanner.** { *; }

# Prevent R8 from failing due to missing Play Core classes used by Flutter
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**
