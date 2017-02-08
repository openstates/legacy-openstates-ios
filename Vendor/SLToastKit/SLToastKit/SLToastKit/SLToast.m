//
//  SLToast.m
//  SLToastKit
//
//  Created by Gregory Combs on 7/10/16.
//  Copyright (C) 2016 Gregory Combs [gcombs at gmail]
//  See LICENSE.txt for details.
//

#import "SLToast.h"
#import "SLTypeCheck.h"

const struct SLToastKeys SLToastKeys = {
    .identifier = @"toastId",
    .type = @"type",
    .title = @"title",
    .subtitle = @"subtitle",
    .image = @"image",
    .duration = @"duration",
    .status = @"status",
};

@interface SLToast ()
@property (nonatomic,copy) NSString *toastId;
@property (nonatomic,assign) SLToastType type;
@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *subtitle;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,assign) NSTimeInterval duration;
@end

NSUInteger SLValueHash(NSUInteger hash, NSUInteger hashIndex) {
    static size_t const uintBitSize = (__CHAR_BIT__ * sizeof(NSUInteger));
    size_t howmuch = uintBitSize / (hashIndex+1);
    hash = (hash) ?: 31; // accounts for nil objects
    return ((hash << howmuch) | (hash >> (uintBitSize - howmuch)));
}

@implementation SLToast

- (instancetype)initWithIdentifier:(nonnull NSString *)toastId
                              type:(SLToastType)type
                             title:(nullable NSString *)title
                          subtitle:(nullable NSString *)subtitle
                             image:(nullable UIImage *)image
                          duration:(NSTimeInterval)duration
{
    self = [super init];
    if (self)
    {
        _toastId = [SLTypeNonEmptyStringOrNil(toastId) copy];
        _title = [SLTypeStringOrNil(title) copy];
        _subtitle = [SLTypeStringOrNil(subtitle) copy];
        _image = SLTypeImageOrNil(image);
        _type = type;
        _duration = duration;

        if (!self.isValid)
            return nil;
    }
    return self;
}

+ (instancetype)toastWithIdentifier:(NSString *)itemId type:(SLToastType)type title:(NSString *)title subtitle:(NSString *)subtitle image:(UIImage *)image duration:(NSTimeInterval)duration
{
    return [[self alloc] initWithIdentifier:itemId type:type title:title subtitle:subtitle image:image duration:duration];
}

- (instancetype)init
{
    self = [self initWithIdentifier:@"<INVALID_INITIALIZER>"
                               type:SLToastTypeError
                              title:nil
                           subtitle:nil
                              image:nil
                           duration:0];
    NSAssert(FALSE, @"Must use the designated initializer, as this is an immutable class");
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (!SLTypeDictionaryOrNil(dictionary))
        return nil;

    struct SLToastKeys keys = SLToastKeys;
    
    NSString *toastId = SLTypeNonEmptyStringOrNil(dictionary[keys.identifier]);
    if (!toastId)
        return nil;
    
    NSString *title = SLTypeStringOrNil(dictionary[keys.title]);
    NSString *subtitle = SLTypeStringOrNil(dictionary[keys.subtitle]);
    UIImage *image = SLTypeImageOrNil(dictionary[keys.image]);
    NSTimeInterval duration = [SLTypeNumberOrNil(dictionary[keys.duration]) doubleValue];

    SLToastType type = [SLTypeNumberOrNil(dictionary[keys.type]) unsignedIntegerValue];
    if (type < SLToastTypeInfo || type > SLToastTypeActivity)
        type = SLToastTypeError; // invalid toast type

    SLToastStatus status = [SLTypeNumberOrNil(dictionary[keys.status]) unsignedIntegerValue];
    if (status < SLToastStatusUnknown || status > SLToastStatusFinished)
        status = SLToastStatusUnknown; // invalid toast status

    self = [self initWithIdentifier:toastId
                               type:type
                              title:title
                           subtitle:subtitle
                              image:image
                           duration:duration];
    if (self)
        self.status = status;

    return self;
}

