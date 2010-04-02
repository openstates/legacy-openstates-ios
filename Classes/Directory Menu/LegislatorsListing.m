//
//  LegislatorsListing.m
//  TexLege
//
//  Created by Gregory Combs on 5/24/09.
//  Copyright 2009 University of Texas at Dallas. All rights reserved.
//

#import "LegislatorsListing.h"
#import "Legislator.h"




@interface LegislatorsListing(mymethods)
// these are private methods that outside classes need not use
- (void)presortLegislatorInitialLetterIndexes;
- (void)presortLegislatorNamesForInitialLetter:(NSString *)aKey;
- (void)presortHouseNamesForInitialLetter:(NSString *)aKey;
- (void)presortSenateNamesForInitialLetter:(NSString *)aKey;
- (void)setupLegislatorsArray;
@end



@implementation LegislatorsListing


@synthesize legislatorDictionary;
@synthesize houseDictionary;
@synthesize senateDictionary;
@synthesize nameIndexesDictionary;
@synthesize legislatorNameIndexArray;

@synthesize legislatorHouseArray;
@synthesize legislatorSenateArray;


// we use the singleton approach, one collection for the entire application
static LegislatorsListing *sharedLegislatorsInstance = nil;

+ (LegislatorsListing*)sharedLegislators {
    @synchronized(self) {
        if (sharedLegislatorsInstance == nil) {
            [[self alloc] init]; // assignment not done here
        }
    }
    return sharedLegislatorsInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedLegislatorsInstance == nil) {
            sharedLegislatorsInstance = [super allocWithZone:zone];
            return sharedLegislatorsInstance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}


// setup the data collection
- init {
	if (self = [super init]) {
		[self setupLegislatorsArray];
	}
	return self;
}

- (EXContainer*)container {
	return container;
}

- (void)dealloc {
	[resultSet release];
	[container release];
	[super dealloc];
}


/*
- (void)sync:(id)sender {
	if ([container synchronizeWithPort: 8899 host: @"127.0.0.1"] == NO) {
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Sync error" message: @"Cannot connect to the server" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	} else {
		[[self tableView] reloadData];
		UIAlertView* alert = [[UIAlertView alloc] initWithTitle: @"Sync" message: @"Completed" delegate: nil cancelButtonTitle: @"OK" otherButtonTitles: nil];
		[alert show];
		[alert release];
	}
}
*/


- (void)setupLegislatorsArray {
	
//********	NSArray* paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//******	NSString* documentsDirectory = [paths objectAtIndex: 0];
	//NSString* dbFileName = [documentsDirectory stringByAppendingFormat: @"/Legislators.db"];
//	NSString *dbFileName = [[NSBundle mainBundle]  pathForResource:@"Legislators" ofType:@"db"];
	NSString *dbFileName = [ NSString stringWithFormat:
						 @"%@/TexLege.app/Legislators.db",NSHomeDirectory() ];
	EXFile* file = [EXFile fileWithName: dbFileName];
	container = [[EXContainer alloc] initWithFile: file];
#if 1
	Legislator* customObject = [[Legislator alloc] init];
	[container store: customObject];
	[customObject release];
#endif	
	
	[resultSet release];
	resultSet = [container queryWithClass: [Legislator class]];
	[resultSet retain];
	
//	NSUInteger numberOfLegislators = [resultSet count];

	
	// create dictionaries that contain the arrays of legislators indexed by
	// name and type
	self.legislatorDictionary = [NSMutableDictionary dictionary];
	self.houseDictionary = [NSMutableDictionary dictionary];
	self.senateDictionary = [NSMutableDictionary dictionary];
	self.nameIndexesDictionary = [NSMutableDictionary dictionary];

	NSDictionary *eachLegislator;
	
	// read the legislator data from the plist
	//*****NSString *thePath = [[NSBundle mainBundle]  pathForResource:@"Elements" ofType:@"plist"];
	//*****NSArray *rawLegislatorsArray = [[NSArray alloc] initWithContentsOfFile:thePath];
	
	// iterate over the values in the raw elements dictionary
	//*****for (eachLegislator in rawLegislatorsArray)
	for (eachLegislator in resultSet)
	{
		// create an legislator instance for each
		Legislator *aLegislator = [[Legislator alloc] initWithDictionary:eachLegislator];
		
		// store that item in the legislators dictionary with the ID as the key
		[legislatorDictionary setObject:aLegislator forKey:aLegislator.legislatorID];
				
		// get the legislator's initial letter
		NSString *firstLetter = [aLegislator.lastname substringToIndex:1];
		NSMutableArray *existingArray;
		
		// if an array already exists in the name index dictionary
		// simply add the legislator to it, otherwise create an array
		// and add it to the name index dictionary with the letter as the key
		if (existingArray = [nameIndexesDictionary valueForKey:firstLetter]) 
		{
			[existingArray addObject:aLegislator];
		} else {
			NSMutableArray *tempArray = [NSMutableArray array];
			[nameIndexesDictionary setObject:tempArray forKey:firstLetter];
			[tempArray addObject:aLegislator];
		}

		// add that legislator to the appropriate array in the chamber dictionary 
		if (aLegislator.legtype.intValue == HOUSE) {
			if (existingArray = [houseDictionary valueForKey:firstLetter]) 
			{
				[existingArray addObject:aLegislator];
			} else {
				NSMutableArray *tempArray = [NSMutableArray array];
				[houseDictionary setObject:tempArray forKey:firstLetter];
				[tempArray addObject:aLegislator];
			}
		}
		else if (aLegislator.legtype.intValue == SENATE) {
			if (existingArray = [senateDictionary valueForKey:firstLetter]) 
			{
				[existingArray addObject:aLegislator];
			} else {
				NSMutableArray *tempArray = [NSMutableArray array];
				[senateDictionary setObject:tempArray forKey:firstLetter];
				[tempArray addObject:aLegislator];
			}
		}
		
		
		// release the legislator, it is held by the various collections
		[aLegislator release];
		
	}
	// release the raw legislator data
	//********[rawLegislatorsArray release];
	
	// presort the dictionaries now
	// this could be done the first time they are requested instead
	
	[self presortLegislatorInitialLetterIndexes];
	
}




