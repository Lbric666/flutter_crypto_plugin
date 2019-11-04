#import "FlutterCryptoPlugin.h"
#import <flutter_crypto_plugin/flutter_crypto_plugin-Swift.h>

@implementation FlutterCryptoPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterCryptoPlugin registerWithRegistrar:registrar];
}
@end
