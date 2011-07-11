//
//  BillMetadataLoader.h
//  Created by Gregory Combs on 3/16/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import <RestKit/RestKit.h>

#define kBillMetadataFile @"BillMetadata.json"
#define kBillMetadataPath @"BillMetadata"

#define kBillMetadataNotifyError	@"BILL_METADATA_ERROR"
#define kBillMetadataNotifyLoaded	@"BILL_METADATA_LOADED"

@interface BillMetadataLoader : NSObject <RKRequestDelegate> {
	NSMutableDictionary *_metadata;
	BOOL isFresh, isLoading;
	NSDate *updated;
}
+ (BillMetadataLoader *)sharedBillMetadataLoader;
- (void)loadMetadata:(id)sender;

@property (nonatomic,readonly) NSDictionary *metadata;
@property (nonatomic) BOOL isFresh;

#define kBillMetadataUpdatedKey @"updated"
#define kBillMetadataContentsKey @"contents"
#define kBillMetadataTypesKey @"types"
#define kBillMetadataTitleKey @"title"

/* metdata contains the following:*
{
	"updated":"2011-03-15 15:31:15",
	"contents":"Texas bill subjects, types, other metadata",
	"types": [
		 {"id":1,"title":"HB"},
		 {"id":2,"title":"HCR"},
		 { "id":3,"title":"HJR"},
		 ...
		 ],
}
*/

@end

