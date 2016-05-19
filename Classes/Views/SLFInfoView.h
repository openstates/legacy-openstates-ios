//
//  SLFInfoView.h
//  OpenStates
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright © 2016 Sunlight Foundation. All rights reserved.
//

@import UIKit;
#import "SLFInfoItem.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^SLFInfoViewCompletion)(SLFInfoStatus status, SLFInfoItem *item);

@interface SLFInfoView : UIView

+ (instancetype)showInfoInView:(UIView *)parentView
                      infoItem:(SLFInfoItem *)infoItem
                    completion:(nullable SLFInfoViewCompletion)completion;

+ (instancetype)showInfoInWindow:(UIWindow *)window
                            type:(SLFInfoType)type
                           title:(nullable NSString *)title
                        subtitle:(nullable NSString *)subtitle
                       hideAfter:(NSTimeInterval)interval;

+ (instancetype)showInfoInView:(UIView *)view
                          type:(SLFInfoType)type
                         title:(nullable NSString *)title
                      subtitle:(nullable NSString *)subtitle
                         image:(nullable UIImage *)image
                     hideAfter:(NSTimeInterval)interval;

+ (instancetype)staticInfoViewWithFrame:(CGRect)frame
                                   type:(SLFInfoType)type
                                  title:(nullable NSString *)title
                               subtitle:(nullable NSString *)subtitle
                                  image:(nullable UIImage *)image;

+ (instancetype)staticInfoViewWithFrame:(CGRect)frame infoItem:(SLFInfoItem *)infoItem;

- (void)setType:(SLFInfoType)type
          title:(nullable NSString *)title
       subtitle:(nullable NSString *)subtitle;

- (void)hideInfoView;

@property (nonatomic,strong,nullable,readonly) SLFInfoItem *infoItem;
@property (nonatomic,copy,nullable,readonly) SLFInfoViewCompletion onCompletion;

@end

NS_ASSUME_NONNULL_END

