//
//  SLFBadgeCell.h
//  Created by Gregory Combs on 3/24/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <UIKit/UIKit.h>

@class BillsSubjectsEntry;
@interface SLFBadgeCell : UITableViewCell
@property (nonatomic,assign) BOOL isClickable;
@property (nonatomic,retain) BillsSubjectsEntry *subjectEntry;
@end
