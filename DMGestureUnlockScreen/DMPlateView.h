//
//  DMPlateView.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMCircleView.h"

#define DMPlateRow                     (3)                  //数字盘行
#define DMPlateColumn                  (3)                  //数字盘列

@interface DMPlateView : UIView

- (void)DMCircleView:(DMCircleView *)circleView clickIndex:(NSInteger)index;

- (void)updateUILayoutWithType:(DMGestureUnlockType)type;

- (CGPoint)checkConnectPoint:(CGPoint)point;

+ (CGFloat)plateHeightWithType:(DMGestureUnlockType)type;

- (NSString *)getGesturePswWithPoints:(NSArray *)pointArr;

- (void)resetCircleBackgroundWithPoints:(NSArray *)points;

- (void)setFailBackgroundWithStartColor:(CGColorRef)startColor endColor:(CGColorRef)endColor points:(NSArray *)points;

@end
