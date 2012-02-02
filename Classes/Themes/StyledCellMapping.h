//
//  StyledCellMapping.h
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <RestKit/UI/UI.h>

@interface StyledCellMapping : RKTableViewCellMapping
@property (nonatomic,assign) BOOL useAlternatingRowColors;
@property (nonatomic,assign) BOOL useLargeRowHeight;
@property (nonatomic,assign) BOOL isSelectableCell;
@property (nonatomic,retain) UIColor *textColor;
@property (nonatomic,retain) UIColor *detailTextColor;
@property (nonatomic,retain) UIFont *textFont;
@property (nonatomic,retain) UIFont *detailTextFont;

+ (StyledCellMapping *)cellMappingWithStyle:(UITableViewCellStyle)style alternatingColors:(BOOL)useAlternatingRowColors largeHeight:(BOOL)useLargeRowHeight selectable:(BOOL)isSelectableCell;
+ (id)styledMappingForClass:(Class)cellClass usingBlock:(void (^)(StyledCellMapping *cellMapping))block;
+ (id)styledMappingUsingBlock:(void (^)(StyledCellMapping *cellMapping))block;
+ (id)staticSubtitleMapping;
+ (id)subtitleMapping;
@end
