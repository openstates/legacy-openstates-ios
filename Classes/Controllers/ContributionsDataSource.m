//
//  ContributionsDataSource.m
//  Created by Gregory Combs on 9/16/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
// TODO: Consider moving this whole class to Core Data

#import "ContributionsDataSource.h"
#import "SLFTheme.h"
#import "SLFRestKitManager.h"
#import "JSONKit.h"
#import "SLFStandardGroupCell.h"

@interface ContributionsDataSource()
- (void)parseJSONObject:(id)jsonDeserialized;
- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath;
- (NSIndexPath *)indexPathForDataObject:(id)dataObject;
@end

@implementation ContributionsDataSource
@synthesize sectionList, queryEntityID, queryType, queryCycle;

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
    [super dealloc];
}

#pragma mark -
#pragma mark UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {    
    if (!IsEmpty(self.sectionList))
        return [self.sectionList count];
    else
        return 0;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
    return index;
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    if (self.sectionList) {
        NSArray *group = [self.sectionList objectAtIndex:section];
        if (group)
            count = [group count];
    }
    return count;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {
    NSString *title = NSLocalizedString(@"Contributions",@"");
    
    switch ([self.queryType integerValue]) {
        case kContributionQueryRecipient:
            title = (section == 0) ? 
                NSLocalizedString(@"Recipient Information", @"")
                    : NSLocalizedString(@"Aggregate Contributions", @"");
            break;
        case kContributionQueryDonor: 
        case kContributionQueryIndividual:
            title = (section == 0) ? 
                NSLocalizedString(@"Contributor Information", @"")
                    : NSLocalizedString(@"Contributions (to everyone)", @"");
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
    SLFAlternateCellForIndexPath(cell, indexPath);    
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


- (void)parseJSONObject:(id)jsonDeserialized {
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
            //NSString *valueKey = @"";
            NSNumber *action = nil;
            if ([entityType isEqualToString:@"Politician"]) {
                //valueKey = @"total_received";
                localizedString = NSLocalizedString(@"Politician", @"");
                action = [NSNumber numberWithInteger:kContributionQueryRecipient];
            }
            else if ([entityType isEqualToString:@"Organization"]) {
                //valueKey = @"total_given";
                localizedString = NSLocalizedString(@"Organization", @"");
                action = [NSNumber numberWithInteger:kContributionQueryDonor];
            }
            else if ([entityType isEqualToString:@"Individual"]) {
                //valueKey = @"total_given";
                localizedString = NSLocalizedString(@"Individual", @"");
                action = [NSNumber numberWithInteger:kContributionQueryIndividual];
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
        
        TableCellDataObject *cellInfo = [[TableCellDataObject alloc] init];
        cellInfo.title = [[jsonDict objectForKey:@"name"] capitalizedString];
        cellInfo.subtitle = [[jsonDict objectForKey:@"type"] capitalizedString];
        cellInfo.entryValue = [jsonDict objectForKey:@"id"];
        cellInfo.entryType = [self.queryType integerValue];
         cellInfo.isClickable = NO;
        cellInfo.action = nil;
        cellInfo.parameter = self.queryCycle;
        
        thisSection = [NSMutableArray arrayWithObject:cellInfo];
        [self.sectionList addObject:thisSection];
        [cellInfo release];
        
        thisSection = [[NSMutableArray alloc] init];
        NSString *amountKey = ([self.queryType integerValue] == kContributionQueryRecipient) ? @"recipient_amount" : @"contributor_amount";

        for (NSString *yearKey in [yearKeys reverseObjectEnumerator]) {            
            NSDictionary *dict = [totals objectForKey:yearKey];
            double tempDouble = [[dict objectForKey:amountKey] doubleValue];
            NSNumber *amount = [NSNumber numberWithDouble:tempDouble];
            cellInfo = [[TableCellDataObject alloc] init];
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
                //cellInfo.entryType = kContributionTotal;
                //cellInfo.isClickable = NO;
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
    else
        RKLogWarning(@"Status Code is %d", [response statusCode]);
  
}


@end
