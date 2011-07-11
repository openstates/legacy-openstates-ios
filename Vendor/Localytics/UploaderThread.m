//  UploaderThread.m
//  Copyright (C) 2009 Char Software Inc., DBA Localytics
// 
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.  
// 
// Please visit www.localytics.com for more information.

#import "UploaderThread.h"
#import "LocalyticsSession.h"

#define SESSION_FILE_PREFIX  @"s_"   // The prefix denoting the file for a session.
#define CLOSE_SESSION_FILE_PREFIX @"c_"	// The prefix denoting the file for close events for a session
#define UPLOAD_FILE_PREFIX   @"u_"   // The prefix denoting a file to be uploaded
#define UPLOAD_FILE_FORMAT   @"u_%@" // The string format for an upload file.

#define ANALYTICS_URL        @"http://analytics.localytics.com/api/datapoints/bulk"	// url to send the datapoints to

@interface UploaderThread ()
- (void)logMessage:(NSString *)message;
- (void)renameOrAppendFile:(NSFileManager *)fileManager origin:(NSString *)originalFilename destination:(NSString *)destFilename;
- (void)complete;
@end

@implementation UploaderThread

@synthesize uploadConnection   = _uploadConnection;
@synthesize localyticsFilePath = _localyticsFilePath;
@synthesize isUploading        = _isUploading;

#pragma mark Singleton Class

+ (id)sharedUploaderThread
{
	static dispatch_once_t pred;
	static UploaderThread *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}

#pragma mark Object Initialization
- (UploaderThread *)init {
	if ((self = [super init])) {
		self.isUploading = false;
		self.uploadConnection = nil;
	}
	return self;
}

#pragma mark Class Methods
- (void)UploaderThread:(NSString *)localyticsFilePath {
	int currentFile;
	
	// Do nothing if already uploading.
	if (self.uploadConnection != nil || self.isUploading == true) 
	{
		//[self logMessage:@"Upload already in progress.  Aborting.."];
		return;
	}
	
	[self logMessage:@"Beginning upload process"];
	self.isUploading = true;
	self.localyticsFilePath = localyticsFilePath;
	
	NSFileManager *sessionFileManager = [NSFileManager defaultManager];	
	if(self.localyticsFilePath == nil || ([sessionFileManager fileExistsAtPath:self.localyticsFilePath] == NO))
	{
		[self logMessage:@"Localtyics dir does not exist, aborting upload."];
		self.isUploading = false;
		return;
	}
	
	// Prepare the data for upload.  The upload could take a long time, so some effort has to be made to be sure that events
	// which get written while the upload is taking place don't get lost or duplicated.  To achieve this, the logic is:
	// 1) Go through every session file and rename it by prepending the upload prefix to it.
	// 2) if an upload file already exists, append the data.
	// Now, the uploader can focus on upload files and any ongoing sessions can safely write to session files
	// 3) Go through every upload file and append it's data to the post body
	// 4) upload the data
	// 5) on success, delete every file from step 3.
	
	// Steps 1 and 2
	NSArray *listOfFiles = [sessionFileManager contentsOfDirectoryAtPath:self.localyticsFilePath error:nil];
	for(currentFile = 0; currentFile < [listOfFiles count]; currentFile++)
	{
		NSString *currentFilename = [listOfFiles objectAtIndex:currentFile];
		if([currentFilename hasPrefix:SESSION_FILE_PREFIX] == YES ||
       [currentFilename hasPrefix:CLOSE_SESSION_FILE_PREFIX] == YES)
		{						
			[self renameOrAppendFile:sessionFileManager 
					 origin:[self.localyticsFilePath stringByAppendingPathComponent:currentFilename]
					 destination:[self.localyticsFilePath stringByAppendingPathComponent:[NSString stringWithFormat:UPLOAD_FILE_FORMAT, currentFilename]]];
		}		
	}
	
	// Step 3
	NSMutableData *requestData = [[NSMutableData alloc] init];
	listOfFiles = [sessionFileManager contentsOfDirectoryAtPath:self.localyticsFilePath error:nil];
	for(currentFile = 0; currentFile < [listOfFiles count]; currentFile++)
	{
		NSString *currentFilename = [listOfFiles objectAtIndex:currentFile];
		if([currentFilename hasPrefix:UPLOAD_FILE_PREFIX] == YES)
		{
			NSData *newData = [[NSData alloc] initWithContentsOfFile:[self.localyticsFilePath stringByAppendingPathComponent:currentFilename]];
			[requestData appendData:newData];
			[newData release];
		}
	}
	
	// step 4, 
	NSMutableURLRequest *submitRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:ANALYTICS_URL] 
																			 cachePolicy:NSURLRequestReloadIgnoringCacheData 
																			 timeoutInterval:60.0];
	[submitRequest setHTTPMethod:@"POST"];
	[submitRequest setValue:@"text/html" forHTTPHeaderField:@"Content-Type"];				
	[submitRequest setHTTPBody:requestData];
	[submitRequest setValue:[NSString stringWithFormat:@"%d", [requestData length]] forHTTPHeaderField:@"Content-Length"];
	[requestData release];
	
	// The NSURLConnection Object automatically spawns it's own thread as a default behavior.
	@try 
	{
		//[self logMessage:@"Spawning new thread for upload"];
		self.uploadConnection = [NSURLConnection connectionWithRequest:submitRequest delegate:self];
		[self.uploadConnection retain]; // Todo: remove extra retain and release ?
		
		// step 5 is handled by connectionDidFinishLoading
	}
	@catch (NSException * e) 
	{ 
		[self complete];
	}	
}

