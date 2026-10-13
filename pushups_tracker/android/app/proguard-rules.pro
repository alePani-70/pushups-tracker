# flutter_local_notifications persists scheduled notifications with Gson and
# reads them back through TypeToken<...>. R8 strips generic signatures by
# default, which fails at runtime with "Missing type parameter."
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**

-keep,allowobfuscation,allowshrinking class com.google.gson.reflect.TypeToken
-keep,allowobfuscation,allowshrinking class * extends com.google.gson.reflect.TypeToken
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer
-keepclassmembers,allowobfuscation class * {
    @com.google.gson.annotations.SerializedName <fields>;
}

# Gson serializes the plugin's model classes by field name.
-keep class com.dexterous.** { *; }
