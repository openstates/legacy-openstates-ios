//  LocalyticsSession.m
//  Copyright (C) 2009 Char Software Inc., DBA Localytics
// 
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.  
// 
// Please visit www.localytics.com for more information.

#import "LocalyticsSession.h"
#import "WebserviceConstants.h"
#import "UploaderThread.h"

#include <sys/types.h>
#include <sys/sysctl.h>
#include <mach/mach.h>

#pragma mark Constants
#define CLIENT_VERSION      @"iphone_1.7"	// The version of this library
#define LOCALYTICS_DIR      @"localytics"	// The directory to store the Localytics files in
#define SESSION_FILE_PREFIX  @"s_"			// The prefix denoting the file for a session.
#define CLOSE_SESSION_FILE_PREFIX @"c_"		// The prefix denoting the file for close events for a session
#define MAX_NUM_SESSIONS    25				// Max number of sessions to store on disk
#define OPT_OUT_FILENAME    @"OPT_OUT"      // The opt-out file.  If present, Localytics is opted out
#define OPT_SESSION_FILE    @"opt_session"  // The file used to store the optin/out YML for upload

#define PATH_TO_APT 		@"/private/var/lib/apt/"

#define DEFAULT_BACKGROUND_SESSION_TIMEOUT 15   // Default value for how many seconds a session persists when App shifts to the background.

// The singleton session object.

@interface LocalyticsSession() 

#pragma mark @property Member Variables
@property (nonatomic, retain) NSString *localyticsFilePath;
@property (nonatomic, retain) NSString *optOutFilePath;
@property (nonatomic, retain) NSString *sessionFilename;
@property (nonatomic, retain) NSString *closeSessionFilename;
@property (nonatomic, retain) NSString *fullPathToSession;
@property (nonatomic, retain) NSString *fullPathToCloseSession;
@property (nonatomic, retain) NSString *sessionUUID;
@property (nonatomic, retain) NSString *applicationKey;
@property (nonatomic, retain) NSDate *sessionCloseTime;
@property (nonatomic, assign) BOOL sessionHasBeenOpen;

#pragma mark Private Methods
- (BOOL)createEmptySessionFile:(NSString *)fileName;
- (void)appendDataToFile:(NSString *)fileName data:(NSString *)data;
- (NSString *)getOpenSessionString;
- (void)createOptEvent:(BOOL)optState;
- (void)logMessage:(NSString *)message;
- (NSString *)getRandomUUID;
- (NSString *)formatControllerValue:(NSString *)paramName paramValue:(NSString *)paramValue;
- (NSString *)formatDatapoint:(NSString *)paramName paramValue:(NSString *)paramValue;
- (NSString *) escapeString:(NSString *)input;
- (NSString *)getGlobalDeviceId;
- (NSString *)getAppVersion;
- (NSString *)getTimeAsDatetime;
- (BOOL)isDeviceJailbroken;
- (NSString *)getDeviceModel;
- (NSString *)modelSizeString;
- (double)availableMemory;
- (void)reopenPreviousSession;
@end

@implementation LocalyticsSession

#pragma mark synthesis
@synthesize localyticsFilePath = _localyticsFilePath;
@synthesize optOutFilePath     = _optOutFilePath;
@synthesize sessionFilename    = _sessionFilename;
@synthesize closeSessionFilename    = _closeSessionFilename;
@synthesize fullPathToSession  = _fullPathToSession;
@synthesize fullPathToCloseSession  = _fullPathToCloseSession;
@synthesize sessionUUID        = _sessionUUID; 
@synthesize applicationKey     = _applicationKey;
@synthesize sessionCloseTime     = _sessionCloseTime;
@synthesize isSessionOpen      = _isSessionOpen;
@synthesize hasInitialized     = _hasInitialized;
@synthesize backgroundSessionTimeout = _backgroundSessionTimeout;
@synthesize sessionHasBeenOpen = _sessionHasBeenOpen;
 
#pragma mark Singleton Class

