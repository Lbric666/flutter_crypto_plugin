import Flutter
import UIKit
import CryptoSwift

public class SwiftFlutterCryptoPlugin: NSObject, FlutterPlugin {
      
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_crypto_plugin", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterCryptoPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "getPlatformVersion" {
            result("iOS " + UIDevice.current.systemVersion)
            return;
        }
        guard let args = call.arguments as? [String: String] else {
            result(
                FlutterError(
                    code: "ERROR_INVALID_PARAMETER_TYPE",
                    message: "the parameters data, key and iv must be all strings",
                    details: nil
                )
            )
            return
        }
        if(args["data"] == nil || args["key"] == nil || args["iv"] == nil || args["padding"] == nil || args["model"] == nil) {
            result(
                FlutterError(
                    code: "ERROR_INVALID_PARAMETER_TYPE",
                    message: "the parameters data, key and iv must be all strings",
                    details: nil
                )
            )
            return
        }
        let data = args["data"]!
        let key = args["key"]!
        let iv = args["iv"]!
        let padding = args["padding"]!
        let mode = args["model"]!
        
        let keyArray = Array(key.utf8)
        let ivArray = Array(iv.utf8)
        var paddingMode = Padding.zeroPadding;
        ///noPadding, zeroPadding, pkcs7, pkcs5
        if padding == "noPadding" {
            paddingMode = Padding.noPadding
        } else if padding == "pkcs7" {
            paddingMode = Padding.pkcs7
        } else if padding == "pkcs5" {
            paddingMode = Padding.pkcs5
        }
        
        switch call.method {
        case "Encrypt_AesCbc":
            let dataArray = Array(data.utf8)
            var encryptedBase64 = "";
            do {
                let encrypted = try AES(
                    key: keyArray,
                    blockMode: CBC(iv: ivArray),
                    padding: paddingMode
                ).encrypt(dataArray)
                
                let encryptedNSData = NSData(bytes: encrypted, length: encrypted.count)
                
                encryptedBase64 = encryptedNSData.base64EncodedString(options:[])
                
            } catch {
                
            }
            result(encryptedBase64)
            
        case "Decrypt_AesCbc":
            
            //解码得到Array<Int32>
            let encryptedData = NSData(base64Encoded: data, options:[]) ?? nil
            
            if(encryptedData == nil || encryptedData!.length % 4 != 0){
                result(
                    FlutterError(
                        code: "ERROR_INVALID_ENCRYPTED_DATA",
                        message: "the data should be a valid base64 string with length at multiple of 128 bits",
                        details: nil
                    )
                )
                return
            }
            
            let encrypted = [UInt8](encryptedData! as Data)
            
            var plaintext = "";
            
            do {
                let decryptedData = try AES(
                    key: keyArray,
                    blockMode: CBC(iv: ivArray),
                    padding: paddingMode
                ).decrypt(encrypted)
                
                plaintext = String(bytes: decryptedData, encoding: String.Encoding.utf8)!
            } catch {
                
            }
            
            result(plaintext)
        default: result(FlutterMethodNotImplemented)
        }
    }
}
