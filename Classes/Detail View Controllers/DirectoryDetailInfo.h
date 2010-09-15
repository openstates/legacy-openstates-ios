//
//  DirectoryDetailCell.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;

enum {
	DirectoryTypeNone = 0,
	DirectoryTypeNotes,
	DirectoryTypeIndex,
	DirectoryTypeCommittee,
	// URL types go below here
	kDirectoryTypeIsURLHandler,
	DirectoryTypeOfficeMap,
	DirectoryTypeWeb,
	DirectoryTypeTwitter,
	kDirectoryTypeIsExternalHandler,
	DirectoryTypeMap,
	DirectoryTypeMail,
	DirectoryTypePhone,
	DirectoryTypeSMS,
};


@interface DirectoryDetailInfo : NSObject {
	
}
@property (nonatomic, retain)id entryValue;
@property (nonatomic)BOOL isClickable;
@property (nonatomic)NSInteger entryType;

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;


- (NSURL *)generateURL:(LegislatorObj *)legislator;

- (id)initWithDictionary:(NSDictionary *)aDictionary;


@end
