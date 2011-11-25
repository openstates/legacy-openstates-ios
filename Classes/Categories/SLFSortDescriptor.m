//
//  SLFSortDescriptor.m
//  Created by Greg Combs on 11/16/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

#import "SLFSortDescriptor.h"

@implementation SLFSortDescriptor
+ (NSSortDescriptor *)stringSortDescriptorWithKey:(NSString *)key ascending:(BOOL)ascending {
    return [NSSortDescriptor sortDescriptorWithKey:key ascending:ascending selector:@selector(localizedStandardCompare:)];
}

@end
