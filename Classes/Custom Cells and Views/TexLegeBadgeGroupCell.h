//
//  TexLegeStandardGroupCell.h
//  Created by Gregory Combs on 3/24/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>
#import "TexLegeGroupCellProtocol.h"

@class DDBadgeView;
@class TableCellDataObject;
@interface TexLegeBadgeGroupCell : UITableViewCell <TexLegeGroupCellProtocol> {
	DDBadgeView *	badgeView_;
	
	NSString *		summary_;
	NSString *		badgeText_;
	UIColor *		badgeColor_;
	UIColor *		badgeHighlightedColor_;
}
@property (nonatomic, copy) NSString *      summary;
@property (nonatomic, copy) NSString *		badgeText;
@property (nonatomic, retain) UIColor *		badgeColor;
@property (nonatomic, retain) UIColor *		badgeHighlightedColor;
@property (nonatomic)		BOOL			isClickable;
@end
