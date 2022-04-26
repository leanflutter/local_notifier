#include "include/local_notifier/local_notifier_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include "wintoastlib.h"

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

using namespace WinToastLib;

namespace {
std::unique_ptr<
    flutter::MethodChannel<flutter::EncodableValue>,
    std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>>
    channel = nullptr;

class CustomToastHandler : public IWinToastHandler {
 public:
  CustomToastHandler(std::string identifier);

  void toastActivated() const {
    flutter::EncodableMap args = flutter::EncodableMap();
    args[flutter::EncodableValue("notificationId")] =
        flutter::EncodableValue(identifier);
    channel->InvokeMethod("onLocalNotificationClick",
                          std::make_unique<flutter::EncodableValue>(args));
  }

  void toastActivated(int actionIndex) const {
    flutter::EncodableMap args = flutter::EncodableMap();
    args[flutter::EncodableValue("notificationId")] =
        flutter::EncodableValue(identifier);
    args[flutter::EncodableValue("actionIndex")] =
        flutter::EncodableValue(actionIndex);
    channel->InvokeMethod("onLocalNotificationClickAction",
                          std::make_unique<flutter::EncodableValue>(args));
  }

  void toastDismissed(WinToastDismissalReason state) const {
    flutter::EncodableMap args = flutter::EncodableMap();
    args[flutter::EncodableValue("notificationId")] =
        flutter::EncodableValue(identifier);
    channel->InvokeMethod("onLocalNotificationClose",
                          std::make_unique<flutter::EncodableValue>(args));
  }

  void toastFailed() const {}

 private:
  std::string identifier;
};

CustomToastHandler::CustomToastHandler(std::string identifier) {
  this->identifier = identifier;
}

class LocalNotifierPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

  LocalNotifierPlugin();

  virtual ~LocalNotifierPlugin();

 private:
  flutter::PluginRegistrarWindows* registrar;

  std::unordered_map<std::string, INT64> toast_id_map_ = {};

  HWND LocalNotifierPlugin::GetMainWindow();
  void LocalNotifierPlugin::Notify(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
  void LocalNotifierPlugin::Close(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue>& method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

// static
void LocalNotifierPlugin::RegisterWithRegistrar(
    flutter::PluginRegistrarWindows* registrar) {
  channel = std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
      registrar->messenger(), "local_notifier",
      &flutter::StandardMethodCodec::GetInstance());

  auto plugin = std::make_unique<LocalNotifierPlugin>();

  channel->SetMethodCallHandler(
      [plugin_pointer = plugin.get()](const auto& call, auto result) {
        plugin_pointer->HandleMethodCall(call, std::move(result));
      });

  registrar->AddPlugin(std::move(plugin));
}

LocalNotifierPlugin::LocalNotifierPlugin() {}

LocalNotifierPlugin::~LocalNotifierPlugin() {}

HWND LocalNotifierPlugin::GetMainWindow() {
  return ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
}

void LocalNotifierPlugin::Notify(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (!WinToast::isCompatible()) {
    std::wcout << L"Error, your system in not supported!" << std::endl;
  }

  std::wstring_convert<std::codecvt_utf8_utf16<wchar_t>> converter;

  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  std::string appName =
      std::get<std::string>(args.at(flutter::EncodableValue("appName")));

  std::string identifier =
      std::get<std::string>(args.at(flutter::EncodableValue("identifier")));
  std::string title =
      std::get<std::string>(args.at(flutter::EncodableValue("title")));
  std::string body =
      std::get<std::string>(args.at(flutter::EncodableValue("body")));

  flutter::EncodableList actions = std::get<flutter::EncodableList>(
      args.at(flutter::EncodableValue("actions")));

  WinToast::instance()->setAppName(converter.from_bytes(appName));
  WinToast::instance()->setAppUserModelId(converter.from_bytes(appName));
  WinToast::instance()->setShortcutPolicy(WinToast::SHORTCUT_POLICY_IGNORE);
  WinToast::instance()->initialize();

  WinToastTemplate toast = WinToastTemplate(WinToastTemplate::Text02);
  toast.setTextField(converter.from_bytes(title), WinToastTemplate::FirstLine);
  toast.setTextField(converter.from_bytes(body), WinToastTemplate::SecondLine);

  for (flutter::EncodableValue action_value : actions) {
    flutter::EncodableMap action_map =
        std::get<flutter::EncodableMap>(action_value);
    std::string action_text =
        std::get<std::string>(action_map.at(flutter::EncodableValue("text")));

    toast.addAction(converter.from_bytes(action_text));
  }

  CustomToastHandler* handler = new CustomToastHandler(identifier);
  INT64 toast_id = WinToast::instance()->showToast(toast, handler);

  toast_id_map_.insert(std::make_pair(identifier, toast_id));

  flutter::EncodableMap args2 = flutter::EncodableMap();
  args2[flutter::EncodableValue("notificationId")] =
      flutter::EncodableValue(identifier);
  channel->InvokeMethod("onLocalNotificationShow",
                        std::make_unique<flutter::EncodableValue>(args2));

  result->Success(flutter::EncodableValue(true));
}

void LocalNotifierPlugin::Close(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  const flutter::EncodableMap& args =
      std::get<flutter::EncodableMap>(*method_call.arguments());

  std::string identifier =
      std::get<std::string>(args.at(flutter::EncodableValue("identifier")));

  if (toast_id_map_.find(identifier) != toast_id_map_.end()) {
    INT64 toast_id = toast_id_map_.at(identifier);

    WinToast::instance()->hideToast(toast_id);
    toast_id_map_.erase(identifier);
  }

  result->Success(flutter::EncodableValue(true));
}

void LocalNotifierPlugin::HandleMethodCall(
    const flutter::MethodCall<flutter::EncodableValue>& method_call,
    std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
  if (method_call.method_name().compare("notify") == 0) {
    Notify(method_call, std::move(result));
  } else if (method_call.method_name().compare("close") == 0) {
    Close(method_call, std::move(result));
  } else {
    result->NotImplemented();
  }
}

}  // namespace

void LocalNotifierPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  LocalNotifierPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
