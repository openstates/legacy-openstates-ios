Open States for iOS (formerly StatesLege)
=============
Created by Gregory S. Combs, on behalf of the [Sunlight Foundation](http://www.sunlightfoundation.com).
Based on work at [GitHub](https://github.com/sunlightlabs/StatesLege).

Description
=============

- This is an application that provides in-depth information on various state legislatures, using available public data from the Sunlight Foundation's [Open States Project](http://openstates.org).

Compiling and Running the Project
=============
This project accesses state legislative data available through the Open States API from the Sunlight Foundation.   In order to build and run the application, the project depends on one key assumption:

  1. You create a file titled "APIKeys.m" and place it in the main directory next to APIKeys.h.  This new file must contain your very own Sunlight Labs API key (available from [Sunlight Labs](http://services.sunlightlabs.com/)) :

    `NSString * const SUNLIGHT_APIKEY = @"YourAPIKeyFromSunlightFoundation";`

Attributions and Thanks
=============
- [Open States Project](http://openstates.sunlightlabs.com) / [Sunlight Labs](http://sunlightlabs.com)
- [Transparency Data](http://transparencydata.org) /  [Sunlight Labs](http://sunlightlabs.com)
- National Institute on Money in State Politics (NIMSP) / [FollowTheMoney.org](http://www.followthemoney.org)
- [RestKit](http://restkit.org) by Blake Watters / [github.com](https://github.com/RestKit/RestKit)
- PSStackedView by Peter Steinberger / [github.com](https://github.com/steipete/PSStackedView)
- ActionSheetPicker by Tim Cinel / [github.com](https://github.com/TimCinel/ActionSheetPicker)
- AFNetworking by Gowalla / [github.com](https://github.com/AFNetworking/AFNetworking)
- AppendingFlowView by Greg Combs / [github.com](https://github.com/grgcombs/AppendingFlowView)
- MultiRowCalloutAnnotationView by Greg Combs / [github.com](https://github.com/grgcombs/MultiRowCalloutAnnotationView)
- DDActionHeaderView by Ching-Lan Huang / [github.com](https://github.com/digdog/DDActionHeaderView)
- DDBadgeViewCell by Ching-Lan Huang / [github.com](https://github.com/digdog/DDBadgeViewCell)
- JSONKit by John E. Zang / [github.com](http://github.com/johnezang/JSONKit)
- SVGeocoder by Sam Vermette / [samvermette.com](http://samvermette.com)
- SVWebViewController by Sam Vermette / [samvermette.com](http://samvermette.com)
- MTInfoPanel by Tretter Matthias / [github.com](https://github.com/myell0w/MTInfoPanel)
- Glyphish icons by Joseph Wain / [glyphish.com](http://glyphish.com)

Additionally, Greg Combs would like to send special thanks to the following:
-
- Thanks to all the generous developers participating at [StackOverflow.com](http://stackoverflow.com) and [GitHub.com](https://github.com)!
- For all the comments, suggestions, and material support, a huge thank you goes to all the TexLege users around the Texas Capitol, including Rep. Jason Isaac, Rep. Van Taylor, Raul Espinoza, Steve Hazlewood, and more!

License
=========================

```
Copyright (c) Sunlight Foundation

All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, 
      this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, 
      this list of conditions and the following disclaimer in the documentation 
      and/or other materials provided with the distribution.
    * Neither the name of Sunlight Labs nor the names of its contributors may be
      used to endorse or promote products derived from this software without 
      specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```
