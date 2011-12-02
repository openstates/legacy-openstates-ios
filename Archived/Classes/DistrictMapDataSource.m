//
//  DistrictMapDataSource.m
//  Created by Gregory Combs on 8/23/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "DistrictMapDataSource.h"
#import "SLFDataModels.h"
#import "LegislatorCell.h"
#import "UtilityMethods.h"
#import "TexLegeStandardGroupCell.h"

@implementation DistrictMapDataSource

- (id)init {
    self = [super initWithObjClass:[SLFDistrict class]
            groupBy:@"chamber"];
            // sortBy:@"legislators.lastName"
            // groupBy:@"legislators.lastnameInitial"];
	if (self) {
    }
	return self;
}


- (void)dealloc { 
    [super dealloc];
}

- (NSString *)resourcePath {
    NSString *rootPath = @"/districts/";
    if (self.stateID)
        return [NSString stringWithFormat:@"%@%@/", rootPath, self.stateID];
    return rootPath;
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
    
    SLFDistrict *mapObj = [self dataObjectForIndexPath:indexPath];
	if (mapObj == nil) {
		RKLogError(@"cellForRowAtIndexPath -> Couldn't get data for row.");
        return cell;
	}
    
    if (!IsEmpty(mapObj.legislators)) {
        SLFLegislator *dataObj = [mapObj.legislators anyObject];
        [cell setLegislator:dataObj];
    }
	else {
        TexLegeStandardGroupCell *genericCell = [[[TexLegeStandardGroupCell alloc] initWithStyle:[TexLegeStandardGroupCell cellStyle] reuseIdentifier:[TexLegeStandardGroupCell cellIdentifier]] autorelease];
        cell.textLabel.text = mapObj.title;
        return genericCell;
    }
	return cell;	
}

@end
