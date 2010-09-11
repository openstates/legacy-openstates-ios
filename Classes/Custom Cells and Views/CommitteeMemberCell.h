//
//  CommitteeMemberCell.h
//  TexLege
//
//  Created by Gregory Combs on 8/9/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CommitteeMemberCellView.h"
@class LegislatorObj;

@interface CommitteeMemberCell : UITableViewCell {
	
}
@property (nonatomic,retain) IBOutlet CommitteeMemberCellView *cellView;
@property (nonatomic,retain) IBOutlet LegislatorObj *legislator;
@end
