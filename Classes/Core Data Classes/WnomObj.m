// 
//  WnomObj.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/10.
//  Copyright 2010 University of Texas at Dallas. All rights reserved.
//

#import "WnomObj.h"

#import "LegislatorObj.h"

@implementation WnomObj 

@dynamic wnomAdj;
@dynamic session;
@dynamic wnomStderr;
@dynamic legislator;
@dynamic adjMean;

- (NSNumber *) year {
	return [NSNumber numberWithInteger:1849+(2*[self.session integerValue])];
}


@end
