#import "AccessorizedCalloutMapAnnotationView.h"
#import "BasicMapAnnotationView.h"

@interface AccessorizedCalloutMapAnnotationView()

@property (nonatomic, retain) UIButton *accessory;

@end


@implementation AccessorizedCalloutMapAnnotationView

@synthesize accessory = _accessory;

- (id) initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.accessory = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        self.accessory.exclusiveTouch = YES;
        self.accessory.enabled = YES;
        [self.accessory addTarget: self action: @selector(calloutAccessoryTapped) forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchCancel];
        [self addSubview:self.accessory];
    }
    return self;
}

- (void)prepareContentFrame {
    self.contentView.frame = CGRectMake(self.bounds.origin.x + 10, self.bounds.origin.y + 3, self.bounds.size.width - 20, self.contentHeight);;
}

- (void)prepareAccessoryFrame {
    self.accessory.frame = CGRectMake(self.bounds.size.width - self.accessory.frame.size.width - 15, 
                                      (self.contentHeight + 3 - self.accessory.frame.size.height) / 2, self.accessory.frame.size.width, self.accessory.frame.size.height);
}

- (void)didMoveToSuperview {
    [super didMoveToSuperview];
    [self prepareAccessoryFrame];
}

- (void) calloutAccessoryTapped {
    if ([self.mapView.delegate respondsToSelector:@selector(mapView:annotationView:calloutAccessoryControlTapped:)]) {
        [self.mapView.delegate mapView:self.mapView annotationView:self.parentAnnotationView calloutAccessoryControlTapped:self.accessory];
    }
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *hitView = [super hitTest:point withEvent:event];
    
    //If the accessory is hit, the map view may want to select an annotation sitting below it, so we must disable the other annotations
    //But not the parent because that will screw up the selection
    if (hitView == self.accessory) {
        [self preventParentSelectionChange];
        [self performSelector:@selector(allowParentSelectionChange) withObject:nil afterDelay:1.0];
        for (UIView *sibling in self.superview.subviews) {
            if ([sibling isKindOfClass:[MKAnnotationView class]] && sibling != self.parentAnnotationView) {
                ((MKAnnotationView *)sibling).enabled = NO;
                [self performSelector:@selector(enableSibling:) withObject:sibling afterDelay:1.0];
            }
        }
    }
    return hitView;
}

- (void) enableSibling:(UIView *)sibling {
    ((MKAnnotationView *)sibling).enabled = YES;
}

- (void) preventParentSelectionChange {
    BasicMapAnnotationView *parentView = (BasicMapAnnotationView *)self.parentAnnotationView;
    parentView.preventSelectionChange = YES;
}

- (void) allowParentSelectionChange {
    //The MapView may think it has deselected the pin, so we should re-select it
    [self.mapView selectAnnotation:self.parentAnnotationView.annotation animated:NO];
    BasicMapAnnotationView *parentView = (BasicMapAnnotationView *)self.parentAnnotationView;
    parentView.preventSelectionChange = NO;
}

@end
