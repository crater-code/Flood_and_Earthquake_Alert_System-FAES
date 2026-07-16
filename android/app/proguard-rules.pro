# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter embedding and deferred components
-dontwarn io.flutter.embedding.engine.deferredcomponents.**
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Play Store split install (ignore missing classes)
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }

# Keep native methods
-keepclassmembers class * {
    native <methods>;
}

# Keep serializable classes
-keepclassmembers class * implements java.io.Serializable {
    static final long serialVersionUID;
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# Geolocator plugin
-keep class com.baseflow.geolocator.** { *; }

# Image picker plugin
-keep class io.flutter.plugins.imagepicker.** { *; }

# HTTP plugin
-keep class io.flutter.plugins.connectivity.** { *; }

# Path provider plugin
-keep class io.flutter.plugins.pathprovider.** { *; }

# Permission handler plugin
-keep class com.baseflow.permissionhandler.** { *; }

# Shared preferences plugin
-keep class io.flutter.plugins.sharedpreferences.** { *; }

# Remove debug information
-assumenosideeffects class android.util.Log {
    public static boolean isLoggable(java.lang.String, int);
    public static int v(...);
    public static int i(...);
    public static int w(...);
    public static int d(...);
    public static int e(...);
}

# Optimize
-optimizations !code/simplification/arithmetic,!code/simplification/cast,!field/*,!class/merging/*
-optimizationpasses 5
-allowaccessmodification