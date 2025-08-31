# Add project specific ProGuard rules here.
# By default, the flags in "proguard-android-optimize.txt" are applied.
# You can remove the flag if you don't want to use proguard settings from Android.Optmize file.
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

-dontwarn com.google.errorprone.annotations.CanIgnoreReturnValue
-dontwarn com.google.errorprone.annotations.CheckReturnValue
-dontwarn com.google.errorprone.annotations.Immutable
-dontwarn com.google.errorprone.annotations.RestrictedApi
-dontwarn javax.annotation.Nullable
-dontwarn javax.annotation.concurrent.GuardedBy