+ (id)sharedLocalyticsSession
{
	static dispatch_once_t pred;
	static LocalyticsSession *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

#pragma mark Object Initialization

- (LocalyticsSession *)init {
	if ((self = [super init])) {
		
		self.isSessionOpen  = NO;
		self.hasInitialized = NO;
		self.backgroundSessionTimeout = DEFAULT_BACKGROUND_SESSION_TIMEOUT;
		self.sessionHasBeenOpen = NO;
	}
	return self;
}

#pragma mark Public Methods
- (void)LocalyticsSession:(NSString *)appKey {	
	// If the session has already initialized, don't bother doing it again.
	if(self.hasInitialized) 
	{
		[self logMessage:@"Object has already been initialized."];
		return;
	}	

	@try {
		// Get the path to store the files
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);

		NSString *documentsDirectory = [paths objectAtIndex:0];
		if (!documentsDirectory) return;

		self.localyticsFilePath = [NSString stringWithFormat:@"%@/%@/", documentsDirectory, LOCALYTICS_DIR];
		self.optOutFilePath = [NSString stringWithFormat:@"%@/%@/%@", documentsDirectory, LOCALYTICS_DIR, OPT_OUT_FILENAME];
		self.applicationKey = appKey;
		self.hasInitialized = YES;
		//[self logMessage:[@"Object Initialized.  Application's key is: " stringByAppendingString:self.applicationKey]];
		[self logMessage:[@"File Path is: " stringByAppendingString:self.localyticsFilePath]];
	}
	@catch (NSException * e) {}
}

- (void)startSession:(NSString *)appKey {
	[self LocalyticsSession:appKey];
	[self open];
	[self upload];
}

- (void)open {
	// There are a number of conditions in which nothing should be done:
	if (self.hasInitialized == NO ||  // the session object has not yet initialized
      self.isSessionOpen == YES)  // session has already been opened
	{
		[self logMessage:@"Unable to open session."];
		return; 
	}
	
	if([self isOptedIn] == false) {
//		[self logMessage:@"Can't open session because user is opted out."];
		return;
	}

	@try {
		self.isSessionOpen = YES;
    self.sessionHasBeenOpen = YES;

		// Because no data can get writen before open is called, this is a safe place to get the path
		// for the session files, and create it if it doesn't exist.
    NSError *error;
		NSFileManager *openFileManager = [NSFileManager defaultManager];
		if ([openFileManager fileExistsAtPath:self.localyticsFilePath] == NO) {
			[openFileManager createDirectoryAtPath:self.localyticsFilePath
                 withIntermediateDirectories:NO
                                  attributes:nil
                                       error:&error];
		}
		NSArray *localFiles = [openFileManager contentsOfDirectoryAtPath:self.localyticsFilePath error:nil];

		// If there are already too many files on the disk, don't bother collecting any more data. 
		if (([localFiles count]) >= MAX_NUM_SESSIONS && [localFiles count] > 0) {
			[self logMessage:@"Maximum number of sessions have already been queued on disk."];
			self.isSessionOpen = NO;
			return;
		}

		// Determine the filename and full path
    // Close events are stored in a filename with an alternative suffix, so that they
    // can be deleted when a session resumes
		self.sessionUUID = [self getRandomUUID];
		self.sessionFilename = [NSString stringWithFormat:@"%@%@.yml", SESSION_FILE_PREFIX, self.sessionUUID];	
		self.closeSessionFilename = [NSString stringWithFormat:@"%@%@.yml", CLOSE_SESSION_FILE_PREFIX, self.sessionUUID];	
		self.fullPathToSession = [self.localyticsFilePath stringByAppendingPathComponent:self.sessionFilename];
		self.fullPathToCloseSession = [self.localyticsFilePath stringByAppendingPathComponent:self.closeSessionFilename];

		// Store the blob
		[self appendDataToFile:self.fullPathToSession data:[self getOpenSessionString]];

		[self logMessage:[@"Succesfully opened session. UUID is: " stringByAppendingString:self.sessionUUID]];
		[self logMessage:[@"Session file is: " stringByAppendingString:self.sessionFilename]];
		[self logMessage:[@"Close session file is: " stringByAppendingString:self.closeSessionFilename]];
	}
	@catch (NSException * e) {}
}

- (void)resume {
  // Do nothing if session is already open
  if(self.isSessionOpen == YES)
    return;
  // conditions for resuming previous session
  if(self.sessionHasBeenOpen &&
     (!self.sessionCloseTime ||
      [self.sessionCloseTime timeIntervalSinceNow]*-1 <= self.backgroundSessionTimeout)) {
    [self reopenPreviousSession];
  } else {
    // otherwise open new session and upload
    [self open];
  }
  self.sessionCloseTime = nil;
}

