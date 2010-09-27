//
//  SynthesizeSingleton.h
//  CocoaWithLove
//
//  Created by Matt Gallagher on 20/10/08.
//  Copyright 2009 Matt Gallagher. All rights reserved.
//
//  Permission is given to use this source code file without charge in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

//// Using Grand Central Dispatch, we can wipe out all the wird slow crap in the intialization with the following:
/*
 + (id)sharedFoo
{
	static dispatch_once_t pred;
	static Foo *foo = nil;
	
	dispatch_once(&pred, ^{ foo = [[self alloc] init]; });
	return foo;
}
 */

/*
 #define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
 \
 static classname *shared##classname = nil; \
 \
 + (classname *)shared##classname \
 { \
 @synchronized(self) \
 { \
 if (shared##classname == nil) \
 { \
 shared##classname = [[self alloc] init]; \
 } \
 } \
 \
 return shared##classname; \
 } \
 \
*/ 

#define SYNTHESIZE_SINGLETON_FOR_CLASS(classname) \
\
static classname *shared##classname = nil; \
+ (classname *)shared##classname \
{ \
	static dispatch_once_t pred; \
	dispatch_once(&pred, ^{ shared##classname = [[self alloc] init]; }); \
	return shared##classname; \
} \
\
+ (id)allocWithZone:(NSZone *)zone \
{ \
	@synchronized(self) \
	{ \
		if (shared##classname == nil) \
		{ \
			shared##classname = [super allocWithZone:zone]; \
			return shared##classname; \
		} \
	} \
	 \
	return nil; \
} \
 \
- (id)copyWithZone:(NSZone *)zone \
{ \
	return self; \
} \
 \
- (id)retain \
{ \
	return self; \
} \
 \
- (NSUInteger)retainCount \
{ \
	return NSUIntegerMax; \
} \
 \
- (void)release \
{ \
} \
 \
- (id)autorelease \
{ \
	return self; \
}
