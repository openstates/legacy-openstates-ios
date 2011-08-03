/*
 *  Constants.h
 *  TexLege
 *
 *  Created by Gregory Combs on 7/13/09.
 *  Copyright 2009 Gregory S. Combs. All rights reserved.
 *
 */

extern NSString * const kAnalyticsAskedForOptInKey;
extern NSString * const kAnalyticsSettingsSwitch;
extern NSString * const kSegmentControlPrefKey;
extern NSString * const kSupportEmailKey;

enum TABBAR_ITEM_TAGS {
	TAB_LEGISLATOR,
	TAB_COMMITTEE,
	TAB_DISTRICTMAP,
	TAB_CALENDAR,
	TAB_BILL,
	TAB_LINK
};

#define kStateMetaNotifyError           @"STATE_METADATA_ERROR"
#define kStateMetaNotifyStateLoaded		@"STATE_METADATA_STATE_LOADED"
#define kStateMetaNotifySessionChange	@"STATE_METADATA_SESSION_CHANGE"
