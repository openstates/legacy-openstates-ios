//
//  UACellBackgroundView.h
//  Ambiance
//
//  Created by Matt Coneybeare on 1/31/10.
//  Copyright 2010 Urban Apps LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <UIKit/UIKit.h>

typedef enum  {
    UACellBackgroundViewPositionSingle = 0,
    UACellBackgroundViewPositionTop, 
    UACellBackgroundViewPositionBottom,
    UACellBackgroundViewPositionMiddle
} UACellBackgroundViewPosition;

@interface UACellBackgroundView : UIView {
    UACellBackgroundViewPosition position;
}

@property(nonatomic) UACellBackgroundViewPosition position;

@end