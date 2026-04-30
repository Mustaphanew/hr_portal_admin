# ─────────────────────────────────────────────────────────────────
# HR Portal Admin — ProGuard / R8 rules for release builds
# ─────────────────────────────────────────────────────────────────
# Add project-specific keep rules here. The android-optimize ruleset
# (referenced from build.gradle.kts) covers the common Android cases;
# we only keep what plugins require.

# ── Flutter core ──────────────────────────────────────────────────
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# ── Firebase / Google Services ────────────────────────────────────
# Firebase libraries handle their own keep rules but we err on the
# safe side for the model/data classes.
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }
-dontwarn com.google.firebase.**
-dontwarn com.google.android.gms.**

# Firebase Cloud Messaging — keep the BroadcastReceivers used by the
# system to deliver push notifications.
-keep class com.google.firebase.iid.** { *; }
-keep class com.google.firebase.messaging.** { *; }

# ── Awesome Notifications ────────────────────────────────────────
-keep class me.carda.awesome_notifications.** { *; }
-keep class me.carda.awesome_notifications.core.** { *; }
-keep class me.carda.awesome_notifications.notifications.** { *; }
-dontwarn me.carda.awesome_notifications.**

# ── Dio / OkHttp / Networking ────────────────────────────────────
-dontwarn okhttp3.**
-dontwarn okio.**
-dontwarn javax.annotation.**

# ── flutter_secure_storage ────────────────────────────────────────
-keep class androidx.security.crypto.** { *; }

# ── sqlite3 / sqlite3_flutter_libs ────────────────────────────────
-keep class org.sqlite.** { *; }

# ── Equatable / Riverpod (reflection on debug only) ──────────────
# These don't actually need keep rules at runtime — but listing them
# silences a few "missing class" warnings during R8 analysis.
-dontwarn org.jetbrains.annotations.**

# ── App-side models (Equatable subclasses) ────────────────────────
# Models use fromJson/toJson with explicit keys — no reflection — so
# no keep rules are required. Add specific classes here only if you
# observe runtime crashes after enabling R8.

# ── Stripping logs in release ────────────────────────────────────
# Remove debug/verbose logging at release time to reduce APK size and
# avoid leaking sensitive request/response bodies to logcat.
-assumenosideeffects class android.util.Log {
    public static *** d(...);
    public static *** v(...);
    public static *** i(...);
}
-assumenosideeffects class java.io.PrintStream {
    public *** println(...);
    public *** print(...);
}

# ── Keep generic signatures so reflection-based libraries work ───
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod
-keepattributes InnerClasses
