#include "include/local_notifier/local_notifier_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <algorithm>
#include <cstring>
#include <map>
#include <vector>

#include <libnotify/notify.h>

#define LOCAL_NOTIFIER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), local_notifier_plugin_get_type(), \
                              LocalNotifierPlugin))

LocalNotifierPlugin* plugin_instance;
std::map<std::string, int> notification_id_map_;
std::vector<NotifyNotification*> notifications_;

struct _LocalNotifierPlugin {
  GObject parent_instance;
  FlPluginRegistrar* registrar;
  FlMethodChannel* channel;
};

G_DEFINE_TYPE(LocalNotifierPlugin, local_notifier_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow* get_window(LocalNotifierPlugin* self) {
  FlView* view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow* get_gdk_window(LocalNotifierPlugin* self) {
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}

const char* _get_identifier(NotifyNotification* notification) {
  int notification_id = -1;
  g_object_get(G_OBJECT(notification), "id", &notification_id, NULL);

  auto result = std::find_if(
      notification_id_map_.begin(), notification_id_map_.end(),
      [notification_id](const auto& e) { return e.second == notification_id; });

  if (result != notification_id_map_.end())
    return result->first.c_str();

  return "";
}

void _on_notification_close(NotifyNotification* notification,
                            gpointer user_data) {
  const char* identifier = _get_identifier(notification);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "notificationId",
                           fl_value_new_string(identifier));
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onLocalNotificationClose", result_data,
                                  nullptr, nullptr, nullptr);
}

void _action_callback(NotifyNotification* notification,
                      char* action,
                      gpointer user_data) {
  const char* identifier = _get_identifier(notification);

  gint index = GPOINTER_TO_INT(user_data);

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "notificationId",
                           fl_value_new_string(identifier));
  fl_value_set_string_take(result_data, "actionIndex", fl_value_new_int(index));
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onLocalNotificationClickAction", result_data,
                                  nullptr, nullptr, nullptr);
}

static FlMethodResponse* notify(LocalNotifierPlugin* self, FlValue* args) {
  const gchar* app_name =
      fl_value_get_string(fl_value_lookup_string(args, "appName"));

  const gchar* identifier =
      fl_value_get_string(fl_value_lookup_string(args, "identifier"));
  const gchar* title =
      fl_value_get_string(fl_value_lookup_string(args, "title"));
  const gchar* body = fl_value_get_string(fl_value_lookup_string(args, "body"));
  FlValue* actions_value = fl_value_lookup_string(args, "actions");

  notify_init(app_name);
  NotifyNotification* notification = notify_notification_new(title, body, 0);
  notify_notification_set_app_name(notification, app_name);

  for (gint i = 0; i < fl_value_get_length(actions_value); i++) {
    FlValue* action_item_value = fl_value_get_list_value(actions_value, i);
    const char* action_text =
        fl_value_get_string(fl_value_lookup_string(action_item_value, "text"));

    notify_notification_add_action(notification, action_text,  // action
                                   action_text,                // label
                                   (NotifyActionCallback)_action_callback,
                                   GINT_TO_POINTER(i),  // user_data,
                                   NULL);
  }

  notify_notification_show(notification, 0);

  g_signal_connect(notification, "closed", G_CALLBACK(_on_notification_close),
                   NULL);

  notifications_.push_back(notification);

  int notification_id = -1;
  g_object_get(G_OBJECT(notification), "id", &notification_id, NULL);

  notification_id_map_.erase(identifier);
  notification_id_map_.insert(
      std::pair<std::string, int>(identifier, notification_id));

  g_autoptr(FlValue) result_data = fl_value_new_map();
  fl_value_set_string_take(result_data, "notificationId",
                           fl_value_new_string(identifier));
  fl_method_channel_invoke_method(plugin_instance->channel,
                                  "onLocalNotificationShow", result_data,
                                  nullptr, nullptr, nullptr);

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

static FlMethodResponse* close(LocalNotifierPlugin* self, FlValue* args) {
  const gchar* identifier =
      fl_value_get_string(fl_value_lookup_string(args, "identifier"));

  for (int i = 0; i < notifications_.size(); i++) {
    NotifyNotification* notification = notifications_[i];
    const char* item_identifier = _get_identifier(notification);
    if (strcmp(identifier, item_identifier) == 0) {
      notify_notification_close(notification, NULL);
      notifications_.erase(notifications_.begin() + i);
      break;
    }
  }

  return FL_METHOD_RESPONSE(
      fl_method_success_response_new(fl_value_new_bool(true)));
}

// Called when a method call is received from Flutter.
static void local_notifier_plugin_handle_method_call(
    LocalNotifierPlugin* self,
    FlMethodCall* method_call) {
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar* method = fl_method_call_get_name(method_call);
  FlValue* args = fl_method_call_get_args(method_call);
  if (strcmp(method, "notify") == 0) {
    response = notify(self, args);
  } else if (strcmp(method, "close") == 0) {
    response = close(self, args);
  } else {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void local_notifier_plugin_dispose(GObject* object) {
  G_OBJECT_CLASS(local_notifier_plugin_parent_class)->dispose(object);
}

static void local_notifier_plugin_class_init(LocalNotifierPluginClass* klass) {
  G_OBJECT_CLASS(klass)->dispose = local_notifier_plugin_dispose;
}

static void local_notifier_plugin_init(LocalNotifierPlugin* self) {}

static void method_call_cb(FlMethodChannel* channel,
                           FlMethodCall* method_call,
                           gpointer user_data) {
  LocalNotifierPlugin* plugin = LOCAL_NOTIFIER_PLUGIN(user_data);
  local_notifier_plugin_handle_method_call(plugin, method_call);
}

void local_notifier_plugin_register_with_registrar(
    FlPluginRegistrar* registrar) {
  LocalNotifierPlugin* plugin = LOCAL_NOTIFIER_PLUGIN(
      g_object_new(local_notifier_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  plugin->channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "local_notifier", FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(
      plugin->channel, method_call_cb, g_object_ref(plugin), g_object_unref);

  plugin_instance = plugin;

  g_object_unref(plugin);
}
