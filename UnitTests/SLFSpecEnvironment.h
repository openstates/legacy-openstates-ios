    // The following is practically verbatim of RestKit's RKSpecEnvironment.

#import <Foundation/Foundation.h>
#import <RestKit/RestKit.h>
#import <RestKit/CoreData/CoreData.h>

NSString* SLFSpecGetBaseURL(void);
void SLFSpecStubNetworkAvailability(BOOL isNetworkAvailable);
RKClient* SLFSpecNewClient(void);
RKObjectManager* SLFSpecNewObjectManager(void);
RKManagedObjectStore* SLFSpecNewManagedObjectStore(void);
void SLFSpecClearCacheDirectory(void);
void SLFSpecSpinRunLoop();
void SLFSpecSpinRunLoopWithDuration(NSTimeInterval timeInterval);
NSString* SLFSpecReadFixture(NSString* fileName);
id SLFSpecParseFixture(NSString* fileName);
