package com.tds.chilango

import io.flutter.app.FlutterApplication
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingBackgroundService
import io.flutter.plugins.firebase.messaging.FlutterFirebaseMessagingPlugin
import io.flutter.plugins.GeneratedPluginRegistrant
class Application: FlutterApplication(), PluginRegistry.PluginRegistrantCallback {
    // ...
    override fun onCreate() {
        super.onCreate()
     
    }
    override fun registerWith(registry:PluginRegistry) {
  
        FlutterFirebaseMessagingPlugin.registerWith(registry?.registrarFor("io.flutter.plugins.firebasemessaging.FirebaseMessagingPlugin"))
    }
    // ...
}