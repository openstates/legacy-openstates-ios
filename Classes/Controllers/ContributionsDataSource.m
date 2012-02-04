//
//  ContributionsDataSource.m
//  Created by Gregory Combs on 9/16/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
SLF_TODO("Move this whole class to RKTableController")

#import "ContributionsDataSource.h"
#import "SLFTheme.h"
#import "SLFRestKitManager.h"
#import "JSONKit.h"
#import "SLFStandardGroupCell.h"
#import "SLFDataModels.h"

@interface ContributionsDataSource()
- (void)parseJSONObject:(id)jsonDeserialized;
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
- (BOOL)hasSearchResults;
@end

@implementation ContributionsDataSource
@synthesize sectionList, queryEntityID, queryType, queryCycle;
@synthesize tableHeaderData = _tableHeaderData;

- (NSString *)title {
    NSString *title = nil;
    
    switch ([self.queryType integerValue]) {
        case kContributionQueryTop10Donors:
            title = NSLocalizedString(@"Top Contributions",@"");
            break;
        case kContributionQueryTop10Recipients:
        case kContributionQueryTop10RecipientsIndiv:
            title = NSLocalizedString(@"Top Recipients", @"");
            break;
        case kContributionQueryRecipient:
            title = NSLocalizedString(@"Recipient Details", @"");
            break;
        case kContributionQueryDonor:
        case kContributionQueryIndividual:
            title = NSLocalizedString(@"Contributor Details", @"");
            break;
        case kContributionQueryEntitySearch:
            title = NSLocalizedString(@"Entity Search", @"");
            break;
        default:
            title = @"";
            break;
    }
    
    if (!IsEmpty(self.queryCycle)) {
        NSString *year = self.queryCycle;
        if (![year isEqualToString:@"-1"])
            title = [NSString stringWithFormat:@"%@ %@", year, title];
    }
    return title;
}


- (void)dealloc {
    RKClient *transClient = [[SLFRestKitManager sharedRestKit] transClient];
    [transClient.requestQueue cancelRequestsWithDelegate:self];
    self.queryCycle = nil;
    self.sectionList = nil;
    self.queryEntityID = nil;
    self.queryType = nil;
    self.tableHeaderData = nil;
    [super dealloc];
}

- (BOOL)hasSearchResults {
    NSInteger totalRows = 0;
    for (NSArray *rows in self.sectionList) {
        totalRows+= [rows count];
    }
    return totalRows > 0;
}

#pragma mark -
#pragma mark UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    if ([self hasSearchResults] == NO)
        return 1;
    return [self.sectionList count];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 && [self hasSearchResults] == NO)
        return 1;
    if (section >= [self.sectionList count])
        return 0;
    return [[self.sectionList objectAtIndex:section] count];
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedString(@"Contributions",@"");
    
    switch ([self.queryType integerValue]) {
        case kContributionQueryRecipient:
            title = NSLocalizedString(@"Aggregate Contributions", @"");
            break;
        case kContributionQueryDonor: 
        case kContributionQueryIndividual:
            title = NSLocalizedString(@"Contributions (to everyone)", @"");
            break;
        case kContributionQueryTop10Donors:
            title = NSLocalizedString(@"Biggest Contributors", @"");
            break;
        case kContributionQueryTop10Recipients:
        case kContributionQueryTop10RecipientsIndiv:
            title = NSLocalizedString(@"Biggest Recipients", @"");
            break;
        case kContributionQueryEntitySearch:
            title = NSLocalizedString(@"Search Closest Matching Entity", @"");
            break;
        default:
            break;
    }
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self hasSearchResults] == NO) {
        SLFStandardGroupCell *cell = [SLFStandardGroupCell standardCellWithIdentifier:nil];
        TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
        cellInfo.subtitle = NSLocalizedString(@"Nothing",@"");
        cellInfo.title = NSLocalizedString(@"Found no results for this selection.", @"");
        cell.cellInfo = cellInfo;
        [cellInfo release];
        return cell;
    }

    TableCellDataObject *cellInfo = [self dataObjectForIndexPath:indexPath];
    if (cellInfo == nil) {
        RKLogError(@"Error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
        return nil;
    }
    NSString *cellIdentifier = [NSString stringWithFormat:@"%@-%d", [SLFStandardGroupCell cellIdentifier], cellInfo.isClickable];
    SLFStandardGroupCell *cell = (SLFStandardGroupCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [SLFStandardGroupCell standardCellWithIdentifier:cellIdentifier];
    }
    cell.cellInfo = cellInfo;
    [cell sizeToFit];
    [cell setNeedsDisplay];
    return cell;
}

