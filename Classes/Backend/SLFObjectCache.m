//
//  SLFObjectCache.m
//  Created by Gregory Combs on 3/21/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFObjectCache.h"
#import "SLFDataModels.h"

@interface SLFObjectCache()
- (NSFetchRequest*)fetchRequestStatesForResourcePath:(NSString*)resourcePath;
- (NSFetchRequest*)fetchRequestLegislatorsForResourcePath:(NSString*)resourcePath;
- (NSFetchRequest*)fetchRequestCommitteesForResourcePath:(NSString*)resourcePath;
- (NSFetchRequest*)fetchRequestDistrictsForResourcePath:(NSString*)resourcePath;
- (NSFetchRequest*)fetchRequestEventsForResourcePath:(NSString*)resourcePath;
- (NSFetchRequest*)fetchRequestBillsForResourcePath:(NSString*)resourcePath;
@end

@implementation SLFObjectCache

- (NSFetchRequest*)fetchRequestForResourcePath:(NSString*)resourcePath {
    NSCParameterAssert(resourcePath != NULL);    
	if ([resourcePath hasPrefix:@"/metadata"])
		return [self fetchRequestStatesForResourcePath:resourcePath];
	if ([resourcePath hasPrefix:@"/legislators"])
		return [self fetchRequestLegislatorsForResourcePath:resourcePath];
	if ([resourcePath hasPrefix:@"/committees"])
		return [self fetchRequestCommitteesForResourcePath:resourcePath];
	if ([resourcePath hasPrefix:@"/districts"])
		return [self fetchRequestDistrictsForResourcePath:resourcePath];
	if ([resourcePath hasPrefix:@"/events"])
		return [self fetchRequestEventsForResourcePath:resourcePath];
	if ([resourcePath hasPrefix:@"/bills"])
		return [self fetchRequestBillsForResourcePath:resourcePath];
    return nil;
}


// FOR STATES ============================
- (NSFetchRequest*)fetchRequestStatesForResourcePath:(NSString*)resourcePath {
	NSDictionary *arguments = nil;
	NSFetchRequest *request = [SLFState fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];

	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/metadata/:stateID" tokenizeQueryStrings:YES parsedArguments:&arguments])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", [arguments objectForKey:@"stateID"]];
    [request setPredicate:predicate];

    // Even without a match, just do it anyway, since we know it's a state/metadata resource
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:byName]];
    return request;
}

