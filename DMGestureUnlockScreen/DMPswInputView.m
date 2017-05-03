//
//  DMPswInputView.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMPswInputView.h"
#import "DMCircleView.h"
#import "UIView+Rect.h"
#import <AudioToolbox/AudioToolbox.h>

#define  DMCircleRadius      (5.0)                   //圈半径
#define  DMCircleNumber      (4)                     //密码位数
#define  DMCircleMargin      (10.0)                  //密码数字间距
#define  DMCircleScaleAnimationDuring    (0.15)      //圈缩放动画周期
#define  DMCircleDrawAnimationDuring     (1.0)       //圈的绘制动画周期
#define  DMLineWidth          (2.0)                  //线宽
@interface DMPswInputView (){
    NSInteger              _currentIndex;               //当前密码圈下标
    UIImage              * _circleImage;                //圈图片
    CGFloat                _circleSumWidth;             //所有圈占的总宽度
    CGFloat                _oneCircleX;                 //第一个圈x坐标
    NSMutableArray       * _circleImageVArr;            //圈视图数组
}

@end

@implementation DMPswInputView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self setBackgroundImage];
        _circleImage = [self makeCircleImage];
        _circleImageVArr = [NSMutableArray new];
    }
    return self;
}

- (void)setBackgroundImage{
    CAGradientLayer   *   gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = self.bounds;
    gradientLayer.colors = @[(id)DMStartColor,(id)DMEndColor];
    gradientLayer.locations = @[@(0.0),@(1.0)];
    
    CAShapeLayer      * subLayer = [CAShapeLayer layer];
    subLayer.backgroundColor = [UIColor clearColor].CGColor;
    subLayer.frame = self.bounds;
    subLayer.lineWidth = DMLineWidth;
    subLayer.strokeColor = [UIColor magentaColor].CGColor;
    subLayer.fillColor = [UIColor clearColor].CGColor;
    CGMutablePathRef  mutablePath = CGPathCreateMutable();
    _circleSumWidth = DMCircleNumber * DMCircleRadius * 2.0 + (DMCircleNumber - 1) * DMCircleMargin;
    _oneCircleX = (self.width - _circleSumWidth) / 2.0;
    for (NSInteger i = 0; i < DMCircleNumber; i++) {
        CGFloat  x = _oneCircleX + DMCircleRadius * (i + 1) + i * (DMCircleMargin + DMCircleRadius);
        CGPathMoveToPoint(mutablePath, NULL, x + DMCircleRadius, self.height / 2.0);
        CGPathAddArc(mutablePath, NULL, x, self.height / 2.0, DMCircleRadius, 0.0, M_PI * 2.0, NO);
    }
    subLayer.path = mutablePath;
    
    CABasicAnimation  * ba = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    ba.fromValue = @(0.0);
    ba.toValue = @(1.0);
    ba.duration = DMCircleDrawAnimationDuring;
    ba.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    [subLayer addAnimation:ba forKey:@"CircleDrawAnimation"];
    
    gradientLayer.mask = subLayer;
    [self.layer addSublayer:gradientLayer];
    CGPathRelease(mutablePath);
    
}

- (UIImage *)makeCircleImage{
    UIImage  * circleImage= nil;
    UIGraphicsBeginImageContext(CGSizeMake(DMCircleRadius * 2.0, DMCircleRadius * 2.0));
    CGContextRef  context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 1.0);
    CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
    CGColorRef  startColor = CGColorCreateCopy(DMStartColor);
    CGColorRef  endColor = CGColorCreateCopy(DMEndColor);
    CFArrayRef  colors = CFArrayCreate(kCFAllocatorDefault, (const void *[]){startColor,endColor}, 2, NULL);
    CGFloat const  locations[] = {0.0,1.0};
    CGGradientRef  gradientRef = CGGradientCreateWithColors(colorSpaceRef, colors, locations);
    CGContextAddArc(context, DMCircleRadius, DMCircleRadius, DMCircleRadius, 0.0, M_PI * 2.0, NO);
    CGContextClip(context);
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextDrawLinearGradient(context, gradientRef, CGPointZero, CGPointMake(self.width, self.height), kCGGradientDrawsBeforeStartLocation);
    
    CFRelease(colors);
    CGColorSpaceRelease(colorSpaceRef);
    CGColorRelease(endColor);
    CGColorRelease(startColor);
    CGGradientRelease(gradientRef);
    
    circleImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return circleImage;
}

- (void)addPswCircleFinish:(void(^)())didFinish{
    if(_currentIndex < DMCircleNumber){
        if(_circleImage == nil){
            _circleImage = [self makeCircleImage];
        }
        CGFloat  x = _oneCircleX + DMCircleRadius * (_currentIndex + 1) + _currentIndex * (DMCircleMargin + DMCircleRadius);
        UIImageView  * circleImageView = [[UIImageView alloc]initWithImage:_circleImage];
        circleImageView.size = CGSizeMake(DMCircleRadius * 2.0, DMCircleRadius * 2.0);
        circleImageView.center = CGPointMake(x, self.height / 2.0);
        _currentIndex++;
        circleImageView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        circleImageView.tag = _currentIndex;
        [_circleImageVArr addObject:circleImageView];
        [self addSubview:circleImageView];
        [UIView animateWithDuration:DMCircleScaleAnimationDuring delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            circleImageView.transform = CGAffineTransformMakeScale(1.0, 1.0);
        } completion:^(BOOL finished) {
            if(didFinish){
                didFinish();
            }
        }];
    }
}

- (void)clearAllPswCircle{
    _currentIndex = 0;
    [UIView animateWithDuration:DMCircleScaleAnimationDuring delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        for (UIImageView * circelView in _circleImageVArr) {
            circelView.transform = CGAffineTransformMakeScale(0.0, 0.0);
        }
    } completion:^(BOOL finished) {
        for (UIImageView * circelView in _circleImageVArr) {
            [circelView removeFromSuperview];
        }
        [_circleImageVArr removeAllObjects];
    }];
    
}

- (void)clearPswCircle{
    _currentIndex--;
    if(_currentIndex < 0){
        _currentIndex = 0;
    }
    UIImageView  * circleView = [_circleImageVArr lastObject];
    [UIView animateWithDuration:DMCircleScaleAnimationDuring delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        circleView.transform = CGAffineTransformMakeScale(0.0, 0.0);
    } completion:^(BOOL finished) {
        [circleView removeFromSuperview];
        [_circleImageVArr removeLastObject];
    }];
}

- (void)showMistakeMsg{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    CABasicAnimation  * ba = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    ba.delegate = self;
    ba.duration = DMCircleScaleAnimationDuring / 2.0;
    ba.fromValue = @(-20.0);
    ba.toValue = @(20.0);
    ba.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    ba.repeatCount = 4.0;
    ba.autoreverses = YES;
    [self.layer addAnimation:ba forKey:@"CABasicAnimation"];
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self clearAllPswCircle];
}

@end
