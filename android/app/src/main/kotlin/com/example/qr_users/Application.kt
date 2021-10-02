package com.tds.chilango

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
import com.huawei.hms.flutter.push.PushPlugin;
import io.flutter.plugins.GeneratedPluginRegistrant
class Application: FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    // ...
    override fun onCreate() {
        super.onCreate()
        PushPlugin.setPluginRegistrant(this);   
    }
    override fun registerWith(registry:PluginRegistry) {
             if (!registry!!.hasPlugin("com.huawei.hms.flutter.push.PushPlugin")) {
            PushPlugin.registerWith(registry?.registrarFor("com.huawei.hms.flutter.push.PushPlugin"))
        }
        FlutterFirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
    }
    // ...
}