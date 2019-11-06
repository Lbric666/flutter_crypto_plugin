package com.cryptoflutter.flutter_crypto_plugin

import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import javax.crypto.Cipher
import javax.crypto.spec.GCMParameterSpec
import javax.crypto.spec.IvParameterSpec
import javax.crypto.spec.SecretKeySpec
import android.util.Base64

class FlutterCryptoPlugin: MethodCallHandler {
  @JvmField val CHARSET = Charsets.UTF_8

  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {
      val channel = MethodChannel(registrar.messenger(), "flutter_crypto_plugin")
      channel.setMethodCallHandler(FlutterCryptoPlugin())
    }
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (call.method == "getPlatformVersion") {
      result.success("Android ${android.os.Build.VERSION.RELEASE}")
    } else if (call.method == "Encrypt_AesCbc") {
      return Encrypt_AesCbc(call, result)
    } else if (call.method == "Decrypt_AesCbc") {
      return Decrypt_AesCbc(call, result)
    } else {
      result.notImplemented()
    }
  }

  // AES 128 cbc
  fun Encrypt_AesCbc(call: MethodCall, result: Result){
    val data = call.argument<String>("data")
    val key = call.argument<String>("key")
    val iv = call.argument<String>("iv")
    val padding = call.argument<String>("padding")
    val mode = call.argument<String>("model")

    if(data == null || key == null || iv == null || padding == null || mode == null){
      result.error(
              "ERROR_INVALID_PARAMETER_TYPE",
              "the parameters data, key and iv must be all strings",
              null
      )
      return
    }

    val dataArray = data.toByteArray(CHARSET)
    val keyArray = key.toByteArray()
    val ivArray = iv.toByteArray()

    if(keyArray.size != 16 || ivArray.size != 16){
      result.error(
              "ERROR_INVALID_KEY_OR_IV_LENGTH",
              "the length of key and iv must be all 128 bits",
              null
      )
      return
    }

    val cipher = Cipher.getInstance("AES/CBC/NoPadding")
    val keySpec = SecretKeySpec(keyArray, "AES")
    val ivSpec = IvParameterSpec(ivArray)
    cipher.init(Cipher.ENCRYPT_MODE, keySpec, ivSpec)

    var len = dataArray.size
    while (len % 16 != 0) {
      ++ len;
    }
    val sraw = ByteArray(len)
    for (i in 0 until len) {
      if (i < dataArray.size) {
        sraw[i] = dataArray[i]
      } else {
        sraw[i] = 0
      }
    }

    val ciphertext = cipher.doFinal(sraw)

    val text = Base64.encodeToString(ciphertext, 0)

    result.success(text)

    return
  }


  /// decrypt aes cbc
  fun Decrypt_AesCbc(call: MethodCall, result: Result){
    val data = call.argument<String>("data")
    val key = call.argument<String>("key")
    val iv = call.argument<String>("iv")
    val padding = call.argument<String>("padding")
    val mode = call.argument<String>("model")

    if(data == null || key == null || iv == null || padding == null || mode == null){
      result.error(
              "ERROR_INVALID_PARAMETER_TYPE",
              "the parameters data, key and iv must be all strings",
              null
      )
      return
    }

    val keyArray = key.toByteArray()
    val ivArray = iv.toByteArray()

    if(keyArray.size != 16 || ivArray.size != 16){
      result.error(
              "ERROR_INVALID_KEY_OR_IV_LENGTH",
              "the length of key and iv must be all 128 bits",
              null
      )
      return
    }

    var dataArray:ByteArray; // = ByteArray(0)

    try{
      dataArray = Base64.decode(data.toByteArray(CHARSET), 0)
      if(dataArray.size % 16 != 0){
        throw IllegalArgumentException("")
      }
    }catch (e: IllegalArgumentException) {
      result.error(
              "ERROR_INVALID_ENCRYPTED_DATA",
              "the data should be a valid base64 string with length at multiple of 128 bits",
              null
      )
      return
    }

    val cipher = Cipher.getInstance("AES/CBC/NoPadding")
    val keySpec = SecretKeySpec(keyArray, "AES")
    val ivSpec = IvParameterSpec(ivArray)

    cipher.init(Cipher.DECRYPT_MODE, keySpec, ivSpec)

    val ciphertext = cipher.doFinal(dataArray)

    val text = ciphertext.toString(Charsets.UTF_8);

    result.success(text)

    return
  }
}

