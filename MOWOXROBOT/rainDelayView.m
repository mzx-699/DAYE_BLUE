//
//  rainDelayView.m
//  MOWOXROBOT
//
//  Created by apple on 2021/6/23.
//  Copyright © 2021 yusz. All rights reserved.
//

#import "rainDelayView.h"

@interface rainDelayView ()

@property (nonatomic, strong) UILabel *timeLbael;
@property (nonatomic, strong) UILabel *hourLabel;
@property (nonatomic, strong) UILabel *minLabel;

@end  
@implementation rainDelayView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (UITextField *)hourTextField{
    if (!_hourTextField) {
        _hourTextField = [[UITextField alloc] init];
        _hourTextField.borderStyle = UITextBorderStyleRoundedRect;
        _hourTextField.placeholder = @"hour";
        _hourTextField.keyboardType = UIKeyboardTypeNumberPad;
        _hourTextField.backgroundColor = [UIColor clearColor];
        _hourTextField.borderStyle = UITextBorderStyleNone;
        _hourTextField.textAlignment = NSTextAlignmentCenter;
        _hourTextField.tintColor = [UIColor grayColor];
        _hourTextField.font = [UIFont systemFontOfSize:13];
    }
    return _hourTextField;
}
- (UITextField *)minTextField{
    if (!_minTextField) {
        _minTextField = [[UITextField alloc] init];
        _minTextField.borderStyle = UITextBorderStyleRoundedRect;
        _minTextField.placeholder = @"min";
        _minTextField.keyboardType = UIKeyboardTypeNumberPad;
        _minTextField.backgroundColor = [UIColor clearColor];
        _minTextField.borderStyle = UITextBorderStyleNone;
        _minTextField.textAlignment = NSTextAlignmentCenter;
        _minTextField.tintColor = [UIColor grayColor];
        _minTextField.font = [UIFont systemFontOfSize:13];
    }
    return _minTextField;
}
- (UILabel *)timeLbael{
    if (!_timeLbael) {
        _timeLbael = [[UILabel alloc] init];
        _timeLbael.text = @"Time:";
        _timeLbael.textColor = [UIColor blackColor];
        _timeLbael.font = [UIFont systemFontOfSize:13];
    }
    return _timeLbael;
}
- (UILabel *)hourLabel{
    if (!_hourLabel) {
        _hourLabel = [[UILabel alloc] init];
        _hourLabel.text = @"H";
        _hourLabel.textColor = [UIColor blackColor];
        _hourLabel.font = [UIFont systemFontOfSize:13];
    }
    return _hourLabel;
}
- (UILabel *)minLabel{
    if (!_minLabel) {
        _minLabel = [[UILabel alloc] init];
        _minLabel.text = @"Min";
        _minLabel.textColor = [UIColor blackColor];
        _minLabel.font = [UIFont systemFontOfSize:13];
    }
    return _minLabel;
}
- (void)setupUI {
    [self addSubview:self.hourTextField];
    [self addSubview:self.minTextField];
    [self addSubview:self.minLabel];
    [self addSubview:self.hourLabel];
    [self addSubview:self.timeLbael];
    
    NSNumber *hourWidth = [self labelAdaptiveWidthWith:self.hourLabel];
    NSNumber *minWidth = [self labelAdaptiveWidthWith:self.minLabel];
    NSNumber *timeWidth = [self labelAdaptiveWidthWith:self.timeLbael];
    
    [self.hourLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.mas_centerX);
        make.centerY.equalTo(self.mas_centerY);
        make.width.equalTo(hourWidth);
        make.height.equalTo(self.mas_height);
    }];
    [self.minTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.left.equalTo(self.hourLabel.mas_right).offset(5);
        make.height.equalTo(self.mas_height);
        make.width.equalTo(@25);
    }];
    [self.minLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hourLabel.mas_centerY);
        make.left.equalTo(self.minTextField.mas_right).offset(5);
        make.width.equalTo(minWidth);
        make.height.equalTo(self.mas_height);
    }];
    [self.hourTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.mas_centerY);
        make.right.equalTo(self.hourLabel.mas_left).offset(-5);
        make.height.equalTo(self.mas_height);
        make.width.equalTo(@35);
    }];
    [self.timeLbael mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.hourLabel.mas_centerY);
        make.right.equalTo(self.hourTextField.mas_left).offset(-5);
        make.width.equalTo(timeWidth);
        make.height.equalTo(self.mas_height);
    }];
    
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 1.5;
    self.layer.cornerRadius = ScreenHeight * 0.033;
}
- (NSNumber *)labelAdaptiveWidthWith:(UILabel *)label {
    CGSize size = [label.text boundingRectWithSize:CGSizeMake(100, self.frame.size.height) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : label.font} context:nil].size;
    return [NSNumber numberWithFloat:size.width + 1];
}
@end
