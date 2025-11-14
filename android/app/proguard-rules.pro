# ProGuard/R8 rules to prevent flutter_local_notifications classes from being stripped or obfuscated
-keep class com.dexterous.flutterlocalnotifications.receivers.* { *; }
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver
-keep class com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver
-keep class com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsReceiver