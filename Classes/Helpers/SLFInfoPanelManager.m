//
//  SLFInfoPanelManager.m
//  OpenStates
//
//  Created by Gregory Combs on 7/8/16.
//  Copyright © 2016 Sunlight Foundation. All rights reserved.
//

#import "SLFInfoPanelManager.h"
#import "SLFObjectQueue.h"
#import "SLFInfoItem.h"

@interface SLFInfoPanelManager()
@property (nonatomic,copy) SLFObjectQueue <SLFInfoItem *> *infoQueue;
@property (nonatomic,copy,nonnull) NSString *managerId;
@end

@implementation SLFInfoPanelManager

- (instancetype)initWithManagerId:(NSString *)managerId parentView:(UIView *)parentView
{
    self = [super init];
    if (self)
    {
        if (!SLFTypeNonEmptyStringOrNil(managerId))
            managerId = @"DefaultInfoPanelManager";
        _managerId = [managerId copy];
        _parentView = parentView;

        NSString *queueName = [managerId stringByAppendingString:@"-Queue"];
        _infoQueue = [[SLFObjectQueue alloc] initWithName:queueName];
    }
    return self;
}

- (instancetype)init
{
    self = [self initWithManagerId:@"" parentView:nil];
    return self;
}

- (void)dealloc
{
    // In case consumers need to check the status of their retained info items
    for (SLFInfoItem *item in self.infoQueue)
    {
        if (item.status != SLFInfoStatusQueued
            && item.status != SLFInfoStatusFinished)
        {
            item.status = SLFInfoStatusUnknown;
        }
    }
}

- (NSUInteger)infoItemCount
{
    return self.infoQueue.count;
}

- (BOOL)addInfoItem:(nonnull SLFInfoItem *)item
{
    if (!SLFValueIfClass(SLFInfoItem, item) || ![item isValid])
        return NO;

    [self.infoQueue push:item];
    item.status = SLFInfoStatusQueued;

    return YES;
}

- (BOOL)removeInfoItem:(nonnull SLFInfoItem *)item
{
    if (!SLFValueIfClass(SLFInfoItem, item))
        return NO;
    BOOL success = [self.infoQueue removeObject:item];
    if (item.status == SLFInfoStatusQueued)
        item.status = SLFInfoStatusUnknown;
    return success;
}


- (nullable SLFInfoItem *)pullNextItem
{
    // do something with status?
    return [self.infoQueue pop];
}

@end
