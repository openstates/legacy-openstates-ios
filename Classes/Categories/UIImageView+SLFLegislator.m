//
//  UIImageView+SLFLegislator.m
//  Created by Greg Combs on 2/3/12.
//
//  OpenStates by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


#import "UIImageView+SLFLegislator.h"
#import "UIImageView+AFNetworking.h"
#import "SLFReachable.h"
#import "SLFDataModels.h"

static UIImage *placeholderImage;

@implementation UIImageView (SLFLegislator)

- (void)setImageWithLegislator:(SLFLegislator *)legislator {
    if (!legislator) {
        self.image = nil;
        return;
    }
    NSString *photoURL = legislator.normalizedPhotoURL;
    if (!placeholderImage)
        placeholderImage = [[UIImage imageNamed:@"placeholder"] retain];
    if (SLFIsReachableAddressNoAlert(photoURL)) {
        [self setImageWithURL:[NSURL URLWithString:photoURL] placeholderImage:placeholderImage];
        return;
    }
    [self setImage:placeholderImage];
}


@end
