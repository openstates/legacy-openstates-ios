//
//  SLFStandardGroupCell.m
//  Created by Gregory Combs on 8/29/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFStandardGroupCell.h"
#import "TableCellDataObject.h"
#import "SLFAppearance.h"
#import "DisclosureQuartzView.h"

@implementation SLFStandardGroupCell
@synthesize cellInfo;

+ (NSString *)cellIdentifier {
	return @"SLFStandardGroupCell";
}

+ (UITableViewCellStyle)cellStyle {
	return UITableViewCellStyleValue2;
}


+ (SLFStandardGroupCell *)standardCellWithIdentifier:(NSString *)cellIdentifier {
    UITableViewCellStyle style = [SLFStandardGroupCell cellStyle];
    SLFStandardGroupCell *cell = [[[SLFStandardGroupCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier] autorelease];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
		self.detailTextLabel.font =			[SLFAppearance boldFourteen];
		self.textLabel.font =				[SLFAppearance boldTwelve];
		self.detailTextLabel.textColor = 	[SLFAppearance cellTextColor];
		self.textLabel.textColor =			[SLFAppearance tableSectionColor];
		self.textLabel.adjustsFontSizeToFitWidth =	YES;
		self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
		self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.minimumFontSize = 12.0f;
		DisclosureQuartzView *qv = [[DisclosureQuartzView alloc] initWithFrame:CGRectMake(0.f, 0.f, 28.f, 28.f)];
		self.accessoryView = qv;
		[qv release];
		self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    }
    return self;
}


- (void)dealloc {
	self.cellInfo = nil;
    [super dealloc];
}

- (void)setCellInfo:(TableCellDataObject *)newCellInfo {	
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
