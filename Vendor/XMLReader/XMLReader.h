//
//  XMLReader.h
//
//  Created by Troy Brant.
//  http://troybrant.net/blog/2010/09/simple-xml-to-nsdictionary-converter/
//

#import <Foundation/Foundation.h>


@interface XMLReader : NSObject <NSXMLParserDelegate>
{
    NSMutableArray *dictionaryStack;
    NSMutableString *textInProgress;
    NSError **errorPointer;
}

+ (NSMutableDictionary *)dictionaryForXMLData:(NSData *)data error:(NSError **)errorPointer;
+ (NSMutableDictionary *)dictionaryForXMLString:(NSString *)string error:(NSError **)errorPointer;

@end
