//
//  SLFLog.h
//  OpenStates
//
//  Created by Gregory Combs on 2/1/17.
//  Copyright © 2017 Sunlight Foundation. All rights reserved.
//

#import <Foundation/Foundation.h>
@import os.log;

os_log_t SLFLoggerForComponent(const char * component);

@interface SLFLog : NSObject

+ (os_log_t)common;

@end
