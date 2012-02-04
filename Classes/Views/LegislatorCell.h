//
//  LegislatorCell.h
//  Created by Gregory Combs on 8/9/10.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

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
