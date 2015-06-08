//
//  TableCellDataObject.h
//  Created by Gregory S. Combs on 5/31/09.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


enum {
	DirectoryTypeNone = 0,
	DirectoryTypeNotes,
	DirectoryTypeLegislator,
	DirectoryTypeCommittee,
	DirectoryTypeContributions,
	DirectoryTypeBills,
	DirectoryTypeEvents,
	DirectoryTypeMap,
	// URL types go below here
	kDirectoryTypeIsURLHandler,
	DirectoryTypeWeb,
	DirectoryTypeTwitter,
	kDirectoryTypeIsExternalHandler,
	DirectoryTypeMail,
	DirectoryTypePhone,
	DirectoryTypeSMS,
};


@interface TableCellDataObject : NSObject {
}
@property (nonatomic, assign) BOOL isClickable;
@property (nonatomic, assign) NSInteger entryType;
@property (nonatomic, retain) id entryValue;
@property (nonatomic, retain) id action;
@property (nonatomic, retain) id parameter;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, retain) NSIndexPath *indexPath;
- (id)initWithDictionary:(NSDictionary *)aDictionary;
@end