- (void)close {
	// Do nothing if the session is not open
	if (self.isSessionOpen == NO)
	{
		[self logMessage:@"Unable to close session"];
		return; 
	}

  // Save time of close
  self.sessionCloseTime = [NSDate date];

	@try {
		// Create the YML representing the close blob
		NSMutableString *closeString = [[NSMutableString alloc] init];
		[closeString appendString:CONTROLLER_SESSION];
		[closeString appendString:ACTION_UPDATE];
		[closeString appendString:[self formatControllerValue:PARAM_UUID paramValue:self.sessionUUID]];
		[closeString appendString:TARGET_SESSION];
		[closeString appendString:[self formatDatapoint:PARAM_CLIENT_CLOSE_TIME paramValue:[self getTimeAsDatetime]]];
		[closeString appendString:[self formatDatapoint:PARAM_APP_KEY paramValue:self.applicationKey]];
		
		[self appendDataToFile:self.fullPathToCloseSession data:closeString];
		[closeString release];

		self.isSessionOpen = NO;    // Session is no longer open
		[self logMessage:@"Session succesfully closed."];
	}
	@catch (NSException * e) {}
}

- (void)setOptIn:(BOOL)optedIn {
	if([self isOptedIn] == optedIn) 
	{
		[self logMessage:@"Opt status unchanged."];
		return;
	}
		
	if(optedIn == true)
	{
		[[NSFileManager defaultManager] removeItemAtPath:self.optOutFilePath error:false];
		[self createOptEvent:YES];
		[self logMessage:@"Application opted in"];
	}
	else
	{
		[self createEmptySessionFile:self.optOutFilePath];
		[self createOptEvent:NO];
		[self logMessage:@"Application opted out"];
		
		// Disable all further Localytics calls for this and future sessions
		// This should not be flipped when the session is opted back in because that
		// would create an incomplete session
		self.isSessionOpen = NO;
	}	
}

- (BOOL)isOptedIn {
	// if the opt-out file exists, Localytics is not opted in.
	return [[NSFileManager defaultManager] fileExistsAtPath:self.optOutFilePath] == false;
}

// A convenience function for users who don't wish to add attributes
- (void)tagEvent:(NSString *)event {
	[self tagEvent:event attributes:nil];
}

- (void)tagEvent:(NSString *)event attributes:(NSDictionary *)attributes {
	// Do nothing if the session is not open.
	if (self.isSessionOpen == NO) 
	{
		[self logMessage:@"Cannot tag an event because the session is not open."];
		return; 
	}
	
	@try {
		// Create the YML for the event
		NSMutableString *eventString = [[NSMutableString alloc] init];
		[eventString appendString:CONTROLLER_EVENT];
		[eventString appendString:ACTION_CREATE];
		[eventString appendString:TARGET_EVENT];		
		[eventString appendString:[self formatDatapoint:PARAM_UUID         paramValue:[self getRandomUUID]]];
		[eventString appendString:[self formatDatapoint:PARAM_APP_KEY      paramValue:self.applicationKey]];		
		[eventString appendString:[self formatDatapoint:PARAM_SESSION_UUID paramValue:self.sessionUUID]];
		[eventString appendString:[self formatDatapoint:PARAM_CLIENT_TIME  paramValue:[self getTimeAsDatetime]]];
		[eventString appendString:[self formatDatapoint:PARAM_EVENT_NAME   paramValue:event]];
		
		// If there are any attributes for this event, add them as a hash
		if(attributes != nil)
		{
			[eventString appendString:[self formatDatapoint:PARAM_EVENT_ATTRS paramValue:nil]];
			NSEnumerator * pairs = [attributes keyEnumerator];
			id key;		
			while ((key = [pairs nextObject])) 
			{
				// Move the key/value pairs in so they are under the attrs: line
				// Have to escape the paramName because this is the only param that doens't come from the constants list.
				[eventString appendString:
							[self formatDatapoint:[@" " stringByAppendingString:[self escapeString:[key description]]]
									   paramValue:[ [attributes valueForKey:key] description ]]];
							 
			}			
		}
		
		[self appendDataToFile:self.fullPathToSession data:(NSString *)eventString];
		[eventString release];
		
		[self logMessage:[@"Tagged event: " stringByAppendingString:event]];
	}
	@catch (NSException * e) {}
}


