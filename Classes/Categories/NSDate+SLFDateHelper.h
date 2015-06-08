//
//  NSDate+SLFDateHelper.h
//  Created by Greg Combs on 11/16/11.
//
//  OpenStates (iOS) by Sunlight Foundation Foundation, based on work at https://github.com/sunlightlabs/StatesLege
//
//  This work is licensed under the BSD-3 License included with this source
// distribution.


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
+ (NSString *)timestampFormat;
+ (NSDate *)dateFromString:(NSString *)string;
+ (NSDate *)dateFromString:(NSString *)string withFormat:(NSString *)format;
- (NSString *)string;
- (NSString *)stringWithFormat:(NSString *)format localized:(BOOL)localized;
- (NSString *)stringWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;
- (NSString *)stringWithLocalizationTemplate:(NSString *)formatTemplate timezone:(NSTimeZone *)timezone;
- (NSString *)stringWithLocalizationTemplate:(NSString *)formatTemplate;

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
