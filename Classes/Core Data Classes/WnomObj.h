//
//  WnomObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import <CoreData/CoreData.h>

@class LegislatorObj;

@interface WnomObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * wnomAdj;
@property (nonatomic, retain) NSNumber * session;
@property (nonatomic, retain) NSNumber * wnomStderr;
@property (nonatomic, retain) LegislatorObj * legislator;
@property (nonatomic, retain) NSNumber * adjMean;

- (NSNumber *) year;
@end



