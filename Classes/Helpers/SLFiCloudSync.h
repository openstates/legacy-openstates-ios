//
//  SLFiCloudSync.h
//  Created by Greg Combs on 12/5/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//  Based in part on Mugunth Kumar's MKiCloudSync, via GitHub

#import <Foundation/Foundation.h>

@interface SLFiCloudSync : NSObject
+(void) start;
@end

extern NSString * const kSLFiCloudSyncNotification;
