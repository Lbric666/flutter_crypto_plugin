import 'dart:async';
import 'dart:core';

import 'package:flutter/services.dart';
import 'dart:core' as core;


/// The class provide AES encryption and decrytion method
class CryptoAES {
  core.String paddingName;
  core.String model;
  core.String iv;
  core.String key;
  /// the channel for flutter_crypto_plugin
  static const MethodChannel _channel = const MethodChannel('flutter_crypto_plugin');


  CryptoAES({
    this.key,
    this.iv,
    this.model = 'cbc',
    this.paddingName = 'zeroPadding',
  });


  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  Future<core.String> encryptAes(core.String plainText) async =>
      await _channel.invokeMethod("Encrypt_AesCbc", {
        "data": plainText,
        "key": key,
        "iv": iv,
        "padding": paddingName,
        "model": model,
      });


  Future<core.String> decryptAes(
      core.String encryptedText) async {
    final decrypted = await _channel.invokeMethod("Decrypt_AesCbc", {
      "data": encryptedText,
      "key": key,
      "iv": iv,
      "padding": paddingName,
      "model": model,
    });
    return decrypted;
  }

}//additionally


