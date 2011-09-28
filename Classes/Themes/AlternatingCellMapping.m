//
//  AlternatingCellMapping.m
//  Created by Greg Combs on 9/27/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "AlternatingCellMapping.h"
#import "SLFAppearance.h"

@implementation AlternatingCellMapping

- (id)init {
    self = [super init];
    if (self) {
        self.onCellWillAppearForObjectAtIndexPath = ^(UITableViewCell* cell, id object, NSIndexPath* indexPath) {
            cell.textLabel.textColor = [SLFAppearance cellTextColor];
            cell.backgroundColor = [SLFAppearance cellBackgroundLightColor];
            if (indexPath.row % 2 == 0)
                cell.backgroundColor = [SLFAppearance cellBackgroundDarkColor];
        };
    }
    return self;
}

@end
