//
//  AppDelegate.m
//  EvCal
//
//  Created by Tom on 5/16/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "AppDelegate.h"
#import <CocoaLumberjack/CocoaLumberjack.h>
#import "ECLogFormatter.h"
#import "ECDayviewController.h"
#import "UIColor+ECAdditions.h"

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [DDASLLogger sharedInstance].logFormatter = [[ECLogFormatter alloc] init];
    [DDTTYLogger sharedInstance].logFormatter = [[ECLogFormatter alloc] init];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    [self.window setTintColor:[UIColor ecPurpleColor]];
    
    return YES;
}

@end
