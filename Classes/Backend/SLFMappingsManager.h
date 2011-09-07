//
//  SLFMappingsManager.h
//  Created by Gregory Combs on 7/31/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class SLFCommittee;
@class SLFLegislator;

@interface SLFMappingsManager : NSObject {

}

@property (nonatomic,retain) RKManagedObjectMapping * legislatorMapping;
@property (nonatomic,retain) RKManagedObjectMapping * committeeMapping;
@property (nonatomic,retain) RKManagedObjectMapping * positionMapping;
@property (nonatomic,retain) RKManagedObjectMapping * eventMapping;
@property (nonatomic,retain) RKManagedObjectMapping * billMapping;
@property (nonatomic,retain) RKManagedObjectMapping * districtMapping;
@property (nonatomic,retain) RKManagedObjectMapping * stateMapping;

- (void)registerMappingsWithProvider:(RKObjectMappingProvider *)provider;

+ (inout id *)premapCommittee:(SLFCommittee *)committee withMappableData:(inout id *)mappableData;
+ (inout id *)premapLegislator:(SLFLegislator *)legislator withMappableData:(inout id *)mappableData;

@end
