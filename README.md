# iOS SDK for ikatago

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

IkatagoSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
platform :ios, '8.0'

target 'your_target_name' do

   pod "IKatagoSDK", :git => "https://github.com/kinfkong/ikatago-ios-sdk.git"

end
```

## Usage
View the example for detail, in the `Example/IkatagoSDK/IKATAGOAppDelegate.m`

### 1. Creates a ikatago client and query the server info
```objective-c
    IkatagosdkClient* client = [[IkatagosdkClient alloc] init:@"" platform:@"aistudio" username:@"kinfkong" password:@"12345678"];
    // query the server to see what weights, configs this server supports
    NSString* serverInfo = [client queryServer:&error];
    if (error != nil) {
        NSLog(@"error happens: %@", [error description]);
        return;
    }
    // parse the server info to object from json string
    NSLog(@"server info: %@", serverInfo);
```
Example of the json response of the server info: 
```json
{"serverVersion":"1.3.1","supportKataWeights":[{"name":"20b","description":null},{"name":"30b","description":null},{"name":"40b","description":null},{"name":"40b-large","description":null}],"supportKataNames":[{"name":"katago-1.5.0","description":null},{"name":"katago-1.6.0","description":null},{"name":"katago-1.3.4","description":null},{"name":"katago-solve","description":null}],"supportKataConfigs":[{"name":"default_gtp","description":null},{"name":"10spermove","description":null},{"name":"2stones_handicap","description":null},{"name":"3stones_handicap","description":null},{"name":"4stones_handicap","description":null},{"name":"5stones_handicap","description":null},{"name":"6stones_handicap","description":null},{"name":"7+stones_handicap","description":null}],"defaultKataName":"katago-1.6.0","defaultKataWeight":"40b","defaultKataConfig":"default_gtp"}
```

### 2. Configs the katago (weights, configs, etc.) and run the katago
```objective-c
    katago = [client createKatagoRunner:&error];
    if (error != nil) {
        NSLog(@"error happens: %@", [error description]);
        return;
    }
    // set the 20b weight
    [katago setKataWeight:@"20b"];
    [katago run:callback error:&error];
    if (error != nil) {
        NSLog(@"error happens: %@", [error description]);
        return;
    }
```

### 3. sends the gtp commands to the katago
```objective-c
    [katago sendGTPCommand:@"version\n" error:&error];
    if (error != nil) {
        NSLog(@"error happens: %@", [error description]);
    }
    [katago sendGTPCommand:@"kata-analyze B 50\n" error:&error];
    if (error != nil) {
        NSLog(@"error happens: %@", [error description]);
    }
```

### 4. example implementation of the data callback
```
@interface IKATAGODataCallback : NSObject <IkatagosdkDataCallback>

@end

@implementation IKATAGODataCallback
- (void)callback:(NSData* _Nullable)content {
    // simply output the data
    NSString* contentString = [[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding];
    NSLog(@"%@", contentString);
}
@end
```
## Author

kinfkong, kinfkong@126.com

QQ Group: 703409387

## License

IkatagoSDK is available under the MIT license. See the LICENSE file for more info.
