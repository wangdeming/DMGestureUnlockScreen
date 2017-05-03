//
//  DMCircleView.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMCircleView.h"

#define DMDrawCircleAnimationDuring            (1.0)           //花圈动画周期
#define DMFontSize                             (30.0)          //字体大小
#define DMBtnSubLayerDismissDuring             (0.1)           //按钮渐变层消失动画

@interface DMCircleView (){
    UIButton                            * _numBtn;                //数字按钮
    CAGradientLayer                     * _btnSubLayer;           //按钮背景层
    CAGradientLayer                     * _gradientLayer;         //背景渐变层
    CAShapeLayer                        * _subLayer;              //背景子层
}

@end

@implementation DMCircleView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        
    }
    return self;
}

- (void)setBackground{
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.colors = @[(id)DMStartColor,(id)DMEndColor];
    _gradientLayer.locations = @[@(0.0),@(1.0)];
    
    _subLayer = [CAShapeLayer layer];
    _subLayer.backgroundColor = [UIColor clearColor].CGColor;
    _subLayer.frame = self.bounds;
    [_gradientLayer setMask:_subLayer];
    [self.layer addSublayer:_gradientLayer];
    
    CGPathRef path = [self getPath];
    _subLayer.path = path;
    CABasicAnimation  * ba = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    ba.duration = DMDrawCircleAnimationDuring;
    ba.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    ba.fromValue = @(0.0);
    ba.toValue = @(1.0);
    [_subLayer addAnimation:ba forKey:@"AnimationDrawCircle"];
    CGPathRelease(path);
}

- (CGPathRef)getPath{
    CGMutablePathRef  path = CGPathCreateMutable();
    CGPathAddArc(path, NULL, _subLayer.frame.size.width / 2.0, _subLayer.frame.size.height / 2.0, self.width / 2.0 - 1.0, 0.0, M_PI * 2.0, NO);
    _subLayer.lineWidth = 2.0;
    _subLayer.strokeColor = [UIColor redColor].CGColor;
    _subLayer.fillColor = [UIColor clearColor].CGColor;
    return path;
}

- (void)setFailBackgroundWithStartColor:(CGColorRef)startColor endColor:(CGColorRef)endColor{
    _gradientLayer.colors = @[(__bridge id)startColor,(__bridge id)endColor];
    _btnSubLayer.colors = @[(__bridge id)startColor,(__bridge id)endColor];
    [_subLayer setNeedsDisplay];
    [_btnSubLayer setNeedsDisplay];
}

- (void)resetBackground{
    [self setFailBackgroundWithStartColor:DMStartColor endColor:DMEndColor];
}

- (void)setCircleType:(DMGestureUnlockType)circleType{
    _circleType = circleType;
    [self setBackground];
    _numBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _numBtn.frame = self.bounds;
    _numBtn.layer.cornerRadius = self.width / 2.0;
    _numBtn.layer.masksToBounds = YES;
    _numBtn.backgroundColor = [UIColor clearColor];
    _numBtn.titleLabel.font = [UIFont boldSystemFontOfSize:DMFontSize];
    [_numBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    if(_circleType == ClickNumberType){
        [_numBtn addTarget:self action:@selector(clickUpNumBtn:) forControlEvents:UIControlEventTouchUpInside];
        [_numBtn addTarget:self action:@selector(clickDownNumBtn:) forControlEvents:UIControlEventTouchDown];
    }else if (_circleType == GestureDragType){
        _numBtn.xy = CGPointMake((self.width - DMSolidCircleRaduis * 2.0) / 2.0, (self.height - DMSolidCircleRaduis * 2.0) / 2.0);
        _numBtn.size = CGSizeMake(DMSolidCircleRaduis * 2.0, DMSolidCircleRaduis * 2.0);
        _numBtn.layer.cornerRadius = DMSolidCircleRaduis;
    }
    [self addSubview:_numBtn];
}

- (void)setNumber:(NSInteger)number{
    _number = number;
    if(_numBtn && _circleType == ClickNumberType){
        _numBtn.tag = number;
        [_numBtn setTitle:@(number).stringValue forState:UIControlStateNormal];
        self.alpha = 0.0;
        [UIView animateWithDuration:DMDrawCircleAnimationDuring delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.alpha = 1.0;
        } completion:nil];
    }else if(_numBtn && _circleType == GestureDragType){
        _numBtn.tag = number;
        _numBtn.backgroundColor = [UIColor grayColor];
        [self addSubLayer];
    }
}

- (void)clickDownNumBtn:(UIButton *)sender{
    [self addSubLayer];
}

- (void)clickUpNumBtn:(UIButton *)sender{
    if(_btnSubLayer){
        CABasicAnimation   * ba = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        ba.delegate = self;
        ba.fromValue = @(1.0);
        ba.toValue = @(4.0);
        ba.duration = DMBtnSubLayerDismissDuring;
        ba.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
        [_btnSubLayer addAnimation:ba forKey:@"_btnSubLayerDismiss"];
    }
    if(_delegate && [_delegate respondsToSelector:@selector(DMCircleView:clickIndex:)]){
        [_delegate DMCircleView:self clickIndex:sender.tag];
    }
}

- (void)addSubLayer{
    if(_btnSubLayer == nil){
        _btnSubLayer = [CAGradientLayer layer];
    }
    _btnSubLayer.frame = _numBtn.bounds;
    _btnSubLayer.colors = @[(id)DMStartColor,(id)DMEndColor];
    _btnSubLayer.locations = @[@(0.0),@(1.0)];
    [_numBtn.layer insertSublayer:_btnSubLayer atIndex:0];
}

#pragma mark - AnimationDelegate
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [_btnSubLayer removeFromSuperlayer];
}

@end