- (void)upload {
	@try {
		[[UploaderThread sharedUploaderThread] UploaderThread:self.localyticsFilePath];
	}
	@catch (NSException * e) {}
}

#pragma mark Private Methods
/*!
 @method reopenPreviousSession
 @abstract reopens the previous session, using previous session variables.
 Remove close session file if it exists
 If there was no previous session, do nothing
*/
-(void) reopenPreviousSession {
  if(self.sessionHasBeenOpen == NO){
		[self logMessage:@"Unable to reopen previous session, because a previous session was never opened."];
    return;
  }

  //Remove close session file if it exists
  NSFileManager *reopenFileManager = [NSFileManager defaultManager];
  if([reopenFileManager fileExistsAtPath:self.fullPathToCloseSession] == YES) {
    [reopenFileManager removeItemAtPath:self.fullPathToCloseSession error:nil];			
  }

  self.isSessionOpen = YES;
}

/*!
 @method appendDataToFile
 @abstract Uses the NSFileManager writeToFile to write and flush a string to the end of a text file.
 If the file does not exist, a new one is created.
 @param fileName Text file to append data to.  
 @param data String to be appended
 */
- (void)appendDataToFile:(NSString *)fileName data:(NSString *)data {
	// Create the file if it does not already exist
	NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:fileName] == NO) {
		[self createEmptySessionFile:fileName];
	}

	// Append the contents of data to the end of the file
	NSFileHandle *currentYML = [NSFileHandle fileHandleForWritingAtPath:fileName];
	[currentYML truncateFileAtOffset:[currentYML seekToEndOfFile]];
	[currentYML writeData:[data dataUsingEncoding:NSASCIIStringEncoding]];
	[currentYML closeFile];
}

/*!
 @method createEmptySessionFile
 @abstract Creates an empty session File for events to be written to
 @param filename relative path for the file to be created
 @return YES if the file was created, NO if not
 */
- (BOOL)createEmptySessionFile:(NSString *)fileName {
	NSMutableData *newFile = [[[NSMutableData alloc] init] autorelease];
	NSFileManager *fileManager = [NSFileManager defaultManager];
	return [fileManager createFileAtPath:fileName contents:newFile attributes:nil];
}

/*!
 @method getOpenSessionString
 @abstract Creates the YAML string for the open session event.
 Collects all the basic session datapoints and writes them out as a YAML string.  
 @return The YAML blob for the open session event.
 */
- (NSString *)getOpenSessionString {
		
	NSMutableString *openString = [[[NSMutableString alloc] init] autorelease];
	UIDevice *thisDevice = [UIDevice currentDevice];
	NSLocale *locale = [NSLocale currentLocale];
	NSLocale *english = [[[NSLocale alloc] initWithLocaleIdentifier: @"en_US"] autorelease];
	NSLocale *device_locale = [[NSLocale preferredLanguages] objectAtIndex:0];	
    NSString *device_language = [english displayNameForKey:NSLocaleIdentifier value:device_locale];
	NSString *locale_country = [english displayNameForKey:NSLocaleCountryCode value:[locale objectForKey:NSLocaleCountryCode]];			
	
	[openString appendString:CONTROLLER_SESSION];
	[openString appendString:ACTION_CREATE];
	[openString appendString:TARGET_SESSION];

	// Application and session information
	[openString appendString:[self formatDatapoint:PARAM_UUID			 paramValue:self.sessionUUID]];
	[openString appendString:[self formatDatapoint:PARAM_APP_KEY		 paramValue:self.applicationKey]];
	[openString appendString:[self formatDatapoint:PARAM_APP_VERSION	 paramValue:[self getAppVersion]]];
	[openString appendString:[self formatDatapoint:PARAM_LIBRARY_VERSION paramValue:CLIENT_VERSION]];
	[openString appendString:[self formatDatapoint:PARAM_CLIENT_TIME     paramValue:[self getTimeAsDatetime]]];

	// Other device information
	[openString appendString:[self formatDatapoint:PARAM_DEVICE_UUID	   paramValue:[self getGlobalDeviceId]]];
	[openString appendString:[self formatDatapoint:PARAM_DEVICE_PLATFORM   paramValue:[thisDevice model]]];
	[openString appendString:[self formatDatapoint:PARAM_DEVICE_OS_VERSION paramValue:[thisDevice systemVersion]]];
	[openString appendString:[self formatDatapoint:PARAM_DEVICE_MODEL      paramValue:[self getDeviceModel]]];
	
	[openString appendString:[NSString stringWithFormat:@"    dmem: %d\n", [self availableMemory]]];
	
	[openString appendString:[self formatDatapoint:PARAM_LOCALE_LANGUAGE   paramValue:device_language]];		
	[openString appendString:[self formatDatapoint:PARAM_LOCALE_COUNTRY    paramValue:locale_country]];		
	[openString appendString:[self formatDatapoint:PARAM_DEVICE_COUNTRY    paramValue:[locale objectForKey:NSLocaleCountryCode]]];	

	[openString appendString:[NSString stringWithFormat:@"    j: %@\n", [self isDeviceJailbroken] ? @"true" : @"false"]];

	return (NSString *)openString;
}

