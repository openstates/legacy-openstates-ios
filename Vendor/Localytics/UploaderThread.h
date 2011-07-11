//  UploaderThread.h
//  Copyright (C) 2009 Char Software Inc., DBA Localytics
// 
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.  
// 
// Please visit www.localytics.com for more information.

#import <UIKit/UIKit.h>

/*!
 @class UploaderThread
 @discussion Singleton class to handle data uploads
 */

@interface UploaderThread : NSObject {
	NSURLConnection *_uploadConnection;		// The connection which uploads the bits
	NSString *_localyticsFilePath;			// The path to the localytics files, to upload

	BOOL _isUploading;						// A flag to gaurantee only one uploader instance can happen at once
}


@property (nonatomic, retain) NSURLConnection *uploadConnection;
@property (nonatomic, retain) NSString *localyticsFilePath;

@property BOOL isUploading;

/*!
 @method sharedUploaderThread
 @abstract Establishes this as a Singleton Class allowing for data persistance.
 The class is accessed within the code using the following syntax:
 [[UploaderThread sharedUploaderThread] functionHere]
 */
+ (UploaderThread *)sharedUploaderThread;

/*!
 @method UploaderThread
 @abstract Creates a thread which uploads the session files in the passed Localytics
 Directory.  All files starting with sessionFilePrefix are renamed,
 uploaded and deleted on upload.  This way the sessions can continue
 writing data regardless of whether or not the upload succeeds.  Files
 which have been renamed still count towards the total number of Localytics
 files which can be stored on the disk.
 @param localyticsSes reference to the primary session
 @param filepaPath the full path of the directory containing the localytics session files.
 */
- (void)UploaderThread:(NSString *)localyticsFilePath;

@end