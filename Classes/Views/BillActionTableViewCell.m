//
//  BillActionTableViewCell.m
//  OpenStates
//
//  Created by Daniel Cloud on 6/3/14.
//
//

#import "BillActionTableViewCell.h"

@implementation BillActionTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self)
    {
        self.textLabel.numberOfLines = 3;
        self.textLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.accessoryType = UITableViewCellAccessoryNone;
        self.editingAccessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.accessoryType = UITableViewCellAccessoryNone;
    self.editingAccessoryType = UITableViewCellAccessoryNone;
}

@end


@implementation BillActionCellMapping : StyledCellMapping

+ (id)cellMapping {
    return [self mappingForClass:[BillActionTableViewCell class]];
}

- (id)init {
    self = [super init];
    if (self) {
        self.cellClass = [BillActionTableViewCell class];
        self.useAlternatingRowColors = NO;
        self.useLargeRowHeight = YES;
        self.reuseIdentifier = NSStringFromClass([BillActionTableViewCell class]);
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

@end