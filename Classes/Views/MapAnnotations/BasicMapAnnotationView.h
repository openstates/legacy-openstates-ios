#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface BasicMapAnnotationView : MKPinAnnotationView {
    BOOL _preventSelectionChange;
}

@property (nonatomic) BOOL preventSelectionChange;

@end
