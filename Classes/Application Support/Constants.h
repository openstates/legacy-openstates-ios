/*
 *  Constants.h
 *  TexLege
 *
 *  Created by Gregory Combs on 7/13/09.
 *  Copyright 2009 Gregory S. Combs. All rights reserved.
 *
 */

//#define DEBUG 0
#ifdef DEBUG //== 1
#define debug_NSLog(format, ...) NSLog(format, ## __VA_ARGS__)
#else
#define debug_NSLog(format, ...)
#endif

#define NEEDS_TO_PARSE_KMLMAPS 0

extern NSString * const kRestoreSelectionKey;
extern NSString * const kAnalyticsAskedForOptInKey;
extern NSString * const kAnalyticsSettingsSwitch;
extern NSString * const kShowedSplashScreenKey;
extern NSString * const kSegmentControlPrefKey;
extern NSString * const kResetSavedDatabaseKey;
extern NSString * const kSavedTabOrderKey;

#define m_iTunesAppID 326478866
//#define m_iTunesURL @"http://itunes.com/us/app/TexLege"
#define m_iTunesURL @"http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=326478866&mt=8"

enum kURLActionDestinations {
    URLAction_internalBrowser = 0,
    URLAction_externalBrowser,
};

#if DEBUG
#define RESTKIT_BASE_URL					@"http://www.texlege.com/jsonDataTest"
#else
#define RESTKIT_BASE_URL					@"http://www.texlege.com/rest"
#endif
#define RESTKIT_HOST						@"www.texlege.com"

enum TABBAR_ITEM_TAGS {
	TAB_LEGISLATOR,
	TAB_COMMITTEE,
	TAB_DISTRICTMAP,
	TAB_CALENDAR,
	TAB_BILL,
	TAB_CAPMAP,
	TAB_LINK
};
