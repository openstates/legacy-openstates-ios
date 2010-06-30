//
//  DirectoryDetailView.h
//  TexLege
//
//  Created by Gregory S. Combs on 5/31/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#include "LegislatorObj.h"
#include "DirectoryDetailInfo.h"

@class DetailTableViewController;
@class StaticGradientSliderView;

@interface DirectoryDetailView : UITableView <UITableViewDataSource>{
	LegislatorObj		*legislator;
	NSMutableArray	*sectionArray;
	IBOutlet StaticGradientSliderView  *sliderView;
	DetailTableViewController *detailController;

}

@property (nonatomic, retain) DetailTableViewController *detailController;
@property (nonatomic, retain) LegislatorObj *legislator;
@property (nonatomic, retain) NSMutableArray *sectionArray;
@property (readonly) NSString *name;
@property (nonatomic, retain) IBOutlet StaticGradientSliderView *sliderView;


- (id) initWithFrameAndLegislator:(CGRect)frame Legislator:(LegislatorObj *)aLegislator;
- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (CGFloat) heightForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void) didSelectRowAtIndexPath:(NSIndexPath *)newIndexPath;
- (void) setupHeader:(UIView *)aHeader;

- (void) loadView;
- (void) createSectionList;
- (void) createEntryInSection:(NSInteger)sectionIndex WithKeys:(NSArray *)keys andObjects:(NSArray *)objects;
- (void) standardTextCell:(UITableViewCell *)cell withInfo:(DirectoryDetailInfo *)cellInfo;

//- (void) showWebViewWithURL:(NSURL *)url;
@end
