//
//  BillsSubjectsEntry.h
//  Created by Greg Combs on 12/1/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@class RKObjectMapping;
@interface BillsSubjectsEntry : NSObject
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) NSNumber *billCount;
+ (RKObjectMapping *)mapping;
+ (NSArray *)sortDescriptors;
@end

