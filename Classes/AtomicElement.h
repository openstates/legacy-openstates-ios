/*

File: AtomicElement.h
Abstract: Simple object that encapsulate the Atomic Element values and images
for the states.

Version: 1.7

*/

#import <Foundation/Foundation.h>


@interface AtomicElement : NSObject {
	NSNumber *atomicNumber;
	NSString *name;
	NSString *symbol;
	NSString *state;
	NSNumber *group;
	NSNumber *period;
	NSNumber *vertPos;
	NSNumber *horizPos;	
	BOOL radioactive;
	NSString *atomicWeight;
	NSString *discoveryYear;
	
}
 
- (id)initWithDictionary:(NSDictionary *)aDictionary;

@property (nonatomic, retain) NSNumber *atomicNumber;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *symbol;
@property (nonatomic, retain) NSString *state;
@property (nonatomic, retain) NSNumber *group;
@property (nonatomic, retain) NSNumber *period;
@property (nonatomic, retain) NSNumber *vertPos;
@property (nonatomic, retain) NSNumber *horizPos;

@property (readonly) UIImage *stateImageForAtomicElementTileView;
@property (readonly) UIImage *flipperImageForAtomicElementNavigationItem;
@property (readonly) UIImage *stateImageForAtomicElementView;
@property (readonly) CGPoint positionForElement;
@property  BOOL radioactive;
@property (nonatomic, retain) NSString *atomicWeight;
@property (nonatomic, retain) NSString *discoveryYear;


@end
