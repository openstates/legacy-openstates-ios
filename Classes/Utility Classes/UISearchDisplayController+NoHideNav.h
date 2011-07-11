//
//  UISearchDisplayController+NoHideNav.h
//  Created by Gregory Combs on 8/3/10.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//
//	Description: Whenever you activate a searchDisplayController searchBar located within a pushed navigationcontroller title bar, 
//		the default iOS behavior (bad) is to hide the nav title bar, including your searchBar, which precludes searching.
//		This idiotic class serves no purpose but to stop that nonsense. It won't hide the nav title bar when searching.  Retarded, yes?
//

@interface UISearchDisplayControllerNoHideNav : UISearchDisplayController 
{

}

@end
