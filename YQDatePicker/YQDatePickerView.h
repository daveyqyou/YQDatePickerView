//
//  YQDatePickerView.h
//  YQDatePicker
//
//  Created by DaveYou on 2018/8/21.
//  Copyright © 2018年 DaveYou. All rights reserved.
//

#import <UIKit/UIKit.h>

//屏幕宽高
#define kScreenW [UIScreen mainScreen].bounds.size.width
#define kScreenH [UIScreen mainScreen].bounds.size.height

//日历显示的高度
#define HEIGHT 300

#define YQBeginYearDefault 1900
#define YQEndYearDefault 2099

typedef void(^CompletionBlock)(void);


//UIPickerView组件
typedef NS_ENUM(NSInteger, YQComponentType) {
    YQYearComponent = 0,
    YQMonthComponent,
    YQDayComponent,
};

//日历的开始日期
typedef NS_ENUM(NSInteger, YQBeginDateType) {
    YQBeginDateDefault, //默认从1900年01月01日开始，给个宏定义1900，需要改动的话，修改宏定义即可
    YQBeginDateFromNow, //从当前年月日开始
    YQBeginDateFromDetailDate, //从指定的具体的日期开始，是这种类型的话，要给FromDate传值
};

//日历的结束日期
typedef NS_ENUM(NSInteger, YQEndDateType) {
    YQEndDateDefault, //默认截止2099年，给个宏定义2099，需要改动的话，修改宏定义即可
    YQEndDateUntilNow, //截止到当前年月日
};



@interface YQDatePickerView : UIView

@property (copy,nonatomic)void (^completionBlock)(NSString *componentsString);


//设置标题
- (instancetype)initWithTitle:(NSString *)title;
//初始化带用户设置的开始时间
- (instancetype)initWithUserFromYear:(NSInteger)year AndMonth:(NSInteger)month AndDay:(NSInteger)day WithTitle:(NSString *)title WithBeginDateType:(NSInteger)beginType;
//生日选择
- (instancetype)initWithTitle:(NSString *)title AndChooseBirthday:(BOOL)isChooseBirthday;


//展示
- (void)show;

@property (nonatomic, assign) YQEndDateType endDateType;
@property (nonatomic, assign) YQBeginDateType beginDateType;


@end
