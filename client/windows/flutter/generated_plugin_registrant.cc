//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <audioplayers_windows/audioplayers_windows_plugin.h>
#include <desktop_webview_auth/desktop_webview_auth_plugin.h>
#include <desktop_webview_window/desktop_webview_window_plugin.h>
#include <flutter_secure_storage_windows/flutter_secure_storage_windows_plugin.h>
#include <just_audio_windows/just_audio_windows_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  AudioplayersWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("AudioplayersWindowsPlugin"));
  DesktopWebviewAuthPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWebviewAuthPlugin"));
  DesktopWebviewWindowPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("DesktopWebviewWindowPlugin"));
  FlutterSecureStorageWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterSecureStorageWindowsPlugin"));
  JustAudioWindowsPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("JustAudioWindowsPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
