//
//  AnalyticsOptInAlertController.h
//  TexLege
//
//  Created by Gregory Combs on 8/24/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AnalyticsOptInAlertController : NSObject <UIAlertViewDelegate> {

}

@property (nonatomic, retain) IBOutlet UIAlertView *currentAlert;
@property (nonatomic, retain) NSString *optInText;

- (void)presentAnalyticsOptInAlert;
- (BOOL) shouldPresentAnalyticsOptInAlert;

@end
