//
//  LinkObj.h
//  TexLege
//
//  Created by Gregory Combs on 7/10/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "Constants.h"


@interface LinkObj :  NSManagedObject  
{
}

@property (nonatomic, retain) NSNumber * order;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * section;

@end



