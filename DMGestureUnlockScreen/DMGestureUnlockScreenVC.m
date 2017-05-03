//
//  DMGestureUnlockScreenVC.m
//  DMGestureUnlockScreen
//
//  Created by SDC201 on 2017/5/3.
//  Copyright © 2017年 PCEBG. All rights reserved.
//

#import "DMGestureUnlockScreenVC.h"
#import "UIView+Rect.h"
#import "DMPswInputView.h"
#import "DMNumberPlateView.h"
#import "DMGestureDragPlateView.h"

#define DMInputPswLabY            (30.0)               //输入密码标签y坐标
#define DMInputPswLabHeight       (30.0)               //输入密码标签高度
#define DMBottomHeight            (40.0)               //底部高度
#define DMDelBtnWidth             (60.0)               //删除按钮宽度
#define DMIphone4Height           (480.0)              //iphone4高度

#define DMinputOldPswLabTxt       (@"请输入旧密码")
#define DMinputNewPswLabTxt       (@"请输入新密码")
#define DMinputOldGestureLabTxt   (@"请输入旧手势")
#define DMinputNewGestureLabTxt   (@"请输入新手势")

#define DMInputPswLabTxt          (@"请输入密码")        //输入密码标签文字
#define DMInputPswLabAgTxt        (@"请再次输入密码")     //输入密码标签文字
#define DMInputPswLabReTxt        (@"请重新输入密码")     //输入密码标签文字
#define DMInputPswLabGestureTxt   (@"请输入手势")         //输入密码标签文字
#define DMInputPswLabGestureAgTxt (@"请再次输入手势")      //输入密码标签文字
#define DMInputPswLabGestureReTxt (@"请重新输入手势")      //输入密码标签文字
#define DMUnlockSuccessTxt        (@"正在进入系统")       //解锁成功提示
#define DMSetUnlockSuccessTxt     (@"设置密码成功")       //解锁成功提示
#define DMDelBtnTxt               (@"删除")             //删除按钮文字
#define DMCancelBtnTxt            (@"取消")             //取消按钮文字
#define DMConfigurationKey        (@"ConfigurationKey")//配置信息key
#define DMSetStateKey             (@"SetStateKey")     //状态key
#define DMPswKey                  (@"PswKey")          //密码key

#define DMBackStartColor          ((id)[UIColor colorWithRed:56.0 / 255.0 green:34.0 / 255.0 blue:80.0 / 255.0 alpha:1.0].CGColor)
#define DMBackEndColor            ((id)[UIColor colorWithRed:56.0 / 255.0 green:34.0 / 255.0 blue:36.0 / 255.0 alpha:1.0].CGColor)

@interface DMGestureUnlockScreenVC ()<DMNumberPlateViewDelegate , DMGestureDragPlateViewDelegate>{
    NSMutableString             * _pswOnce;               //第一次密码
    NSMutableString             * _pswTwo;                //第二次密码
    NSString                    * _modifyPsw;             //修改的密码
    NSString                    * _didSavePsw;            //已经存储的密码
    UILabel                     * _inputPswLab;           //输入密码提示标签
    DMPswInputView            * _pswInputView;          //密码输入视图
    DMGestureDragPlateView    * _gestureInputView;      //手势密码输入视图
    DMNumberPlateView         * _numberPlateView;       //数字按钮视图
    UIButton                    * _delBtn;                //删除按钮
    UIButton                    * _cancelBtn;             //取消按钮
    CAGradientLayer             * _defaultBackgroudLayer; //默认背景层
    BOOL                          _setState;              //设置状态
    BOOL                          _isAgainSetPsw;         //是否再次设置密码
    BOOL                          _isModifyPassword;      //是否修改密码
    BOOL                          _isRemovePassword;      //是否删除密码
}

@end

@implementation DMGestureUnlockScreenVC

+ (void)setUnlockScreen{
    [DMGestureUnlockScreenVC setUnlockScreenWithSelf:[DMGestureUnlockScreenVC getCurrentVC]];
}

