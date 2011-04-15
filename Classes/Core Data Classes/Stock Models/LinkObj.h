//
//  LinkObj.h
//  TexLege
//
//  Created by Gregory Combs on 1/22/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>


@interface LinkObj :  RKManagedObject  
{
}

@property (nonatomic, retain) NSString * label;
@property (nonatomic, retain) NSNumber * section;
@property (nonatomic, retain) NSNumber * sortOrder;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * updated;

@end



