//
//  NSDate+SLFDateHelper.h
//  Created by Greg Combs on 11/16/11.
//
//  StatesLege by Sunlight Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the Creative Commons Attribution-NonCommercial 3.0 Unported License. 
//  To view a copy of this license, visit http://creativecommons.org/licenses/by-nc/3.0/
//  or send a letter to Creative Commons, 444 Castro Street, Suite 900, Mountain View, California, 94041, USA.
//
//

@interface NSDate (SLFDateHelper)
#pragma mark - Comparison
- (BOOL)equalsDefaultDate;
- (BOOL)isEarlierThanDate:(NSDate *)laterDate;
- (BOOL)isLaterThanDate:(NSDate *)earlierDate;

#pragma mark - User Friendly Presentation
- (NSString *)localWeekdayString;
- (NSString *)stringDaysAgo;
- (NSString *)stringDaysAgoAgainstMidnight:(BOOL)flag;
- (NSString *)stringForDisplay;
- (NSString *)stringForDisplayWithPrefix:(BOOL)prefixed;

#pragma mark Date<->String Conversion
+ (NSString *)dateFormatString;
+ (NSString *)timeFormatString;
+ (NSString *)timestampFormatString;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

#pragma mark - Calendar Math
- (NSUInteger)daysAgo;
- (NSUInteger)daysAgoAgainstMidnight;
- (NSUInteger)weekday;
- (NSUInteger)year;
- (NSDate *)beginningOfWeek;
- (NSDate *)beginningOfDay;
- (NSDate *)endOfWeek;
- (NSDate *)dateByAddingDays:(NSInteger)days;

#pragma mark - Timestamps
- (NSString *)timestampString;
+ (NSDate *)dateFromTimestampString:(NSString *)timestamp;
+ (NSDate *)localDateFromUTCTimestamp:(NSString *)utcString;

#pragma mark - Time Zone Conversion
- (NSDate *)localDateConvertingFromOtherTimeZone:(NSString *)tzAbbrev;

@end