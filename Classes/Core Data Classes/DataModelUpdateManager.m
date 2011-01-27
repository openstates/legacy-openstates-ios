//
//  DataModelUpdateManager.m
//  TexLege
//
//  Created by Gregory Combs on 1/26/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#define JSONDATA_VERSIONNAME	@"jsonDataVersion"
#define JSONDATA_VERSIONFILE	@"jsonDataVersion.json"
#define JSONDATA_BASE_URL		@"http://www.texlege.com/jsonData"
#define JSONDATA_VERSIONKEY		@"Version"
#define JSONDATA_TIMESTAMPKEY	@"Timestamp"
#define JSONDATA_URLKEY			@"URL"
//#define JSONDATA_ENCODING		NSMacOSRomanStringEncoding	
#define JSONDATA_ENCODING		NSUTF8StringEncoding

#import "DataModelUpdateManager.h"
#import "JSON.h"
#import "UtilityMethods.h"
#import "TexLegeReachability.h"
#import "TexLegeCoreDataUtils.h"
#import "TexLegeDataObjectProtocol.h"
#import "TexLegeAppDelegate.h"
#import "TexLegeDataImporter.h"

//#import "CommitteeObj.h"
//#import "LegislatorObj.h"

@interface DataModelUpdateManager (Private)

- (NSDictionary *)getLocalDataModelCatalog;
- (NSDictionary *)getRemoteDataModelCatalog;
- (NSArray *)getListOfAvailableUpdates;
- (NSArray *)getRemoteModelWithKey:(NSString *)key;
- (IBAction)saveAction:(id)sender;
- (BOOL)checkUpdateFinished;

@end

@implementation DataModelUpdateManager

@synthesize managedObjectContext;
@synthesize localModelCatalog, remoteModelCatalog, availableUpdates, downloadedUpdates;

- (id) initWithManagedObjectContext:(NSManagedObjectContext*)newContext {
	if (self=[super init]) {
		self.managedObjectContext = newContext;	
		self.remoteModelCatalog = self.localModelCatalog = nil;
		self.downloadedUpdates = [NSMutableArray array];
	}
	return self;
}

- (void) dealloc {
	self.managedObjectContext = nil;
	self.downloadedUpdates = nil;
	self.availableUpdates = nil;
	self.localModelCatalog = self.remoteModelCatalog = nil;
	[super dealloc];
}

- (NSDictionary *)getLocalDataModelCatalog {
	NSDictionary *localVersionDict = nil;
	NSError *error = nil;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	NSString *localVersionPath = [[UtilityMethods applicationDocumentsDirectory] 
								  stringByAppendingPathComponent:JSONDATA_VERSIONFILE];
	
	if (![fileManager fileExistsAtPath:localVersionPath]) {
		NSString *defaultVersionPath = [[NSBundle mainBundle] pathForResource:JSONDATA_VERSIONNAME ofType:@"json"];
		if (defaultVersionPath) {
			[fileManager copyItemAtPath:defaultVersionPath toPath:localVersionPath error:&error];
			if (error) {
				NSLog(@"Error attempting to copy default json data version file to docs folder: %@", error);
			}
			else {
				[[NSNotificationCenter defaultCenter] postNotificationName:@"JSONDATAVERSION_COPIED" object:localVersionPath];	
				NSLog(@"Successfully copied a jsonDataVersion file in %@", localVersionPath);
			}
		}
	}
	NSString * localVersionString = [NSString stringWithContentsOfFile:localVersionPath encoding:NSUTF8StringEncoding error:&error];
	if (error) {
		NSLog(@"Error attempting to read local json data version file with error: %@ [path: %@]", error, localVersionPath);
	}
	if (localVersionString && [localVersionString length]) {
		localVersionDict = [localVersionString JSONValue];
		if (!localVersionDict)
			NSLog(@"Error parsing local json data version string: %@", localVersionString);
	}
	
	return localVersionDict;
}

