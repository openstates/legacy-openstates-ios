//
//  StretchedLabel.h
//  Created by Greg Combs on 10/6/11.
//
//  Crap by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface StretchedTitleLabel : UIView
@property(copy, nonatomic) NSAttributedString *attributedText;
- (void)setAttributedTextWithString:(NSString *)string illuminatedAtLocation:(NSInteger)location;
@end

StretchedTitleLabel * CreateOpenStatesTitleLabelForFrame(CGRect rect);
