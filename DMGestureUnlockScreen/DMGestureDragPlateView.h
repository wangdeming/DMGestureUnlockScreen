//
//  DMGestureDragPlateView.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMPlateView.h"
#import <UIKit/UIKit.h>

@class DMGestureDragPlateView;
@protocol  DMGestureDragPlateViewDelegate<NSObject>

@required

- (BOOL)DMGestureDragPlateView:(DMGestureDragPlateView *)gestureDragPlateView psw:(NSString *)strPsw  didFinish:(BOOL)finish;

@end

@interface DMGestureDragPlateView : DMPlateView

@property (nonatomic , assign)id<DMGestureDragPlateViewDelegate> delegate;

- (void)againSetGesturePath:(BOOL)bSet;

@end
