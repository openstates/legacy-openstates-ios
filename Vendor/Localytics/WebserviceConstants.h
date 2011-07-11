//  WebserviceConstants.h
//  Copyright (C) 2009 Char Software Inc., DBA Localytics
// 
//  This code is provided under the Localytics Modified BSD License.
//  A copy of this license has been distributed in a file called LICENSE
//  with this source code.  
// 
// Please visit www.localytics.com for more information.

// The constants which are used to make up the YML blob
// To save disk space and network bandwidth all the keywords have been
// abbreviated and are exploded by the server.  

#define CONTROLLER_SESSION      @"- c: se\n"	// - controller: session_datapoints
#define CONTROLLER_EVENT		@"- c: ev\n"	// - controller: event_datapoints
#define CONTROLLER_OPT			@"- c: optin\n" // - controller: optin

#define ACTION_CREATE			@"  a: c\n"		//  action: create
#define ACTION_UPDATE			@"  a: u\n"		//  action: update
#define ACTION_OPT				@"  a: optin\n" //  action: optin

#define TARGET_SESSION			@"  se:\n"		//  session_datapoint
#define TARGET_EVENT			@"  ev:\n"		//  event_datapoint
#define TARGET_OPT              @"  optin:\n"   //  optin/out event

#define PARAM_UUID              @"u"		// uuid
#define PARAM_APP_KEY	        @"au"		// localytics_application_id
#define PARAM_APP_VERSION       @"av"		// application_Version
#define PARAM_SESSION_UUID      @"su"		// session_uuid
#define PARAM_DEVICE_UUID       @"du"		// device_id
#define PARAM_DEVICE_PLATFORM   @"dp"		// device_platform
#define PARAM_DEVICE_MAKE	    @"dma"		// device_make
#define PARAM_DEVICE_MODEL	    @"dmo"		// device_model
#define PARAM_DEVICE_SUBMODEL   @"dms"      // device_sub_model
#define PARAM_DEVICE_COUNTRY    @"dc"       // device_country 
#define PARAM_DEVICE_OS_VERSION @"dov"		// device_os_version
#define PARAM_LOCALE_COUNTRY    @"dlc"		// device_locale_country
#define PARAM_LOCALE_LANGUAGE   @"dll"		// device_locale_language
#define PARAM_DATA_CONNECTION   @"dac"		// connection_type
#define PARAM_LIBRARY_VERSION   @"lv"		// client_version
#define PARAM_CLIENT_TIME       @"ct"		// client_time
#define PARAM_CLIENT_CLOSE_TIME @"ctc"		// client_time_closed_ate
#define PARAM_EVENT_NAME        @"n"		// event_name
#define PARAM_EVENT_ATTRS       @"attrs"    // Event Attributes
#define PARAM_OPT_VALUE			@"optin"	// optin