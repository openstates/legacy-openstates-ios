//
//  BillMetadataLoader.m
//  TexLege
//
//  Created by Gregory Combs on 3/16/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "BillMetadataLoader.h"
#import <RestKit/Support/JSON/JSONKit/JSONKit.h>
#import "UtilityMethods.h"
#import "TexLegeReachability.h"


@implementation BillMetadataLoader
SYNTHESIZE_SINGLETON_FOR_CLASS(BillMetadataLoader);
//@synthesize metadata=_metadata;
@synthesize isFresh;

- (id)init {
	if (self=[super init]) {
		updated = nil;
		isFresh = NO;
		_metadata = nil;
		//[self loadMetadata:nil];
	}
	return self;
}

- (void)dealloc {
	[[RKRequestQueue sharedQueue] cancelRequestsWithDelegate:self];
	if (updated)
		[updated release], updated = nil;

	if (_metadata)
		[_metadata release], _metadata = nil;
	
	[super dealloc];
}

- (void)loadMetadata:(id)sender {
	if ([TexLegeReachability canReachHostWithURL:[NSURL URLWithString:@"http://www.texlege.com"] alert:NO]) {
		[[RKClient sharedClient] get:[NSString stringWithFormat:@"/%@", kBillMetadataFile] delegate:self];  	
	}
	else {
		[self request:nil didFailLoadWithError:nil];
	}
}

- (NSDictionary *)metadata {
	if (!isFresh || !updated || ([[NSDate date] timeIntervalSinceDate:updated] > (3600*24))) {	// if we're over a day old, let's refresh
		isFresh = NO;
		debug_NSLog(@"BillMetaData is stale, need to refresh");
		
		[self loadMetadata:nil];
	}
	
	return _metadata;
}

#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
	if (error && request) {
		debug_NSLog(@"Error loading bill metadata from %@: %@", [request description], [error localizedDescription]);
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillMetadataNotifyError object:nil];
	}
	
	// We had trouble loading the metadata online, so pull it up from the one in the documents folder (or the app bundle)
	NSError *newError = nil;
	NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillMetadataFile];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if (![fileManager fileExistsAtPath:localPath]) {
		NSString *defaultPath = [[NSBundle mainBundle] pathForResource:kBillMetadataPath ofType:@"json"];
		[fileManager copyItemAtPath:defaultPath toPath:localPath error:&newError];
		debug_NSLog(@"BillMetadata: copied metadata from the app bundle's original.");
	}
	else {
		debug_NSLog(@"BillMetadata: using cached metadata in the documents folder.");
	}

	NSData *jsonFile = [NSData dataWithContentsOfFile:localPath];
	if (_metadata)
		[_metadata release];	
	_metadata = [[jsonFile mutableObjectFromJSONData] retain];
	if (_metadata) {
		[[NSNotificationCenter defaultCenter] postNotificationName:kBillMetadataNotifyLoaded object:nil];
	}
}


// Handling GET /BillMetadata.json  
- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
	if ([request isGET] && [response isOK]) {  
		// Success! Let's take a look at the data  
		if (_metadata)
			[_metadata release];	
		
		_metadata = [[response.body mutableObjectFromJSONData] retain];
		if (_metadata) {
			updated = [[NSDate date] retain];
			NSString *localPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:kBillMetadataFile];
			if (![[_metadata JSONData] writeToFile:localPath atomically:YES])
				NSLog(@"BillMetadataLoader: error writing cache to file: %@", localPath);
			isFresh = YES;
			[[NSNotificationCenter defaultCenter] postNotificationName:kBillMetadataNotifyLoaded object:nil];
			debug_NSLog(@"BillMetadata network download successfull, archiving for others.");
		}		
		else {
			[self request:request didFailLoadWithError:nil];
			return;
		}
	}
}		

@end
