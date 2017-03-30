//
//  WWMBaseTool.h
//  Wenwanmi
//
//  Created by YLRS on 16/5/31.
//  Copyright © 2016年 YLRS. All rights reserved.
//

#import <Accelerate/Accelerate.h>
#import "YYKit.h"
@interface WWMBaseTool : NSObject

//通过字典打开链接
+(void)showDetailFromURL:(NSString *)url;

+(void)showDetailFromURL:(NSString *)url isDismiss:(BOOL)isDismiss;
/**
 等级颜色
 */
+ (UIColor *)levelColor:(NSInteger) level;

/**
 数字字符串转换
 */
+ (NSString *)numberToStr:(NSInteger)integer;

/**
 获取text宽度
 */
+ (CGFloat)getTextWidth:(NSString *)text font:(float)font;

/**
 获取text高度
 */
+ (CGFloat)getTextHeight:(NSString *)text font:(float)font width:(float)width;

/**
 获取text宽高
 */
+ (CGSize)getTextSize:(NSString *)text font:(float)font maxWidth:(float)width;
/**
 获取AttributedString宽高
 */
+(CGSize)getLabelAttributedSize:(NSAttributedString *)text font:(UIFont *)font maxWidth:(float)width;
/**
  获取YYText布局
 */
+(YYTextLayout *)getYYTextLayout:(NSAttributedString *)attributed font:(CGFloat)fontSize maxWidth:(float)width maxLine:(NSInteger)maxLine;
/**
 获取YYText布局 space自定义
 */
+(YYTextLayout *)getYYTextLayout:(NSAttributedString *)attributed font:(CGFloat)fontSize maxWidth:(float)width maxLine:(NSInteger)maxLine space:(CGFloat)space;
/**
 获取随机色
 */
+ (UIColor *)getRandomColor;

/**
 生成一张单一颜色图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 渐变色方法
 */
+ (CAGradientLayer *)shadowAsInverse:(UIColor *)fColor toColor:(UIColor *)tColor frame:(CGRect)rect;

/**
 图片方形剪裁方法
 */
+(NSString*)addFangxingCaijianParmToURL:(NSString*)url;

/*
 *改变行间距
 */
+(NSAttributedString *)addParagraphStyleWithString:(NSString *)content alignment:(NSTextAlignment)textAlignment  space:(CGFloat)space;
/**
 校验手机号是否合法
 */
+ (BOOL)validateMobile:(NSString *)mobile;

/**
 图片上添加文字方法
 */
//+(UIImage *)addText:(UIImage *)img text:(NSString *)text;

/**
 获取View的截图方法
 */
+(UIImage *)getImageFromView:(UIView *)view;

/**
 将两张图片拼接
 */
+(UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 rect:(CGRect)frame;

/**
 获两张图片混合
 */
+ (UIImage *)fixImage:(UIImage *)image1 toImage:(UIImage *)image2 rect:(CGRect)frame;

/**
 图片定宽，获取图片等比缩放高度方法
 */
+(float)imageHeight:(CGSize)imageSize width:(float)width;

/**
 图片马赛克
 */
+(UIImage *)mosaicImage:(UIImage *)imageIn;
/**
 倒计时time字符串
 */
+(NSString *)timeStr:(NSInteger)hour min:(NSInteger)min  sec:(NSInteger)sec status:(NSInteger)status;
/**
 获取当前时间戳
 */
+(NSString *)getNowTime;
/**
 判断是否是汉字和数字
 */
+(BOOL)isChineseCharacter:(NSString *)string;
/**
 投票进度条背景颜色
 */
+(UIColor *)getVoteBackColor:(NSInteger)vid optionCount:(NSInteger)count tid:(NSInteger)tid selectOption:(NSInteger)selectOption;
/**
 替换表情方法
 */
+(NSMutableAttributedString *)getExpressString:(NSString *)content;

+(NSAttributedString *)getAttributeString:(NSString *)content withInvites:(NSArray *)invites inviteTapAction:(BOOL)isTapAction font:(UIFont *)font isEdit:(BOOL)isEdit;

+(NSString *)attributeToString:(NSAttributedString *)attributedText;

+(NSString *)attributeToStringWithUser:(NSAttributedString *)attributedText users:(NSArray *)userArray;

+(NSString *)imageToString:(UIImage *)image;
//获取当前屏幕的viewController
+(UIViewController *)currentViewController;
//获取presentViewController
+(UIViewController *)getPresentedViewController;
//改变文本数字颜色
+(NSMutableAttributedString *)getNumber:(NSString *)title;

+(UIImage *)addImageLogo:(UIImage *)img logoImg:(UIImage *)logo;
//生成二维码
+(UIImage *)createQRImage:(CGFloat)width string:(NSString *)content;
//获取网络类型
+(NSString *)getNetWorkType;

+(NSString *)getPreKey:(NSString *)key;

+(NSString *)getCurrentTime;
//URL参数解析
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr;
//获取当前可用磁盘空间
+(CGFloat)getAvailableDiskSize;
//获取函数执行时间
+(CGFloat)getActionTimeSecond;
@end
