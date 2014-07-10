//
//  AppDelegate.m
//  On Tap
//
//  Created by Jose Carlos Rodriguez on 03/07/14.
//  Copyright (c) 2014 On Tap. All rights reserved.
//

#import "AppDelegate.h"
#import "Mixpanel.h"
#import "RestaurantsAPI.h"
#import <Parse/Parse.h>

#define MIXPANEL_TOKEN @"4c17ddeeca7b97fce4f9a2943862ded1"
#define PARSE_APPID @"IxUCPjjiZSnNGatbeeg89GC0sx6t6He30q8vA9XC"
#define PARSE_CLIENT_KEY @"ZyDCNn4UITZvlFgjyfI58TnOIz6dQzrbT8VevwA5"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    Mixpanel* mixpanel = [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
    
    NSString* mixpanelUUID = [[NSUserDefaults standardUserDefaults] objectForKey:@"MixpanelUUID"];
    if (!mixpanelUUID)
    {
        mixpanelUUID = [[NSUUID UUID] UUIDString];
        [[NSUserDefaults standardUserDefaults] setObject:mixpanelUUID forKey:@"MixpanelUUID"];
    }
    
    [mixpanel identify:mixpanelUUID];

    [Parse setApplicationId:PARSE_APPID
                  clientKey:PARSE_CLIENT_KEY];

    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is ab@out to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
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
