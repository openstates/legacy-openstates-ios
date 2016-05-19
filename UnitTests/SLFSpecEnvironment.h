// The following is practically verbatim of RestKit's RKSpecEnvironment.

#import <Foundation/Foundation.h>
#import <SLFRestKit/SLFRestKit.h>

NSURL* SLFSpecGetBaseURL(void);
void SLFSpecStubNetworkAvailability(BOOL isNetworkAvailable);
RKClient* SLFSpecNewClient(void);
RKObjectManager* SLFSpecNewObjectManager(void);
RKManagedObjectStore* SLFSpecNewManagedObjectStore(void);
void SLFSpecClearCacheDirectory(void);
void SLFSpecSpinRunLoop();
void SLFSpecSpinRunLoopWithDuration(NSTimeInterval timeInterval);
NSString* SLFSpecReadFixture(NSString* fileName);
id SLFSpecParseFixture(NSString* fileName);
void SLFSpecRestKitEnvironment(void);
NSManagedObjectModel* SLFSpecGetManagedObjectModel(void);
BOOL IsEmpty(NSObject * thing);