// FOR LEGISLATORS ============================
- (NSFetchRequest*)fetchRequestLegislatorsForResourcePath:(NSString*)resourcePath {
	NSDictionary *arguments = nil;
	NSFetchRequest *request = [SLFLegislator fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];
    
	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/legislators/:legID" tokenizeQueryStrings:YES parsedArguments:&arguments])
		predicate = [NSPredicate predicateWithFormat:@"legID LIKE[cd] %@", [arguments objectForKey:@"legID"]];
	else if ([pathMatcher matchesPattern:@"/legislators" tokenizeQueryStrings:YES parsedArguments:&arguments])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", [arguments objectForKey:@"state"]];
    [request setPredicate:predicate];

    NSSortDescriptor *byLastName = [NSSortDescriptor sortDescriptorWithKey:@"lastName" ascending:YES];
    NSSortDescriptor *byFirstName = [NSSortDescriptor sortDescriptorWithKey:@"firstName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObjects:byLastName, byFirstName, nil]];
    return request;
}

// FOR COMMITTEES ============================
- (NSFetchRequest*)fetchRequestCommitteesForResourcePath:(NSString*)resourcePath {
	NSDictionary *arguments = nil;
	NSFetchRequest *request = [SLFCommittee fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];
    
	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/committees/:committeeID" tokenizeQueryStrings:YES parsedArguments:&arguments])
		predicate = [NSPredicate predicateWithFormat:@"committeeID LIKE[cd] %@", [arguments objectForKey:@"committeeID"]];
	else if ([pathMatcher matchesPattern:@"/committees" tokenizeQueryStrings:YES parsedArguments:&arguments])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", [arguments objectForKey:@"state"]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *byName = [NSSortDescriptor sortDescriptorWithKey:@"committeeName" ascending:YES];
    [request setSortDescriptors:[NSArray arrayWithObject:byName]];
    return request;
}

// FOR DISTRICTS ============================
- (NSFetchRequest*)fetchRequestDistrictsForResourcePath:(NSString*)resourcePath {
	NSDictionary *args = nil;
	NSFetchRequest *request = [SLFDistrict fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];
    
	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/districts/boundary/:boundaryID" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"boundaryID LIKE[cd] %@", 
                     [args objectForKey:@"boundaryID"]];
	else if ([pathMatcher matchesPattern:@"/districts/:stateID/:chamber" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@ AND chamber LIKE[cd] %@", 
                     [args objectForKey:@"stateID"], [args objectForKey:@"chamber"]];
	else if ([pathMatcher matchesPattern:@"/districts/:stateID" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", 
                     [args objectForKey:@"stateID"]];
    [request setPredicate:predicate];
    
    NSSortDescriptor *byNumeric = [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES selector:@selector(localizedStandardCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:byNumeric]];
    return request;
}

// FOR EVENTS ============================
- (NSFetchRequest*)fetchRequestEventsForResourcePath:(NSString*)resourcePath {
	NSDictionary *args = nil;
	NSFetchRequest *request = [SLFEvent fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];
    
	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/events/:eventID" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"eventID LIKE[cd] %@", [args objectForKey:@"eventID"]];
	else if ([pathMatcher matchesPattern:@"/events" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", [args objectForKey:@"state"]];
    [request setPredicate:predicate];

    NSSortDescriptor *byNumeric = [NSSortDescriptor sortDescriptorWithKey:@"dateStart" ascending:YES selector:@selector(localizedStandardCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObject:byNumeric]];
    return request;
}

// FOR BILLS ============================
// TODO: Subject Counts Cache?
    // /subject_counts/tx/821/upper/?apikey=REDACTED
// TODO: Need a way to accurately search current session when search_window is just "session"
// TODO: Need a way to search for "updated_since"
    // /bills?updated_since=2011-04-27&state=tx&apikey=REDACTED

- (NSFetchRequest*)fetchRequestBillsForResourcePath:(NSString*)resourcePath {

	NSDictionary *args = nil;
	NSFetchRequest *request = [SLFBill fetchRequest];
	RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];

	NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
	if ([pathMatcher matchesPattern:@"/bills/:stateID/:billID" tokenizeQueryStrings:YES parsedArguments:&args])
		predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@ AND billID LIKE[cd] %@", 
                     [args objectForKey:@"stateID"], [args objectForKey:@"billID"]];
	else if ([pathMatcher matchesPattern:@"/bills" tokenizeQueryStrings:YES parsedArguments:&args]) {
		NSMutableArray *subpredicates = [NSMutableArray array];
		
		[args enumerateKeysAndObjectsUsingBlock: ^ (id key, id value, BOOL *stop)
        {
            NSPredicate *subpredicate = nil;
			if ([key isEqualToString:@"sponsor_id"])
				subpredicate = [NSPredicate predicateWithFormat:@"(ANY sponsors.leg_id LIKE[cd] %@)", value];
			else if ([key isEqualToString:@"q"])
				subpredicate = [NSPredicate predicateWithFormat:@"(title CONTAINS[cd] %@ OR subjects CONTAINS[cd] %@)", value, value];
            else if ([key isEqualToString:@"subject"])
				subpredicate = [NSPredicate predicateWithFormat:@"(subjects CONTAINS[cd] %@)", value, value];
			else if ([key isEqualToString:@"chamber"])
				subpredicate = [NSPredicate predicateWithFormat:@"(chamber LIKE[cd] %@)", value];
			else if ([key isEqualToString:@"state"] || [key isEqualToString:@"stateID"])
				subpredicate = [NSPredicate predicateWithFormat:@"(stateID LIKE[cd] %@)", value];
			else if ([key isEqualToString:@"search_window"]) {
				NSArray *sessionComponents = [value componentsSeparatedByString:@"session"];
				if ([sessionComponents count] > 1)
					subpredicate = [NSPredicate predicateWithFormat:@"(session LIKE[cd] %@)", [sessionComponents objectAtIndex:1]];
			}	
            if (subpredicate != NULL)
                [subpredicates addObject:subpredicate];
		}];
		if ([subpredicates count])
			predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
	}
    [request setPredicate:predicate];
    
    NSSortDescriptor *bySession = [NSSortDescriptor sortDescriptorWithKey:@"session" ascending:YES selector:@selector(localizedStandardCompare:)];
    NSSortDescriptor *byBillID = [NSSortDescriptor sortDescriptorWithKey:@"billID" ascending:YES selector:@selector(localizedStandardCompare:)];
    [request setSortDescriptors:[NSArray arrayWithObjects:bySession, byBillID, nil]];
    return request;
}



@end
