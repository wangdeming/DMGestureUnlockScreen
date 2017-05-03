//
//  DMCircleView.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+Rect.h"

#define DMSolidCircleRaduis                    (15.0)            //中心实心圆半径
#define DMStartColor      ([UIColor colorWithRed:136.0 / 255.0  green:112.0 / 255.0 blue:151.0 / 255.0 alpha:1.0].CGColor)
#define DMEndColor        ([UIColor colorWithRed:176.0 / 255.0 green:114.0 / 255.0 blue:135.0 / 255.0 alpha:1.0].CGColor)

typedef NS_ENUM(NSInteger,DMGestureUnlockType){
    UnknownType = 0 ,            //未知类型
    ClickNumberType,             //点击数字键盘解锁
    GestureDragType              //手势路径拖拽解锁
};

@class DMCircleView;

@protocol DMCircleViewDelegate <NSObject>

@required

- (void)DMCircleView:(DMCircleView *)circleView clickIndex:(NSInteger)index;

@end

@interface DMCircleView : UIView

@property (nonatomic , assign)id<DMCircleViewDelegate> delegate;
@property (nonatomic , assign)DMGestureUnlockType  circleType;
@property (nonatomic , assign)NSInteger number;

- (void)setFailBackgroundWithStartColor:(CGColorRef)startColor endColor:(CGColorRef)endColor;

- (void)resetBackground;

@end
