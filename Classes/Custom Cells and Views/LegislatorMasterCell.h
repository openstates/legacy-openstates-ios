//
//  LegislatorMasterCell.h
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LegislatorMasterCellView.h"
@class LegislatorObj;

@interface LegislatorMasterCell : UITableViewCell {
	
}
@property (nonatomic,retain) IBOutlet LegislatorMasterCellView *cellView;
@property (nonatomic,retain) IBOutlet LegislatorObj *legislator;
@end