- (NSDictionary *)getRemoteDataModelCatalog {
	NSDictionary *remoteVersionDict = nil;
	
	if ([[TexLegeReachability sharedTexLegeReachability] isNetworkReachable]) {
		
		NSString *urlMethod = [NSString stringWithFormat:@"%@/%@", JSONDATA_BASE_URL, JSONDATA_VERSIONFILE];
		NSURL *url = [NSURL URLWithString:urlMethod];
		NSError *error = nil;
		NSString * remoteVersionString = [NSString stringWithContentsOfURL:url encoding:JSONDATA_ENCODING error:&error];
		if (error) {
			NSLog(@"Error retrieving remote JSON data version file:%@", error);
		}
		if (remoteVersionString && [remoteVersionString length]) {
			remoteVersionDict = [remoteVersionString JSONValue];
			if (!remoteVersionDict) {
				NSLog(@"Error parsing remote json data version string: %@", remoteVersionString);
			}
/*
			else {
				outFile = [NSString stringWithFormat:@"%@.remotecache", JSONDATA_VERSIONFILE];
				outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:outFile];
				[remoteVersionString writeToFile:outPath atomically:YES encoding:JSONDATA_ENCODING error:&error];
				if (error) {
					NSLog(@"Error attempting to cache remote json data version file with error: %@ [path: %@]", error, outPath);
				}
			}
*/
		}
	}
	else {
		NSLog(@"Network is unreachable, cannot obtain remote json data version file.");
	}
	
	return remoteVersionDict;
}


- (NSArray *)getListOfAvailableUpdates {
	NSMutableArray *updatableArray = [NSMutableArray array];
		
	self.remoteModelCatalog = [self getRemoteDataModelCatalog];
	self.localModelCatalog = [self getLocalDataModelCatalog];
	//updateAvail = ([self.localModelCatalog isEqualToDictionary:self.remoteModelCatalog] == NO);

	if (self.remoteModelCatalog) {
		for (NSString *remoteModelKey in [self.remoteModelCatalog allKeys]) {
			NSDictionary *remoteModel = [self.remoteModelCatalog objectForKey:remoteModelKey];
			if (!remoteModel)
				continue;			
			NSNumber *modelVersionNum = [remoteModel objectForKey:JSONDATA_VERSIONKEY];
			if (!modelVersionNum)
				continue;
			
			NSInteger remoteModelVersion = [modelVersionNum integerValue];
			BOOL addModelToUpdates = remoteModelVersion > 0;
			
			if (addModelToUpdates && self.localModelCatalog) {
				NSDictionary *localModel = [self.localModelCatalog objectForKey:remoteModelKey];
				
				if (localModel) {
					modelVersionNum = [localModel objectForKey:JSONDATA_VERSIONKEY];
					if (modelVersionNum) {
						NSInteger localModelVersion = [modelVersionNum integerValue];
						addModelToUpdates = remoteModelVersion > localModelVersion;
					}
				}
			}
			if (addModelToUpdates)
				[updatableArray addObject:remoteModelKey];
		}
	}
	
	return updatableArray;
}

- (BOOL)isDataUpdateAvailable {
	self.availableUpdates = [self getListOfAvailableUpdates];	
	return (self.availableUpdates && [self.availableUpdates count]);
}	

