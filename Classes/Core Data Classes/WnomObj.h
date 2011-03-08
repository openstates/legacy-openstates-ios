//
//  WnomObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class LegislatorObj;

@interface WnomObj :  RKManagedObject
{
	NSNumber * wnomID;
	NSNumber * legislatorID;
	NSNumber * wnomAdj;
	NSNumber * session;
	NSNumber * wnomStderr;
	NSNumber * adjMean;
	NSString * updated;
	LegislatorObj * legislator;	
}

@property (nonatomic, retain) NSNumber * wnomID;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSNumber * wnomAdj;
@property (nonatomic, retain) NSNumber * session;
@property (nonatomic, retain) NSNumber * wnomStderr;
@property (nonatomic, retain) NSNumber * adjMean;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) LegislatorObj * legislator;

- (NSNumber *) year;
@end



