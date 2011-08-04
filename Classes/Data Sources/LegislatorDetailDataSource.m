//
//  LegislatorDetailDataSource.m
//  Created by Gregory S. Combs on 8/3/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorDetailDataSource.h"
#import "SLFMappingsManager.h"
#import "SLFDataModels.h"

#import "TableDataSourceProtocol.h"
#import "TexLegeTheme.h"
#import "UtilityMethods.h"
#import "TableCellDataObject.h"
#import "TexLegeStandardGroupCell.h"
#import "NotesViewController.h"

enum SECTIONS {
    kMemberInfo = 0,
    kDistrictMap,
    kCommittees,
    kBills,
    kNumSections
};

@implementation LegislatorDetailDataSource

- (id)initWithDetailObjectID:(NSString *)newID {
    NSString *newPath = @"/legislators/";
    if (newID) {
        newPath = [newPath stringByAppendingFormat:@"%@/", newID];
    }
        
    if ((self = [super initWithResourcePath:newPath
                                   objClass:[SLFLegislator class]
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
    NSString *newPath = @"/legislators/";
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
		
        mappableData = [SLFMappingsManager premapLegislator:self.detailObject withMappableData:mappableData];
        
	}
}

#pragma mark -
#pragma mark Data Object Methods

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath || !self.detailObject || ![self.detailObject isKindOfClass:self.resourceClass])
		return nil;
    
    SLFLegislator *legislator = self.detailObject;
    
    TableCellDataObject *obj = [[TableCellDataObject alloc] init];
    obj.indexPath = indexPath;
    
    switch (indexPath.section) {
        case kCommittees:
        {
            NSArray *sortedPos = legislator.sortedPositions;
            if (indexPath.row < [sortedPos count]) {
                SLFCommitteePosition *position = [sortedPos objectAtIndex:indexPath.row];
                if (position) {
                    obj.title       = position.committeeName;
                    obj.subtitle    = position.positionType;
                    obj.entryValue  = position.committeeID;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeCommittee;
                }
            }
        }
            break;
            
        case kDistrictMap:
        {
            SLFDistrictMap *map = legislator.hydratedDistrictMap;
            NSString *mapID = nil;
            
            if (map)
                mapID = map.slug;
            else
                mapID = legislator.districtMapSlug;
            
            obj.subtitle    = NSLocalizedStringFromTable(@"Map", @"DataTableUI", @"Title for cell");
            obj.title       = NSLocalizedStringFromTable(@"District Map", @"DataTableUI", @"Title for cell");
            obj.entryValue  = mapID;
            obj.isClickable = YES;
            obj.entryType   = DirectoryTypeMap;            
        }
            break;
            
        case kBills: 
        {
            obj.subtitle    = NSLocalizedStringFromTable(@"Legislation", @"DataTableUI", @"Title for cell");
            obj.title       = NSLocalizedStringFromTable(@"Authored Bills", @"DataTableUI", @"Title for cell");
            obj.entryValue  = legislator.legID;
            obj.isClickable = YES;
            obj.entryType   = DirectoryTypeBills;            
        }
            break;
            
        case kMemberInfo:   // The Legislator's Info (contact, bio, etc)
        default:
        {
            switch (indexPath.row) 
            {
                case 0: 
                {
                    obj.title       = legislator.fullName;
                    obj.subtitle    = NSLocalizedStringFromTable(@"Name", @"DataTableUI", @"Title for cell");
                    obj.entryValue  = legislator.fullName;
                    obj.isClickable = NO;
                    obj.entryType   = DirectoryTypeNone;            
                }
                    break;
                    
                case 1: 
                {
                    obj.title       = NSLocalizedStringFromTable(@"Campaign Contributions", @"DataTableUI", @"title for cell");
                    obj.subtitle    = NSLocalizedStringFromTable(@"Finances", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = legislator.transparencyID;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeContributions;
                }
                    break;
                    
                case 2:
                {
                    NSString *url   = [legislator.sources count] ? [legislator.sources objectAtIndex:0] : nil;
                    
                    obj.title       = NSLocalizedStringFromTable(@"Official Website", @"DataTableUI", @"Title for Cell");
                    obj.subtitle    = NSLocalizedStringFromTable(@"Web", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = url;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeWeb;
                }
                    break;
                    
                case 3:
                {
                    obj.title       = NSLocalizedStringFromTable(@"Votesmart Bio", @"DataTableUI", @"Title for Cell");
                    obj.subtitle    = NSLocalizedStringFromTable(@"Web", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@",legislator.votesmartID];
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeWeb;
                }
                    break;
                    
                case 4:
                default:
                {
                    [[NSUserDefaults standardUserDefaults] synchronize];	
                    NSDictionary *storedNotesDict = [[NSUserDefaults standardUserDefaults] valueForKey:@"LEGE_NOTES"];
                    NSString *storedNotes = nil;
                    
                    if (storedNotesDict) 
                        storedNotes = [storedNotesDict valueForKey:legislator.legID];
                    
                    if (IsEmpty(storedNotes))
                        storedNotes = kStaticNotes;
                    
                    obj.title       = storedNotes;
                    obj.subtitle    = NSLocalizedStringFromTable(@"Notes", @"DataTableUI", @"Title for the cell indicating custom notes option");
                    obj.entryValue  = storedNotes;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeNotes;
                }
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
    
    SLFLegislator *legislator = self.detailObject;
    
    switch (section) {
        case kCommittees:
            rows = [legislator.positions count];
            break;
        case kDistrictMap:
            rows = 1;
            break;
        case kBills:
            rows = 1;
            break;
        case kMemberInfo:
        default:
            rows = 5;
            break;
    }
    
	return rows;
}

- (NSString *)tableView:(UITableView *)aTableView titleForHeaderInSection:(NSInteger)section {	
	NSString *title = nil;
	
	switch (section) {
        case kDistrictMap:
			title = NSLocalizedStringFromTable(@"District", @"DataTableUI", @"Cell title");;
            break;
		case kCommittees:
			title = NSLocalizedStringFromTable(@"Committee Assignments", @"DataTableUI", @"Cell title");;
			break;
		case kBills:
			title = NSLocalizedStringFromTable(@"Bills", @"DataTableUI", @"Cell title");;
			break;
		case kMemberInfo:
        default:
			title = NSLocalizedStringFromTable(@"Legislator Information", @"DataTableUI", @"Cell title");
			break;
	}
	return title;
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
    
	TableCellDataObject *cellInfo = [self dataObjectForIndexPath:indexPath];
    
    if (cellInfo == nil) {
		RKLogError(@"cellForRowAtIndexPath -> Couldn't get legislator detail for index path: %@", indexPath);
		return nil;
	}
    
	NSString *stdCellID = [TexLegeStandardGroupCell cellIdentifier];
	if (cellInfo.entryType == DirectoryTypeNotes)
		stdCellID = @"TexLegeNotesGroupCell";
    
	NSString *cellIdentifier = [NSString stringWithFormat:@"%@-%d", stdCellID, cellInfo.isClickable];
	
	/* Look up cell in the table queue */
	TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[aTableView dequeueReusableCellWithIdentifier:cellIdentifier];
	
	/* Not found in queue, create a new cell object */
    if (cell == nil) {
		cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:[TexLegeStandardGroupCell cellStyle] reuseIdentifier:cellIdentifier] autorelease];
    }
    
    cell.cellInfo = cellInfo;
    
	if (cellInfo.entryType == DirectoryTypeNotes) {
		if (![cellInfo.entryValue isEqualToString:kStaticNotes])
			cell.detailTextLabel.textColor = [UIColor blackColor];
		else
			cell.detailTextLabel.textColor = [UIColor grayColor];
	}
	
	[cell sizeToFit];
	[cell setNeedsDisplay];
	
    //cell.cellView.useDarkBackground = (indexPath.row % 2 == 0);

	return cell;
	
}

@end
