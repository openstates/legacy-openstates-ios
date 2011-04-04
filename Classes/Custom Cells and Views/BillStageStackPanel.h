//
//  BillStageStackPanel.m
//  Stacks UIView's horizontally or vertically with a specified spacing. 
//  If contained in a UIScrollView, it can automatically adjust it's content size.
//
//  Created by Raymond Reggers on 8/5/10.
//  Copyright 2010 Adaptiv Design. All rights reserved.
//
 
typedef enum StackOrientationType {
    VERTICAL,
    HORIZONTAL
} StackOrientation;
 
@interface BillStageStackPanel : UIView {
     
@private
    StackOrientation orientation;
    int spacing;
    BOOL resizeFrame;
}
 
@property (nonatomic, setter=_orientationSetter:) StackOrientation orientation;
@property (nonatomic, setter=_spacingSetter:) int spacing;
@property (nonatomic, setter=_resizeFrameSetter:) BOOL resizeFrame;
 
@end