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

[Under a Creative Commons Attribution-NonCommercial 3.0 Unported License](http://creativecommons.org/licenses/by-nc/3.0/)

![Creative Commons License Badge](http://i.creativecommons.org/l/by-nc/3.0/88x31.png "Creative Commons Attribution-NonCommercial")

