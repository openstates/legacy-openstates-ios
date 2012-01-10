//
//  SLFObjectCache.m
//  Created by Gregory Combs on 3/21/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFObjectCache.h"
#import "SLFDataModels.h"
#import "NSDate+SLFDateHelper.h"

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
    [request setSortDescriptors:[SLFState sortDescriptors]];
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

    [request setSortDescriptors:[SLFLegislator sortDescriptors]];
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
    [request setSortDescriptors:[SLFCommittee sortDescriptors]];
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
        predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@ AND chamber = %@", 
                     [args objectForKey:@"stateID"], [args objectForKey:@"chamber"]];
    else if ([pathMatcher matchesPattern:@"/districts/:stateID" tokenizeQueryStrings:YES parsedArguments:&args])
        predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@", 
                     [args objectForKey:@"stateID"]];
    [request setPredicate:predicate];
    [request setSortDescriptors:[SLFDistrict sortDescriptors]];
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
    [request setSortDescriptors:[SLFEvent sortDescriptors]];
    return request;
}

// FOR BILLS ============================
SLF_TODO("Need a way to accurately search current session when search_window is just 'session'")

- (NSFetchRequest*)fetchRequestBillsForResourcePath:(NSString*)resourcePath {

    NSDictionary *args = nil;
    NSFetchRequest *request = [SLFBill fetchRequest];
    
    RKPathMatcher *pathMatcher = [RKPathMatcher matcherWithPath:resourcePath];

    NSPredicate *predicate = [NSPredicate predicateWithValue:YES];
    if ([pathMatcher matchesPattern:@"/bills/:stateID/:session/:billID" tokenizeQueryStrings:YES parsedArguments:&args]) {
        predicate = [NSPredicate predicateWithFormat:@"stateID LIKE[cd] %@ AND billID LIKE[cd] %@ AND session LIKE[cd] %@", 
                     [args objectForKey:@"stateID"], [args objectForKey:@"billID"], [args objectForKey:@"session"]];
        [request setReturnsObjectsAsFaults:NO];;
        [request setRelationshipKeyPathsForPrefetching:[NSArray arrayWithObjects:@"yesVotes", @"noVotes", @"otherVotes", nil]];
    }
    else if ([pathMatcher matchesPattern:@"/bills" tokenizeQueryStrings:YES parsedArguments:&args]) {
        args = [args removePercentEscapesFromKeysAndObjects];
        NSMutableArray *subpredicates = [NSMutableArray array];
        
        [args enumerateKeysAndObjectsUsingBlock: ^(id key, id value, BOOL *stop)
        {
            NSPredicate *subpredicate = nil;
            if ([key isEqualToString:@"sponsor_id"])
                subpredicate = [NSPredicate predicateWithFormat:@"(0!=SUBQUERY(sponsors,$eachSponsor,$eachSponsor.legID=%@ AND ($eachSponsor.type LIKE[cd] 'sponsor' OR $eachSponsor.type LIKE[cd] 'author' OR $eachSponsor.type LIKE[cd] 'primary')).@count)", value];
            else if ([key isEqualToString:@"q"])
                subpredicate = [NSPredicate predicateWithFormat:@"(billID LIKE[cd] %@ OR title CONTAINS[cd] %@ OR ANY subjects.word LIKE[cd] %@)", value, value, value];
            else if ([key isEqualToString:@"subject"])
                subpredicate = [NSPredicate predicateWithFormat:@"(ANY subjects.word LIKE[cd] %@)", value];
            else if ([key isEqualToString:@"chamber"])
                subpredicate = [NSPredicate predicateWithFormat:@"(chamber = %@)", value];
            else if ([key isEqualToString:@"state"] || [key isEqualToString:@"stateID"])
                subpredicate = [NSPredicate predicateWithFormat:@"(stateID LIKE[cd] %@)", value];
            else if ([key isEqualToString:@"search_window"]) {
                NSArray *sessionComponents = [value componentsSeparatedByString:@"session:"];
                if ([sessionComponents count] > 1)
                    subpredicate = [NSPredicate predicateWithFormat:@"(session LIKE[cd] %@)", [sessionComponents objectAtIndex:1]];
            }
            else if ([key isEqualToString:@"updated_since"]) {
                NSDate *updatedSince = [NSDate dateFromString:value withFormat:[NSDate dateFormatString]];
                if (updatedSince) {
                    subpredicate = [NSPredicate predicateWithFormat:@"(dateUpdated >= %@)", updatedSince];
                }
            }
            if (subpredicate != NULL)
                [subpredicates addObject:subpredicate];
        }];
        if ([subpredicates count])
            predicate = [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
    }
    [request setPredicate:predicate];
    [request setSortDescriptors:[SLFBill sortDescriptors]];
    return request;
}



@end
