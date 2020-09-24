//
//  IKATAGOAppDelegate.m
//  IkatagoSDK
//
//  Created by kinfkong on 09/13/2020.
//  Copyright (c) 2020 kinfkong. All rights reserved.
//

#import "IKATAGOAppDelegate.h"
#import <ikatagosdk/ikatagosdk.h>

#define IKATAGO_PLATFORM @"aistudio"
#define IKATAGO_USERNAME @"wce"
#define IKATAGO_PASSWORD @"12345678"

@interface IKATAGODataCallback : NSObject <IkatagosdkDataCallback>

@end

@implementation IKATAGODataCallback

- (void)callback:(NSData* )content {
    // simply output the data
    NSString* contentString = [[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding];
    NSLog(@"%@", contentString);
}
- (void) stderrCallback:(NSData *)content {
    // simply output the data
    NSString* contentString = [[NSString alloc] initWithData:content encoding:NSASCIIStringEncoding];
    NSLog(@"stderr: %@", contentString);
}
@end

@implementation IKATAGOAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    dispatch_queue_t katagoRunQueue = dispatch_queue_create("katago.runQueue", DISPATCH_QUEUE_SERIAL);
    dispatch_queue_t katagoCmdQueue = dispatch_queue_create("katago.cmdQueue", DISPATCH_QUEUE_SERIAL);
    
    // Override point for customization after application launch.
    IkatagosdkClient* client = [[IkatagosdkClient alloc] init:@"" platform:IKATAGO_PLATFORM username:IKATAGO_USERNAME password:IKATAGO_PASSWORD];
    __block IkatagosdkKatagoRunner* katago = nil;
    IKATAGODataCallback* callback = [[IKATAGODataCallback alloc] init];
    dispatch_async(katagoRunQueue, ^{
        NSError* error = nil;
        // query the server to see what weights, configs this server supports
        NSString* serverInfo = [client queryServer:&error];
        if (error != nil) {
            NSLog(@"error happens: %@", [error description]);
            return;
        }
        // parse the server info to object from json string
        NSLog(@"server info: %@", serverInfo);
        // run the katago
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
    });
    
    dispatch_async(katagoCmdQueue, ^{
        NSError* error = nil;
        while (true) {
            if (katago == nil) {
                // wait
                [NSThread sleepForTimeInterval:1.0f];
                continue;
            }
            [katago sendGTPCommand:@"version\n" error:&error];
            if (error != nil) {
                NSLog(@"error happens: %@", [error description]);
            }
            [NSThread sleepForTimeInterval:2.0f];
            [katago sendGTPCommand:@"kata-analyze B 50\n" error:&error];
            if (error != nil) {
                 NSLog(@"error happens: %@", [error description]);
            }
            break;
        }
    });
    dispatch_async(katagoCmdQueue, ^{
        NSError* error = nil;
        while (true) {
            if (katago == nil) {
                // wait
                [NSThread sleepForTimeInterval:1.0f];
                continue;
            }
            [NSThread sleepForTimeInterval:15.0f];
            [katago stop:&error];
            break;
        }
    });
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
