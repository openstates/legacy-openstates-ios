#import "_SLFLegislator.h"
#import <CoreLocation/CoreLocation.h>

@class MultiRowCalloutCell;
@class RKManagedObjectMapping;
@class SLFState;
@class SLFChamber;
@class SLFParty;
@interface SLFLegislator : _SLFLegislator {}
@property (weak, nonatomic,readonly) SLFState *state;
@property (weak, nonatomic, readonly) NSArray *sortedRoles;
@property (weak, nonatomic, readonly) NSString *districtID;
@property (weak, nonatomic, readonly) SLFDistrict *hydratedDistrict;
@property (weak, nonatomic, readonly) NSString *term;
@property (weak, nonatomic, readonly) SLFParty *partyObj;
@property (weak, nonatomic, readonly) SLFChamber *chamberObj;
@property (weak, nonatomic, readonly) NSString *fullNameLastFirst;
@property (weak, nonatomic, readonly) NSString *lastnameInitial;
@property (weak, nonatomic, readonly) NSString *chamberShortName;
@property (weak, nonatomic, readonly) NSString *formalName;
@property (weak, nonatomic, readonly) NSString *demoLongName;
@property (weak, nonatomic, readonly) NSString *districtMapLabel;
@property (weak, nonatomic, readonly) NSString *subtitle;
@property (weak, nonatomic, readonly) NSString *districtLongName;
@property (weak, nonatomic, readonly) NSString *districtShortName;
@property (weak, nonatomic, readonly) NSString *normalizedPhotoURL;
@property (weak, nonatomic, readonly) MultiRowCalloutCell *calloutCell;

+ (NSArray *)sortDescriptors;
- (NSString *)districtPartyString;
- (NSString *)title;
+ (RKManagedObjectMapping *)mappingWithStateMapping:(RKManagedObjectMapping *)stateMapping;
+ (NSString *)resourcePathForCoordinate:(CLLocationCoordinate2D)coordinate;
+ (NSString *)resourcePathForAllWithStateID:(NSString *)stateID;
@end