/*!
 @method createOptEvent
 @abstract Generates the YML for an opt event (user opting in or out).  The same file is
 used every time to ensure proper ordering.  This file will be uploaded by the uploader.
 */
- (void)createOptEvent:(BOOL) optState {
	NSMutableString *optString = [[[NSMutableString alloc] init] autorelease];
	[optString appendString:CONTROLLER_OPT];
	[optString appendString:ACTION_OPT];
	[optString appendString:TARGET_OPT];
	
	[optString appendString:[self formatDatapoint:PARAM_DEVICE_UUID paramValue:[self getGlobalDeviceId]]];
	[optString appendString:[self formatDatapoint:PARAM_APP_KEY		paramValue:self.applicationKey]];
	[optString appendString:[self formatDatapoint:PARAM_OPT_VALUE   paramValue:(optState ? @"true" : @"false")]];	
	[optString appendString:[self formatDatapoint:PARAM_CLIENT_TIME     paramValue:[self getTimeAsDatetime]]];
	
	// Store the blob
	[self appendDataToFile:[self.localyticsFilePath 
		stringByAppendingPathComponent:[NSString 
			stringWithFormat:@"%@%@.yml", SESSION_FILE_PREFIX, OPT_SESSION_FILE]]
		data:(NSString *)optString];	 
}

/*!
 @method logMessage
 @abstract Logs a message with (localytics) prepended to it.
 @param message The message to log
 */
- (void)logMessage:(NSString *)message
{
	printf("[%s] (localytics) %s\n", [[[NSDate date] description] UTF8String], [message UTF8String]);
}

#pragma mark Datapoint Functions
/*!
 @method getRandomUUID
 @abstract Generates a random UUID
 @return NSString containing the new UUID
 */
- (NSString *)getRandomUUID {
	CFUUIDRef theUUID = CFUUIDCreate(NULL);
	CFStringRef stringUUID = CFUUIDCreateString(NULL, theUUID);
	CFRelease(theUUID);
	return [(NSString *)stringUUID autorelease];
}

/*!
 @method formatControllerValue
 @abstract Returns the given key/value pair as a YAML string.  This string is intended to be
 used to define values for the first level of data in the YAML file.  This is
 different from the datapoints which belong another level in. 
 @param paramName The name of the parameter 
 @param paramValue The value of the parameter
 @return a YAML string which can be dumped to the YAML file
 */
- (NSString *)formatControllerValue:(NSString *)paramName paramValue:(NSString *)paramValue {
	// The params are stored in the second tier of the YAML data.
	// so with spacing, the expected result is: "    paramname: paramvalue\n"
	NSMutableString *formattedString = [[[NSMutableString alloc] initWithString:
										 [NSString stringWithFormat:@"  %@: ", paramName]] autorelease];	
	
	if (paramValue != nil)	// It is possible for some parameter values to be nil. 
	{
		[formattedString appendString:[self escapeString:paramValue]];
	}
	
	[formattedString appendString:@"\n"];	
	return formattedString;
}

/*!
 @method formatDatapoint
 @abstract Returns the given datapoint as a formatted YAML string to be stored in the session file.
 @param paramName Name of the parameter as expected by the webservice
 @param paramValue The parameter's value
 @return the YAML formatted string, complete with trailing newline.
 */