- (BOOL)isValid
{
    SLToastStatus status = self.status;
    SLToastType type = self.type;
    return (SLTypeNonEmptyStringOrNil(self.toastId) != nil
            && status >= SLToastStatusMinimumValue
            && status <= SLToastStatusMaximumValue
            && type >= SLToastTypeMinimumValue
            && type <= SLToastTypeMaximumValue);
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    NSString *toastId = [self.toastId copyWithZone:zone];
    NSString *title = [self.title copyWithZone:zone];
    NSString *subtitle = [self.subtitle copyWithZone:zone];
    SLToast *copy = [[SLToast allocWithZone:zone] initWithIdentifier:toastId type:self.type title:title subtitle:subtitle image:self.image duration:self.duration];
    if (!copy)
        return copy;
    copy.status = self.status;
    return copy;
}

#pragma mark - NSCoding / NSSecureCoding

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (NSDictionary *)codableKeysAndClasses
{
    struct SLToastKeys keys = SLToastKeys;

    /* Don't add any mutables here (i.e. status) or risk the changing `-hash` inside a collection (bad). */
    return @{keys.identifier:[NSString class],
             keys.type:      [NSNumber class],
             keys.title:     [NSString class],
             keys.subtitle:  [NSString class],
             keys.image:     [UIImage class],
             keys.duration:  [NSNumber class]};
}

- (instancetype)initWithCoder:(NSCoder *)decoder
{
    NSSet *allowedString = [NSSet setWithObjects:[NSString class], [NSNull class], nil];
    NSSet *allowedNumber = [NSSet setWithObjects:[NSNumber class], [NSNull class], nil];
    NSSet *allowedImage = [NSSet setWithObjects:[UIImage class], [NSNull class], nil];

    NSString *toastId = nil;
    SLToastType type = SLToastTypeInfo;
    NSTimeInterval duration = 0;
    NSString *title = nil;
    NSString *subtitle = nil;
    UIImage *image = nil;
    SLToastStatus status = SLToastStatusUnknown;

    struct SLToastKeys keys = SLToastKeys;

    @try {
        if ([decoder containsValueForKey:keys.identifier])
            toastId = [decoder decodeObjectOfClasses:allowedString forKey:keys.identifier];
        if ([decoder containsValueForKey:SLToastKeys.type])
            type = [[decoder decodeObjectOfClasses:allowedNumber forKey:keys.type] unsignedIntegerValue];
        if ([decoder containsValueForKey:keys.duration])
            duration = [[decoder decodeObjectOfClasses:allowedNumber forKey:keys.duration] unsignedIntegerValue];
        if ([decoder containsValueForKey:keys.title])
            title = [decoder decodeObjectOfClasses:allowedString forKey:SLToastKeys.title];
        if ([decoder containsValueForKey:keys.subtitle])
            subtitle = [decoder decodeObjectOfClasses:allowedString forKey:keys.subtitle];
        if ([decoder containsValueForKey:keys.image])
            image = [decoder decodeObjectOfClasses:allowedImage forKey:SLToastKeys.image];
        if ([decoder containsValueForKey:keys.status])
            status = [[decoder decodeObjectOfClasses:allowedNumber forKey:keys.status] unsignedIntegerValue];
    }
    @catch (NSException *exception) {
        NSLog(@"Exception while decoding plist: %@", exception);
    }

    self = [self initWithIdentifier:toastId
                               type:type
                              title:title
                           subtitle:subtitle
                              image:image
                           duration:duration];

    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    if (!encoder)
        return;

    struct SLToastKeys keys = SLToastKeys;

    [encoder encodeObject:@(self.type) forKey:keys.type];
    [encoder encodeObject:@(self.status) forKey:keys.status];
    [encoder encodeObject:@(self.duration) forKey:keys.duration];

    NSString *toastId = self.toastId;
    if (toastId)
        [encoder encodeObject:toastId forKey:keys.identifier];
    
    NSString *title = self.title;
    if (title)
        [encoder encodeObject:title forKey:keys.title];
    
    NSString *subtitle = self.subtitle;
    if (subtitle)
        [encoder encodeObject:subtitle forKey:keys.subtitle];

    UIImage *image = self.image;
    if (image)
        [encoder encodeObject:image forKey:keys.image];
}