- (void)requestRemoteModelWithDict:(NSDictionary *)requestDict {
	if (!requestDict)
		return;
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];

	NSDictionary *catalog = [requestDict objectForKey:@"catalog"];
	NSString *key = [requestDict objectForKey:@"modelKey"];
	
	if (!catalog || !key)
		return;
	
	NSDictionary *remoteModelInfo = [catalog objectForKey:key];
	
	// this reachability can't be in a thread, right?
	if (remoteModelInfo) {
		NSNumber *versionNumber = [remoteModelInfo objectForKey:JSONDATA_VERSIONKEY];
		if (versionNumber && ([versionNumber integerValue] > 0)) {
			NSString *modelFile = [remoteModelInfo objectForKey:JSONDATA_URLKEY];
			if (modelFile) {
				NSString *urlString = [NSString stringWithFormat:@"%@/%@", JSONDATA_BASE_URL, modelFile];
				NSURL *url = [NSURL URLWithString:urlString];
				
				NSError *error = nil;
				NSString * modelString = [NSString stringWithContentsOfURL:url encoding:JSONDATA_ENCODING error:&error];
				if (error) {
					NSLog(@"Error retrieving remote JSON data update:%@ [file:%@]", error, modelFile);
				}
				if (modelString && [modelString length]) {
					NSArray *modelArray = [modelString JSONValue];
					if (!modelArray) {
						NSLog(@"Error parsing remote json data update in file: %@", modelFile);
					}
					else {
						NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:modelFile];
						[modelString writeToFile:outPath atomically:YES encoding:JSONDATA_ENCODING error:&error];
						if (error) {
							NSLog(@"Error attempting to write json data update file with error: %@ [path: %@]", error, outPath);
						}
						
						if (remoteModelInfo && key && modelArray && [modelArray count]) {
							NSDictionary *updatedModelDict = [NSDictionary dictionaryWithObjectsAndKeys:
															  remoteModelInfo, @"modelInfo",
															  key, @"modelKey",
															  /*[modelArray count], @"modelSize",*/ nil];
							
							[self performSelectorOnMainThread:@selector(receiveDataModelUpdate:) withObject:updatedModelDict waitUntilDone:NO];
						}
					}
				}
			}
		}
	}
	[pool drain];
}

- (void)receiveDataModelUpdate:(NSDictionary *)updatedModelDict {	
	if (updatedModelDict) {
		NSArray *updatedModelInfo = [updatedModelDict objectForKey:@"modelInfo"];
		NSString *modelKey = [updatedModelDict objectForKey:@"modelKey"];
		//NSNumber *modelSize = [updatedModelDict objectForKey:@"modelSize"];
		
		if (modelKey && updatedModelInfo) {			
			[self.downloadedUpdates addObject:updatedModelDict];
			[self checkUpdateFinished];
		}
	}
}
 
- (void)downloadDataUpdatesUsingCachedList:(BOOL)cached {
	if (!cached || !self.availableUpdates)
		self.availableUpdates = [self getListOfAvailableUpdates];
		
	if (NO == (self.availableUpdates && [self.availableUpdates count])) {
		NSLog(@"[DataModelUpdateManager performUpdate]: No available updates, nothing to do.");
		return;
	}
	if ([[TexLegeAppDelegate appDelegate] databaseIsCopying]) {
		NSLog(@"[DataModelUpdateManager performUpdate]: Persistent Store is still copying, can't peform an update right now.");
		return;
	}
	if (!self.remoteModelCatalog)
		return;
	
	[self.downloadedUpdates removeAllObjects];
	
	for (NSString * modelKey in self.availableUpdates) {
		if ([[TexLegeReachability sharedTexLegeReachability] isNetworkReachable]) {
			NSDictionary *requestDict = [NSDictionary dictionaryWithObjectsAndKeys:
										 self.remoteModelCatalog, @"catalog", 
										 modelKey, @"modelKey", nil];
			[self performSelectorInBackground:@selector(requestRemoteModelWithDict:) withObject:requestDict];
		}
	}
}


