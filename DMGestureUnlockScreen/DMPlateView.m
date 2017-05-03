//
//  DMPlateView.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMPlateView.h"

#define DMCircleMargin                 (30.0)               //圈之间的间隙


@interface DMRect : NSObject

@property (nonatomic , assign)NSInteger number;

@property (nonatomic , assign)CGRect    rect;

@end

@implementation DMRect

- (instancetype)init{
    self = [super init];
    if(self){
        _number = 0;
        _rect = CGRectZero;
    }
    return self;
}

@end


@interface DMPlateView ()<DMCircleViewDelegate>{
    NSMutableArray             *    _rectArr;                  //区域数组
    NSMutableArray             *    _circleViewArr;            //圈视图数组
}

@end

@implementation DMPlateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        _rectArr = [NSMutableArray array];
        _circleViewArr = [NSMutableArray array];
    }
    return self;
}

+ (CGFloat)plateHeightWithType:(DMGestureUnlockType)type{
    CGFloat   screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat   circleWidth = (screenWidth - (DMPlateColumn + 1) * DMCircleMargin) / (CGFloat)DMPlateColumn;
    CGFloat   circleSumWidth = DMPlateRow * circleWidth + DMPlateRow * DMCircleMargin;
    circleSumWidth += circleWidth;
    if(type == GestureDragType){
        circleSumWidth -= circleWidth;
    }
    return circleSumWidth;
}

- (void)updateUILayoutWithType:(DMGestureUnlockType)type{
    NSArray  * subArr = self.subviews;
    if(subArr){
        for (UIView * subView in subArr) {
            [subView removeFromSuperview];
        }
    }
    [_rectArr removeAllObjects];
    [_circleViewArr removeAllObjects];
    self.backgroundColor = [UIColor clearColor];
    CGFloat   circleWidth = (self.width - (DMPlateColumn + 1) * DMCircleMargin) / (CGFloat)DMPlateColumn;
    CGFloat   circleSumWidth = DMPlateColumn * circleWidth + (DMPlateColumn - 1) * DMCircleMargin;
    CGFloat   oneCircleX = (self.width - circleSumWidth) / 2.0;
    for (NSInteger i = 0; i < DMPlateRow; i++) {
        for (NSInteger j = 0; j < DMPlateColumn; j++) {
            NSInteger  number = i * DMPlateRow + j + 1;
            CGFloat  x = oneCircleX + circleWidth / 2.0 * (j + 1) + j * (DMCircleMargin + circleWidth / 2.0);
            DMCircleView  * circleView = [DMCircleView new];
            circleView.delegate = self;
            circleView.size = CGSizeMake(circleWidth, circleWidth);
            circleView.center = CGPointMake(x, (i + 1) * circleWidth / 2.0 + i * (DMCircleMargin + circleWidth / 2.0));
            circleView.circleType = type;
            [circleView setNumber:number];
            [self addSubview:circleView];
            [_circleViewArr addObject:circleView];
            if(type == GestureDragType){
                DMRect   * rectObject = [DMRect new];
                CGRect     rect  = {circleView.x, circleView.y , circleWidth, circleWidth};
                rectObject.rect = rect;
                rectObject.number = number;
                [_rectArr addObject:rectObject];
            }
        }
    }
    if(type == ClickNumberType){
        DMCircleView  * circleView = [DMCircleView new];
        circleView.delegate = self;
        circleView.size = CGSizeMake(circleWidth, circleWidth);
        circleView.center = CGPointMake(self.centerX, (DMPlateRow + 1) * circleWidth / 2.0 + DMPlateRow * (DMCircleMargin + circleWidth / 2.0));
        circleView.circleType = ClickNumberType;
        [circleView setNumber:0];
        [self addSubview:circleView];
    }
}

- (CGPoint)checkConnectPoint:(CGPoint)point{
    CGPoint     resultPoint = CGPointZero;
    for (DMRect * rectObject in _rectArr) {
        CGRect  rect = rectObject.rect;
        if(CGRectContainsPoint(rect, point)){
            resultPoint = CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect) / 2.0, CGRectGetMinY(rect) + CGRectGetHeight(rect) / 2.0);
            break;
        }
    }
    return resultPoint;
}

- (NSString *)getGesturePswWithPoints:(NSArray *)pointArr{
    NSMutableString  * strPsw = [NSMutableString string];
    NSInteger          count = _rectArr.count;
    for (NSValue * value in pointArr) {
        CGPoint  point = [value CGPointValue];
        for (NSInteger i = 0; i < count; i++) {
            DMRect * rectObject = _rectArr[i];
            CGRect  rect = rectObject.rect;
            if(CGRectContainsPoint(rect, point)){
                [strPsw appendString:@(rectObject.number).stringValue];
            }
        }
    }
    return strPsw;
}


- (NSInteger)checkDidConnectIndexPoint:(CGPoint)point{
    NSInteger  index = -1;
    for (DMRect * rectObject in _rectArr) {
        CGRect  rect = rectObject.rect;
        if(CGRectContainsPoint(rect, point)){
            index = rectObject.number;
            break;
        }
    }
    return index;
}

- (DMCircleView *)getCircleViewWithIndex:(NSInteger)index{
    DMCircleView * circleView = nil;
    if(_circleViewArr){
        for (DMCircleView * tempCircleView in _circleViewArr) {
            if(index == tempCircleView.number){
                circleView = tempCircleView;
                break;
            }
        }
    }
    return circleView;
}

- (void)resetCircleBackgroundWithPoints:(NSArray *)points{
    [self setFailBackgroundWithStartColor:NULL endColor:NULL isFail:NO  points:points];
}

- (void)setFailBackgroundWithStartColor:(CGColorRef)startColor endColor:(CGColorRef)endColor points:(NSArray *)points{
    [self setFailBackgroundWithStartColor:startColor endColor:endColor isFail:YES points:points];
}

- (void)setFailBackgroundWithStartColor:(CGColorRef)startColor endColor:(CGColorRef)endColor isFail:(BOOL)isFail points:(NSArray *)points{
    
    for (NSValue * pointValue in points) {
        CGPoint  point = [pointValue CGPointValue];
        NSInteger  index = [self checkDidConnectIndexPoint:point];
        if(index != -1){
            DMCircleView  * circleView = [self getCircleViewWithIndex:index];
            if(circleView){
                if(isFail){
                    [circleView setFailBackgroundWithStartColor:startColor endColor:endColor];
                }else{
                    [circleView resetBackground];
                }
            }
        }
    }
}

#pragma mark - DMCircleViewDelegate
- (void)DMCircleView:(DMCircleView *)circleView clickIndex:(NSInteger)index{
    //空实现
}

@end
