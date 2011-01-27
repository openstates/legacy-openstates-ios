//
//  StafferObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "TexLegeDataObjectProtocol.h"

@class LegislatorObj;

@interface StafferObj :  NSManagedObject <TexLegeDataObjectProtocol>
{
}

@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * stafferID;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



