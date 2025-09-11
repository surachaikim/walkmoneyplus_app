# ProGuard rules for Flutter Android release build
# Keep Flutter embedding and plugins
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# Keep AndroidX lifecycle DefaultLifecycleObserver used by plugins
-keep class androidx.lifecycle.DefaultLifecycleObserver { *; }

# Keep ML Kit and ODML (used by text recognition plugin)
-keep class com.google.mlkit.** { *; }
-dontwarn com.google.mlkit.**
-keep class com.google.android.odml.** { *; }
-dontwarn com.google.android.odml.**

# Kotlin coroutines (avoid over-aggressive shrinking warnings)
-keep class kotlinx.coroutines.** { *; }
-dontwarn kotlinx.coroutines.**

# Keep annotations often referenced reflectively
-keep @interface androidx.annotation.Keep
-keep @androidx.annotation.Keep class *

# Workaround: keep classes that implement parcelable/reflected parcelable
-keep class * implements android.os.Parcelable { *; }
-keep class * implements com.google.android.gms.common.internal.ReflectedParcelable { *; }
