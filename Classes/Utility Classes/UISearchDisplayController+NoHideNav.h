//
//  UISearchDisplayController+NoHideNav.h
//  TexLege
//
//  Created by Gregory Combs on 8/3/10.
//  Copyright 2010 Gregory S. Combs. All rights reserved.
//
//	Description: Whenever you activate a searchDisplayController searchBar located within a pushed navigationcontroller title bar, 
//		the default iOS behavior (bad) is to hide the nav title bar, including your searchBar, which precludes searching.
//		This idiotic class serves no purpose but to stop that nonsense. It won't hide the nav title bar when searching.  Retarded, yes?
//

@interface UISearchDisplayControllerNoHideNav : UISearchDisplayController 
{

}

@end
