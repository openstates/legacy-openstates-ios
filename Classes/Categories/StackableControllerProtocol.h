//
//  StackableController.h
//  Created by Greg Combs on 10/16/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


@protocol StackableController <NSObject>
@required
- (void)stackOrPushViewController:(UIViewController *)viewController;
@optional
- (void)popToThisViewController;
@end
