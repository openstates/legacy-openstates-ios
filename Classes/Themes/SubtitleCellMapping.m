//
//  SubtitleCellMapping.m
//  StatesLege
//
//  Created by Greg Combs on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SubtitleCellMapping.h"

@implementation SubtitleCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.style = UITableViewCellStyleSubtitle;
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end

@implementation StaticSubtitleCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

@end
