# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.embedding.**

# In-App Purchase
-keep class com.android.vending.billing.** { *; }

# Firebase Crashlytics
-keepattributes SourceFile,LineNumberTable
-keep public class * extends java.lang.Exception
-keep class com.google.firebase.crashlytics.** { *; }
-dontwarn com.google.firebase.crashlytics.**

# flutter_local_notifications guarda los avisos programados con Gson.
# Con R8 en modo completo el TypeToken pierde su tipo genérico y cancel()
# y zonedSchedule() fallan en la versión de la tienda (P-25).
-keep class com.dexterous.flutterlocalnotifications.models.** { *; }
-keep class com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.reflect.TypeToken
-keep public class * implements java.lang.reflect.Type

# AndroidX
-keep class androidx.** { *; }
-dontwarn androidx.**

# Kotlin
-keep class kotlin.** { *; }
-dontwarn kotlin.**

# General
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes InnerClasses
-keepattributes EnclosingMethod
