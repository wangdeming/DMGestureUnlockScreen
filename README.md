# DMGestureUnlockScreen

  接口使用实例
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


   示例图如下：

   ![](https://github.com/wangdeming/DMGestureUnlockScreen/blob/master/DMGestureUnlockScreen.gif)
