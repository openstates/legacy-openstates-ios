
#if DEBUG
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <CoreData/CoreData.h>

@implementation NSObject(MCManagedObjectDebug)
+ (NSMutableArray *)MCproperties
{
    NSMutableArray *properties = nil;
    
    if ([self superclass] != [NSManagedObject class])
        properties = [[self superclass] MCproperties];
    else
        properties = [NSMutableArray array];
    
    
    unsigned int propCount;
    objc_property_t * propList = class_copyPropertyList([self class], &propCount);
    int i;
    
    for (i=0; i < propCount; i++)
    {
        objc_property_t oneProp = propList[i];
        NSString *propName = [NSString stringWithUTF8String:property_getName(oneProp)];
        if (![properties containsObject:propName])
            [properties addObject:propName];
    }
    return properties;
}
@end

@implementation NSManagedObject(MCManagedObjectDebug)
- (NSString *)description
{
    NSArray *properties = [[self class] MCproperties];
    NSMutableString *ret = [NSMutableString stringWithFormat:@"%@:", [self className]];
    NSDictionary *myAttributes = [[self entity] attributesByName];
    
    for (NSString *oneProperty in properties)
    {
        NSAttributeDescription *oneAttribute = [myAttributes valueForKey:oneProperty];
        if (oneAttribute != nil) // If not, it's a relationship or fetched property
        {
            id value = [self valueForKey:oneProperty];
            [ret appendFormat:@"\n\t%@ = %@", oneProperty, value];
        }
		
    }
    return ret;
}

@end
#endif