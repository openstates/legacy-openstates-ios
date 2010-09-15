//
//  TexLegeDataObjectProtocol.h
//  TexLege
//
//  Created by Gregory Combs on 9/15/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol TexLegeDataObjectProtocol

@required

- (void) importFromDictionary: (NSDictionary *)dictionary;
- (NSDictionary *)exportToDictionary;
	
@end