- (NSString *)formatDatapoint:(NSString *)paramName paramValue:(NSString *)paramValue {	
	// A datapoint variable is exactly the same as a controller value, except it has
	// two leading spaces which move it to the second level of data.
	// With spacing, the expected result is: "    paramname:paramvalue\n"
	return [NSString stringWithFormat:@"  %@", [self formatControllerValue:paramName paramValue:paramValue]];
}

/*!
 @method escapeString
 @abstract Formats the input string so it fits nicely in a YML document.  This includes
 sorrounding it with quotes and escaping quote and slash characters.
 @return The escaped version of the input string
 */
- (NSString *) escapeString:(NSString *)input
{		
	NSString *output = [input stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
	output = [output stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
	return [NSString stringWithFormat:@"\"%@\"", output];
}

/*!
 @method getGlobalDeviceId
 @abstract A unique device identifier is a hash value composed from various hardware identifiers such
 as the device’s serial number. It is guaranteed to be unique for every device but cannot 
 be tied to a user account. [UIDevice Class Reference]
 @return An 1-way hashed identifier unique to this device.
 */
- (NSString *)getGlobalDeviceId {
	NSString *systemId = [[UIDevice currentDevice] uniqueIdentifier];
	if (systemId == nil) {
		return nil;
	}
	return systemId;
}

/*!
 @method getAppVersion
 @abstract Gets the pretty string for this application's version.
 @return The application's version as a pretty string
 */
- (NSString *)getAppVersion {
	return [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];	
}
		
/*!
 @method getTimeAsDatetime
 @abstract Gets the current time, along with local timezone, formatted as a DateTime for the webservice. 
 @return a DateTime of the current local time and timezone.
 */
- (NSString *)getTimeAsDatetime {
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss-00:00"];
	[dateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
	return [dateFormatter stringFromDate:[NSDate date]];
}

/*!
 @method isDeviceJailbroken
 @abstract checks for the existance of apt to determine whether the user is running any
 of the jailbroken app sources.
 @return whether or not the device is jailbroken.
 */
- (BOOL) isDeviceJailbroken {
	NSFileManager *sessionFileManager = [NSFileManager defaultManager];	
	return [sessionFileManager fileExistsAtPath:PATH_TO_APT];
}

/*!
 @method getDeviceModel
 @abstract Gets the device model string. 
 @return a platform string identifying the device
 */
- (NSString *)getDeviceModel {
	char *buffer[256] = { 0 };
	size_t size = sizeof(buffer);
    sysctlbyname("hw.machine", buffer, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:(const char*)buffer
											encoding:NSUTF8StringEncoding];
	return platform;
}	

/*!
 @method modelSizeString
 @abstract Checks how much disk space is reported and uses that to determine the model
 @return A string identifying the model, e.g. 8GB, 16GB, etc
 */
- (NSString *) modelSizeString {
	
#if TARGET_IPHONE_SIMULATOR
	return @"simulator";
#endif
	
	// User partition
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *stats = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[path lastObject] error:nil];  
	uint64_t user = [[stats objectForKey:NSFileSystemSize] longLongValue];
	
	// System partition
	path = NSSearchPathForDirectoriesInDomains(NSApplicationDirectory, NSSystemDomainMask, YES);
    stats = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[path lastObject] error:nil];  
	uint64_t system = [[stats objectForKey:NSFileSystemSize] longLongValue];
	
	// Add up and convert to gigabytes
	// TODO: seem to be missing a system partiton or two...
	NSInteger size = (user + system) >> 30;
	
	// Find nearest power of 2 (eg, 1,2,4,8,16,32,etc).  Over 64 and we return 0
	for (NSInteger gig = 1; gig < 257; gig = gig << 1) {
		if (size < gig)
			return [NSString stringWithFormat:@"%dGB", gig];
	}
	return nil;
}

/*!
 @method availableMemory
 @abstract Reports how much memory is available  
 @return A double containing the available free memory
 */
- (double)availableMemory {
	double result = NSNotFound;
	vm_statistics_data_t stats;
	mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
	if (!host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&stats, &count))
		result = vm_page_size * stats.free_count;

	return result;
}

- (void)dealloc {
	[_localyticsFilePath release];
	[_sessionFilename release];
	[_closeSessionFilename release];
	[_sessionUUID release];
	[_applicationKey release];
	[_sessionCloseTime release];
	[_fullPathToSession release];
	[_fullPathToCloseSession release];
	[super dealloc];
}

@end
