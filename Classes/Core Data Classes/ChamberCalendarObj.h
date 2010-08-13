//
//  ChamberCalendarObj.h
//  TexLege
//
//  Created by Gregory Combs on 8/12/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CFeedStore.h"

@interface ChamberCalendarObj : NSObject {	
}

@property (nonatomic,retain) NSString *title;
@property (nonatomic,retain) NSNumber *chamber;
@property (nonatomic,retain) NSArray *feedURLS;
@property (nonatomic,retain) CFeedStore *feedStore;

- (NSArray *)feedEntries;

@end
