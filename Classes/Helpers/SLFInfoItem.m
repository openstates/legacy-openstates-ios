//
//  SLFInfoItem.m
//  OpenStates
//
//  Created by Gregory Combs on 7/9/16.
//  Copyright © 2016 Sunlight Foundation. All rights reserved.
//

#import "SLFInfoItem.h"

const struct SLFInfoItemKeys SLFInfoItemKeys = {
    .identifier = @"infoItemId",
    .type = @"type",
    .title = @"title",
    .subtitle = @"subtitle",
    .image = @"image",
    .duration = @"duration",
    .status = @"status",
};

@interface SLFInfoItem ()
@property (nonatomic,copy) NSString *itemId;
@property (nonatomic,assign) SLFInfoType type;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) NSTimeInterval duration;
@end

@implementation SLFInfoItem

- (instancetype)initWithIdentifier:(nonnull NSString *)itemId
                              type:(SLFInfoType)type
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                             image:(nullable UIImage *)image
                          duration:(NSTimeInterval)duration
{
    NSMutableDictionary *dict = [@{} mutableCopy];

    dict[SLFInfoItemKeys.type] = @(type);
    dict[SLFInfoItemKeys.duration] = @(duration);

    if (SLFTypeNonEmptyStringOrNil(itemId))
        dict[SLFInfoItemKeys.identifier] = itemId;
    if (SLFTypeStringOrNil(title))
        dict[SLFInfoItemKeys.title] = title;
    if (SLFTypeStringOrNil(subtitle))
        dict[SLFInfoItemKeys.subtitle] = subtitle;
    if (SLFTypeImageOrNil(image))
        dict[SLFInfoItemKeys.image] = image;

    self = [super initWithDictionary:dict];
    return self;
}

- (void)setDictionaryRepresentation:(NSDictionary *)dictionary
{
    if (!SLFTypeDictionaryOrNil(dictionary))
        return;

    self.itemId = SLFTypeNonEmptyStringOrNil(dictionary[SLFInfoItemKeys.identifier]);
    self.type = [SLFTypeNumberOrNil(dictionary[SLFInfoItemKeys.type]) unsignedIntegerValue];
    self.title = SLFTypeStringOrNil(dictionary[SLFInfoItemKeys.title]);
    self.subtitle = SLFTypeStringOrNil(dictionary[SLFInfoItemKeys.subtitle]);
    self.image = SLFTypeImageOrNil(dictionary[SLFInfoItemKeys.image]);
    self.duration = [SLFTypeNumberOrNil(dictionary[SLFInfoItemKeys.duration]) doubleValue];
    self.status = [SLFTypeNumberOrNil(dictionary[SLFInfoItemKeys.status]) unsignedIntegerValue];
}

- (BOOL)isValid
{
    return (SLFTypeNonEmptyStringOrNil(self.itemId)
            && self.status >= SLFInfoStatusUnknown
            && self.status <= SLFInfoStatusFinished);
}

- (id)copyWithZone:(NSZone *)zone
{
    SLFInfoItem *copy = [super copyWithZone:zone];
    if (!copy)
        return copy;
    copy.type = self.type;
    copy.duration = self.duration;
    copy.status = self.status;
    if (self.itemId)
        copy.itemId = [self.itemId copyWithZone:zone];
    if (self.title)
        copy.title = [self.title copyWithZone:zone];
    if (self.subtitle)
        copy.subtitle = [self.subtitle copyWithZone:zone];
    if (self.image)
        copy.image = self.image;

    return copy;
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (!self)
        return self;
    NSSet *allowedString = [NSSet setWithObjects:[NSString class], [NSNull class], nil];
    NSSet *allowedNumber = [NSSet setWithObjects:[NSNumber class], [NSNull class], nil];
    NSSet *allowedImage = [NSSet setWithObjects:[UIImage class], [NSNull class], nil];
    @try {
        if ([decoder containsValueForKey:SLFInfoItemKeys.identifier])
            self.itemId = [decoder decodeObjectOfClasses:allowedString forKey:SLFInfoItemKeys.identifier];
        if ([decoder containsValueForKey:SLFInfoItemKeys.type])
            self.type = [[decoder decodeObjectOfClasses:allowedNumber forKey:SLFInfoItemKeys.type] unsignedIntegerValue];
        if ([decoder containsValueForKey:SLFInfoItemKeys.duration])
            self.duration = [[decoder decodeObjectOfClasses:allowedNumber forKey:SLFInfoItemKeys.duration] unsignedIntegerValue];
        if ([decoder containsValueForKey:SLFInfoItemKeys.title])
            self.title = [decoder decodeObjectOfClasses:allowedString forKey:SLFInfoItemKeys.title];
        if ([decoder containsValueForKey:SLFInfoItemKeys.subtitle])
            self.subtitle = [decoder decodeObjectOfClasses:allowedString forKey:SLFInfoItemKeys.subtitle];
        if ([decoder containsValueForKey:SLFInfoItemKeys.image])
            self.image = [decoder decodeObjectOfClasses:allowedImage forKey:SLFInfoItemKeys.image];
        if ([decoder containsValueForKey:SLFInfoItemKeys.status])
            self.status = [[decoder decodeObjectOfClasses:allowedNumber forKey:SLFInfoItemKeys.status] unsignedIntegerValue];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while decoding plist: %@", exception);
    }

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:@(self.type) forKey:SLFInfoItemKeys.type];
    [encoder encodeObject:@(self.status) forKey:SLFInfoItemKeys.status];
    [encoder encodeObject:@(self.duration) forKey:SLFInfoItemKeys.duration];
    if (self.itemId)
        [encoder encodeObject:self.itemId forKey:SLFInfoItemKeys.identifier];
    if (self.title)
        [encoder encodeObject:self.title forKey:SLFInfoItemKeys.title];
    if (self.subtitle)
        [encoder encodeObject:self.title forKey:SLFInfoItemKeys.subtitle];
    if (self.image)
        [encoder encodeObject:self.image forKey:SLFInfoItemKeys.image];
}

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)codableKeysAndClasses
{
    /* Don't add mutables here (i.e. status) or risk altering `-hash` while inside a collection (bad). */
    return @{SLFInfoItemKeys.identifier: [NSString class],
             SLFInfoItemKeys.type: [NSNumber class],
             SLFInfoItemKeys.title: [NSString class],
             SLFInfoItemKeys.subtitle: [NSString class],
             SLFInfoItemKeys.image: [UIImage class],
             SLFInfoItemKeys.duration: [NSNumber class]};
}

@end
