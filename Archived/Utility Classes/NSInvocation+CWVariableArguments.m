//
//  NSInvocation+CWVariableArguments.m
//  SharedComponents
//
//  Copyright 2010 Jayway. All rights reserved.
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import "NSInvocation+CWVariableArguments.h"
#include <stdarg.h>

@implementation NSInvocation (CWVariableArguments)

+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)aSelector
                     retainArguments:(BOOL)retainArguments, ...;
{
	va_list ap;
	va_start(ap, retainArguments);
	char* args = (char*)ap;
	NSMethodSignature* signature = [target methodSignatureForSelector:aSelector];
	NSInvocation* invocation = [NSInvocation invocationWithMethodSignature:signature];
	if (retainArguments) {
		[invocation retainArguments];
	}
	[invocation setTarget:target];
	[invocation setSelector:aSelector];
	for (int index = 2; index < [signature numberOfArguments]; index++) {
		const char *type = [signature getArgumentTypeAtIndex:index];
		NSUInteger size, align;
		NSGetSizeAndAlignment(type, &size, &align);
		NSUInteger mod = (NSUInteger)args % align;
		if (mod != 0) {
			args += (align - mod);
		}
		[invocation setArgument:args atIndex:index];
		args += size;
	}
	va_end(ap);
	return invocation;
}

-(void)invokeInBackground;
{
	/*[someTextField performSelectorOnMainThread:@selector(setText:)
									withObject:@"A new text"
								 waitUntilDone:YES];
	*/
	[self performSelectorInBackground:@selector(invoke) withObject:nil];
}

-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;
{
	[self performSelectorOnMainThread:@selector(invoke)
						   withObject:nil
						waitUntilDone:wait];
}

@end

