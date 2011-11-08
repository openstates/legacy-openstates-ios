#import "BasicMapAnnotationView.h"


@implementation BasicMapAnnotationView

@synthesize preventSelectionChange = _preventSelectionChange;

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    if (!self.preventSelectionChange) {
        [super setSelected:selected animated: animated];
    }
}

@end
