//
//  TableItem.m
//  Created by Greg Combs on 9/22/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "TableItem.h"

@implementation SubtitleTableItem

- (id)init {
    self = [super init];
    if (self) {
        self.cellMapping.style = UITableViewCellStyleSubtitle;
        self.cellMapping.selectionStyle = UITableViewCellSelectionStyleBlue;
        self.cellMapping.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

@end

@implementation StaticSubtitleTableItem

- (id)init {
    self = [super init];
    if (self) {
        self.cellMapping.style = UITableViewCellStyleSubtitle;
        self.cellMapping.selectionStyle = UITableViewCellSelectionStyleNone;
        self.cellMapping.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

@end