#pragma mark -
#pragma mark Data Query

- (void)initiateQueryWithQueryID:(NSString *)aQuery type:(NSNumber *)type cycle:(NSString *)cycle {
    self.queryEntityID = aQuery;
    self.queryType = type;
    self.queryCycle = cycle;
    
    NSString *resourcePath = nil;
    NSMutableDictionary *queryParams = [NSMutableDictionary dictionaryWithObjectsAndKeys:SUNLIGHT_APIKEY, @"apikey", self.queryCycle, @"cycle",nil];
    switch ([self.queryType integerValue]) {
        case kContributionQueryEntitySearch:
            [queryParams removeObjectForKey:@"cycle"];
            [queryParams setObject:aQuery forKey:@"search"];    
            resourcePath = @"/entities.json";
            break;
        case kContributionQueryTop10Donors:
            resourcePath = [NSString stringWithFormat:@"/aggregates/pol/%@/contributors.json", aQuery];
            break;
        case kContributionQueryTop10RecipientsIndiv:
            resourcePath = [NSString stringWithFormat:@"/aggregates/indiv/%@/recipient_pols.json", aQuery];
            break;
        case kContributionQueryTop10Recipients:
            resourcePath = [NSString stringWithFormat:@"/aggregates/org/%@/recipients.json", aQuery];
            break;
        case kContributionQueryRecipient:
        case kContributionQueryDonor:
        case kContributionQueryIndividual:
        default:
            resourcePath = [NSString stringWithFormat:@"/entities/%@.json", aQuery];;
            break;
    }
    RKLogDebug(@"Contributions resource path: %@", resourcePath);
    [[[SLFRestKitManager sharedRestKit] transClient] get:resourcePath queryParams:queryParams delegate:self];
}

- (NSString *)subtitleForEntity:(NSDictionary *)data {
    NSString *type = [[data valueForKey:@"type"] capitalizedString];    // politician/organization/individual
    NSString *state = [data valueForKeyPath:@"metadata.state"];         // TX
    NSString *partyID = [data valueForKeyPath:@"metadata.party"];       // R
    //NSString *seat = [data valueForKeyPath:@"metadata.seat"];         // state:lower
    //NSString *photoURL = [data valueForKeyPath:@"metadata.photo_url"];
    NSMutableString *subtitle = [NSMutableString string];
    if (!IsEmpty(state)) {
        [subtitle appendFormat:@"(%@",state];
        if (!IsEmpty(partyID))
            [subtitle appendFormat:@"-%@", partyID];
        [subtitle appendString:@") "];
    }
    if (!IsEmpty(type))
        [subtitle appendString:type];
    return subtitle;
}

- (NSString *)bioForEntity:(NSDictionary *)data {
    NSString *bio = [data valueForKeyPath:@"metadata.bio"];      // <p>Some bio text in html</p>
    if (!IsEmpty(bio)) {
        bio = [bio stringByReplacingOccurrencesOfString:@"<p>" withString:@""];
        bio = [bio stringByReplacingOccurrencesOfString:@"</p>" withString:@"\n"];
    }
    else
        bio = @"";
    return bio;
}

- (void)createTableHeaderDataForEntity:(NSDictionary *)data {
    self.tableHeaderData = nil;
    NSString *name = [[data valueForKey:@"name"] capitalizedString];
    _tableHeaderData = [[NSDictionary alloc] initWithObjectsAndKeys:
                       name, @"title", 
                       [self subtitleForEntity:data], @"subtitle", 
                       [self bioForEntity:data], @"detail", nil];
}

