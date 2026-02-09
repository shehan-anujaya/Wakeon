# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-keep class com.google.firebase.** { *; }
-keep class io.flutter.embedding.** { *; }

# Flutter animations and ticker - Critical for ripple animations
-keep class io.flutter.animation.** { *; }
-keep class io.flutter.scheduler.** { *; }
-keepclassmembers class * {
    *** *Controller*;
    *** *Animation*;
    *** *Ticker*;
}

# Preserve all widget state and lifecycle methods
-keepclassmembers class * extends androidx.lifecycle.ViewModel {
    <init>();
}
-keepclassmembers class * {
    *** initState();
    *** dispose();
    *** didUpdateWidget(...);
    *** build(...);
}

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

# Keep face detection features - head pose, eye tracking, classification
-keep class com.google.mlkit.vision.face.Face { *; }
-keep class com.google.mlkit.vision.face.FaceDetector { *; }
-keep class com.google.mlkit.vision.face.FaceDetectorOptions { *; }
-keep class com.google.mlkit.vision.face.FaceLandmark { *; }
-keep class com.google.mlkit.vision.face.FaceContour { *; }
-keepclassmembers class com.google.mlkit.vision.face.Face {
    public <methods>;
    public <fields>;
}

# Keep methods for head pose (Euler angles)
-keepclassmembers class com.google.mlkit.vision.face.Face {
    public java.lang.Float getHeadEulerAngleX();
    public java.lang.Float getHeadEulerAngleY();
    public java.lang.Float getHeadEulerAngleZ();
}

# Keep methods for eye tracking
-keepclassmembers class com.google.mlkit.vision.face.Face {
    public java.lang.Float getLeftEyeOpenProbability();
    public java.lang.Float getRightEyeOpenProbability();
    public java.lang.Float getSmilingProbability();
}

# Keep bounding box and tracking
-keepclassmembers class com.google.mlkit.vision.face.Face {
    public android.graphics.Rect getBoundingBox();
    public java.lang.Integer getTrackingId();
    public java.util.List getLandmarks();
    public java.util.List getContours();
}

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
