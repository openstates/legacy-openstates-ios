//
//  SLFStandardGroupCell.m
//  Created by Gregory Combs on 8/29/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFStandardGroupCell.h"
#import "TableCellDataObject.h"
#import "SLFAppearance.h"

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
    SLFStandardGroupCell *cell = [[SLFStandardGroupCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
    return cell;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    style = [SLFStandardGroupCell cellStyle]; // in the event we're instantiated from via registration with the table view
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;	
		self.detailTextLabel.font =	SLFFont(14);
		self.textLabel.font = SLFFont(12);
		self.detailTextLabel.textColor = [SLFAppearance cellTextColor];
		self.textLabel.textColor =	[SLFAppearance tableSectionColor];
		self.textLabel.adjustsFontSizeToFitWidth =	YES;
		self.detailTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
		self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
		self.detailTextLabel.minimumScaleFactor = 12.f/14.f;
		self.backgroundColor = [SLFAppearance cellBackgroundLightColor];
    }
    return self;
}


- (void)dealloc {
	self.cellInfo = nil;
}

- (void)setCellInfo:(TableCellDataObject *)newCellInfo {	
	if (cellInfo)
		cellInfo = nil;
	
	if (newCellInfo) {
		cellInfo = newCellInfo;
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
