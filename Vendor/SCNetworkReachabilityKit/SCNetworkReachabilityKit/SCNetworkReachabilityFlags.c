/* SCNetworkReachabilityKit SCNetworkReachabilityFlags.c
 *
 * Copyright © 2011, Roy Ratcliffe, Pioneering Software, United Kingdom
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the “Software”), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 *	The above copyright notice and this permission notice shall be included in
 *	all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED “AS IS,” WITHOUT WARRANTY OF ANY KIND, EITHER
 * EXPRESSED OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO
 * EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES
 * OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
 *
 ******************************************************************************/

#include "SCNetworkReachabilityFlags.h"

CFStringRef SCNetworkReachabilityCFStringCreateFromFlags(SCNetworkReachabilityFlags flags)
{
	/*
	 * Map between network reachability flags and ASCII characters. Ordering is
	 * important. Left-to-right in the resulting string corresponds to
	 * most-to-least significant flags.
	 */
	static struct
	{
		char ascii;
		SCNetworkReachabilityFlags flags;
	}
	flagsToASCII[] =
	{
		/*
		 * The “Is WWAN flag” is only available on iOS, i.e. iPhones and
		 * iPads. Devices without GPRS, EDGE or other “cell” connection hardware
		 * cannot reach Wireless Wide-Area Networks.
		 *
		 * Use 0 for the flags for non-iOS platforms however. This will make the
		 * first flag character always output a dash. Hence the resulting string
		 * will always have a consistent length, with consistent character flag
		 * positions within the string, regardless of the platform. The
		 * framework aims towards cross-platform compatibility.
		 */
		{
			'W',
#if TARGET_OS_IPHONE
			kSCNetworkReachabilityFlagsIsWWAN
#else
			0
#endif
		},
		
		{ 'd', kSCNetworkReachabilityFlagsIsDirect },
		{ 'l', kSCNetworkReachabilityFlagsIsLocalAddress },
		{ 'D', kSCNetworkReachabilityFlagsConnectionOnDemand },
		{ 'i', kSCNetworkReachabilityFlagsInterventionRequired },
		{ 'C', kSCNetworkReachabilityFlagsConnectionOnTraffic },
		{ 'c', kSCNetworkReachabilityFlagsConnectionRequired },
		{ 'R', kSCNetworkReachabilityFlagsReachable },
		{ 't', kSCNetworkReachabilityFlagsTransientConnection },
	};
#define COUNT(array) (sizeof(array)/sizeof((array)[0]))
	char asciiString[COUNT(flagsToASCII) + 1];
	for (CFIndex i = 0; i < COUNT(flagsToASCII); i++)
	{
		asciiString[i] = (flags & flagsToASCII[i].flags) ? flagsToASCII[i].ascii : '-';
	}
	asciiString[COUNT(flagsToASCII)] = '\0';
	return CFStringCreateWithCString(kCFAllocatorDefault, asciiString, kCFStringEncodingASCII);
}