// return the array of elements for the requested chamber
- (NSArray *)legislatorsWithInitialLetter:(NSString*)aKey forChamber:(NSNumber*)aChamber{
	if (aChamber.intValue == HOUSE)
		return [houseDictionary objectForKey:aKey];
	else if (aChamber.intValue == SENATE)
		return [senateDictionary objectForKey:aKey];
	else
		// Blown up, obviously ... hope you're looking for this problem.
		return NULL;
}


// return an array of elements for an initial letter (ie A, B, C, ...)
- (NSArray *)legislatorsWithInitialLetter:(NSString*)aKey {
	return [nameIndexesDictionary objectForKey:aKey];
}


// presort the name index arrays so the legislators are in the correct order
- (void)presortLegislatorInitialLetterIndexes {
	self.legislatorNameIndexArray = [[nameIndexesDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *eachNameIndex in legislatorNameIndexArray) {
		[self presortLegislatorNamesForInitialLetter:eachNameIndex];
	}	

	self.legislatorHouseArray = [[senateDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *eachNameIndex in legislatorHouseArray) {
		[self presortHouseNamesForInitialLetter:eachNameIndex];
	}	

	self.legislatorSenateArray = [[senateDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
	for (NSString *eachNameIndex in legislatorSenateArray) {
		[self presortSenateNamesForInitialLetter:eachNameIndex];
	}	
}

- (void)presortLegislatorNamesForInitialLetter:(NSString *)aKey {
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastname"
																   ascending:YES
																	selector:@selector(localizedCaseInsensitiveCompare:)] ;
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	[[nameIndexesDictionary objectForKey:aKey] sortUsingDescriptors:descriptors];
	[nameDescriptor release];
}

- (void)presortHouseNamesForInitialLetter:(NSString *)aKey {
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastname"
																   ascending:YES
																	selector:@selector(localizedCaseInsensitiveCompare:)] ;
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	[[houseDictionary objectForKey:aKey] sortUsingDescriptors:descriptors];
	[nameDescriptor release];
}

- (void)presortSenateNamesForInitialLetter:(NSString *)aKey {
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"lastname"
																   ascending:YES
																	selector:@selector(localizedCaseInsensitiveCompare:)] ;
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	[[senateDictionary objectForKey:aKey] sortUsingDescriptors:descriptors];
	[nameDescriptor release];
}



/*
// presort the elementsSortedByNumber array
- (NSArray *)presortElementsByDistrict {
	NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"district"
																   ascending:YES
																	selector:@selector(compare:)] ;
	
	NSArray *descriptors = [NSArray arrayWithObject:nameDescriptor];
	NSArray *sortedElements = [[legislatorDictionary allValues] sortedArrayUsingDescriptors:descriptors];
	[nameDescriptor release];
	return sortedElements;
}

*/
// presort the elementsSortedBySymbol array



@end