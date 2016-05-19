//
//  SLFInfoItem.h
//  OpenStates
//
//  Created by Gregory Combs on 7/9/16.
//

#import "SLFAbstractCodableObject.h"

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT const struct SLFInfoItemKeys {
    __unsafe_unretained NSString * const identifier;
    __unsafe_unretained NSString * const type;
    __unsafe_unretained NSString * const title;
    __unsafe_unretained NSString * const subtitle;
    __unsafe_unretained NSString * const image;
    __unsafe_unretained NSString * const duration;
    __unsafe_unretained NSString * const status;
} SLFInfoItemKeys;

typedef NS_ENUM(NSUInteger, SLFInfoType) {
    SLFInfoTypeInfo,        // blue
    SLFInfoTypeNotice,      // gray
    SLFInfoTypeSuccess,     // green
    SLFInfoTypeWarning,     // yellow
    SLFInfoTypeError,       // red
    SLFInfoTypeActivity,    // blue + activity indicator
};

typedef NS_ENUM(NSUInteger, SLFInfoStatus) {
    SLFInfoStatusUnknown = 0,
    SLFInfoStatusQueued,
    SLFInfoStatusShowing,
    SLFInfoStatusFinished,
};

@interface SLFInfoItem : SLFAbstractCodableObject

- (nullable instancetype)initWithIdentifier:(nonnull NSString *)itemId
                                       type:(SLFInfoType)type
                                      title:(nullable NSString *)title
                                   subtitle:(nullable NSString *)subtitle
                                      image:(nullable UIImage *)image
                                   duration:(NSTimeInterval)duration;

@property (nonatomic,copy,readonly) NSString *itemId;
@property (nonatomic,assign,readonly) SLFInfoType type;
@property (nonatomic,copy,readonly,nullable) NSString *title;
@property (nonatomic,copy,readonly,nullable) NSString *subtitle;
@property (nonatomic,strong,readonly,nullable) UIImage *image;
@property (nonatomic,assign,readonly) NSTimeInterval duration;
@property (nonatomic,assign) SLFInfoStatus status;

- (BOOL)isValid;

@end

NS_ASSUME_NONNULL_END

