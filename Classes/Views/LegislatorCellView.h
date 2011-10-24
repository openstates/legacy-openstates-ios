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

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) SLFParty *party;
@property (copy, nonatomic) NSString *district;
@property (copy, nonatomic) NSString *role;

@property (nonatomic) BOOL highlighted;
@property (nonatomic) BOOL useDarkBackground;

@property (nonatomic,readonly) CGSize cellSize; 

- (void)setLegislator:(SLFLegislator *)value;

@end
