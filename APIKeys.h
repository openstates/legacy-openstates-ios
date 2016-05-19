//
//  APIKeys.h
//  Created by Gregory Combs on 7/10/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

// You need to create your own APIKeys.m file, and all it needs is this constant string as an API key ...
//
// This key is used whenever the app makes contact with the data provider, the Sunlight Foundation.
//   Each key is tied to an individual developer, but obtaining an API key is easy and free.
//   Sign up for your key, and check out the multitudinous government transparency sites from Sunlight:
//   http://services.sunlightlabs.com/

#import <Foundation/Foundation.h>

FOUNDATION_EXPORT NSString *const PRIVATE_SUNLIGHT_APIKEY;

FOUNDATION_EXPORT NSString *const kGoogleAnalyticsIdRelease;

#ifndef SUNLIGHT_APIKEY
#define SUNLIGHT_APIKEY PRIVATE_SUNLIGHT_APIKEY
#endif
