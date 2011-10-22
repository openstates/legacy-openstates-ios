Development Milestones
=======================
 1. **(done)** Move project development to GitHub.  
- Clean up code a little, including removal of any swearing in comments.  
- Upload sources.  
- Point repository to any existing GitHub submodules, where possible.   
- Move to Creative Commons licensing.  
- Create a TexLege branch/fork of the public repository.  
  
 
 2. **(done)** Remove TexLege specific application features:  
- Partisanship scores, scales, and historical charts.  
- Capitol Building Maps.  
- Web Resources / Web Links (specific to Texas). Keeping stubs around for future use.  


 3. **(done)** Remove State Specific Data Assumptions.  
- Seek out alternatives from Open States data for flagging Speaker & Lt. Gov. / Senate Pres.  
- Adapt to Open States metadata for chamber names and legislator titles.  
- Adapt to generic events from Events API, no more Texas specific event parsing.  
  

 4. **(done)** New interface elements and framework for multi-state selection.
- Initial table view with list of available states.
- Store memory of user’s state selection, allow re-selection via UI element or settings panel.
- Reformulate view controller hierarchy to load after state selection.  
  

 5. **(done)** Move data to the cloud.
- Move to latest redesigned RestKit library (JSON->Object mapping framework).  
- Test and consider using RestKit’s static data caching/updating instead of 100% live online data,  
to improve performance.  
- Image caching for legislator photos, instead of shipping static images with the application.  
- Pull district map coordinates from an Open States API; perhaps use binary encoding for better
performance.  
- Point-In-Polygon testing/searching via Open States API, rather than on the device.  
- New iOS Core Data model with live RestKit->OpenStates object modeling.  
  

 6. **(done)** Move iPad version to new “Twitter-like” sliding view panel user experience.  
- If successful, it will greatly improve logical UI flow and codeability, and moves away from some
questionable mangling of Apple’s UISplitViewController.  
- Also opens pathway to easier view persistence for users when stopping and starting the application.  
  

 7. Incorporate Rebranded Graphic Elements from Sunlight.  
  

 8. Changes for iTunes App Store and Apple iOS Developer Portal.  
- Change ownership of TexLege (if possible), and alter pricing model to *free*.  
  

