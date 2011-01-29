//
//	CommitteeMemberCellView.h
//
//  TexLege
//
//  Created by Gregory Combs on 8/29/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>

extern const CGFloat kCommitteeMemberCellViewWidth;
extern const CGFloat kCommitteeMemberCellViewHeight;

@class LegislatorObj;
@interface CommitteeMemberCellView : UIView
{
}

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *tenure;

@property (copy, nonatomic) NSString *party;
@property (copy, nonatomic) NSString *rank;
@property (copy, nonatomic) NSString *district;

@property (nonatomic) NSInteger party_id;
@property (nonatomic) CGFloat partisan_index;
@property (nonatomic) CGFloat sliderValue;
@property (nonatomic) CGFloat sliderMin;
@property (nonatomic) CGFloat sliderMax;

@property (retain, nonatomic) UIImage *questionImage;
@property (nonatomic) BOOL highlighted;

- (void)setLegislator:(LegislatorObj *)value;

@end
