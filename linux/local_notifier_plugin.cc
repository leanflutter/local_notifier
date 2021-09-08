#include "include/local_notifier/local_notifier_plugin.h"

#include <flutter_linux/flutter_linux.h>
#include <gtk/gtk.h>
#include <sys/utsname.h>

#include <cstring>

#define LOCAL_NOTIFIER_PLUGIN(obj)                                     \
  (G_TYPE_CHECK_INSTANCE_CAST((obj), local_notifier_plugin_get_type(), \
                              LocalNotifierPlugin))

struct _LocalNotifierPlugin
{
  GObject parent_instance;
  FlPluginRegistrar *registrar;
};

G_DEFINE_TYPE(LocalNotifierPlugin, local_notifier_plugin, g_object_get_type())

// Gets the window being controlled.
GtkWindow *get_window(LocalNotifierPlugin *self)
{
  FlView *view = fl_plugin_registrar_get_view(self->registrar);
  if (view == nullptr)
    return nullptr;

  return GTK_WINDOW(gtk_widget_get_toplevel(GTK_WIDGET(view)));
}

GdkWindow *get_gdk_window(LocalNotifierPlugin *self)
{
  return gtk_widget_get_window(GTK_WIDGET(get_window(self)));
}

static FlMethodResponse *notify(LocalNotifierPlugin *self,
                                             FlValue *args)
{
  return FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
}

// Called when a method call is received from Flutter.
static void local_notifier_plugin_handle_method_call(
    LocalNotifierPlugin *self,
    FlMethodCall *method_call)
{
  g_autoptr(FlMethodResponse) response = nullptr;

  const gchar *method = fl_method_call_get_name(method_call);
  FlValue *args = fl_method_call_get_args(method_call);
  if (strcmp(method, "notify") == 0)
  {
    response = notify(self, args);
  }
  else
  {
    response = FL_METHOD_RESPONSE(fl_method_not_implemented_response_new());
  }

  fl_method_call_respond(method_call, response, nullptr);
}

static void local_notifier_plugin_dispose(GObject *object)
{
  G_OBJECT_CLASS(local_notifier_plugin_parent_class)->dispose(object);
}

static void local_notifier_plugin_class_init(LocalNotifierPluginClass *klass)
{
  G_OBJECT_CLASS(klass)->dispose = local_notifier_plugin_dispose;
}

static void local_notifier_plugin_init(LocalNotifierPlugin *self) {}

static void method_call_cb(FlMethodChannel *channel, FlMethodCall *method_call,
                           gpointer user_data)
{
  LocalNotifierPlugin *plugin = LOCAL_NOTIFIER_PLUGIN(user_data);
  local_notifier_plugin_handle_method_call(plugin, method_call);
}

void local_notifier_plugin_register_with_registrar(FlPluginRegistrar *registrar)
{
  LocalNotifierPlugin *plugin = LOCAL_NOTIFIER_PLUGIN(
      g_object_new(local_notifier_plugin_get_type(), nullptr));

  plugin->registrar = FL_PLUGIN_REGISTRAR(g_object_ref(registrar));

  g_autoptr(FlStandardMethodCodec) codec = fl_standard_method_codec_new();
  g_autoptr(FlMethodChannel) channel =
      fl_method_channel_new(fl_plugin_registrar_get_messenger(registrar),
                            "local_notifier",
                            FL_METHOD_CODEC(codec));
  fl_method_channel_set_method_call_handler(channel, method_call_cb,
                                            g_object_ref(plugin),
                                            g_object_unref);

  g_object_unref(plugin);
}