#pragma mark - Equality & hash

- (BOOL)isEqual:(nullable id)obj
{
    if (!obj || ![obj isKindOfClass:[self class]])
        return NO;
    return [[self dictionaryRepresentation] isEqualToDictionary:[obj dictionaryRepresentation]];
}

- (NSUInteger)hash
{
    __block NSUInteger current = 31;
    __block NSUInteger hashIndex = 1;
    __weak typeof(self) weakSelf = self;

    // WARNING: You must ensure that no mutable properties are encoded into the hash

    [[SLToast codableKeysAndClasses] enumerateKeysAndObjectsUsingBlock:^(NSString *key, Class valueClass, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf)
            return;
        current = SLValueHash([[strongSelf valueForKey:key] hash], hashIndex) ^ current;
        hashIndex++;
    }];

    return current;
}

#pragma mark - Description and Dictionary Representation

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];

    __weak typeof(self) weakSelf = self;
    [[[self class] codableKeysAndClasses] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        id value = [strongSelf valueForKey:key];
        if (value)
        {
            dict[key] = value;
        }
    }];

    dict[SLToastKeys.status] = @(self.status);

    return [dict copy];
}

- (NSString *)description
{
    NSMutableString *description = [[NSMutableString alloc] initWithFormat:@"[%@] - ", NSStringFromClass(self.class)];

    __weak typeof(self) weakSelf = self;
    [[self dictionaryRepresentation] enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        id value = nil;
        @try {
            value = [strongSelf valueForKey:key];
        }
        @catch (NSException *exception) {
        }
        if (!value)
            value = @"<nil>";
        [description appendFormat:@"  %@: %@\n", key, value];
    }];

    return description;
}

#pragma mark - Keyed Subscripting

- (nullable id)objectForKeyedSubscript:(nonnull NSString *)key
{
    if (!SLTypeNonEmptyStringOrNil(key))
        return nil;

    // Status cannot be included in codableKeysAndClasses due to mutability
    if ([key isEqualToString:SLToastKeys.status])
        return @(self.status);

    if (![[self class] codableKeysAndClasses][key])
        return nil;

    return [self valueForKey:key];
}

#if INFO_SHOULD_BE_MUTABLE

- (void)setDictionaryRepresentation:(NSDictionary *)dictionary
{
    if (!SLTypeDictionaryOrNil(dictionary))
        return;

    struct SLToastKeys keys = SLToastKeys;

    _toastId = [SLTypeNonEmptyStringOrNil(dictionary[keys.identifier]) copy];
    _type = [SLTypeNumberOrNil(dictionary[keys.type]) unsignedIntegerValue];
    _title = [SLTypeStringOrNil(dictionary[keys.title]) copy];
    _subtitle = [SLTypeStringOrNil(dictionary[keys.subtitle]) copy];
    _image = SLTypeImageOrNil(dictionary[keys.image]);
    _duration = [SLTypeNumberOrNil(dictionary[keys.duration]) doubleValue];
    _status = [SLTypeNumberOrNil(dictionary[keys.status]) unsignedIntegerValue];
}


- (void)setObject:(nullable id)object forKeyedSubscript:(nonnull NSString *)key
{
    if (!SLTypeNonEmptyStringOrNil(key))
        return;
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *codableProperties = [[self class] codableKeysAndClasses];
    Class valueClass = codableProperties[key];
    if (!valueClass)
        return;
    if (secureSupported && object && ![object isKindOfClass:valueClass])
    {
        NSLog(@"Expected '%@' to be a %@, but was actually a %@", key, valueClass, [object class]);
        return;
    }
    [self setValue:object forKey:key];
}

#endif

@end
