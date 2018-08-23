//
//  NSDate+YYAdd.m
//  YQDatePicker
//
//  Created by DaveYou on 2018/8/22.
//  Copyright © 2018年 DaveYou. All rights reserved.
//

#import "NSDate+YYAdd.h"

@implementation NSDate (YYAdd)

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter dateFromString:dateString];
}
@end