// DistrictMapObj doesn't work correctly in JSON, due to binary data  ... we import it from a plist at the end
- (BOOL)installDataUpdates {	
	self.localModelCatalog = [self getLocalDataModelCatalog];

	NSArray *installOrderOfKeys = [NSArray arrayWithObjects:@"LegislatorObj", @"WnomObj", 
								   @"CommitteeObj", @"CommitteePositionObj", @"StafferObj", 
								   @"DistrictOfficeObj", /*@"DistrictMapObj",*/ @"LinkObj", nil]; 
	
	NSInteger installedCount = 0;
	for (NSString *modelKey in installOrderOfKeys) {
		NSString *modelFile = [self.localModelCatalog objectForKey:JSONDATA_URLKEY];
		if (modelFile && [modelFile length]) {
			NSError *error = nil;
			NSString *modelPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:modelFile];			
			NSString *modelString = [[NSString alloc] initWithContentsOfFile:modelPath encoding:JSONDATA_ENCODING error:&error];
			if (!modelString || error) {
				NSLog(@"DataModelUpdateManager - InstallDataUpdates: Error reading a data file: %@; error: %@", modelFile, [error localizedDescription]);
			}
			else {
				NSArray *modelArray = [modelString JSONValue];
				if (!modelArray) {
					NSLog(@"Error parsing local json data in file: %@", modelFile);
				}
				else {
					NSInteger importCount = 0;
					debug_NSLog(@"DataModelUpdateManager: Beginning update for data model: %@", modelKey);
					[TexLegeCoreDataUtils deleteAllObjectsInEntityNamed:modelKey context:self.managedObjectContext];
					
					for (NSDictionary * aDictionary in modelArray) {				
						id<TexLegeDataObjectProtocol> object = [NSEntityDescription insertNewObjectForEntityForName:modelKey inManagedObjectContext:self.managedObjectContext];
						
						if (object) {
							[object importFromDictionary:aDictionary];
							importCount++;
						}
					}
					if (importCount) {
						[self saveAction:nil];
						installedCount++;
						debug_NSLog(@"DataModelUpdateManager: Updated %d %@ model objects", importCount, modelKey);
						//	[[NSNotificationCenter defaultCenter] postNotificationName:@"DATAMODEL_UPDATED" object:nil];

					}
					else {
						[self.managedObjectContext rollback];
						debug_NSLog(@"DataModelUpdateManager: Failed to update %@ model objects, rolling back changes.", modelKey);
					}	
				}
			}
			[modelString release];			
		}
	}
	
	TexLegeDataImporter *importer = [[TexLegeDataImporter alloc] initWithManagedObjectContext:self.managedObjectContext];
	if (importer) {
		[importer importObjectsWithEntityName:@"DistrictMapObj"];
		[importer release];
	}
	
	[[NSNotificationCenter defaultCenter] postNotificationName:@"DATAMODEL_UPDATED" object:nil];
	
	return installedCount == [installOrderOfKeys count];;
}

- (BOOL)checkUpdateFinished {
	BOOL success = self.availableUpdates && ([self.downloadedUpdates count] == [self.availableUpdates count]);
	
	if (success && self.remoteModelCatalog) {
		NSError *error = nil;
		NSString *catalogString = [self.remoteModelCatalog JSONRepresentation];
		NSString *outPath = [[UtilityMethods applicationDocumentsDirectory] stringByAppendingPathComponent:JSONDATA_VERSIONFILE];
		[catalogString writeToFile:outPath atomically:YES encoding:JSONDATA_ENCODING error:&error];
		if (error) {
			NSLog(@"Error attempting to write update json data version catalog with error: %@ [path: %@]", error, outPath);
		}
		else {
			self.availableUpdates = nil;
			
			[self installDataUpdates];
		}
	}
	return success;
}

- (IBAction)saveAction:(id)sender{
	
	@try {
		NSError *error = nil;
		if (self.managedObjectContext != nil) {
			if ([self.managedObjectContext hasChanges] && ![self.managedObjectContext save:&error]) {
				debug_NSLog(@"DataModelUpdateManager:saveAction - unresolved error %@, %@", error, [error userInfo]);
			} 
		}
	}
	@catch (NSException * e) {
		debug_NSLog(@"Failure in DataModelUpdateManager:saveAction, name=%@ reason=%@", e.name, e.reason);
	}
}

@end
