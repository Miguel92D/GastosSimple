# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase rules
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.android.gms.**

# local_auth rules
-keep class com.baseflow.localauth.** { *; }

# sqflite rules
-keep class com.tekartik.sqflite.** { *; }

# flutter_secure_storage
-keep class com.it_st.flutter_secure_storage.** { *; }

# General rules for common plugins
-dontwarn io.flutter.plugins.**
-keepattributes Signature, *Annotation*, InnerClasses
