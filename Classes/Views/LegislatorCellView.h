//
//	CommitteeMemberCellView.h
//  Created by Gregory Combs on 7/12/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import <UIKit/UIKit.h>

@class SLFLegislator;
@class SLFParty;

@interface LegislatorCellView : UIView

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,strong) SLFParty *party;
@property (nonatomic,copy) NSString *district;
@property (nonatomic,copy) NSString *role;
@property (nonatomic,assign) BOOL highlighted;
@property (nonatomic,assign) BOOL useDarkBackground;
@property (nonatomic,readonly) CGSize cellSize; 
@property (nonatomic,copy) NSString *genericName;
- (void)setLegislator:(SLFLegislator *)value;

@end
