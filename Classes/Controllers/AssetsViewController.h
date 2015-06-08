//
//  AssetsViewController.h
//  Created by Greg Combs on 1/4/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTableViewController.h"

@interface AssetsViewController : SLFTableViewController
@property (nonatomic,retain) NSArray *assets;
- (id)initWithAssets:(NSArray *)assets;
- (id)initWithState:(SLFState *)state;
@end
