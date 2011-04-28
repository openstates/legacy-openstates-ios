//
//  DirectoryDetailCell.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
	DirectoryTypeNone = 0,
	DirectoryTypeNotes,
	DirectoryTypeIndex,
	DirectoryTypeCommittee,
	DirectoryTypeContributions,
	DirectoryTypeBills,
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


@interface TableCellDataObject : NSObject {
	
}
@property (nonatomic, retain)id entryValue;
@property (nonatomic)BOOL isClickable;
@property (nonatomic)NSInteger entryType;
@property (nonatomic, retain) id action;
@property (nonatomic, retain) id parameter;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;


- (NSURL *)generateURL;

- (id)initWithDictionary:(NSDictionary *)aDictionary;


@end
