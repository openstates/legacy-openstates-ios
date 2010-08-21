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
	DirectoryTypeChamberMap,
	DirectoryTypeWeb,
	DirectoryTypeTwitter,
	kDirectoryTypeIsExternalHandler,
	DirectoryTypeMap,
	DirectoryTypeMail,
	DirectoryTypePhone,
	DirectoryTypeSMS,
};


@interface DirectoryDetailInfo : NSObject {
	
	NSString *entryName;
	NSString *entryValue;
	BOOL isClickable;
	NSInteger entryType;
}
@property (nonatomic, retain)NSString *entryName;
@property (nonatomic, retain)NSString *entryValue;
@property (nonatomic)BOOL isClickable;
@property (nonatomic)NSInteger entryType;

- (NSURL *)generateURL:(LegislatorObj *)legislator;

- (id)initWithDictionary:(NSDictionary *)aDictionary;
- (id)initWithName:(NSString *)newName value:(NSString *)newValue isClickable:(BOOL)newClickable type:(NSInteger)newType;


@end
