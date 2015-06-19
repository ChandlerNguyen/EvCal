//
//  ECLogFormatter.m
//  EvCal
//
//  Created by Tom on 5/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECLogFormatter.h"

@implementation ECLogFormatter

- (NSString*)formatLogMessage:(DDLogMessage *)logMessage
{
    NSString* levelPrefix = nil;
    switch (logMessage.flag) {
        case DDLogFlagInfo:
            levelPrefix = @"<INFO>";
            break;
            
        case DDLogFlagDebug:
            levelPrefix = @"<DEBUG>";
            break;
            
        case DDLogFlagWarning:
            levelPrefix = @"<WARNING>";
            break;
            
        case DDLogFlagError:
            levelPrefix = @"<ERROR>";
            break;
            
        case DDLogFlagVerbose:
            levelPrefix = @"<VERBOSE>";
            break;
    }
    
    return [NSString stringWithFormat:@"%@ %@ %@", levelPrefix, logMessage.function, logMessage.message];
}

+ (NSDateFormatter*)logMessageDateFormatter
{
    static NSDateFormatter* formatter = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        formatter = [[NSDateFormatter alloc] init];
        formatter.locale = [NSLocale autoupdatingCurrentLocale];
        formatter.dateStyle = NSDateFormatterLongStyle;
    });
    
    return formatter;
}

@end
