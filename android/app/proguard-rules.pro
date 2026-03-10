## Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

## Google ML Kit
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**

## Gson (used by various plugins)
-keepattributes Signature
-keepattributes *Annotation*
-keep class com.google.gson.** { *; }

## Firebase
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

## OkHttp / HTTP
-dontwarn okhttp3.**
-dontwarn okio.**
