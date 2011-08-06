//
//  CommitteeDetailDataSource.m
//  Created by Gregory S. Combs on 8/6/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteeDetailDataSource.h"
#import "SLFMappingsManager.h"
#import "SLFDataModels.h"

#import "TableDataSourceProtocol.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "TexLegeStandardGroupCell.h"
#import "LegislatorCell.h"

enum SECTIONS {
    kCommitteeInfo = 0,
    kMembers,
    kNumSections
};

@implementation CommitteeDetailDataSource

- (id)initWithDetailObjectID:(NSString *)newID {
    NSString *newPath = @"/committees/";
    if (newID) {
        newPath = [newPath stringByAppendingFormat:@"%@/", newID];
    }
    
    if ((self = [super initWithResourcePath:newPath
                                   objClass:[SLFCommittee class]
                                     sortBy:nil
                                    groupBy:nil])) {
        self.detailObjectID = newID;
        self.hideTableIndex = YES;
    }
	return self;    
}

- (void) dealloc {
    [super dealloc];
}

- (NSDictionary *)queryParameters {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            SUNLIGHT_APIKEY, @"apikey",
            nil];
}

- (NSString *)buildResourcePathWithObjectID:(NSString *)newID {
    NSString *newPath = @"/committees/";
    if (newID)
        newPath = [newPath stringByAppendingFormat:@"%@/", newID];
    
    return newPath;
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
    if (![object isKindOfClass:self.resourceClass]) {
        RKLogError(@"Received incorrect data object! ... %@", object);
        return;
    }
    
    self.detailObject = object;
    
        //[self willChangeValueForKey:"detailObject"];
        //[detailObject release];
        //detailObject = [object retain];
        //[self didChangeValueForKey:@"detailObject"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
    
}


- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
	
	if (loader.objectMapping.objectClass == self.resourceClass) {
		
        mappableData = [SLFMappingsManager premapCommittee:self.detailObject withMappableData:mappableData];
        
	}
}


#pragma mark -
#pragma mark Data Object Methods

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath || !self.detailObject || ![self.detailObject isKindOfClass:self.resourceClass])
		return nil;
    
    SLFCommittee *committee = self.detailObject;
    
    TableCellDataObject *obj = [[TableCellDataObject alloc] init];
    obj.indexPath = indexPath;
    
    switch (indexPath.section) {
        case kMembers:
        {
            NSArray *sortedPos = committee.sortedMembers;
            if (indexPath.row < [sortedPos count]) {
                SLFCommitteePosition *position = [sortedPos objectAtIndex:indexPath.row];
                if (position) {
                    obj.title       = position.legislatorName;
                    obj.subtitle    = position.positionType;
                    obj.entryValue  = position.legID;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeLegislator;
                }
            }
        }
            break;
            
        case kCommitteeInfo:
        default:
        {
            switch (indexPath.row) 
            {
                case 0: 
                {
                    obj.title       = committee.committeeName;
                    obj.subtitle    = NSLocalizedStringFromTable(@"Name", @"DataTableUI", @"Title for cell");
                    obj.entryValue  = committee.committeeName;
                    obj.isClickable = NO;
                    obj.entryType   = DirectoryTypeNone;            
                }
                    break;
                    
                case 1: 
                {
                    obj.title       = chamberStringFromOpenStates(committee.chamber);
                    obj.subtitle    = NSLocalizedStringFromTable(@"Chamber", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = committee.chamber;
                    obj.isClickable = NO;
                    obj.entryType   = DirectoryTypeNone;
                }
                    break;
                    
                case 2:
                {
                    NSString *url   = [committee.sources count] ? [committee.sources objectAtIndex:0] : nil;
                    
                    obj.title       = NSLocalizedStringFromTable(@"Official Website", @"DataTableUI", @"Title for Cell");
                    obj.subtitle    = NSLocalizedStringFromTable(@"Web", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = url;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeWeb;
                }
                    break;
                    
                default:
                    break;
                    
            }
        }
            break;
    }    
    
    return [obj autorelease];
}

- (NSIndexPath *)indexPathForDataObject:(id)inObject {
	
    if (inObject && [inObject respondsToSelector:@selector(indexPath)])
        return [inObject performSelector:@selector(indexPath)];
    
	return nil;
}



#pragma mark -
#pragma mark Indexing / Sections


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {	
	return kNumSections;	
}

    // This is for the little index along the right side of the table ... use nil if you don't want it.
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return  nil ;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return index; // index ..........
}

- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section {
    
    if (!self.detailObject || ![self.detailObject isKindOfClass:self.resourceClass])
        return 0;
    
    NSInteger rows = 0;
    
    SLFCommittee *committee = self.detailObject;
    
    switch (section) {
        case kMembers:
            rows = [committee.positions count];
            break;
        case kCommitteeInfo:
            rows = 3;
            break;
        default:
            break;
    }
    
	return rows;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {	
	NSString *title = nil;
	
	switch (section) {
		case kMembers:
			title = NSLocalizedStringFromTable(@"Committee Members", @"DataTableUI", @"Cell title");;
			break;
		case kCommitteeInfo:
        default:
			title = NSLocalizedStringFromTable(@"Committee Information", @"DataTableUI", @"Cell title");
			break;
	}
	return title;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
    BOOL useDark = NO;
    BOOL isMember = (indexPath.section == kMembers);

	TableCellDataObject *cellInfo = [self dataObjectForIndexPath:indexPath];
    
    if (cellInfo == nil) {
		RKLogError(@"Couldn't get committee detail for index path: %@", indexPath);
		return nil;
	}
        
	NSString *cellIdentifier;
    if (isMember) {
		useDark = (indexPath.row % 2 != 0);
		
		if (useDark)
			cellIdentifier = @"CommitteeMemberDark";
		else
			cellIdentifier = @"CommitteeMemberLight";
        
	} else {
        cellIdentifier = [NSString stringWithFormat:@"%@-%d", [TexLegeStandardGroupCell cellIdentifier], cellInfo.isClickable];
    }
	
	/* Look up cell in the table queue */
	UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
		if (isMember) {
			LegislatorCell *newcell = [[[LegislatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
			if ([UtilityMethods isIPadDevice]) {
				newcell.cellView.wideSize = YES;
			}
			newcell.frame = CGRectMake(0.0, 0.0, newcell.cellSize.width, kCommitteeMemberCellHeight);		
			newcell.accessoryView.hidden = NO;
			cell = newcell;
		} else {
            cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:[TexLegeStandardGroupCell cellStyle] reuseIdentifier:cellIdentifier] autorelease];
        }
    }
    
    cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];

    if ([cell respondsToSelector:@selector(setCellInfo:)])
        [cell performSelector:@selector(setCellInfo:) withObject:cellInfo];
    	
    if (cellInfo.entryType == DirectoryTypeLegislator && [cell isKindOfClass:[LegislatorCell class]]) {
 		LegislatorCell *newcell = (LegislatorCell *)cell;
        newcell.cellView.useDarkBackground = useDark;

        NSArray *memberList = [self.detailObject sortedMembers];
        
        if (indexPath.row < [memberList count]) {
            SLFCommitteePosition* pos = [memberList objectAtIndex:indexPath.row];
            [newcell setLegislator:pos.legislator];
            newcell.role = cellInfo.subtitle;
        }
    }
	[cell sizeToFit];
	[cell setNeedsDisplay];
	
    
	return cell;
	
}

@end
