//
//  NSInvocation+CWVariableArguments.h
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

#import <Foundation/Foundation.h>


@interface NSInvocation (CWVariableArguments)

/*!
 * @abstract Create an NSInvication instance for a given target, selector, and a
 *					 variable list of arguments.
 *
 * @discussion Arguments are not retained by NSInvocation by default for
 *						 performance. Always retain arguments when passing objects across
 *             thread boundries.
 *
 * @param target target of invocation.
 * @param selector selector of method to invoke on target.
 * @param retainArguments YES if object arguments should be retained.
 * @param ... a list of arguments to send to the method when invoking.
 * @result a prepared invocation object.
 */
+(NSInvocation*)invocationWithTarget:(id)target
                            selector:(SEL)selector
                     retainArguments:(BOOL)retainArguments, ...;

/*!
 * @abstract Perform invoke on a new bakcground thread.
 *
 * @discussion You should not read the return value, since there is no way to
 * 						 know when the invokation has finished.
 */
-(void)invokeInBackground;

/*!
 * @abstract Perform invoke on the main thread, optionally wait until done.
 *
 * @abstract You should only read the return value if you have waited until the
 *           invocation is done.
 */
-(void)invokeOnMainThreadWaitUntilDone:(BOOL)wait;

@end
