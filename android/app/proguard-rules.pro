# android/app/proguard-rules.pro

# =========================================================================
# FLUTTER LOCAL NOTIFICATIONS - CRITICAL FOR BACKGROUND EXECUTION
# Prevents R8/ProGuard from stripping the necessary Android receivers, 
# services, and the application context required to handle background alarms.
# =========================================================================

# Rule 1: Preserve all classes within the flutter_local_notifications plugin package.
# This is a broad, necessary fix when targeted rules fail.
-keep class com.dexterous.flutterlocalnotifications.** { *; }

# Rule 2: Explicitly preserve all receiver/service classes referenced in AndroidManifest.xml.
-keep class com.dexterous.flutterlocalnotifications.receivers.* { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver { *; }
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsReceiver { *; }

# Rule 3: Explicitly preserve the main activity and application class structure.
# This prevents R8 from obfuscating the primary entry point called by the OS 
# and the base application class used for context in background services.
-keep class com.example.zbeub_task_plan.MainActivity { *; }

-keep class * extends android.app.Application {
    <init>();
    void attachBaseContext(android.content.Context);
    void onCreate();
}

# =========================================================================
# GENERAL FLUTTER/DART RULES (Standard Safety)
# =========================================================================

# Preserve the generated plugin registrar.
-keep class io.flutter.plugins.GeneratedPluginRegistrant