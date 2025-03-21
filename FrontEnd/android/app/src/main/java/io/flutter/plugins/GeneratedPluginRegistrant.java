package io.flutter.plugins;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import io.flutter.Log;

import io.flutter.embedding.engine.FlutterEngine;

/**
 * Generated file. Do not edit.
 * This file is generated by the Flutter tool based on the
 * plugins that support the Android platform.
 */
@Keep
public final class GeneratedPluginRegistrant {
  private static final String TAG = "GeneratedPluginRegistrant";
  public static void registerWith(@NonNull FlutterEngine flutterEngine) {
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.audio_session.AudioSessionPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin audio_session, com.ryanheise.audio_session.AudioSessionPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin device_info_plus, dev.fluttercommunity.plus.device_info.DeviceInfoPlusPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_plugin_android_lifecycle, io.flutter.plugins.flutter_plugin_android_lifecycle.FlutterAndroidLifecyclePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin flutter_secure_storage, com.it_nomads.fluttersecurestorage.FlutterSecureStoragePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.googlesignin.GoogleSignInPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin google_sign_in_android, io.flutter.plugins.googlesignin.GoogleSignInPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.imagepicker.ImagePickerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin image_picker_android, io.flutter.plugins.imagepicker.ImagePickerPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.ryanheise.just_audio.JustAudioPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin just_audio, com.ryanheise.just_audio.JustAudioPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.pathprovider.PathProviderPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin path_provider_android, io.flutter.plugins.pathprovider.PathProviderPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin shared_preferences_android, io.flutter.plugins.sharedpreferences.SharedPreferencesPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.tekartik.sqflite.SqflitePlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin sqflite_android, com.tekartik.sqflite.SqflitePlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new com.benjaminabel.vibration.VibrationPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin vibration, com.benjaminabel.vibration.VibrationPlugin", e);
    }
    try {
      flutterEngine.getPlugins().add(new io.flutter.plugins.videoplayer.VideoPlayerPlugin());
    } catch (Exception e) {
      Log.e(TAG, "Error registering plugin video_player_android, io.flutter.plugins.videoplayer.VideoPlayerPlugin", e);
    }
  }
}
