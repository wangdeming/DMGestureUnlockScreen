//
//  DMNumberPlateView.h
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMPlateView.h"

@class DMNumberPlateView;
@protocol  DMNumberPlateViewDelegate<NSObject>

@required
- (void)DMNumberPlateView:(DMNumberPlateView *)numberPlateView clickIndex:(NSInteger)index  didFinish:(BOOL)finish;
@end

@interface DMNumberPlateView : DMPlateView

@property (nonatomic , assign)id<DMNumberPlateViewDelegate> delegate;

- (void)updateUILayout;

- (void)clearClickCount;

- (void)decClickCount;

@end
