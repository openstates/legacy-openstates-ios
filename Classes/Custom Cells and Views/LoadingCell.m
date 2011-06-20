//
//  LoadingCell.m
//  TexLege
//
//  Created by Gregory Combs on 4/3/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import "LoadingCell.h"
#import "TexLegeTheme.h"

@implementation LoadingCell

+ (LoadingCell *)loadingCellWithStatus:(NSInteger)loadingStatus tableView:(UITableView *)tableView {
	
	NSString *loadingCellIdentifier = [NSString stringWithFormat:@"LOADING_CELL_%d", loadingStatus];
	LoadingCell *loadingCell = (LoadingCell *)[tableView dequeueReusableCellWithIdentifier:loadingCellIdentifier];
	if (loadingCell == nil)
	{
		loadingCell = [[[LoadingCell alloc] initWithStyle:UITableViewCellStyleDefault 
											  reuseIdentifier:loadingCellIdentifier] autorelease];		
		
		if (loadingStatus == LOADING_ACTIVE) {
			loadingCell.textLabel.text = NSLocalizedStringFromTable(@"Contacting Server", @"StandardUI", @"Notifies the user that data is currently loading");
			UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:
												 UIActivityIndicatorViewStyleWhiteLarge];
			activity.hidesWhenStopped = YES;
			[activity startAnimating];
			loadingCell.accessoryView = activity;
			[activity release];
		}
		else { // (loadingStatus == LOADING_NO_NET)
			loadingCell.textLabel.text = NSLocalizedStringFromTable(@"Network Connection Unavailable", @"StandardUI", @"");
			UIImageView *errorView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24.f, 24.f)];
			errorView.image = [UIImage imageNamed:@"error"];
			loadingCell.accessoryView = errorView;
			[errorView release];
		}
		
		loadingCell.selectionStyle = UITableViewCellSelectionStyleNone;
		loadingCell.textLabel.textColor = [TexLegeTheme textDark];
		loadingCell.textLabel.font = [TexLegeTheme boldFourteen];
	}
	return loadingCell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code.
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    return;
    //[super setSelected:selected animated:animated];
    
    // Configure the view for the selected state.
}


- (void)dealloc {
    [super dealloc];
}


@end