- (void)parseJSONObject:(id)jsonDeserialized {
    self.tableHeaderData = nil;
    
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle: NSNumberFormatterCurrencyStyle];
    [numberFormatter setMaximumFractionDigits:0];
    
    if (!self.sectionList)
        self.sectionList = [NSMutableArray array];
    
    if ([self.queryType integerValue] == kContributionQueryEntitySearch) {
        NSArray *jsonArray = jsonDeserialized;    
        
        // only one section right now
        [self.sectionList removeAllObjects];
        
        NSMutableArray *thisSection = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in jsonArray) {
            NSString *localizedString = NSLocalizedString(@"Unknown", @"");
            NSString *entityType = [[dict objectForKey:@"type"] capitalizedString];
            NSNumber *action = nil;
            if ([entityType isEqualToString:@"Politician"]) {
                localizedString = NSLocalizedString(@"Politician", @"");
                action = [NSNumber numberWithInteger:kContributionQueryRecipient];
            }
            else if ([entityType isEqualToString:@"Organization"]) {
                localizedString = NSLocalizedString(@"Organization", @"");
                action = [NSNumber numberWithInteger:kContributionQueryDonor];
            }
            else if ([entityType isEqualToString:@"Individual"]) {
                localizedString = NSLocalizedString(@"Individual", @"");
                action = [NSNumber numberWithInteger:kContributionQueryIndividual];
            }
            NSString *state = [dict valueForKey:@"state"];
            if (!IsEmpty(state)) {
                localizedString = [NSString stringWithFormat:@"%@ %@", state, localizedString];
            }
            
            TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
            cellInfo.title = [dict valueForKey:@"name"];
            cellInfo.subtitle = localizedString;
            cellInfo.entryValue = [dict objectForKey:@"id"];
            cellInfo.entryType = [self.queryType integerValue];
            cellInfo.isClickable = YES;
            cellInfo.action = action;
            cellInfo.parameter = @"-1";
            [thisSection addObject:cellInfo];
            [cellInfo release];
        }
        
        if (![jsonArray count]) {    // no search results!
            NSString *name = [self.queryEntityID stringByReplacingOccurrencesOfString:@"+" withString:@" "];
            TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
            cellInfo.title = name;
            cellInfo.subtitle = NSLocalizedString(@"Nothing for", @"");
            cellInfo.entryValue = nil;
            cellInfo.entryType = [self.queryType integerValue];
            cellInfo.isClickable = NO;
            cellInfo.action = nil;
            cellInfo.parameter = nil;
            [thisSection addObject:cellInfo];
            [cellInfo release];
        }
        [self.sectionList addObject:thisSection];
        [thisSection release];
        
    }
    else if ([self.queryType integerValue] == kContributionQueryTop10RecipientsIndiv) {
        NSArray *jsonArray = jsonDeserialized;    
        
        // only one section right now
        [self.sectionList removeAllObjects];
        
        NSMutableArray *thisSection = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in jsonArray) {
            double tempDouble = [[dict objectForKey:@"amount"] doubleValue];
            NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
            TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
            NSString *name = [[dict objectForKey:@"recipient_name"] capitalizedString];
            id dataID = [dict objectForKey:@"recipient_entity"];

            cellInfo.title = name;
            cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
            cellInfo.entryValue = dataID;
            cellInfo.entryType = [self.queryType integerValue];
            cellInfo.isClickable = YES;
            cellInfo.parameter = self.queryCycle;
            cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];

            if (!dataID || [[NSNull null] isEqual:dataID] || ![dataID isKindOfClass:[NSString class]]) {
                RKLogError(@"ERROR - Contribution results have an empty entity ID for: %@", name);                                

                NSString *nameSearch = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                cellInfo.entryValue = nameSearch;
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryEntitySearch];
            }
            [thisSection addObject:cellInfo];
            [cellInfo release];
        }
        
        [self.sectionList addObject:thisSection];
        [thisSection release];
        
    }
    else if (([self.queryType integerValue] == kContributionQueryTop10Donors) ||
        ([self.queryType integerValue] == kContributionQueryTop10Recipients)) {
        NSArray *jsonArray = jsonDeserialized;    
        
        // only one section right now
        [self.sectionList removeAllObjects];
        
        NSMutableArray *thisSection = [[NSMutableArray alloc] init];
        
        for (NSDictionary *dict in jsonArray) {
            double tempDouble = [[dict objectForKey:@"total_amount"] doubleValue];
            NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
            
            TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
            NSString *name = [[dict objectForKey:@"name"] capitalizedString];

            id dataID = [dict objectForKey:@"id"];
            
            cellInfo.title = name;
            cellInfo.subtitle = [numberFormatter stringFromNumber:amount];
            cellInfo.entryValue = dataID;
            cellInfo.entryType = [self.queryType integerValue];
            cellInfo.isClickable = YES;
            cellInfo.parameter = self.queryCycle;
            if ([self.queryType integerValue] == kContributionQueryTop10Donors)
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryDonor];
            else
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryRecipient];
            
            if (!dataID || [[NSNull null] isEqual:dataID] || ![dataID isKindOfClass:[NSString class]]) {
                RKLogError(@"ERROR - Contribution results have an empty entity ID for: %@", name);
                
                NSString *nameSearch = [name stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                cellInfo.entryValue = nameSearch;
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryEntitySearch];
            }
            [thisSection addObject:cellInfo];
            [cellInfo release];
        }
        
        [self.sectionList addObject:thisSection];
        [thisSection release];
        
    }
    else if ([self.queryType integerValue] == kContributionQueryRecipient ||
             [self.queryType integerValue] == kContributionQueryDonor ||
             [self.queryType integerValue] == kContributionQueryIndividual )
    {
        NSDictionary *jsonDict = jsonDeserialized;

        [self.sectionList removeAllObjects];
        NSMutableArray *thisSection = nil;
        
        NSDictionary *totals = [jsonDict objectForKey:@"totals"];
        NSArray *yearKeys = [totals allKeys]; 
        yearKeys = [yearKeys sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
        
        [self createTableHeaderDataForEntity:jsonDict];
                
        thisSection = [[NSMutableArray alloc] init];
        NSString *amountKey = ([self.queryType integerValue] == kContributionQueryRecipient) ? @"recipient_amount" : @"contributor_amount";

        for (NSString *yearKey in [yearKeys reverseObjectEnumerator]) {            
            TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
            NSDictionary *dict = [totals objectForKey:yearKey];
            double tempDouble = [[dict objectForKey:amountKey] doubleValue];
            NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
            cellInfo.subtitle = yearKey;
            cellInfo.title = [numberFormatter stringFromNumber:amount];
            cellInfo.entryValue = [jsonDict objectForKey:@"id"];
            cellInfo.entryType = [self.queryType integerValue];
            cellInfo.isClickable = YES;
            cellInfo.parameter = yearKey;
            
            if ([self.queryType integerValue] == kContributionQueryRecipient)
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10Donors];
            else if ([self.queryType integerValue] == kContributionQueryIndividual)
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10RecipientsIndiv];
            else
                cellInfo.action = [NSNumber numberWithInteger:kContributionQueryTop10Recipients];
            
            if ([yearKey isEqualToString:@"-1"]) {
                cellInfo.subtitle = NSLocalizedString(@"Total", @"");
            }
            [thisSection addObject:cellInfo];
            [cellInfo release];
        }
        
        [self.sectionList addObject:thisSection];
        [thisSection release];
    }
    
    [numberFormatter release];
    [pool drain];
}


