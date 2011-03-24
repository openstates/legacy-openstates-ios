//
//  TexLegeStandardGroupCell.h
//  TexLege
//
//  Created by Gregory Combs on 3/24/11.
//  Copyright 2011 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TexLegeGroupCellProtocol.h"

@class DDBadgeView;
@class TableCellDataObject;
@interface TexLegeBadgeGroupCell : UITableViewCell <TexLegeGroupCellProtocol> {
	DDBadgeView *	badgeView_;
	
	NSString *		summary_;
	//NSString *		detail_;
	NSString *		badgeText_;
	UIColor *		badgeColor_;
	UIColor *		badgeHighlightedColor_;
	BOOL			isClickable;
}
@property (nonatomic, copy) NSString *      summary;
//@property (nonatomic, copy) NSString *      detail;
@property (nonatomic, copy) NSString *		badgeText;
@property (nonatomic, retain) UIColor *		badgeColor;
@property (nonatomic, retain) UIColor *		badgeHighlightedColor;
@property (nonatomic)		BOOL			isClickable;
@end
