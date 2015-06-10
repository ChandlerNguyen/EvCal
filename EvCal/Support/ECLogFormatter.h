//
//  ECLogFormatter.h
//  EvCal
//
//  Created by Tom on 5/30/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaLumberjack/CocoaLumberjack.h>

@interface ECLogFormatter : NSObject <DDLogFormatter>

//------------------------------------------------------------------------------
// @name Formatting Log Messages
//------------------------------------------------------------------------------

/**
 *  Appends the log level and calling method to the front of any log message
 *
 *  @param logMessage The log message being modified
 *
 *  @return A newly created string with the log level, calling function, and 
 *          original message concatenated together.
 */
- (NSString*)formatLogMessage:(DDLogMessage *)logMessage;

@end
