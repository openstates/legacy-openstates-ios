//
//  main.m
//  TexLege
//
//  Created by Gregory Combs on 7/22/09.
//  Copyright 2009 Gregory S. Combs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TexLegeAppDelegate.h"

int main(int argc, char *argv[])
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	int retVal = UIApplicationMain(argc, argv, nil, NSStringFromClass([TexLegeAppDelegate class]));
    [pool drain];
    return retVal;
}
