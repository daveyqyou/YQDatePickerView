//
//  ViewController.m
//  YQDatePicker
//
//  Created by DaveYou on 2018/8/21.
//  Copyright © 2018年 DaveYou. All rights reserved.
//

#import "ViewController.h"
#import "YQDatePickerView.h"

@interface ViewController ()
@property (nonatomic, strong) YQDatePickerView *yqPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"xxx");
    self.yqPickerView.completionBlock = ^(NSString *componentsString) {
        NSLog(@"选择的是：%@", componentsString);
    };
    [self.yqPickerView show];
}

#pragma mark - Lazy Loading
//默认开始时间、默认截止时间
//- (YQDatePickerView *)yqPickerView {
//    if (_yqPickerView == nil) {
//        _yqPickerView = [[YQDatePickerView alloc]initWithTitle:@"xxxxxxxxx"];
//          //default默认可以不传
//        _yqPickerView.beginDateType = YQBeginDateDefault;
//        _yqPickerView.endDateType = YQEndDateDefault;
//    }
//    return _yqPickerView;
//}

//开始时间为当前时间、默认截止时间
//- (YQDatePickerView *)yqPickerView {
//    if (_yqPickerView == nil) {
//        _yqPickerView = [[YQDatePickerView alloc]initWithTitle:@"xxxxxxxxx"];
//        _yqPickerView.beginDateType = YQBeginDateFromNow;
//        _yqPickerView.endDateType = YQEndDateDefault;
//    }
//    return _yqPickerView;
//}

//开始时间用户输入年月日和开始类型、默认截止时间


- (YQDatePickerView *)yqPickerView {
    if (_yqPickerView == nil) {
//        NSDate *localDate = [NSDate dateWithTimeIntervalSinceNow:8 * 60 * 60];
//        NSDate *date = [NSDate dateWithTimeInterval:3*24*60*60 sinceDate:localDate];
        //项目需求传入三天后
        NSDate *date = [NSDate dateWithTimeIntervalSinceNow:3*24*60*60];
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"]; //格式化字符串会变成本地时间
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        NSString *dateStr = [dateFormatter stringFromDate:date];
 
        NSArray *tmpArr = [dateStr componentsSeparatedByString:@"-"];
        NSInteger year = [tmpArr[0] integerValue];
        NSInteger month = [tmpArr[1] integerValue];
        NSInteger day = [tmpArr[2] integerValue];
        
        
        _yqPickerView = [[YQDatePickerView alloc]initWithUserFromYear:year AndMonth:month AndDay:day WithTitle:@"标题标题" WithBeginDateType:YQBeginDateFromDetailDate];
    }
    return _yqPickerView;
}




//默认开始时间、截止到当前日期：生日选择
//- (YQDatePickerView *)yqPickerView {
//    if (_yqPickerView == nil) {
//        _yqPickerView = [[YQDatePickerView alloc]initWithTitle:@"选择出生日期" AndChooseBirthday:YES];
//    }
//    return _yqPickerView;
//}
@end
