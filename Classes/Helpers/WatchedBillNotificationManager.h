//
//  WatchedBillNotificationManager.h
//  Created by Greg Combs on 12/3/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@interface WatchedBillNotificationManager : NSObject <RKObjectLoaderDelegate,RKRequestQueueDelegate>
+ (WatchedBillNotificationManager *)manager;
- (NSString *)alertMessageForUpdatedBill:(SLFBill *)updatedBill;
- (IBAction)checkBillsStatus:(id)sender;
- (IBAction)resetStatusNotifications:(id)sender;
@end
