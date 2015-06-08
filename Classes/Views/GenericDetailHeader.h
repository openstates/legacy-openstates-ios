//
//  GenericDetailHeader.h
//  Created by Greg Combs on 12/12/11.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@interface GenericDetailHeader : UIView
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,copy) NSString *detail;
@property (nonatomic,assign) CGSize defaultSize;
- (void)configure;
@end