+ (void)setUnlockScreenWithSelf:(UIViewController *)sf{
    if([DMGestureUnlockScreenVC readDefaultUnlockType] != UnknownType){
        [DMGestureUnlockScreenVC setUnlockScreenWithType:UnknownType withSelf:sf];
    }
}

+ (void)setUnlockScreenWithType:(DMGestureUnlockType)unlockType{
    [DMGestureUnlockScreenVC setUnlockScreenWithType:unlockType withSelf:[DMGestureUnlockScreenVC getCurrentVC]];
}

+ (void)setUnlockScreenWithType:(DMGestureUnlockType)unlockType withSelf:(UIViewController *)sf{
    DMGestureUnlockScreenVC  * unlockVC = [DMGestureUnlockScreenVC new];
    unlockVC.unlockType = unlockType;
    [sf presentViewController:unlockVC animated:NO completion:nil];
}

+ (BOOL)modifyUnlockPasswrodWithVC:(UIViewController *)vc{
    if([DMGestureUnlockScreenVC readDefaultUnlockType] != UnknownType){
        DMGestureUnlockScreenVC * unlockVC = [DMGestureUnlockScreenVC new];
        unlockVC.unlockType = UnknownType;
        [unlockVC setModifyPasswordState:YES];
        [vc presentViewController:unlockVC animated:NO completion:nil];
        return YES;
    }
    return NO;
}

+ (BOOL)removeGesturePasswordWithVC:(UIViewController *)vc{
    if([DMGestureUnlockScreenVC readDefaultUnlockType] != UnknownType){
        DMGestureUnlockScreenVC * unlockVC = [DMGestureUnlockScreenVC new];
        unlockVC.unlockType = UnknownType;
        [unlockVC setRemoveGesturePassword:YES];
        [vc presentViewController:unlockVC animated:NO completion:nil];
        return YES;
    }
    return NO;
}

+ (void)removeGesturePassword{
    NSUserDefaults  * ud = [NSUserDefaults standardUserDefaults];
    [ud removeObjectForKey:DMConfigurationKey];
    [ud synchronize];
}

+ (UIViewController *)getCurrentVC{
    UIViewController  * currentVC = nil;
    UIViewController  * rootVC = [[UIApplication sharedApplication].delegate window].rootViewController;
    if([rootVC isKindOfClass:[UINavigationController class]]){
        currentVC = ((UINavigationController *) rootVC).topViewController;
    }else if ([rootVC isKindOfClass:[UITabBarController class]]){
        UIViewController  * tabBarVC = ((UITabBarController *)rootVC).selectedViewController;
        if([tabBarVC isKindOfClass:[UINavigationController class]]){
            currentVC = ((UINavigationController *) tabBarVC).topViewController;
        }else{
            currentVC = tabBarVC;
        }
    }else{
        currentVC = rootVC;
    }
    return currentVC;
}

