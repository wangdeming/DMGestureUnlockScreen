//
//  DMNumberPlateView.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMNumberPlateView.h"

@interface DMNumberPlateView (){
    
    NSInteger         _clickCount;       //单击次数
}

@end


@implementation DMNumberPlateView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if(self){
        [self updateUILayout];
    }
    return self;
}

- (void)updateUILayout{
    _clickCount = 0;
    [self updateUILayoutWithType:ClickNumberType];
}

- (void)clearClickCount{
    _clickCount = 0;
}

- (void)decClickCount{
    _clickCount--;
}
#pragma mark - DMCircleViewDelegate
- (void)DMCircleView:(DMCircleView *)circleView clickIndex:(NSInteger)index{
    if(_clickCount >= DMPlateColumn){
        _clickCount = 0;
        if(_delegate && [_delegate respondsToSelector:@selector(DMNumberPlateView:clickIndex:didFinish:)]){
            [_delegate DMNumberPlateView:self clickIndex:index didFinish:YES];
        }
    }else{
        if(_delegate && [_delegate respondsToSelector:@selector(DMNumberPlateView:clickIndex:didFinish:)]){
            [_delegate DMNumberPlateView:self clickIndex:index didFinish:NO];
        }
    }
    _clickCount++;
}

@end
