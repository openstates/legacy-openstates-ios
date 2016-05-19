//
//  InlineSubtitleCell.h
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "SLFTheme.h"

@interface InlineSubtitleCell : UITableViewCell
@property (nonatomic,weak) NSString *title;
@property (nonatomic,weak) NSString *subtitle;
@end

@interface InlineSubtitleMapping : StyledCellMapping
@end
