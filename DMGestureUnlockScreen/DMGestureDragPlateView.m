//
//  DMGestureDragPlateView.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMGestureDragPlateView.h"
#import <AudioToolbox/AudioToolbox.h>

#define DMErrorShakeAnimationDuring (0.1)
#define DMErrorStartColor  ([UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:0.8].CGColor)
#define DMErrorEndColor    ([UIColor colorWithRed:1.0 green:0.7 blue:0.0 alpha:0.8].CGColor)

@interface DMGestureDragPlateView (){
    UIPanGestureRecognizer         *  _panGesture;             //拖拽手势
    NSMutableArray                 *  _savePointArr;           //存储坐标点得值
    BOOL                              _canDrag;                //是否能夠拖拽
    BOOL                              _againSetGesture;        //再次設置手勢路徑
    CAGradientLayer                *  _gradientLayer;          //漸變層
    CAShapeLayer                   *  _shapeLayer;             //子層
    CGPoint                           _currentPoint;           //當前點
    CGPoint                           _startPoint;             //開始點
}

@end

@implementation DMGestureDragPlateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self initData];
        [self updateUILayout];
    }
    return self;
}

- (void)updateUILayout{
    [self updateUILayoutWithType:GestureDragType];
    _gradientLayer = [CAGradientLayer layer];
    _gradientLayer.frame = self.bounds;
    _gradientLayer.backgroundColor = [UIColor clearColor].CGColor;
    _gradientLayer.colors = @[(id)DMStartColor,(id)DMEndColor];
    _gradientLayer.locations = @[@(0.0),@(1.0)];
    
    _shapeLayer = [CAShapeLayer layer];
    _shapeLayer.frame = self.bounds;
    _shapeLayer.backgroundColor = [UIColor clearColor].CGColor;
    _shapeLayer.lineWidth = DMSolidCircleRaduis;
    _shapeLayer.lineJoin = kCALineJoinRound;
    _shapeLayer.lineCap = kCALineCapRound;
    _shapeLayer.strokeColor = [UIColor magentaColor].CGColor;
    _shapeLayer.fillColor = [UIColor clearColor].CGColor;
    
    _gradientLayer.mask = _shapeLayer;
    [self.layer addSublayer:_gradientLayer];
}

- (void)initData{
    
    _savePointArr = [NSMutableArray array];
    _panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:_panGesture];
}

- (void)setFailPath{
    if(!_againSetGesture){
        [self setFailBackgroundWithStartColor:DMErrorStartColor endColor:DMErrorEndColor points:_savePointArr];
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        _gradientLayer.colors = @[(id)DMErrorStartColor,(id)DMErrorEndColor];
        [self drawDragPath];
        
        CABasicAnimation  * ba = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        ba.delegate = self;
        ba.duration = DMErrorShakeAnimationDuring;
        ba.fromValue = @(-10.0);
        ba.toValue = @(10.0);
        ba.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        ba.repeatCount = 2.0;
        ba.autoreverses = YES;
        [_gradientLayer addAnimation:ba forKey:@"_gradientLayer"];
    }
}

- (void)clearPath{
    [_savePointArr removeAllObjects];
    _currentPoint = CGPointZero;
    _startPoint =  CGPointZero;
    [self drawDragPath];
}

- (void)againSetGesturePath:(BOOL)bSet{
    _againSetGesture = bSet;
    if(bSet){
        [self clearPath];
    }
}

- (BOOL)checkIsRepetPath:(CGPoint)point{
    BOOL      result = NO;
    for (NSValue * value in _savePointArr) {
        CGPoint tempPoint = [value CGPointValue];
        if(point.x == tempPoint.x && point.y == tempPoint.y){
            result = YES;
            break;
        }
    }
    return result;
}

#pragma mark - handlePanGesture

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture{
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            [self clearPath];
            _startPoint = [panGesture locationInView:panGesture.view];
            CGPoint   checkPoint = CGPointZero;
            checkPoint = [self checkConnectPoint:_startPoint];
            if(checkPoint.x == 0.0 && checkPoint.y == 0.0){
                _canDrag = NO;
            }else{
                _startPoint = checkPoint;
                _canDrag = YES;
                [_savePointArr addObject:[NSValue valueWithCGPoint:checkPoint]];
                [self drawDragPath];
            }
        }
            break;
        case UIGestureRecognizerStateChanged:{
            if(_canDrag){
                _currentPoint = [panGesture locationInView:panGesture.view];
                CGPoint   checkPoint = [self checkConnectPoint:_currentPoint];
                if(checkPoint.x != 0.0 && checkPoint.y != 0.0){
                    if(![self checkIsRepetPath:checkPoint]){
                        [_savePointArr addObject:[NSValue valueWithCGPoint:checkPoint]];
                    }
                }
                [self drawDragPath];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:{
            if(_canDrag){
                if(_savePointArr.count > 1){
                    _currentPoint = [_savePointArr.lastObject CGPointValue];
                    [self drawDragPath];
                }else if (_savePointArr.count == 1){
                    [self clearPath];
                    _canDrag = NO;
                    return;
                }
                
                if(_delegate && [_delegate respondsToSelector:@selector(DMGestureDragPlateView:psw:didFinish:)]){
                    NSString  * strGesturePsw = [self getGesturePswWithPoints:_savePointArr];
                    if(![_delegate DMGestureDragPlateView:self psw:strGesturePsw didFinish:YES]){
                        [self setFailPath];
                    }
                }
            }
            _canDrag = NO;
        }
            break;
        default:
            break;
    }
}

- (void)drawDragPath{
    CGMutablePathRef  mutablePath = CGPathCreateMutable();
    CGPathMoveToPoint(mutablePath, NULL, _startPoint.x, _startPoint.y);
    for (NSValue  * value in _savePointArr) {
        CGPoint     point = [value CGPointValue];
        CGPathAddLineToPoint(mutablePath, NULL, point.x, point.y);
    }
    if(_currentPoint.x != 0.0 && _currentPoint.y != 0.0){
        CGPathAddLineToPoint(mutablePath, NULL, _currentPoint.x, _currentPoint.y);
    }
    _shapeLayer.path = mutablePath;
    CGPathRelease(mutablePath);
}

#pragma mark -
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    _gradientLayer.colors = @[(id)DMStartColor,(id)DMEndColor];
    [self resetCircleBackgroundWithPoints:_savePointArr];
    [self clearPath];
}

@end
