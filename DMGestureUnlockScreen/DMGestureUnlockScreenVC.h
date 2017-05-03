//
//  DMGestureUnlockScreenVC.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DMPlateView.h"

@interface DMGestureUnlockScreenVC : UIViewController

@property (nonatomic , assign)DMGestureUnlockType unlockType;

//! 设置背景图片
- (void)setBackgroudImage:(UIImage *)image;

//! 设置屏幕锁(默认当前VC)
+ (void)setUnlockScreen;

//! 设置屏幕锁(自定义当前VC)
+ (void)setUnlockScreenWithSelf:(UIViewController *)sf;

//! 设置屏幕锁(自定义类型默认当前VC)
+ (void)setUnlockScreenWithType:(DMGestureUnlockType)unlockType;

//! 设置屏幕锁(自定义类型和VC)
+ (void)setUnlockScreenWithType:(DMGestureUnlockType)unlockType withSelf:(UIViewController *)sf;

//! 修改解锁密码(自定义当前VC) 可以修改返回yes 否则no
+ (BOOL)modifyUnlockPasswrodWithVC:(UIViewController *)vc;

//! 删除手势密码(自定义当前VC) 可以删除返回yes 否则no
+ (BOOL)removeGesturePasswordWithVC:(UIViewController *)vc;

//！强制删除手势密码,不需要用户输入现有手势密码
+ (void)removeGesturePassword;

@end
