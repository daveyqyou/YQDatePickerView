//
//  NSDate+YYAdd.h
//  YQDatePicker
//
//  Created by DaveYou on 2018/8/22.
//  Copyright © 2018年 DaveYou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (YYAdd)
/**
 Returns a date parsed from given string interpreted using the format.
 
 @param dateString The string to parse.
 @param format     The string's date format.
 
 @return A date representation of string interpreted using the format.
 If can not parse the string, returns nil.
 */
+ (nullable NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

@end
