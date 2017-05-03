//
//  DMPswInputView.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMPswInputView : UIView

- (void)addPswCircleFinish:(void(^)())didFinish;

- (void)clearAllPswCircle;

- (void)clearPswCircle;

- (void)showMistakeMsg;

@end
