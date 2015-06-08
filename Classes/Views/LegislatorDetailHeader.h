//
//  LegislatorDetailHeader.h
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@class SLFLegislator;
@interface LegislatorDetailHeader : UIView
@property (nonatomic,retain) SLFLegislator *legislator;
- (void)configure;
@end
