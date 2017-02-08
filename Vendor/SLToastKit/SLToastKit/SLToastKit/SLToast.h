//
//  SLToast.h
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import <UIKit/UIKit.h>


@class SLToast;

NS_ASSUME_NONNULL_BEGIN

extern const struct SLToastKeys {
    __unsafe_unretained NSString * const identifier;
    __unsafe_unretained NSString * const type;
    __unsafe_unretained NSString * const title;
    __unsafe_unretained NSString * const subtitle;
    __unsafe_unretained NSString * const image;
    __unsafe_unretained NSString * const duration;
    __unsafe_unretained NSString * const status;
} SLToastKeys;

NS_ASSUME_NONNULL_END

typedef NS_ENUM(NSUInteger, SLToastType) {
    SLToastTypeInfo,        // blue
    SLToastTypeActivity,    // blue + activity indicator
    SLToastTypeNotice,      // gray
    SLToastTypeSuccess,     // green
    SLToastTypeWarning,     // yellow
    SLToastTypeError,       // red
    
    SLToastTypeMinimumValue = SLToastTypeInfo,
    SLToastTypeMaximumValue = SLToastTypeError
};

typedef NS_ENUM(NSUInteger, SLToastStatus) {
    SLToastStatusUnknown = 0,
    SLToastStatusSkipped,
    SLToastStatusQueued,
    SLToastStatusShowing,
    SLToastStatusFinished,
    
    SLToastStatusMinimumValue = SLToastStatusUnknown,
    SLToastStatusMaximumValue = SLToastStatusFinished
};

typedef void(^SLToastBlock)(SLToast * _Nonnull infoItem);
typedef void(^SLToastStatusBlock)(SLToastStatus status, SLToast * _Nonnull infoItem);

@interface SLToast : NSObject<NSCopying, NSSecureCoding>

- (nullable instancetype)initWithIdentifier:(nonnull NSString *)itemId
                                       type:(SLToastType)type
                                      title:(nullable NSString *)title
                                   subtitle:(nullable NSString *)subtitle
                                      image:(nullable UIImage *)image
                                   duration:(NSTimeInterval)duration NS_DESIGNATED_INITIALIZER;

+ (nullable instancetype)toastWithIdentifier:(nonnull NSString *)itemId
                                        type:(SLToastType)type
                                       title:(nullable NSString *)title
                                    subtitle:(nullable NSString *)subtitle
                                       image:(nullable UIImage *)image
                                    duration:(NSTimeInterval)duration;

@property (nonatomic,copy,readonly,nonnull) NSString *itemId;
@property (nonatomic,assign,readonly) SLToastType type;
@property (nonatomic,copy,readonly,nullable) NSString *title;
@property (nonatomic,copy,readonly,nullable) NSString *subtitle;
@property (nonatomic,strong,readonly,nullable) UIImage *image;
@property (nonatomic,assign,readonly) NSTimeInterval duration;
@property (nonatomic,assign) SLToastStatus status;

/**
 *  This method initializes a new object instance using the provided dictionary to populate the objects property values.
 *
 *  @param dictionary A dictionary with keys matching the receiver's property names.  Values should
 *                    be of the same type as the matching property to avoid issues.
 *
 *  @return A newly initialized object instance.
 */
- (nullable instancetype)initWithDictionary:(nullable NSDictionary *)dictionary;

/**
 *
 *  Returns an object initialized from data in a given unarchiver.
 *
 *  @param decoder An unarchiver object.
 *
 *  @return `self`, initialized using the data in the decoder.
 */
- (nullable instancetype)initWithCoder:(nonnull NSCoder *)decoder;

/**
 *  As a getter, this method returns a dictionary of the keys and values of all the codable/copyable properties
 *  of the receiver.
 *
 *  As a setter, this method populates the receiver's properties based on the key/value pairs found in the dictionary.
 */
@property (nullable,nonatomic,readonly) NSDictionary *dictionaryRepresentation;

/**
 *  Return the receiver's value for the provided property key.
 *
 *  @param key A key string for the desired property value.
 *
 *  @return A property value corresponding to the key.
 */
- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key;

@end
