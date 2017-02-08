//
//  SLFLog.m
//  OpenStates
//
//  Created by Gregory Combs on 2/1/17.
//  Copyright © 2017 Sunlight Foundation. All rights reserved.
//

#import "SLFLog.h"
@import os.log;

static os_log_t slfCommonLog;

os_log_t SLFLoggerForComponent(const char * component)
{
    if (!component)
        return nil;
    NSMutableDictionary *loggers = [[NSThread currentThread] threadDictionary];
    NSString *string = [NSString stringWithCString:component encoding:NSASCIIStringEncoding];
    if (!string)
        return nil;
    os_log_t logger = loggers[string];
    if (!logger)
    {
        logger = os_log_create("org.openstates.openstates", component);
        loggers[string] = logger;
    }
    return logger;
}

@implementation SLFLog

+ (void)initialize
{
    slfCommonLog = SLFLoggerForComponent("SLFLog-Common");
}

+ (os_log_t)common
{
    return slfCommonLog;
}

@end
