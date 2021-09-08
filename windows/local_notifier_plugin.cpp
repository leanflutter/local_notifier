#include "include/local_notifier/local_notifier_plugin.h"

// This must be included before many other Windows headers.
#include <windows.h>

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>
#include <flutter/standard_method_codec.h>

#include <codecvt>
#include <map>
#include <memory>
#include <sstream>

namespace {
    std::unique_ptr<flutter::MethodChannel<flutter::EncodableValue>, std::default_delete<flutter::MethodChannel<flutter::EncodableValue>>> channel = nullptr;

    class LocalNotifierPlugin : public flutter::Plugin {
    public:
        static void RegisterWithRegistrar(flutter::PluginRegistrarWindows* registrar);

        LocalNotifierPlugin();

        virtual ~LocalNotifierPlugin();

    private:
        flutter::PluginRegistrarWindows* registrar;

        void LocalNotifierPlugin::_EmitEvent(std::string eventName);
        
        HWND LocalNotifierPlugin::GetMainWindow();
        void LocalNotifierPlugin::Notify(
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
        channel =
            std::make_unique<flutter::MethodChannel<flutter::EncodableValue>>(
                registrar->messenger(), "local_notifier",
                &flutter::StandardMethodCodec::GetInstance());

        auto plugin = std::make_unique<LocalNotifierPlugin>();

        channel->SetMethodCallHandler(
            [plugin_pointer = plugin.get()](const auto& call, auto result)
        {
            plugin_pointer->HandleMethodCall(call, std::move(result));
        });

        registrar->AddPlugin(std::move(plugin));
    }


    LocalNotifierPlugin::LocalNotifierPlugin() { }

    LocalNotifierPlugin::~LocalNotifierPlugin() { }

    void LocalNotifierPlugin::_EmitEvent(std::string eventName) {
        flutter::EncodableMap args = flutter::EncodableMap();
            args[flutter::EncodableValue("eventName")] = flutter::EncodableValue(eventName);
        channel->InvokeMethod("onEvent", std::make_unique<flutter::EncodableValue>(args));
    }

    HWND LocalNotifierPlugin::GetMainWindow() {
        return ::GetAncestor(registrar->GetView()->GetNativeWindow(), GA_ROOT);
    }

    void LocalNotifierPlugin::Notify(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        result->NotImplemented();
    }

    void LocalNotifierPlugin::HandleMethodCall(
        const flutter::MethodCall<flutter::EncodableValue>& method_call,
        std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result) {
        if (method_call.method_name().compare("notify") == 0) {
            Notify(method_call, std::move(result));
        }
        else {
            result->NotImplemented();
        }
    }

} // namespace

void LocalNotifierPluginRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
    LocalNotifierPlugin::RegisterWithRegistrar(
        flutter::PluginRegistrarManager::GetInstance()
        ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
