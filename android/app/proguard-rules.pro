# Flutter-specific ProGuard rules
# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Google Play Billing (in_app_purchase)
-keep class com.android.vending.billing.** { *; }

# Keep Google Sign-In classes (googleapis / google_sign_in)
-keep class com.google.android.gms.auth.** { *; }
-keep class com.google.android.gms.common.** { *; }

# Keep SQLite native libs (drift / sqlite3_flutter_libs)
-keep class io.requery.android.database.** { *; }

# Suppress warnings for common Flutter plugin dependencies
-dontwarn com.google.android.play.core.**
-dontwarn io.flutter.embedding.**
