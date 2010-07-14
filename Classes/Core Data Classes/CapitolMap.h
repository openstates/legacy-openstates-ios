//
//  CapitolMap.h
//  TexLege
//
//  Created by Gregory Combs on 7/11/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CapitolMap : NSObject {
	NSString *m_name;
	NSString *m_file;
	NSNumber *m_type;
	NSNumber *m_order;
}

@property (nonatomic,retain) NSString *name;
@property (nonatomic,retain) NSString *file;
@property (nonatomic,retain) NSNumber *type;
@property (nonatomic,retain) NSNumber *order;
@property (nonatomic,readonly) NSURL *url;

- (id)initWithDictionary:(NSDictionary *)mapDict;

@end
