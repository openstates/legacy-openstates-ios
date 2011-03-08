//
//  CommitteeObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/11/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "TexLegeDataObjectProtocol.h"

@class CommitteePositionObj, LegislatorObj;

@interface CommitteeObj :  RKManagedObject
{
	NSNumber * committeeId;
	NSString * committeeName;
	NSNumber * committeeType;
	NSNumber * parentId;
	NSString * url;
	NSString * committeeNameInitial;
	NSString * clerk;
	NSString * clerk_email;
	NSString * phone;
	NSString * office;
	NSNumber * votesmartID;
	NSString * openstatesID;
	NSString * txlonline_id;
	NSString * updated;
	NSSet * committeePositions;	
}

@property (nonatomic, retain) NSNumber * parentId;
@property (nonatomic, retain) NSNumber * committeeId;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * committeeName;
@property (nonatomic, retain) NSNumber * committeeType;
@property (nonatomic, retain) NSString * committeeNameInitial;
@property (nonatomic, retain) NSSet * committeePositions;
@property (nonatomic, retain) NSString * clerk;
@property (nonatomic, retain) NSString * clerk_email;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * office;

@property (nonatomic, retain) NSNumber * votesmartID;
@property (nonatomic, retain) NSString * openstatesID;
@property (nonatomic, retain) NSString * txlonline_id;
@property (nonatomic, retain) NSString * updated;

- (NSString *) typeString;
- (NSString *) description;
- (LegislatorObj *) chair;
- (LegislatorObj *) vicechair;
- (NSArray *) sortedMembers;


@end


@interface CommitteeObj (CoreDataGeneratedAccessors)
- (void)addCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)removeCommitteePositionsObject:(CommitteePositionObj *)value;
- (void)addCommitteePositions:(NSSet *)value;
- (void)removeCommitteePositions:(NSSet *)value;

@end

