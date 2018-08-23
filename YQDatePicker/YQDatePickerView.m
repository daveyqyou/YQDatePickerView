//
//  YQDatePickerView.m
//  YQDatePicker
//
//  Created by DaveYou on 2018/8/21.
//  Copyright © 2018年 DaveYou. All rights reserved.
//

#import "YQDatePickerView.h"

#define MAS_SHORTHAND
#import "Masonry.h"

#import "NSDate+YYAdd.h"

@interface YQDatePickerView() <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, copy) NSString *title;

//控件
@property (nonatomic, strong) UIView *bgView; //整个背景图
@property (nonatomic, strong) UIView *containerView; //总容器
@property (nonatomic, strong) UIView *menuView; //顶部容器
@property (nonatomic, strong) UILabel *titleLabel; //标题
@property (nonatomic, strong) UIButton *confirmBtn; //确认按钮
@property (nonatomic, strong) UIButton *cancelBtn; //取消按钮

@property (nonatomic, strong) UIPickerView *yqPickView; //选择日历控件

@property (nonatomic, assign) BOOL isShown;


//数据 //这个是最后用户选择的日期
@property (nonatomic, assign) NSInteger year;
@property (nonatomic, assign) NSInteger month;
@property (nonatomic, assign) NSInteger day;

//数据 //这个是用户使用传递进来的日期
@property (nonatomic, assign) NSInteger userSelectedYear;
@property (nonatomic, assign) NSInteger userSelectedMonth;
@property (nonatomic, assign) NSInteger userSelectedDay;

@property (nonatomic, strong) NSMutableArray *yqYearsArr;
@property (nonatomic, strong) NSMutableArray *yqMonthsArr;
@property (nonatomic, strong) NSMutableArray *yqDaysArr;

@property (nonatomic, copy) NSString *selectedDateString;

@property (nonatomic, strong) NSDateComponents *components;
@end

@implementation YQDatePickerView

- (instancetype)initWithTitle:(NSString *)title {
    if (self = [super init]) {
        _title = title;
        
        [self initSubViews];
        [self initData];
    }
    return self;
}

