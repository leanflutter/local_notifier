import Cocoa
import FlutterMacOS

public class LocalNotifierPlugin: NSObject, FlutterPlugin, NSUserNotificationCenterDelegate {
    var registrar: FlutterPluginRegistrar!;
    var channel: FlutterMethodChannel!
    
    public override init() {
        super.init()
        NSUserNotificationCenter.default.delegate = self
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "local_notifier", binaryMessenger: registrar.messenger)
        let instance = LocalNotifierPlugin()
        instance.registrar = registrar
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch (call.method) {
        case "notify":
            notify(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func notify(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let identifier: String? = args["identifier"] as? String
        let title: String? = args["title"] as? String
        let subtitle: String? = args["subtitle"] as? String
        let body: String? = args["body"] as? String
        
        let notification = NSUserNotification()
        notification.identifier = identifier
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        NSUserNotificationCenter.default.deliver(notification)
        result(true)
    }
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        _emitEvent("click")
    }
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        _emitEvent("show")
    }

    public func _emitEvent(_ eventName: String) {
        let args: NSDictionary = [
            "eventName": eventName,
        ]
        channel.invokeMethod("onEvent", arguments: args, result: nil)
    }
}
