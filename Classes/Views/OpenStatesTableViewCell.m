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
    if (style == UITableViewCellStyleDefault) {
        style = UITableViewCellStyleValue1;
    }
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];

    return self;
}

@end