- (instancetype)initWithUserFromYear:(NSInteger)year AndMonth:(NSInteger)month AndDay:(NSInteger)day WithTitle:(NSString *)title WithBeginDateType:(NSInteger)beginType {
    if (self = [super init]) {
        _title = title;
        _userSelectedDay = day;
        _userSelectedMonth = month;
        _userSelectedYear = year;
        
        _beginDateType = beginType;
        _endDateType = YQEndDateDefault;
        
        [self initSubViews];
        [self initData];
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title AndChooseBirthday:(BOOL)isChooseBirthday {
    if (self = [super init]) {
        _title = title;
        
        _beginDateType = YQBeginDateDefault;
        _endDateType = YQEndDateUntilNow;
        
        [self initSubViews];
        [self initData];
    }
    return self;
}

- (void)initSubViews {
    self.frame = CGRectMake(0, 0, kScreenW, kScreenH);
    
    self.bgView = [[UIView alloc]initWithFrame:self.frame];
    self.bgView.backgroundColor = [UIColor grayColor];
    self.bgView.alpha = 0.1;
    [self addSubview:self.bgView];
    
    self.containerView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenH, kScreenW, HEIGHT)];
    self.containerView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.containerView];
    
    //顶部容器
    self.menuView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kScreenW, 45)];
    self.menuView.backgroundColor = [UIColor greenColor];
    [self.containerView addSubview:self.menuView];
    
    //标题
    self.titleLabel = [[UILabel alloc]init];
    self.titleLabel.font = [UIFont systemFontOfSize:15];
    self.titleLabel.textColor = [UIColor darkGrayColor];
    self.titleLabel.text = self.title;
    [self.titleLabel sizeToFit];
    [self.menuView addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.menuView);
    }];
    
    //取消按钮
    self.cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuView addSubview:self.cancelBtn];
    [self.cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    self.cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.cancelBtn  setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.cancelBtn sizeToFit];
    [self.cancelBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    
    [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.menuView.mas_left).mas_offset(15);
        make.centerY.equalTo(self.menuView);
    }];
    

    //确认按钮
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.menuView addSubview:self.confirmBtn];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.confirmBtn  setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.confirmBtn sizeToFit];
    [self.confirmBtn addTarget:self action:@selector(completionAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.menuView.mas_right).mas_offset(-15);
        make.centerY.equalTo(self.menuView);
    }];
    
    //DatePicker
    self.yqPickView = [[UIPickerView alloc]init];
    self.yqPickView.backgroundColor = [UIColor whiteColor];

    [self.containerView addSubview:self.yqPickView];
    [self.yqPickView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.containerView.mas_left);
        make.right.equalTo(self.containerView.mas_right);
        make.bottom.equalTo(self.containerView.mas_bottom);
        make.top.equalTo(self.menuView.mas_bottom);
    }];
    
    //设置代理
    self.yqPickView.delegate=self;
    self.yqPickView.dataSource=self;

    //初始化为不显示
    self.isShown = NO;

}
- (void)initData {
    
    self.year = self.components.year;
    self.month = self.components.month;
    self.day = self.components.day;
    
    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateDefault) { //都是默认未设置时，默认开始，默认截止

        for (NSInteger i = YQBeginYearDefault; i <= YQEndYearDefault; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = 1; i <= 12; i++) { //12个月
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = 1; i <= 31; i++) { //默认31天
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }else if (self.beginDateType == YQBeginDateFromDetailDate && self.endDateType == YQEndDateDefault) {
        NSLog(@"用户传递的时间是：%ld-%ld-%ld", _userSelectedYear, _userSelectedMonth, _userSelectedDay);
        
        self.year = _userSelectedYear;
        self.month = _userSelectedMonth;
        self.day = _userSelectedDay;
        
        [self.yqYearsArr removeAllObjects];
        for (NSInteger i = _userSelectedYear; i <= YQEndYearDefault; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = _userSelectedMonth; i <= 12; i++) {
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = _userSelectedDay; i <= 31; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }else if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateUntilNow) {
        _beginDateType = YQBeginDateDefault;
        _endDateType = YQEndDateUntilNow;
        NSLog(@"用户选择生日");
        for (NSInteger i = YQBeginYearDefault; i <= self.components.year; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = 1; i <= self.components.month; i++) {
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = 1; i <= self.components.day; i++) { //默认31天
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }
    [self updateUserInterface];
}

- (BOOL)isLeapYear:(NSInteger)year {
    if (year%100 == 0 && year%400 == 0) {
        return YES;
    }else if(year%100 !=0 && year%4 == 0){
        return YES;
    }else{
        return NO;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    NSLog(@"xxx***************************************xxx");
    [self dismiss];
}
-(void)show {
    NSLog(@"展示");
    if (!_isShown) {
        _isShown = YES;
        
        [[UIApplication sharedApplication].keyWindow addSubview:self];
        [self updateUserInterface];
        [UIView animateWithDuration:0.5 animations:^{
            self.containerView.transform = CGAffineTransformTranslate(self.transform,0, -1*HEIGHT);
            self.bgView.alpha = 1;
        } completion:^(BOOL finished) {
            self.bgView.userInteractionEnabled = YES;
            self.userInteractionEnabled = YES;
        }];
    }
}

- (void)dismiss {
    if (_isShown) {
        _isShown = NO;
        self.bgView.userInteractionEnabled = NO;
        [UIView animateWithDuration:0.5 animations:^{
            self.containerView.transform = CGAffineTransformTranslate(self.transform,0,HEIGHT);
            self.bgView.alpha = 0.1;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }
}


-(void)completionAction:(UIButton *)sender {
    if (_isShown) {
        _isShown = NO;
        self.userInteractionEnabled = NO;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.containerView.transform = CGAffineTransformTranslate(self.transform,0,HEIGHT);
            self.bgView.alpha = 0.1;
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
            //点击确定的时候防止出现2-31、6-31出现
            if (self.day > [self.yqDaysArr[self.yqDaysArr.count - 1] integerValue]) {
                self.day = [self.yqDaysArr[self.yqDaysArr.count - 1] integerValue];
            }
            self.selectedDateString = [NSString stringWithFormat:@"%zd-%02zd-%02zd",self.year,self.month,self.day];
            NSDate *date = [NSDate dateWithString:self.selectedDateString format:@"yyyy-MM-dd"];
            NSLog(@"date = %@",date);
            
            if (self.completionBlock) {
                self.completionBlock(self.selectedDateString);
            }
        }];
    }
}


#pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3; //返回年月日三列
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component { //年月日分别返回多少行
    if (component == YQYearComponent) {
        return self.yqYearsArr.count;
    }else if (component == YQMonthComponent) {
        return self.yqMonthsArr.count;
    }else {
        return self.yqDaysArr.count;
    }
}
#pragma mark - UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component __TVOS_PROHIBITED {
    return self.frame.size.width*0.28; //宽度
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component __TVOS_PROHIBITED {
    if (component == YQYearComponent) {
        return [NSString stringWithFormat:@"%@年", self.yqYearsArr[row]];
    }else if (component == YQMonthComponent) {
        return [NSString stringWithFormat:@"%@月", self.yqMonthsArr[row]];
    }else {
        return [NSString stringWithFormat:@"%@日", self.yqDaysArr[row]];
    }
}
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component __TVOS_PROHIBITED {
    if (component == YQYearComponent) {
        self.year = [self.yqYearsArr[row] integerValue];
    }else if (component == YQMonthComponent) {
        self.month = [self.yqMonthsArr[row] integerValue];
    }else {
        self.day = [self.yqDaysArr[row] integerValue];
    }
}

#pragma mark - setter
- (void)setBeginDateType:(YQBeginDateType)beginDateType {
    _beginDateType = beginDateType;

    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateDefault) {
        //默认的使用初始化数据即可
    }

    if (self.beginDateType == YQBeginDateFromNow && self.endDateType == YQEndDateDefault) { //从当前日期开始，默认截止

        [self.yqYearsArr removeAllObjects];
        for (NSInteger i = self.components.year; i <= YQEndYearDefault; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = self.components.month; i <= 12; i++) {
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = self.components.day; i <= 31; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self updateUserInterface];
    }
    
    if (self.beginDateType == YQBeginDateFromDetailDate && self.endDateType == YQEndDateDefault) {
        [self.yqYearsArr removeAllObjects];
        for (NSInteger i = _userSelectedYear; i <= YQEndYearDefault; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = _userSelectedMonth; i <= 12; i++) {
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = _userSelectedDay; i <= 31; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self updateUserInterface];
    }
    
    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateUntilNow) {
        [self.yqYearsArr removeAllObjects];
        for (NSInteger i = YQBeginYearDefault; i <= self.components.year; i++) { //多少年年
            [self.yqYearsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqMonthsArr removeAllObjects];
        for (NSInteger i = 1; i <= self.components.month; i++) {
            [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = 1; i <= self.components.day; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
        
        [self updateUserInterface];
    }
}

- (void)setDay:(NSInteger)day {
    _day = day;
    NSLog(@"setDay:%ld", day);
}
- (void)setMonth:(NSInteger)month {
    _month = month;
    NSLog(@"setMonth%ld", month);
    [self updateDays];

}
- (void)setYear:(NSInteger)year {
    _year = year;
    NSLog(@"setYear%ld", year);
    [self updateMonths];
    [self updateDays];
}

- (void)updateMonths {
    //更新数据
    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateDefault) { //默认的情况月份一直是12个，不用更新
    }else if (self.beginDateType == YQBeginDateFromNow && self.endDateType == YQEndDateDefault) {
        if (self.year == self.components.year) {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = self.components.month; i <= 12; i++) {
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            self.month = [self.yqMonthsArr[0] integerValue]; //同时将月份设置为第一行
        }else {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = 1; i <= 12; i++) { //12个月
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        }
    }else if (self.beginDateType == YQBeginDateFromDetailDate && self.endDateType == YQEndDateDefault) {
        if (self.year == _userSelectedYear) {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = _userSelectedMonth; i <= 12; i++) {
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            self.month = [self.yqMonthsArr[0] integerValue]; //同时将月份设置为第一行
        }else {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = 1; i <= 12; i++) { //12个月
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        }
    }else if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateUntilNow) {
        if (self.year == self.components.year) {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = 1; i <= self.components.month; i++) {
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            self.month = [self.yqMonthsArr[self.yqMonthsArr.count - 1] integerValue]; //同时将月份设置为第一行
        }else {
            [self.yqMonthsArr removeAllObjects];
            for (NSInteger i = 1; i <= 12; i++) { //12个月
                [self.yqMonthsArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        }
    }

}

- (void)updateDays {
    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateDefault) {
        [self setDefaultDays];
    }else if (self.beginDateType == YQBeginDateFromNow && self.endDateType == YQEndDateDefault) {
        if (self.year == self.components.year && self.month == self.components.month) {
            if (self.month == 1 || self.month == 3 || self.month == 5 || self.month == 7 || self.month == 8 || self.month == 10 || self.month == 12) {
                [self.yqDaysArr removeAllObjects];
                for (NSInteger i = self.components.day; i <= 31; i++) {
                    [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                }
                self.day = [self.yqDaysArr[0] integerValue];
            }else if (self.month != 2) {
                [self.yqDaysArr removeAllObjects];
                for (NSInteger i = self.components.day; i <= 30; i++) {
                    [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                }
                self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
            }else {
                if ([self isLeapYear:self.year]) {
                    [self.yqDaysArr removeAllObjects];
                    for (NSInteger i = self.components.day; i <= 29; i++) {
                        [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                    }
                    self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
                }else {
                    [self.yqDaysArr removeAllObjects];
                    for (NSInteger i = self.components.day; i <= 28; i++) {
                        [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                    }
                    self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
                }
            }
        }else {
            [self setDefaultDays];
        }
    }else if (self.beginDateType == YQBeginDateFromDetailDate && self.endDateType == YQEndDateDefault) {
        if (self.year == _userSelectedYear && self.month == _userSelectedMonth) {
            if (self.month == 1 || self.month == 3 || self.month == 5 || self.month == 7 || self.month == 8 || self.month == 10 || self.month == 12) {
                [self.yqDaysArr removeAllObjects];
                for (NSInteger i = _userSelectedDay; i <= 31; i++) {
                    [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                }
                self.day = [self.yqDaysArr[0] integerValue];
            }else if (self.month != 2) {
                [self.yqDaysArr removeAllObjects];
                for (NSInteger i = _userSelectedDay; i <= 30; i++) {
                    [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                }
                self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
            }else {
                if ([self isLeapYear:self.year]) {
                    [self.yqDaysArr removeAllObjects];
                    for (NSInteger i = _userSelectedDay; i <= 29; i++) {
                        [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                    }
                    self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
                }else {
                    [self.yqDaysArr removeAllObjects];
                    for (NSInteger i = _userSelectedDay; i <= 28; i++) {
                        [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
                    }
                    self.day = [self.yqDaysArr[0] integerValue]; //同时将日期设置为第一行
                }
            }
        }else {
            [self setDefaultDays];
        }
    }else if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateUntilNow) {
        if (self.year == self.components.year && self.month == self.components.month) {
            [self.yqDaysArr removeAllObjects];
            for (NSInteger i = 1; i <= self.components.day; i++) {
                [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
            self.day = [self.yqDaysArr[self.yqDaysArr.count - 1] integerValue];
        }else {
            [self setDefaultDays];
        }
    }
    
    [self updateUserInterface];
}
- (void)setDefaultDays {
    if (self.month == 1 || self.month == 3 || self.month == 5 || self.month == 7 || self.month == 8 || self.month == 10 || self.month == 12) {
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = 1; i <= 31; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }else if (self.month != 2) {
        [self.yqDaysArr removeAllObjects];
        for (NSInteger i = 1; i <= 30; i++) {
            [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
        }
    }else {
        if ([self isLeapYear:self.year]) {
            [self.yqDaysArr removeAllObjects];
            for (NSInteger i = 1; i <= 29; i++) {
                [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        }else {
            [self.yqDaysArr removeAllObjects];
            for (NSInteger i = 1; i <= 28; i++) {
                [self.yqDaysArr addObject:[NSString stringWithFormat:@"%ld", i]];
            }
        }
    }
}

- (void)updateUserInterface {
    //更新UI
    [self.yqPickView reloadComponent:YQYearComponent];
    [self.yqPickView reloadComponent:YQMonthComponent];
    [self.yqPickView reloadComponent:YQDayComponent];
    
    [self selectRowInComponentWithAnimated:YES];
}

- (void)selectRowInComponentWithAnimated:(BOOL)animated {
    if (self.yqYearsArr.count <= 0 || self.yqMonthsArr.count <= 0 || self.yqDaysArr.count <= 0) {
        return;
    }
    if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateDefault) {
        [self.yqPickView selectRow:self.year-YQBeginYearDefault inComponent:YQYearComponent animated:animated];
        [self.yqPickView selectRow:self.month-1 inComponent:YQMonthComponent animated:animated];
        [self.yqPickView selectRow:self.day-1 inComponent:YQDayComponent animated:animated];
    }else if (self.beginDateType == YQBeginDateFromNow && self.endDateType == YQEndDateDefault) {
        if (self.year == self.components.year && self.month == self.components.month) {
            [self.yqPickView selectRow:self.year - self.components.year inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - self.components.month > 0 ? self.month - self.components.month : 0 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day - self.components.day > 0 ? self.day - self.components.day : 0 inComponent:YQDayComponent animated:animated];
        }else {
            [self.yqPickView selectRow:self.year - self.components.year inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - 1 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day - 1 inComponent:YQDayComponent animated:animated];
        }
    }else if (self.beginDateType == YQBeginDateFromDetailDate && self.endDateType == YQEndDateDefault) {
        if (self.year == _userSelectedYear && self.month == _userSelectedMonth) {
            [self.yqPickView selectRow:self.year - _userSelectedYear inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - _userSelectedMonth > 0 ? self.month - _userSelectedMonth : 0 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day - _userSelectedDay > 0 ? self.day - _userSelectedDay : 0 inComponent:YQDayComponent animated:animated];
        }else {
            [self.yqPickView selectRow:self.year - _userSelectedYear inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - 1 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day - 1 inComponent:YQDayComponent animated:animated];
        }
    }else if (self.beginDateType == YQBeginDateDefault && self.endDateType == YQEndDateUntilNow) {
        if (self.year == self.components.year && self.month == self.components.month) {
            [self.yqPickView selectRow:self.components.year - YQBeginYearDefault inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - 1 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day -1 inComponent:YQDayComponent animated:animated];
        }else {
            [self.yqPickView selectRow:self.year - YQBeginYearDefault inComponent:YQYearComponent animated:animated];
            [self.yqPickView selectRow:self.month - 1 inComponent:YQMonthComponent animated:animated];
            [self.yqPickView selectRow:self.day - 1 inComponent:YQDayComponent animated:animated];
        }
    }
    
}
#pragma mark - Lazy Loading
- (NSMutableArray *)yqYearsArr {
    if (_yqYearsArr == nil) {
        _yqYearsArr = [NSMutableArray array];
    }
    return _yqYearsArr;
}
- (NSMutableArray *)yqMonthsArr {
    if (_yqMonthsArr == nil) {
        _yqMonthsArr = [NSMutableArray arrayWithCapacity:12];
    }
    return _yqMonthsArr;
}
- (NSMutableArray *)yqDaysArr {
    if (_yqDaysArr == nil) {
        _yqDaysArr = [NSMutableArray arrayWithCapacity:31];
    }
    return _yqDaysArr;
}

- (NSDateComponents *)components {
    if (_components == nil) {
        NSDate *currentDate = [NSDate date];//当前时间
        NSCalendar *calendar = [NSCalendar currentCalendar];//当前用户的calendar
        _components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:currentDate];
    }
    return _components;
}

@end
