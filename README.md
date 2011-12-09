StatesLege - The Open States Project for iOS 
=============
Created by Gregory S. Combs, on behalf of the [Sunlight Foundation](http://www.sunlightfoundation.com).  
Based on work at [GitHub](https://github.com/sunlightlabs/StatesLege).

Description
=============

- This is an application that provides in-depth information on various state legislatures, using available public data from the Sunlight Foundation's [Open States Project](http://openstates.sunlightlabs.com).

Compiling and Running the Project (The current state of StatesLege)
=============
This project accesses state legislative data available through the Open States API from the Sunlight Foundation.   In order to build and run the application, the project depends on one key assumption:

  1. You create a file titled "APIKeys.m" and place it in the main directory next to APIKeys.h.  This new file must contain your very own Sunlight Labs API key (available from [Sunlight Labs](http://services.sunlightlabs.com/)) :

    `NSString * const SUNLIGHT_APIKEY = @"YourAPIKeyFromSunlightFoundation";`
  
Attributions and Thanks
=============
- National Institute on Money in State Politics (NIMSP) / [FollowTheMoney.org](http://www.followthemoney.org)  
- [Transparency Data](http://transparencydata.org) /  [Sunlight Labs](http://sunlightlabs.com)  
- [Open States Project](http://openstates.sunlightlabs.com) / [Sunlight Labs](http://sunlightlabs.com)  
- [RestKit](http://restkit.org) / [TwoToasters](http://twotoasters.com)  
- IntelligentSplitViewController by Gregory S. Combs / [github.com](https://github.com/grgcombs/IntelligentSplitViewController)  
- AppendingFlowView by Gregory S. Combs / [github.com](https://github.com/grgcombs/AppendingFlowView)  
- Kal by Keith Lazuka / [github.com](https://github.com/klazuka/Kal)  
- SVGeocoder by Sam Vermette / [samvermette.com](http://samvermette.com)  
- SVWebViewController by Sam Vermette / [samvermette.com](http://samvermette.com)  
- MTStatusBarOverlay by Matthias Tretter / [github.com](https://github.com/myell0w/MTStatusBarOverlay)  
- DDBadgeViewCell by Ching-Lan Huang / [github.com](https://github.com/digdog/DDBadgeViewCell)  
- Glyphish icons by Joseph Wain / [glyphish.com](http://glyphish.com)  
- PHP/REST/MySQL by Michael Stricklin / Applied Research Laboratories  
  
Additionally, Greg Combs would like to send special thanks to the following:  
-  
- For all the comments, suggestions, and material support, a huge thank you goes to from TexLege users around the Texas Capitol, including Rep. Jason Isaac, Rep. Van Taylor, Raul Espinoza, Steve Hazlewood, and more!  
- Thanks to all the generous developers participating at [StackOverflow.com](http://stackoverflow.com)!  

License
=========================

[Under a Creative Commons Attribution-NonCommercial 3.0 Unported License](http://creativecommons.org/licenses/by-nc/3.0/)

![Creative Commons License Badge](http://i.creativecommons.org/l/by-nc/3.0/88x31.png "Creative Commons Attribution-NonCommercial")

Screenshots
=========================

![Screenshot](https://github.com/sunlightlabs/StatesLege/raw/master/Screenshots/BillDetails.png "Bill Details")

![Screenshot](https://github.com/sunlightlabs/StatesLege/raw/master/Screenshots/DistrictDetail.png "District Map")
