//
//  PinTuConst.h
//  PinTu
//
//  Created by YLRS on 2017/3/30.
//  Copyright © 2017年 YLRS. All rights reserved.
//

#ifndef PinTuConst_h
#define PinTuConst_h

#define HardLevel1      3
#define HardLevel2      5
#define HardLevel3      15
#define HardLevel4      30
#define HardLevel5      50

#define ADMOB_ACCOUNT_ID   @"ca-app-pub-6997611675344488~1776136250"
#define ADMOB_BANNERID_1   @"ca-app-pub-6997611675344488/4574873453"

#define RGB(r, g, b) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]

#define StandardFont1Size           17  //顶部标题
#define StandardFont2Size           15  //大范围使用文字
#define StandardFont3Size           13  //辅助性文字
#define StandardFont4Size           12  //备注性文字
#define StandardFont5Size           11  //用于时间
#define StandardFont6Size           10  //
#define StandardFont7Size           9   //
#define StandardFont8Size           18  //
#define StandardFont9Size           14  //
#define StandardFont10Size          16  //

#define StandardFont1               [UIFont systemFontOfSize:StandardFont1Size]
#define StandardFont2               [UIFont systemFontOfSize:StandardFont2Size]
#define StandardFont3               [UIFont systemFontOfSize:StandardFont3Size]
#define StandardFont4               [UIFont systemFontOfSize:StandardFont4Size]
#define StandardFont5               [UIFont systemFontOfSize:StandardFont5Size]
#define StandardFont6               [UIFont systemFontOfSize:StandardFont6Size]
#define StandardFont7               [UIFont systemFontOfSize:StandardFont7Size]
#define StandardFont8               [UIFont systemFontOfSize:StandardFont8Size]
#define StandardFont9               [UIFont systemFontOfSize:StandardFont9Size]
#define StandardFont10              [UIFont systemFontOfSize:StandardFont10Size]

#define StandardColor1                    RGB(100, 75, 70)
#define StandardColor2                    RGB(141,123,119)
#define StandardColor3                    RGB(242,235,215)
#define StandardColor4                    RGB(255,100,100)
#define StandardColor5                    RGB( 32,174, 66)
#define StandardColor6                    RGB( 38,150,255)
#define StandardColor7                    RGB( 50, 50, 50)
#define StandardColor8                    RGB(160,160,160)
#define StandardColor9                    RGB(200,200,200)
#define StandardColor10                   RGB(235,235,235)
#define StandardColor11                   RGB(245,245,245)
#define StandardColor12                   RGB( 93, 93, 93)
#define StandardColor13                   RGB(239, 34,111)
#define StandardColor14                   RGB(219, 87, 88)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone4 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 960), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) : NO)
#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size) : NO)

#define iOS8 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0 && [[[UIDevice currentDevice] systemVersion] floatValue] < 9.0)
#define iOS7 ([[[UIDevice currentDevice] systemVersion] floatValue] < 8.0)
#define iOS71s ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.1)

#define iOS8Later   ([UIDevice currentDevice].systemVersion.floatValue >= 8.3f)
#define iOS9Later   ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)
#define iOS10Later  ([UIDevice currentDevice].systemVersion.floatValue >= 10.0f)

#define kDeviceWidth [UIScreen mainScreen].bounds.size.width

#define KDeviceHeight [[[UIDevice currentDevice] systemVersion] floatValue] < 7.0?[UIScreen mainScreen].bounds.size.height - 20 : [UIScreen mainScreen].bounds.size.height

#define WS(weakSelf)     __weak __typeof(&*self)weakSelf = self;

#define kDocumentPath   [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define SYS_VERSION            [[[UIDevice currentDevice] systemVersion] floatValue]

#endif /* PinTuConst_h */
