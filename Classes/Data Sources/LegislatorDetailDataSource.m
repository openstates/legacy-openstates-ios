//
//  LegislatorDetailDataSource.m
//  Created by Gregory Combs on 8/29/10.
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

@interface LegislatorDetailDataSource()

- (void)loadDataFromDataStoreWithID:(NSString *)objID;

@end


@implementation LegislatorDetailDataSource
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize legislator;
@synthesize dataObjectID;

- (id)initWithLegislatorID:(NSString *)legislatorID {
    if ((self = [super init])) {
        
        self.dataObjectID = legislatorID;

        self.resourceClass = [SLFLegislator class];
        self.resourcePath = [NSString stringWithFormat:@"/legislators/%@/", legislatorID];
        
        [self loadDataFromDataStoreWithID:legislatorID];
        [self loadData];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
												 selector:@selector(stateChanged:) 
                                                     name:kStateMetaNotifyStateLoaded 
                                                   object:nil];        
        
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    self.legislator = nil;
    self.resourcePath = nil;
	self.dataObjectID = nil;
	
    [super dealloc];
}

#pragma mark -
#pragma mark Load Data

- (void)loadDataFromDataStoreWithID:(NSString *)objID {
	self.legislator = [SLFLegislator findFirstByAttribute:@"legID" withValue:objID];
}

- (void)loadData {
	if (!self.resourcePath)
		return;
	
    // Load the object model via RestKit	
    RKObjectManager* objectManager = [RKObjectManager sharedManager];
    RKObjectMapping* legMapping = [objectManager.mappingProvider objectMappingForClass:self.resourceClass];
    
	NSDictionary *queryParams = [NSDictionary dictionaryWithObjectsAndKeys:
								 SUNLIGHT_APIKEY, @"apikey",
								 nil];
	NSString *newPath = [self.resourcePath appendQueryParams:queryParams];
    [objectManager loadObjectsAtResourcePath:newPath objectMapping:legMapping delegate:self];
}

#pragma mark -
#pragma mark Data Object

- (void)stateChanged:(NSNotification *)notification {
    SLFLegislator *leg = [self legislator];
    if (leg) {
        [self setLegislator:leg];
    }
}


- (SLFLegislator *)legislator {
	SLFLegislator *anObject = nil;
	if (self.dataObjectID) {
		@try {
			anObject = [SLFLegislator findFirstByAttribute:@"legID" withValue:self.dataObjectID];
		}
		@catch (NSException * e) {
		}
	}
	return anObject;
}

- (void)setLegislator:(SLFLegislator *)newObj {
	[legislator release];
	legislator = [newObj retain];
	
	if (newObj) {
        self.resourcePath = RKMakePathWithObject(@"/legislators/(legID)/", newObj);
		[self loadData];
	}
}

#pragma mark -
#pragma mark RKObjectLoaderDelegate methods

- (void)objectLoader:(RKObjectLoader*)objectLoader didLoadObject:(id)object {
	[[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"LastUpdatedAt"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    
	[legislator release];
	legislator = [object retain];
        
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
    
}

- (void)objectLoader:(RKObjectLoader*)objectLoader didFailWithError:(NSError*)error {
	UIAlertView* alert = [[[UIAlertView alloc] initWithTitle:@"Error" 
                                                     message:[error localizedDescription] 
                                                    delegate:nil 
                                           cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
	[alert show];
	NSLog(@"Hit error: %@", error);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataError object:self];

}

- (void)objectLoader:(RKObjectLoader*)loader willMapData:(inout id *)mappableData {
	
	if (loader.objectMapping.objectClass == self.resourceClass) {
		
        [SLFMappingsManager premapLegislator:self.legislator toComitteesWithData:mappableData];
        
	}
}

#pragma mark -
#pragma mark Data Object Methods

- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
	if (!indexPath)
		return nil;
    
    TableCellDataObject *obj = [[TableCellDataObject alloc] init];
    obj.indexPath = indexPath;

    switch (indexPath.section) {
        case kCommittees:
        {
            NSArray *sortedPos = self.legislator.sortedPositions;
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
            SLFDistrictMap *map = self.legislator.hydratedDistrictMap;
            NSString *mapID = nil;
            
            if (map)
                mapID = map.slug;
            else
                mapID = self.legislator.districtMapSlug;

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
            obj.entryValue  = self.legislator.legID;
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
                    obj.title       = self.legislator.fullName;
                    obj.subtitle    = NSLocalizedStringFromTable(@"Name", @"DataTableUI", @"Title for cell");
                    obj.entryValue  = self.legislator.fullName;
                    obj.isClickable = NO;
                    obj.entryType   = DirectoryTypeNone;            
                }
                    break;
                    
                case 1: 
                {
                    obj.title       = NSLocalizedStringFromTable(@"Campaign Contributions", @"DataTableUI", @"title for cell");
                    obj.subtitle    = NSLocalizedStringFromTable(@"Finances", @"DataTableUI", @"Title for Cell");
                    obj.entryValue  = self.legislator.transparencyID;
                    obj.isClickable = YES;
                    obj.entryType   = DirectoryTypeContributions;
                }
                    break;
                    
                case 2:
                {
                    NSString *url = [self.legislator.sources count] ? [self.legislator.sources objectAtIndex:0] : nil;
                    
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
                    obj.entryValue  = [NSString stringWithFormat:@"http://votesmart.org/bio.php?can_id=%@",self.legislator.votesmartID];
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
                        storedNotes = [storedNotesDict valueForKey:self.legislator.legID];

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

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
	
    if (dataObject && [dataObject respondsToSelector:@selector(indexPath)])
        return [dataObject performSelector:@selector(indexPath)];

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
    NSInteger rows = 0;
    
    switch (section) {
        case kCommittees:
            rows = [self.legislator.positions count];
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


#pragma mark -
#pragma mark UITableViewDataSource methods


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{		
		
	TableCellDataObject *cellInfo = [self dataObjectForIndexPath:indexPath];
		
	if (cellInfo == nil) {
		debug_NSLog(@"LegislatorDetailDataSource:cellForRow: error finding table entry for section:%d row:%d", indexPath.section, indexPath.row);
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
	else if (cellInfo.entryType == DirectoryTypeMap) {
			cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
			cell.detailTextLabel.numberOfLines = 4;
	}			
	
	[cell sizeToFit];
	[cell setNeedsDisplay];
	
	return cell;
	
}

@end
