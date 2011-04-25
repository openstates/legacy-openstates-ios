//
//  NSData_Extensions.m
//  TouchCode
//
//  Created by Jonathan Wight on 05/09/09.
//  Copyright 2009 toxicsoftware.com. All rights reserved.
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

#import "NSData_Extensions.h"

@implementation NSData (NSData_Extensions)

- (NSString *)hexString
{
NSUInteger theLength = [self length];
NSMutableData *theHex = [NSMutableData dataWithLength:theLength * 2];
const char *IN = [self bytes];
char *OUT = [theHex mutableBytes];
const char theHexTable[] = "0123456789ABCDEF";
size_t INX = 0;
for (; INX < theLength; ++INX)
	{
	const UInt8 theOctet = IN[INX];
	*OUT++ = theHexTable[(theOctet >> 4) & 0x0F];
	*OUT++ = theHexTable[theOctet & 0x0F];
	}

NSString *theString = [[[NSString alloc] initWithData:theHex encoding:NSASCIIStringEncoding] autorelease];
return(theString);
}

@end
