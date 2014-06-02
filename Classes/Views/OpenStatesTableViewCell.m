//
//  OpenStatesTableViewCell.m
//  OpenStates
//
//  Created by Daniel Cloud on 5/27/14.
//
//

#import "OpenStatesTableViewCell.h"

@implementation OpenStatesTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCellStyle osCellStyle = style;
    if (style == UITableViewCellStyleDefault) {
        if (SLFIsIpad()) {
            osCellStyle = UITableViewCellStyleValue1;
        }
        else {
            osCellStyle = UITableViewCellStyleSubtitle;
        }
    }
    self = [super initWithStyle:osCellStyle reuseIdentifier:reuseIdentifier];

    return self;
}

@end