#pragma mark -
#pragma mark Data Object Methods

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath)
        return nil;
    
    id tempEntry = nil;
    NSArray *group = [self.sectionList objectAtIndex:indexPath.section];
    if (group && [group count] > indexPath.row)
        tempEntry = [group objectAtIndex:indexPath.row];
        return tempEntry;
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
    if (!dataObject)
        return nil;
    
    NSInteger section = 0, row = 0;
    for (NSArray *group in self.sectionList) {
        for (id object in group) {
            if ([object isEqual:dataObject])
                return [NSIndexPath indexPathForRow:row inSection:section];
            row++;
        }
        section++;
    }
    return nil;
}


#pragma mark -
#pragma mark RestKit:RKObjectLoaderDelegate

- (void)request:(RKRequest*)request didFailLoadWithError:(NSError*)error {
    if (error && request) {
        RKLogError(@"Error loading from %@: %@", [request description], [error localizedDescription]);
        [SLFRestKitManager showFailureAlertWithRequest:request error:error];
        [[NSNotificationCenter defaultCenter] postNotificationName:kContributionsDataNotifyError object:nil];
    }
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {  
    if ([request isGET] && [response isOK]) {  
        id jsonDeserialized = [response.body mutableObjectFromJSONDataWithParseOptions:(JKParseOptionUnicodeNewlines & JKParseOptionLooseUnicode)];
        if (IsEmpty(jsonDeserialized))
            return;
        
        [self parseJSONObject:jsonDeserialized];
        [[NSNotificationCenter defaultCenter] postNotificationName:kContributionsDataNotifyLoaded object:self];
    }
    else {
        RKLogWarning(@"Status Code is %d", [response statusCode]);
        NSString *errorDescription = [NSString stringWithFormat:NSLocalizedString(@"An error occurred while loading results from the server: (Status Code = %d)", @""), [response statusCode]];
        NSError *error = [NSError errorWithDomain:@"Contributions Error" code:[response statusCode] userInfo:[NSDictionary dictionaryWithObject:errorDescription forKey:NSLocalizedDescriptionKey]];
        [self request:request didFailLoadWithError:error];
    }
}


@end
