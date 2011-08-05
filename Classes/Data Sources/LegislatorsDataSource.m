//
//  LegislatorsDataSource.m
//  Created by Gregory S. Combs on 5/31/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "LegislatorsDataSource.h"
#import "SLFLegislator.h"
#import "LegislatorCell.h"


@implementation LegislatorsDataSource

- (id)init {
	if ((self = [super initWithResourcePath:@"/legislators/" 
                                   objClass:[SLFLegislator class]
                                     sortBy:@"lastName"
                                    groupBy:@"lastnameInitial"])) {
    }
	return self;
}


- (void)dealloc { 
    [super dealloc];
}


- (NSDictionary *)queryParameters {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.stateID, @"state",
            @"true", @"active",
            SUNLIGHT_APIKEY, @"apikey",
            nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *leg_cell_ID = @"LegislatorQuartz";		
		
	LegislatorCell *cell = (LegislatorCell *)[tableView dequeueReusableCellWithIdentifier:leg_cell_ID];
	
	if (cell == nil) {
		cell = [[[LegislatorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:leg_cell_ID] autorelease];
		cell.frame = CGRectMake(0.0, 0.0, 320.0, 73.0);
	}
    cell.cellView.useDarkBackground = (indexPath.row % 2 == 0);
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);

    SLFLegislator *dataObj = [self dataObjectForIndexPath:indexPath];
	if (dataObj == nil) {
		RKLogError(@"cellForRowAtIndexPath -> Couldn't get legislator data for row.");
        return cell;
	}
    
	[cell setLegislator:dataObj];
	
	return cell;	
}

@end
