//
//  WnomObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

@class LegislatorObj;

@interface WnomObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSNumber * adjMean;
@property (nonatomic, retain) NSNumber * wnomID;
@property (nonatomic, retain) NSNumber * legislatorID;
@property (nonatomic, retain) NSString * updated;
@property (nonatomic, retain) NSNumber * wnomAdj;
@property (nonatomic, retain) NSNumber * session;
@property (nonatomic, retain) NSNumber * wnomStderr;
@property (nonatomic, retain) LegislatorObj * legislator;

@end



