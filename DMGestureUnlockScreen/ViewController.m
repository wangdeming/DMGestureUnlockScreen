//
//  ViewController.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "ViewController.h"
#import "DMGestureUnlockScreenVC.h"

@interface ViewController ()

@property (nonatomic, strong) DMGestureUnlockScreenVC *vc;

@property (nonatomic, strong) NSArray *dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"DMGestureUnlockScreen";
    
    [self setupUI];
    
}

- (void)setupUI{
    
    for (int i = 0; i < self.dataArr.count; i ++) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:self.dataArr[i] forState:UIControlStateNormal];
        button.frame = CGRectMake(80, 80 + i * 60, self.view.width - 160, 40);
        button.layer.cornerRadius = 10;
        button.backgroundColor = [UIColor redColor];
        [button setTag:i];
        [button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        
    }
}

- (void)btnClick:(UIButton *)btn
{
    switch (btn.tag) {
        case 0://设置数字解锁
            [DMGestureUnlockScreenVC setUnlockScreenWithType:ClickNumberType];
            break;
        case 1://设置手势路径解锁
            [DMGestureUnlockScreenVC setUnlockScreenWithType:GestureDragType];
            break;
        case 2://修改手势密码
            if(![DMGestureUnlockScreenVC modifyUnlockPasswrodWithVC:self]){
                [self alert:@"先设置手势密码再修改"];
            }
            break;
        case 3://删除手势密码锁
            if(![DMGestureUnlockScreenVC removeGesturePasswordWithVC:self]){
                [self alert:@"先设置手势密码再删除"];
            }
            break;
        default:
            break;
    }
}

- (void)alert:(NSString *)msg{
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sureAc = [UIAlertAction actionWithTitle:@"" style:UIAlertActionStyleDefault handler:nil];
    
    [alertVc addAction:sureAc];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
       
        _dataArr = @[@"设置数字锁屏样式",@"设置路径锁屏样式",@"修改手势密码",@"删除手势密码"];
        
    }
    return _dataArr;
}

@end
