//
//  AppendingFlowView.h
//
//  AppendingFlowView by Gregory S. Combs, based on work at https://github.com/grgcombs/AppendingFlowView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//

#import <UIKit/UIKit.h>

typedef enum  {
	FlowStagePending = 0,
	FlowStageReached = 1,
	FlowStageFailed = 10,
} AppendingFlowStageType;

@interface AppendingFlowStage : NSObject
@property (nonatomic,assign) NSInteger stageNumber;
@property (nonatomic,assign) AppendingFlowStageType stageType;
@property (nonatomic,copy) NSString *caption;

+ (AppendingFlowStage *)stageWithNumber:(NSInteger)stageNumber caption:(NSString *)defaultCaption;
+ (AppendingFlowStage *)stageWithNumber:(NSInteger)stageNumber type:(AppendingFlowStageType)stageType caption:(NSString *)defaultCaption;
- (id)initWithStage:(NSInteger)stageNumber stageType:(AppendingFlowStageType)stageType caption:(NSString *)defaultCaption;
- (BOOL)shouldPromoteTypeTo:(AppendingFlowStageType)newType;
@end



@interface AppendingFlowView : UIView

@property (nonatomic,copy) NSArray *stages;		// An array of AppendingFlowStages
@property (nonatomic,retain) UIFont *font;
@property (nonatomic,retain) UIColor *fontColor;
@property (nonatomic,copy) NSDictionary *stageColors;	// [NSNumber numberWithInt:FlowStageFailed] = [UIColor redColor]
@property (nonatomic,assign) CGSize connectorSize;		// desired size for the connecting lines between boxes
@property (nonatomic,assign) CGSize preferredBoxSize;			// desired size for the stage boxes w/text
@property (nonatomic,assign) CGSize insetMargin;		// width is margin from max left/right ... height is vertical padding per row
@property (nonatomic,assign) CGFloat pendingAlpha;		// the level of alpha to use whenever the stage is pending

// standardize on a suitable width / height for all stages in the flow view, for visual appeal or (inverse = compactness)
@property (nonatomic,assign) BOOL uniformWidth, uniformHeight;

@end

CGFloat widthOfViews(NSArray *views);
CGFloat maxHeightOfViews(NSArray *views);

