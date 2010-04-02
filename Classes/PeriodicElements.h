/*

File: PeriodicElements.h
Abstract: Encapsulates the collection of elements and returns them in presorted
states.

Version: 1.7

*/

#import <Foundation/Foundation.h>


@interface PeriodicElements : NSObject {
	NSMutableDictionary *elementsDictionary;
	NSMutableDictionary *statesDictionary;
	
	NSMutableDictionary *nameIndexesDictionary;
	NSArray *elementNameIndexArray;
	
	NSArray *elementsSortedByNumber;
	NSArray *elementsSortedBySymbol;
	NSArray *elementPhysicalStatesArray;

}

@property (nonatomic,retain) NSMutableDictionary *statesDictionary;
@property (nonatomic,retain) NSMutableDictionary *elementsDictionary;
@property (nonatomic,retain) NSMutableDictionary *nameIndexesDictionary;
@property (nonatomic,retain) NSArray *elementNameIndexArray;
@property (nonatomic,retain) NSArray *elementsSortedByNumber;
@property (nonatomic,retain) NSArray *elementsSortedBySymbol;
@property (nonatomic,retain) NSArray *elementPhysicalStatesArray;

+ (PeriodicElements*)sharedPeriodicElements;
- (NSArray *)elementsWithPhysicalState:(NSString*)aState;

- (NSArray *)elementsWithInitialLetter:(NSString*)aKey;

 
@end
