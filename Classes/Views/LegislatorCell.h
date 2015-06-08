//
//  LegislatorCell.h
//  Created by Gregory Combs on 8/9/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <RestKit/UI/UI.h>

@class SLFLegislator;
@class LegislatorCellView;
@interface LegislatorCell : UITableViewCell
@property (nonatomic,readonly) CGSize cellSize;
@property (nonatomic,retain) SLFLegislator *legislator;
@property (nonatomic,retain) LegislatorCellView *cellContentView;
@property (nonatomic,copy) NSString *role;
@property (nonatomic,assign) BOOL useDarkBackground;
@property (nonatomic,assign) NSString *genericName;
@end

@interface LegislatorCellMapping : RKTableViewCellMapping
@property (nonatomic,assign) BOOL roundImageCorners;
@property (nonatomic,assign) BOOL useAlternatingRowColors;
@end

@interface FoundLegislatorCellMapping : LegislatorCellMapping
@end