- (instancetype)init{
    self = [super init];
    if(self){
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setDefaultBackgroud];
    [self initData];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    if(_unlockType == UnknownType){
        _unlockType = [DMGestureUnlockScreenVC readDefaultUnlockType];
    }
    [self updateUILayout];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initData{
    _pswOnce = [NSMutableString string];
    _pswTwo = [NSMutableString string];
}

+ (DMGestureUnlockType)readDefaultUnlockType{
    DMGestureUnlockType  unlockType;
    NSUserDefaults   * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary  * dict = [ud objectForKey:DMConfigurationKey];
    if(dict && dict.count > 0){
        NSArray * keyArr = [dict allKeys];
        if(keyArr && keyArr.count > 0){
            unlockType = [keyArr[0] integerValue];
        }else{
            unlockType = UnknownType;
        }
    }else{
        unlockType = UnknownType;
    }
    return unlockType;
}

- (void)readConfigurationInfo{
    NSUserDefaults   * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary  * dict = [ud objectForKey:DMConfigurationKey];
    if(dict && dict.count > 0){
        NSDictionary  * typeDict = dict[@(_unlockType).stringValue];
        if(typeDict && typeDict.count > 0){
            _setState = [typeDict[DMSetStateKey] boolValue];
            _setState = !_setState;
            _didSavePsw = typeDict[DMPswKey];
        }else{
            _setState = YES;
            _didSavePsw = @"";
        }
    }else{
        _setState = YES;
        _didSavePsw = @"";
    }
}

- (void)setModifyPasswordState:(BOOL)state{
    _isModifyPassword = state;
}

- (void)setRemoveGesturePassword:(BOOL)state{
    _isRemovePassword = state;
}

- (void)saveConfigurationInfo{
    NSString  * gesturePsw = nil;
    if(_isModifyPassword){
        gesturePsw = _modifyPsw;
    }else{
        gesturePsw = _pswOnce;
    }
    _setState = YES;
    NSUserDefaults  * ud = [NSUserDefaults standardUserDefaults];
    NSDictionary    * dict = @{@(_unlockType).stringValue:@{DMSetStateKey:@(_setState),DMPswKey:gesturePsw}};
    [ud setObject:dict forKey:DMConfigurationKey];
    [ud synchronize];
}

- (void)setDefaultBackgroud{
    _defaultBackgroudLayer = [CAGradientLayer layer];
    _defaultBackgroudLayer.frame = self.view.bounds;
    _defaultBackgroudLayer.colors = @[DMBackStartColor,DMBackEndColor];
    _defaultBackgroudLayer.locations = @[@(0.0),@(1.0)];
    [self.view.layer insertSublayer:_defaultBackgroudLayer atIndex:0];
}

- (void)updateUILayout{
    [self readConfigurationInfo];
    for (UIView * subView in self.view.subviews) {
        [subView removeFromSuperview];
    }
    CGFloat   ratioHeight = [UIScreen mainScreen].bounds.size.height / DMIphone4Height;
    if(_unlockType == ClickNumberType){
        _inputPswLab = [[UILabel alloc]initWithFrame:CGRectMake(0.0, DMInputPswLabY * ratioHeight, self.view.width, DMInputPswLabHeight)];
        _inputPswLab.backgroundColor = [UIColor clearColor];
        _inputPswLab.textAlignment = NSTextAlignmentCenter;
        if(_isModifyPassword){
            _inputPswLab.text = DMinputOldPswLabTxt;
        }else{
            _inputPswLab.text = DMInputPswLabTxt;
        }
        _inputPswLab.textColor = [UIColor whiteColor];
        [self.view addSubview:_inputPswLab];
        
        _pswInputView = [[DMPswInputView alloc]initWithFrame:CGRectMake(0.0, _inputPswLab.maxY, self.view.width, DMInputPswLabHeight)];
        [self.view addSubview:_pswInputView];
        
        CGFloat    numberPlateViewY = self.view.height - DMBottomHeight - [DMPlateView plateHeightWithType:ClickNumberType];
        _numberPlateView = [[DMNumberPlateView alloc]initWithFrame:CGRectMake(0.0, numberPlateViewY, self.view.width, [DMPlateView plateHeightWithType:ClickNumberType])];
        _numberPlateView.delegate = self;
        [self.view addSubview:_numberPlateView];
        
        _delBtn = [self createButtonWithFrame:CGRectMake(self.view.width - DMDelBtnWidth * 1.5, _numberPlateView.maxY, DMDelBtnWidth, DMBottomHeight) txt:DMDelBtnTxt];
        [_delBtn addTarget:self action:@selector(clickDelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_delBtn];
        
    }else if (_unlockType == GestureDragType){
        _inputPswLab = [[UILabel alloc]initWithFrame:CGRectMake(0.0, DMInputPswLabY * ratioHeight * 2.0, self.view.width, DMInputPswLabHeight)];
        _inputPswLab.backgroundColor = [UIColor clearColor];
        _inputPswLab.textAlignment = NSTextAlignmentCenter;
        if(_isModifyPassword){
            _inputPswLab.text = DMinputOldGestureLabTxt;
        }else{
            _inputPswLab.text = DMInputPswLabGestureTxt;
        }
        _inputPswLab.textColor = [UIColor whiteColor];
        [self.view addSubview:_inputPswLab];
        
        CGFloat    numberPlateViewY = _inputPswLab.maxY * 1.5;
        _gestureInputView = [[DMGestureDragPlateView alloc]initWithFrame:CGRectMake(0.0, numberPlateViewY, self.view.width, [DMPlateView plateHeightWithType:GestureDragType])];
        _gestureInputView.delegate = self;
        [self.view addSubview:_gestureInputView];
    }
    
    if(_setState || _isModifyPassword || _isRemovePassword){
        _cancelBtn = [self createButtonWithFrame:CGRectMake(DMDelBtnWidth / 2.0, self.view.height - DMBottomHeight, DMDelBtnWidth, DMBottomHeight) txt:DMCancelBtnTxt];
        [_cancelBtn addTarget:self action:@selector(clickCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:_cancelBtn];
    }
}

- (UIButton *)createButtonWithFrame:(CGRect)frame txt:(NSString *)txt{
    UIButton  * btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = frame;
    btn.backgroundColor = [UIColor clearColor];
    btn.titleLabel.font = [UIFont systemFontOfSize:14.0];
    [btn setTitle:txt forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    return btn;
}

- (void)setUnlockType:(DMGestureUnlockType)unlockType{
    if(unlockType != _unlockType){
        _unlockType = unlockType;
        [self updateUILayout];
    }
}

- (void)setBackgroudImage:(UIImage *)image{
    if(image){
        if(_defaultBackgroudLayer){
            [_defaultBackgroudLayer removeFromSuperlayer];
            _defaultBackgroudLayer = nil;
        }
        self.view.backgroundColor = [UIColor colorWithPatternImage:image];
    }
}

- (void)clickDelBtn:(UIButton *)sender{
    [_pswInputView clearPswCircle];
    [_numberPlateView decClickCount];
}

- (void)clickCancelBtn:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - DMNumberPlateViewDelegate
- (void)DMNumberPlateView:(DMNumberPlateView *)numberPlateView clickIndex:(NSInteger)index  didFinish:(BOOL)finish{
    if(_isAgainSetPsw){
        [_pswTwo appendString:@(index).stringValue];
    }else{
        [_pswOnce appendString:@(index).stringValue];
    }
    if(finish){
        __weak typeof(self)  sf = self;
        [_pswInputView addPswCircleFinish:^{
            if(_isAgainSetPsw){
                if(_isModifyPassword){
                    if(_modifyPsw){
                        if([_pswTwo isEqualToString:_modifyPsw]){
                            _inputPswLab.text = DMSetUnlockSuccessTxt;
                            [_pswInputView clearAllPswCircle];
                            [sf saveConfigurationInfo];
                            [sf dismissViewControllerAnimated:YES completion:nil];
                        }else{
                            [_pswInputView showMistakeMsg];
                            [_numberPlateView clearClickCount];
                            if(_isModifyPassword){
                                _inputPswLab.text = DMinputOldPswLabTxt;
                            }else{
                                _inputPswLab.text = DMInputPswLabTxt;
                            }
                            _modifyPsw = nil;
                            [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                            [_pswTwo deleteCharactersInRange:NSMakeRange(0, _pswTwo.length)];
                            _isAgainSetPsw = NO;
                        }
                    }else{
                        _modifyPsw = _pswTwo.copy;
                        [_pswInputView clearAllPswCircle];
                        [_numberPlateView clearClickCount];
                        _inputPswLab.text = DMInputPswLabTxt;
                        [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                        [_pswTwo deleteCharactersInRange:NSMakeRange(0, _pswTwo.length)];
                    }
                }else{
                    if([_pswTwo isEqualToString:_pswOnce]){
                        _inputPswLab.text = DMSetUnlockSuccessTxt;
                        [_pswInputView clearAllPswCircle];
                        [sf saveConfigurationInfo];
                        [sf dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [_pswInputView showMistakeMsg];
                        [_numberPlateView clearClickCount];
                        if(_isModifyPassword){
                            _inputPswLab.text = DMinputOldPswLabTxt;
                        }else{
                            _inputPswLab.text = DMInputPswLabTxt;
                        }
                        [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                        [_pswTwo deleteCharactersInRange:NSMakeRange(0, _pswTwo.length)];
                        _isAgainSetPsw = NO;
                    }
                }
            }else{
                if(_setState || _isModifyPassword){
                    _isAgainSetPsw = YES;
                    if(_isModifyPassword){
                        if([_didSavePsw isEqualToString:_pswOnce]){
                            _inputPswLab.text = DMinputNewPswLabTxt;
                        }else{
                            _isAgainSetPsw = NO;
                            [_pswInputView showMistakeMsg];
                            _inputPswLab.text = DMinputOldPswLabTxt;
                            [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                        }
                    }else{
                        _inputPswLab.text = DMInputPswLabAgTxt;
                    }
                    [_pswInputView clearAllPswCircle];
                    [_numberPlateView clearClickCount];
                }else{
                    if([_didSavePsw isEqualToString:_pswOnce]){
                        _inputPswLab.text = DMInputPswLabGestureReTxt;
                        [_pswInputView clearAllPswCircle];
                        [sf dismissViewControllerAnimated:YES completion:nil];
                        if(_isRemovePassword){
                            [DMGestureUnlockScreenVC removeGesturePassword];
                        }
                    }else{
                        [_pswInputView showMistakeMsg];
                        [_numberPlateView clearClickCount];
                        if(_isModifyPassword){
                            _inputPswLab.text = DMinputOldPswLabTxt;
                        }else{
                            _inputPswLab.text = DMInputPswLabReTxt;
                        }
                        [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                    }
                }
            }
        }];
    }else{
        [_pswInputView addPswCircleFinish:nil];
    }
}

#pragma mark - DMGestureDragPlateViewDelegate
- (BOOL)DMGestureDragPlateView:(DMGestureDragPlateView *)gestureDragPlateView psw:(NSString *)strPsw  didFinish:(BOOL)finish{
    BOOL  isSuccess = NO;
    if(finish){
        if(_isAgainSetPsw){
            if(_isModifyPassword){
                if(_modifyPsw){
                    if([_modifyPsw isEqualToString:strPsw]){
                        isSuccess = YES;
                        _inputPswLab.text = DMSetUnlockSuccessTxt;
                        [self saveConfigurationInfo];
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        _modifyPsw = nil;
                        [_gestureInputView againSetGesturePath:NO];
                        _inputPswLab.text = DMinputOldGestureLabTxt;
                        [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                        _isAgainSetPsw = NO;
                    }
                }else{
                    isSuccess = YES;
                    _modifyPsw = strPsw.copy;
                    [_gestureInputView againSetGesturePath:YES];
                }
                [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
            }else{
                if([strPsw isEqualToString:_pswOnce]){
                    isSuccess = YES;
                    _inputPswLab.text = DMSetUnlockSuccessTxt;
                    [self saveConfigurationInfo];
                    [self dismissViewControllerAnimated:YES completion:nil];
                }else{
                    [_gestureInputView againSetGesturePath:NO];
                    _inputPswLab.text = DMInputPswLabGestureTxt;
                    [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                    _isAgainSetPsw = NO;
                }
            }
        }else{
            if(_setState || _isModifyPassword){
                _pswOnce = [NSMutableString stringWithString:strPsw];
                _isAgainSetPsw = YES;
                if(_isModifyPassword){
                    if([strPsw isEqualToString:_didSavePsw]){
                        isSuccess = YES;
                        _inputPswLab.text = DMinputNewGestureLabTxt;
                    }else{
                        _inputPswLab.text = DMinputOldGestureLabTxt;
                        _isAgainSetPsw = NO;
                        [_pswOnce deleteCharactersInRange:NSMakeRange(0, _pswOnce.length)];
                    }
                }else{
                    _inputPswLab.text = DMInputPswLabGestureAgTxt;
                }
                [_gestureInputView againSetGesturePath:_isAgainSetPsw];
            }else{
                if([strPsw isEqualToString:_didSavePsw]){
                    isSuccess = YES;
                    _inputPswLab.text = DMUnlockSuccessTxt;
                    [self dismissViewControllerAnimated:YES completion:nil];
                    if(_isRemovePassword){
                        [DMGestureUnlockScreenVC removeGesturePassword];
                    }
                }else{
                    _inputPswLab.text = DMInputPswLabGestureReTxt;
                }
            }
        }
    }
    return isSuccess;
}

@end
