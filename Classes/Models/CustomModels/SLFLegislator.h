#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFLegislator.h"

@class SLFState;
@class SLFChamber;
@interface SLFLegislator : _SLFLegislator {}
@property (nonatomic,readonly) SLFState *state;
@property (nonatomic, readonly) NSArray *sortedPositions;
@property (nonatomic, readonly) NSString *districtID;
@property (nonatomic, readonly) SLFDistrict *hydratedDistrict;
@property (nonatomic, readonly) NSString *term;
@property (nonatomic, readonly) SLFChamber *chamberObj;
@property (nonatomic, readonly) NSString *fullNameLastFirst;

- (NSComparisonResult)compareMembersByName:(SLFLegislator *)p;
- (NSString *)lastnameInitial;
- (NSString *)partyShortName;
- (NSString *)chamberShortName;
- (NSString *)districtPartyString;
- (NSString *)shortNameForButtons;
- (NSString *)labelSubText;
- (NSString *)title;
@end

    // Political Party
enum kParties {
    kUnknownParty = 0,
    DEMOCRAT,
    REPUBLICAN
};

