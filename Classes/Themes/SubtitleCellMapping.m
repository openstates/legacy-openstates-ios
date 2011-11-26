//
//  SubtitleCellMapping.m
//  StatesLege
//
//  Created by Greg Combs on 9/27/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "SubtitleCellMapping.h"
#import "SLFTheme.h"

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

@implementation LargeSubtitleCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.rowHeight = 90;
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = [SLFAppearance cellTextColor];
            cell.textLabel.font = SLFFont(15);
            cell.detailTextLabel.textColor = [SLFAppearance cellSecondaryTextColor];
            cell.detailTextLabel.font = SLFFont(12);
            SLFAlternateCellForIndexPath(cell, indexPath);
            cell.detailTextLabel.numberOfLines = 4;
            cell.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        };
    }
    return self;
}
@end

@implementation LargeStaticSubtitleCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

@end
