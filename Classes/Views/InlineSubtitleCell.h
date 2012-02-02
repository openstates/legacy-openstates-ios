//
//  InlineSubtitleCell.h
//  Created by Greg Combs on 2/1/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFTheme.h"

@interface InlineSubtitleCell : UITableViewCell
@property (nonatomic,assign) NSString *title;
@property (nonatomic,assign) NSString *subtitle;
@end

@interface InlineSubtitleMapping : StyledCellMapping
@end