import Cocoa
import FlutterMacOS

public class LocalNotifierPlugin: NSObject, FlutterPlugin, NSUserNotificationCenterDelegate {
    var registrar: FlutterPluginRegistrar!;
    var channel: FlutterMethodChannel!
    
    var notificationDict: Dictionary<String, NSUserNotification> = [:]
    
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
        case "close":
            close(call, result: result)
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    public func notify(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let identifier: String = args["identifier"] as! String
        let title: String? = args["title"] as? String
        let subtitle: String? = args["subtitle"] as? String
        let body: String? = args["body"] as? String
        
        let notification = NSUserNotification()
        notification.identifier = identifier
        notification.title = title
        notification.subtitle = subtitle
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        
        let actions: [NSDictionary]? = args["actions"] as? [NSDictionary];
        
        if (actions != nil && !(actions!.isEmpty)) {
            let actionDict =  actions!.first as! [String: Any]
            let actionText: String? = actionDict["text"] as? String
            notification.actionButtonTitle = actionText!
        }
        
        NSUserNotificationCenter.default.deliver(notification)
        self.notificationDict[identifier] = notification
        
        result(true)
    }
    
    public func close(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let args = call.arguments as! Dictionary<String, Any>
        let identifier: String = args["identifier"] as! String
        
        let notification: NSUserNotification? = self.notificationDict[identifier]
        
        if (notification != nil) {
            NSUserNotificationCenter.default.removeDeliveredNotification(notification!)
            self.notificationDict[identifier] = nil
            
            _invokeMethod("onLocalNotificationClose", identifier)
        }
        result(true)
    }
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didActivate notification: NSUserNotification) {
        _invokeMethod("onLocalNotificationClick", notification.identifier!)
    }
    
    public func userNotificationCenter(_ center: NSUserNotificationCenter, didDeliver notification: NSUserNotification) {
        _invokeMethod("onLocalNotificationShow", notification.identifier!)
    }
    
    public func _invokeMethod(_ methodName: String, _ notificationId: String) {
        let args: NSDictionary = [
            "notificationId": notificationId,
        ]
        channel.invokeMethod(methodName, arguments: args, result: nil)
    }
}