#pragma mark **** NSURLConnection FUNCTIONS ****
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	// Used to gather response data from server - Not utilized in this version
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	// If the connection completed, the files should be deleted.  It is important not to
	// check for a specific return value before deleting the files because this might cause
	// an invalid file to stick around forever.
	[self logMessage:@"Upload completed."];

	// Presume that upload was successful & delete all uploaded files.  Because only one instance of the uploader
	// can be running at a time it should not be possible for new upload files to appear so there is no fear of
	// deleting data which has not yet been uploaded.
	NSFileManager *sessionFileManager = [NSFileManager defaultManager];
	NSArray *listOfFiles = [sessionFileManager contentsOfDirectoryAtPath:self.localyticsFilePath error:nil];
	for(int currentFile = 0; currentFile < [listOfFiles count]; currentFile++)
	{		
		NSString *currentFilename =  [listOfFiles objectAtIndex:currentFile];
		if([currentFilename hasPrefix:UPLOAD_FILE_PREFIX] == YES)
		{
			[sessionFileManager removeItemAtPath:[self.localyticsFilePath stringByAppendingPathComponent:currentFilename] error:nil];			
		}
	}
	
	// Close upload session
	[self complete];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	// On error, simply print the error and close the uploader.  We have to assume the data was not transmited
	// so it is not deleted.  In the event that we accidently store data which was succesfully uploaded, the
	// duplicate data will be ignored by the server when it is next uploaded.
	[self logMessage:[NSString stringWithFormat: 
					  @"Error Uploading.  Code: %d,  Description: %s", 
					  [error code], 
					  [error localizedDescription]]];

	[self complete];
}

/*!
 @method complete
 @abstract closes the upload connection and reports back to the session that the upload is complete
 */
- (void)complete {
		//[self.uploadConnection release]; // Todo: remove extra retain and release
	self.uploadConnection = nil;
	self.isUploading = false;
}

/*!
 @method renameOrAppendFile
 @abstract Checks if the destination exists.  If so it appends the origin to the destination, and if not, it just renames the origin.
 @param origin A string containing the path + filename of the original file
 @param destination A string containing the path + filename of the destination file
 */
- (void)renameOrAppendFile:(NSFileManager *)fileManager origin:(NSString *)originalFilename destination:(NSString *)destFilename {
	if ([fileManager fileExistsAtPath:destFilename]) 
	{
		// If the destination file already exists then append the data and delete the file 
		NSData *fileData = [[NSData alloc] initWithContentsOfFile:originalFilename];
		NSFileHandle *currentYML = [NSFileHandle fileHandleForUpdatingAtPath:destFilename];
		[currentYML seekToEndOfFile];
		[currentYML writeData:fileData];
		[currentYML closeFile];
		[fileData release];
		
		[fileManager removeItemAtPath:originalFilename error:nil];
	}
	else
	{
		// otherwise just rename the file
		[fileManager moveItemAtPath:originalFilename toPath:destFilename error:nil];
	}		
}

/*!
 @method logMessage
 @abstract Logs a message with (localytics uploader) prepended to it
 @param message The message to log
*/
- (void) logMessage:(NSString *)message {
		printf("[%s] (localytics uploader) %s\n", [[[NSDate date] description] UTF8String], [message UTF8String]);
}

- (void)dealloc {
    [super dealloc];
}

@end
