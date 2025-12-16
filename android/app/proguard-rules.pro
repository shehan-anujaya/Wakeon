# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.embedding.** { *; }

# Play Core (optional feature, suppress warnings)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# TensorFlow Lite GPU (optional feature, suppress warnings)
-dontwarn org.tensorflow.lite.gpu.**
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.** { *; }

# Google ML Kit - Critical for face detection
-keep class com.google.android.gms.** { *; }
-keep class com.google.mlkit.** { *; }
-keep class com.google.android.gms.vision.** { *; }
-keep class com.google.android.gms.internal.** { *; }
-keep interface com.google.mlkit.** { *; }
-dontwarn com.google.android.gms.**
-dontwarn com.google.mlkit.**

# Keep ML Kit face detection specific classes
-keep class com.google.mlkit.vision.** { *; }
-keep class com.google.mlkit.vision.face.** { *; }
-keep interface com.google.mlkit.vision.face.** { *; }

# Camera - Critical for image stream
-keep class androidx.camera.** { *; }
-keep interface androidx.camera.** { *; }
-keep class androidx.camera.core.** { *; }
-keep class androidx.camera.camera2.** { *; }
-keep class androidx.camera.lifecycle.** { *; }
-dontwarn androidx.camera.**

# Camera plugin specific
-keep class io.flutter.plugins.camera.** { *; }
-keep interface io.flutter.plugins.camera.** { *; }

# Gson (if used)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Keep Parcelables
-keep class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator *;
}

# Keep Serializable
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# AudioPlayers
-keep class xyz.luan.audioplayers.** { *; }
-keep interface xyz.luan.audioplayers.** { *; }

# TTS
-keep class com.tencent.** { *; }
-keep class com.taylorcyang.flutter_tts.** { *; }

# Vibration
-keep class vibration.** { *; }

# Path Provider
-keep class io.flutter.plugins.pathprovider.** { *; }

# Shared Preferences
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Permission Handler
-keep class com.baseflow.permissionhandler.** { *; }

# Device Info
-keep class dev.fluttercommunity.plus.device_info.** { *; }

# Reflection and Runtime
-keepattributes SourceFile,LineNumberTable
-keepattributes RuntimeVisibleAnnotations
-keepattributes RuntimeInvisibleAnnotations
-keepattributes RuntimeVisibleParameterAnnotations
-keepattributes RuntimeInvisibleParameterAnnotations
-keepattributes EnclosingMethod
-keepattributes InnerClasses
-renamesourcefileattribute SourceFile

# Keep all enums
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# Prevent stripping of native libraries
-keepclasseswithmembernames,includedescriptorclasses class * {
    native <methods>;
}

# Don't obfuscate classes that use native methods
-keepclasseswithmembers class * {
    native <methods>;
}

# Suppress warnings for missing optional dependencies
-dontwarn javax.annotation.**
-dontwarn org.conscrypt.**
-dontwarn org.bouncycastle.**
-dontwarn org.openjsse.**
