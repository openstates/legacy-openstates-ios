//
//  NSData_Base64Extensions.h
//  TouchCode
//
//  Created by Jonathan Wight on 5/10/06.
//  Copyright 2006 toxicsoftware.com. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import <Foundation/Foundation.h>

/**
 * @category NSObject (NSData_Base64Extensions)
 */
@interface NSData (NSData_Base64Extensions)

+ (id)dataWithBase64EncodedString:(NSString *)inString flags:(NSInteger)inFlags NS_RETURNS_RETAINED;
+ (id)dataWithBase64EncodedString:(NSString *)inString NS_RETURNS_RETAINED;
- (NSString *)asBase64EncodedString;
- (NSString *)asBase64EncodedString:(NSInteger)inFlags;


@end

/*@interface NSData (NSData_Base64JSON)
- (id)proxyForJson;
@end

@interface NSString (NSString_Base64JSON)
- (id)JSONValueAsData;
@end
*/