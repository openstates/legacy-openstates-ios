#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>
#import "_SLFLegislator.h"

@interface SLFLegislator : _SLFLegislator {}

@property (nonatomic, readonly) NSArray *sortedPositions;
@property (nonatomic, readonly) NSString *districtMapSlug;
    //@property (nonatomic, readonly) NSString *districtMapResourcePath;
@property (nonatomic, readonly) SLFDistrictMap *hydratedDistrictMap;

@property (nonatomic, readonly) NSString *term;

- (NSComparisonResult)compareMembersByName:(SLFLegislator *)p;
- (NSString *)lastnameInitial;
- (NSString *)partyShortName;
- (NSString *)chamberShortName;
- (NSString *)districtPartyString;
- (NSString *)fullNameLastFirst;
- (NSString *)shortNameForButtons;
- (NSString *)labelSubText;
- (NSString *)title;
@end
