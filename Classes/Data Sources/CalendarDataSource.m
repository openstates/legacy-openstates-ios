//
//  CalendarDataSource.m
//  Created by Gregory Combs on 7/27/10.
//  Copyright (c) 2010 Gregory S. Combs. All rights reserved.
//

#import "CalendarDataSource.h"
#import "UtilityMethods.h"
#import "TexLegeTheme.h"
#import "SLFDataModels.h"
#import "TexLegeStandardGroupCell.h"

enum EventTypes {
    kCommitteeMeetingType = 0,
    NUM_ROWS
};

@interface CalendarDataSource()
@end


@implementation CalendarDataSource
@synthesize resourcePath;
@synthesize resourceClass;
@synthesize stateID;    


- (BOOL)usesCoreData
{ return NO; }


- (id)init {
	if ((self = [super init])) {
        self.resourcePath = @"/events/";
        self.resourceClass = [SLFEvent class];
	}
	return self;
}

- (void)dealloc {
    self.resourcePath = nil;
    self.stateID = nil;
	[super dealloc];
}

- (void)setStateID:(NSString *)newID {
    [stateID release];
    stateID = [newID copy];
    if (newID) {
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotifyTableDataUpdated object:self];
    }
}


- (id) dataObjectForIndexPath:(NSIndexPath *)indexPath {
    if (!indexPath)
		return nil;
       
    // One way or another, there's only one type of event right now.
    
    TableCellDataObject *obj = [[TableCellDataObject alloc] init];
    obj.indexPath = indexPath;
    
    if (!self.stateID) {   // should never happen
        obj.indexPath = indexPath;

        obj.title = NSLocalizedStringFromTable(@"No State is Selected", @"StandardUI", @"");
        obj.entryType = DirectoryTypeNone;
        obj.isClickable = NO;
        return [obj autorelease];
    }
    
    SLFState *state = [SLFState findFirstByAttribute:@"abbreviation" withValue:self.stateID];

    if (!state || NO == [state isFeatureEnabled:@"events"]) {
        obj.title = NSLocalizedStringFromTable(@"Events aren't available for this state", @"StandardUI", @"");
        obj.entryType = DirectoryTypeNone;
        obj.isClickable = NO;
    }
    else {
        obj.title = NSLocalizedStringFromTable(@"Committee Meetings", @"DataTableUI", @"Menu item to display upcoming calendar events in a legislative chamber");
        obj.subtitle = NSLocalizedStringFromTable(@"Events", @"StandardUI", @"");
        obj.entryType = DirectoryTypeEvents;
        obj.entryValue = @"committee:meeting";    // we'll use it in our filter query to pick only committe meetings
        obj.isClickable = YES;
    }
    
	return [obj autorelease];
}

- (NSIndexPath *)indexPathForDataObject:(id)dataObject {
    if (dataObject && [dataObject respondsToSelector:@selector(indexPath)])
        return [dataObject performSelector:@selector(indexPath)];
    
	return nil;
}


#pragma mark -
#pragma mark UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{			
    TableCellDataObject *cellData = [self dataObjectForIndexPath:indexPath];

    NSString *cellID = [TexLegeStandardGroupCell cellIdentifier];
    if (!cellData.isClickable)
        cellID = [cellID stringByAppendingString:@"-OFF"];
    
	/* Look up cell in the table queue */
    TexLegeStandardGroupCell *cell = (TexLegeStandardGroupCell *)[tableView dequeueReusableCellWithIdentifier:cellID];
	
    if (cell == nil) {
        cell = [[[TexLegeStandardGroupCell alloc] initWithStyle:[TexLegeStandardGroupCell cellStyle] reuseIdentifier:cellID] autorelease];		
    }

	BOOL useDark = (indexPath.row % 2 == 0);
	cell.backgroundColor = useDark ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
		
    cell.cellInfo = cellData;
		
	return cell;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{		
	return NUM_ROWS;
}



@end
