//
//  CommitteesDataSource.m
//  Created by Gregory S. Combs on 5/31/09.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "CommitteesDataSource.h"
#import "SLFCommittee.h"
#import "LegislatorCell.h"

#import "TexLegeTheme.h"
#import "DisclosureQuartzView.h"

@implementation CommitteesDataSource

- (id)init {
	if ((self = [super initWithResourcePath:@"/committees/" 
                                   objClass:[SLFCommittee class]
                                     sortBy:@"committeeName"
                                    groupBy:@"committeeNameInitial"])) {
    }
	return self;
}


- (void)dealloc { 
    [super dealloc];
}


- (NSDictionary *)queryParameters {
    return [[NSDictionary alloc] initWithObjectsAndKeys:
            self.stateID, @"state",
            SUNLIGHT_APIKEY, @"apikey",
            nil];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	SLFCommittee *dataObj = [self dataObjectForIndexPath:indexPath];
	if (dataObj == nil) {
		RKLogError(@"cellForRowAtIndexPath -> Couldn't get committee data for row.");
		return nil;
	}
	static NSString *commsCellID = @"Committees";		
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:commsCellID];
	
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:commsCellID] autorelease];
        
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.font =		[TexLegeTheme boldTwelve];
		cell.textLabel.textColor =	[TexLegeTheme accent];
		cell.detailTextLabel.font = [TexLegeTheme boldFifteen];
		cell.detailTextLabel.textColor = 	[TexLegeTheme textDark];
        cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		cell.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		cell.detailTextLabel.minimumFontSize = 12.0f;
        
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		cell.accessoryView = qv;
		[qv release];
	}
	
	cell.detailTextLabel.text = [dataObj.committeeName capitalizedString];
	cell.textLabel.text = chamberStringFromOpenStates(dataObj.chamber);

	cell.backgroundColor = (indexPath.row % 2 == 0) ? [TexLegeTheme backgroundDark] : [TexLegeTheme backgroundLight];
	cell.accessoryView.hidden = (tableView == self.searchDisplayController.searchResultsTableView);
	
	return cell;	
}

@end
