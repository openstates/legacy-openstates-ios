//
//  TexLegeStandardGroupCell.m
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import "TexLegeStandardGroupCell.h"
#import "DirectoryDetailInfo.h"
#import "TexLegeTheme.h"

@implementation TexLegeStandardGroupCell
@synthesize cellInfo;

+ (NSString *)cellIdentifier {
	return @"TexLegeStandardGroupCell";
}

+ (UITableViewCellStyle)cellStyle {
	return UITableViewCellStyleValue2;
	//return UITableViewCellStyleSubtitle;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	

		self.detailTextLabel.font =			[TexLegeTheme boldTwelve];
		self.textLabel.font =				[TexLegeTheme boldTen];
		self.detailTextLabel.textColor = 	[TexLegeTheme textDark];
		self.textLabel.textColor =			[TexLegeTheme accent];
		
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.minimumFontSize = 12.0f;
		
		//cell.accessoryView = [TexLegeTheme disclosureLabel:YES];
		self.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"disclosure"]] autorelease];
		self.backgroundColor = [TexLegeTheme backgroundLight];
		
    }
    return self;
}


- (void)dealloc {
	self.cellInfo = nil;
    [super dealloc];
}

- (void)setCellInfo:(DirectoryDetailInfo *)newCellInfo {	
	if (cellInfo)
		[cellInfo release], cellInfo = nil;
	
	if (newCellInfo) {
		cellInfo = [newCellInfo retain];
		self.detailTextLabel.text = cellInfo.title;
		self.textLabel.text = cellInfo.subtitle;
		if (!cellInfo.isClickable) {
			self.selectionStyle = UITableViewCellSelectionStyleNone;
			self.accessoryType = UITableViewCellAccessoryNone;
			self.accessoryView = nil;
		}
	}
		
}

@end
