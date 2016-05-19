//
//  SLFInfoPanelManager.h
//  OpenStates
//
//  Created by Gregory Combs on 7/8/16.
//  Copyright © 2016 Sunlight Foundation. All rights reserved.
//

@import Foundation;
#import "SLFInfoItem.h"

@interface SLFInfoPanelManager : NSObject

- (nonnull instancetype)initWithManagerId:(nonnull NSString *)managerId parentView:(nullable UIView *)parentView NS_DESIGNATED_INITIALIZER;
- (BOOL)addInfoItem:(nonnull SLFInfoItem *)item;
- (BOOL)removeInfoItem:(nonnull SLFInfoItem *)item;
@property (nonatomic,readonly) NSUInteger infoItemCount;
@property (nonatomic,copy,readonly,nonnull) NSString *managerId;
@property (nonatomic,weak,nullable) UIView *parentView;

@end
