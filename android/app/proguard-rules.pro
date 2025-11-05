# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Gson specific classes
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# Flutter notifications plugin
-keep class com.dexterous.** { *; }

# SharedPreferences
-keep class android.content.SharedPreferences { *; }
-keep class android.content.SharedPreferences$Editor { *; }

# Prevent obfuscation of Flutter classes
-keepattributes *Annotation*
-keepclassmembers class * {
    @android.webkit.JavascriptInterface <methods>;
}

# Flutter Local Notifications
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Permission handler
-keep class com.baseflow.permissionhandler.** { *; }

# Timezone
-keep class timezone.** { *; }