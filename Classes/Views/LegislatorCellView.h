//
//	CommitteeMemberCellView.h
//  Created by Gregory Combs on 7/12/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import <UIKit/UIKit.h>

@class SLFLegislator;
@class SLFParty;
@interface LegislatorCellView : UIView
{
}

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,retain) SLFParty *party;
@property (nonatomic,copy) NSString *district;
@property (nonatomic,assign) NSString *role;
@property (nonatomic,assign) BOOL highlighted;
@property (nonatomic,assign) BOOL useDarkBackground;
@property (nonatomic,readonly) CGSize cellSize; 
@property (nonatomic,copy) NSString *genericName;
- (void)setLegislator:(SLFLegislator *)value;

@end
