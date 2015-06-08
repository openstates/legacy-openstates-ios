//
//  OpenStatesTableViewCell.m
//  OpenStates
//
//  Created by Daniel Cloud on 5/27/14.
//
//
// This work is licensed under the BSD-3 License included with this source
// distribution.


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

@implementation OpenStatesSubtitleTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];

    return self;
}

@end
