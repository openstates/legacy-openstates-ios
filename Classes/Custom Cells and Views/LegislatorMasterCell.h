//
//  LegislatorMasterCell.h
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LegislatorObj;
@class MyView;
@interface LegislatorMasterCell : UITableViewCell {
	
}
@property (nonatomic,retain) IBOutlet MyView *cellView;
@property (nonatomic,retain) IBOutlet LegislatorObj *legislator;
@end
