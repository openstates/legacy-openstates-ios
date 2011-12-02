//
//  MKiCloudSync.m
//  iCloud1
//
//  Created by Mugunth Kumar on 20/11/11.
//  Copyright (c) 2011 Steinlogic. All rights reserved.

//  As a side note on using this code, you might consider giving some credit to me by
//	1) linking my website from your app's website 
//	2) or crediting me inside the app's credits page 
//	3) or a tweet mentioning @mugunthkumar
//	4) A paypal donation to mugunth.kumar@gmail.com
//
//  A note on redistribution
//	if you are re-publishing after editing, please retain the above copyright notices


#import "MKiCloudSync.h"

NSString * const kMKiCloudSyncNotification = @"MKiCloudSyncDidUpdateToLatest";

@implementation MKiCloudSync

+(void)updateToiCloud:(NSNotification*) notificationObject {
    NSLog(@"Updating to iCloud");
    NSDictionary *dict = [[NSUserDefaults standardUserDefaults] dictionaryRepresentation];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [[NSUbiquitousKeyValueStore defaultStore] setObject:obj forKey:key];
    }];
    [[NSUbiquitousKeyValueStore defaultStore] synchronize];
}

+(void)updateFromiCloud:(NSNotification*) notificationObject {
    
    NSLog(@"Updating from iCloud");
    NSUbiquitousKeyValueStore *iCloudStore = [NSUbiquitousKeyValueStore defaultStore];
    NSDictionary *dict = [iCloudStore dictionaryRepresentation];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    NSUserDefaults *standardDefaults = [NSUserDefaults standardUserDefaults];
    
        // prevent NSUserDefaultsDidChangeNotification from being posted while we update from iCloud
    [defaultCenter removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
    [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [standardDefaults setObject:obj forKey:key];
    }];
    [standardDefaults synchronize];
    
        // enable NSUserDefaultsDidChangeNotification notifications again
    [defaultCenter addObserver:self selector:@selector(updateToiCloud:) name:NSUserDefaultsDidChangeNotification object:nil];
    [defaultCenter postNotificationName:kMKiCloudSyncNotification object:nil];
}

+(void)start {
    if(NO == NSClassFromString(@"NSUbiquitousKeyValueStore")) { // is iOS 5?
        NSLog(@"Not an iOS 5 device");  
        return;
    }
    if(NO == [NSUbiquitousKeyValueStore defaultStore]) {  // is iCloud enabled
        NSLog(@"iCloud not enabled");
        return;
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFromiCloud:) name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateToiCloud:) name:NSUserDefaultsDidChangeNotification object:nil];
}

+ (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUbiquitousKeyValueStoreDidChangeExternallyNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSUserDefaultsDidChangeNotification object:nil];
}
@end
