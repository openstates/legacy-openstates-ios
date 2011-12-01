//
//  MultiRowCalloutCell.m
//  Created by Greg Combs on 11/29/11.
//
//  based on work at https://github.com/grgcombs/MultiRowCalloutAnnotationView
//
//  This work is licensed under the Creative Commons Attribution 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "MultiRowCalloutCell.h"
#import <QuartzCore/QuartzCore.h>
#import "SLFTheme.h"

CGSize const kMultiRowCalloutCellSize = {245,44};

@interface MultiRowCalloutCell()
- (id)initWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block;
- (IBAction)calloutAccessoryTapped:(id)sender;
@end

@implementation MultiRowCalloutCell
@synthesize userData = _userData;
@synthesize onCalloutAccessoryTapped = _onCalloutAccessoryTapped;

+ (MultiRowCalloutCell *)cellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block {
    return [[[MultiRowCalloutCell alloc] initWithImage:image title:title subtitle:subtitle userData:userData onCalloutAccessoryTapped:block] autorelease];
}

+ (MultiRowCalloutCell *)cellWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData {
    return [MultiRowCalloutCell cellWithImage:image title:title subtitle:subtitle userData:userData onCalloutAccessoryTapped:nil];
}

- (id)initWithImage:(UIImage *)image title:(NSString *)title subtitle:(NSString *)subtitle userData:(NSDictionary *)userData onCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)block {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    if (self) {
        self.onCalloutAccessoryTapped = block;
        self.title = title;
        self.subtitle = subtitle;
        self.image = image;
        self.userData = userData;
        self.opaque = YES;
        self.backgroundColor = [SLFAppearance menuSelectedTextColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        UIButton *accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        accessory.exclusiveTouch = YES;
        accessory.enabled = YES;
        [accessory addTarget: self action:@selector(calloutAccessoryTapped:) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];
        self.accessoryView = accessory;
        self.textLabel.backgroundColor = self.backgroundColor;
        self.textLabel.textColor = [SLFAppearance cellTextColor];
        self.textLabel.font = SLFFont(12);
        self.textLabel.shadowColor = [UIColor lightTextColor];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.textColor = [SLFAppearance tableBackgroundLightColor];
        self.detailTextLabel.font =	SLFFont(14);
        self.detailTextLabel.adjustsFontSizeToFitWidth = YES;
        self.detailTextLabel.backgroundColor = self.backgroundColor;
        self.detailTextLabel.shadowColor = [UIColor darkTextColor];
        self.detailTextLabel.shadowOffset = CGSizeMake(0, -1);
        self.layer.cornerRadius = 5;
    }
    return self;
}

- (void)dealloc {
    Block_release(_onCalloutAccessoryTapped);
    self.userData = nil;
    [super dealloc];
}

- (IBAction)calloutAccessoryTapped:(id)sender {
    if (self.onCalloutAccessoryTapped)
        _onCalloutAccessoryTapped(self, sender, self.userData);
}

#pragma mark - Block setters

// NOTE: Sometimes see crashes when relying on just the copy property. Using Block_copy ensures correct behavior

- (void)setOnCalloutAccessoryTapped:(MultiRowAccessoryTappedBlock)onCalloutAccessoryTapped {
    if (_onCalloutAccessoryTapped) {
        Block_release(_onCalloutAccessoryTapped);
        _onCalloutAccessoryTapped = nil;
    }
    _onCalloutAccessoryTapped = Block_copy(onCalloutAccessoryTapped);
}

#pragma mark - Convenience Accessors

- (UIImage *)image {
    return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
    self.imageView.image = image;
}

- (NSString *)title {
    return self.textLabel.text;
}

- (void)setTitle:(NSString *)title {
    self.textLabel.text = title;
}

- (NSString *)subtitle {
    return self.detailTextLabel.text;
}

- (void)setSubtitle:(NSString *)subtitle {
    self.detailTextLabel.text = subtitle;
}

@end

