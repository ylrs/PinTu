//
//  WWMBaseTool.m
//  Wenwanmi
//
//  Created by YLRS on 16/5/31.
//  Copyright © 2016年 YLRS. All rights reserved.
//

#import "WWMBaseTool.h"
#import "PinTuConst.h"
#import <CoreText/CoreText.h>
#import "RegExCategories.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#include <sys/param.h>
#include <sys/mount.h>

@implementation WWMBaseTool
//字体转换
+(NSString *)numberToStr:(NSInteger)integer
{
    NSString *string;
    if (integer>10000) {
        float number = integer/10000.0;
        string = [NSString stringWithFormat:@"%.1f万",number];
        
        if ([string rangeOfString:@".0"].location != NSNotFound) {
            string = [string stringByReplacingOccurrencesOfString:@".0" withString:@""];
        }
    }
    else{
        string = [NSString stringWithFormat:@"%li",(long)integer];
    }
    return string;
}
+(CGFloat)getTextWidth:(NSString *)text font:(float)font
{
    @try {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, MAXFLOAT, MAXFLOAT)];
        label.font = [UIFont systemFontOfSize:font];
        label.lineBreakMode = NSLineBreakByClipping;
        label.text = text;
        CGSize size = [label sizeThatFits:CGSizeMake(MAXFLOAT, MAXFLOAT)];
        return size.width;

    } @catch (NSException *exception) {

    } @finally {
        
    }
}
+(CGFloat)getTextHeight:(NSString *)text font:(float)font width:(float)width
{
    @try {
        NSDictionary *attrs = @{NSFontAttributeName : [UIFont systemFontOfSize:font]};
        float textHeight = [text boundingRectWithSize:CGSizeMake(width, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:attrs context:nil].size.height;
        return textHeight+1;

    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];

    } @finally {
        
    }
}

+(CGSize)getTextSize:(NSString *)text font:(float)font maxWidth:(float)width
{
    @try {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, MAXFLOAT)];
        label.font = [UIFont systemFontOfSize:font];
        label.text = text;
        label.lineBreakMode = NSLineBreakByClipping;
        label.numberOfLines = 0;
        CGSize size = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        return size;

    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];
    } @finally {
        
    }
}
+(CGSize)getLabelAttributedSize:(NSAttributedString *)text font:(UIFont *)font maxWidth:(float)width
{
    @try {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, width, MAXFLOAT)];
        label.font = font;
        label.attributedText = text;
        label.lineBreakMode = NSLineBreakByClipping;
        label.numberOfLines = 0;
        CGSize size = [label sizeThatFits:CGSizeMake(width, MAXFLOAT)];
        return size;
        
    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];
    } @finally {
        
    }
}
+(YYTextLayout *)getYYTextLayout:(NSAttributedString *)attributed font:(CGFloat)fontSize maxWidth:(float)width maxLine:(NSInteger)maxLine space:(CGFloat)space
{
    @try {
        //限制每行高度
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        
        CGFloat lineSpace = space;
        
        modifier.fixedLineHeight = fontSize+lineSpace;
        
        YYTextContainer *container = [YYTextContainer new];
        container.size = CGSizeMake(width, CGFLOAT_MAX);
        container.linePositionModifier = modifier;
        if (maxLine>0) {
            container.maximumNumberOfRows = maxLine;
        }
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attributed];
        return layout;
        
    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];
    } @finally {
        
    }
}

+(YYTextLayout *)getYYTextLayout:(NSAttributedString *)attributed font:(CGFloat)fontSize maxWidth:(float)width maxLine:(NSInteger)maxLine
{
    @try {
        //限制每行高度
        YYTextLinePositionSimpleModifier *modifier = [YYTextLinePositionSimpleModifier new];
        
        CGFloat lineSpace = 5;
        
        if (fontSize >= StandardFont1Size) {
            lineSpace = 10;
        }
        else if (fontSize == StandardFont2Size){
            lineSpace = 8;
        }
        else if (fontSize == StandardFont3Size){
            lineSpace = 7;
        }
        modifier.fixedLineHeight = fontSize+lineSpace;
        
        YYTextContainer *container = [YYTextContainer new];
        container.size = CGSizeMake(width, CGFLOAT_MAX);
        container.linePositionModifier = modifier;
        if (maxLine>0) {
            container.maximumNumberOfRows = maxLine;
        }
        
        YYTextLayout *layout = [YYTextLayout layoutWithContainer:container text:attributed];
        return layout;
        
    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];
    } @finally {
        
    }
}

+(NSAttributedString *)addParagraphStyleWithString:(NSString *)content alignment:(NSTextAlignment)textAlignment  space:(CGFloat)space
{
    @try {
        if (content == nil) {
            return nil;
        }
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:content];
        
        NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        [paragraphStyle setLineSpacing:space];
        [paragraphStyle setAlignment:textAlignment];
    
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [content length])];
        
        return attributedString;

    } @catch (NSException *exception) {
        [Dialog toastCenter:@"处理异常"];

    } @finally {
        
    }
}
+(NSMutableAttributedString *)getNumber:(NSString *)title
{
    if (title == nil || title.length <= 0) {
        return nil;
    }
    
    NSString *tempTitle = title;
    NSString * searchText = @"\\d+";//得到数字
    NSMutableAttributedString *titleAttributed = [[NSMutableAttributedString alloc] initWithString:title];
    
    NSRange range1 = [tempTitle rangeOfString:searchText options:NSRegularExpressionSearch];
    
    NSString *number1;
    NSString *number2;
    NSString *number3;
    NSRange  location1 = NSMakeRange(0, 0);
    NSRange  location2 = NSMakeRange(0, 0);
    NSRange  location3 = NSMakeRange(0, 0);
    
    if (range1.length > 0) {
        number1   = [tempTitle substringWithRange:range1];
        tempTitle = [tempTitle stringByReplacingCharactersInRange:range1 withString:@""];
        location1 = range1;
    }
    
    NSRange range2 = [tempTitle rangeOfString:searchText options:NSRegularExpressionSearch];
    if (range2.length > 0) {
        number2 = [tempTitle substringWithRange:range2];
        tempTitle = [tempTitle stringByReplacingCharactersInRange:range2 withString:@""];
        location2 = NSMakeRange(range2.location+range1.length, range2.length);
    }
    
    NSRange range3 = [tempTitle rangeOfString:searchText options:NSRegularExpressionSearch];
    if (range3.length > 0) {
        number3 = [tempTitle substringWithRange:range3];
        location3 = NSMakeRange(range3.location+range2.length+range1.length, range3.length);
    }
    
    
    if (location1.length > 0) {
        [titleAttributed addAttributes:@{NSForegroundColorAttributeName : RGB(255, 175, 21)} range:location1];
    }
    
    if (location2.length > 0) {
        [titleAttributed addAttributes:@{NSForegroundColorAttributeName : RGB(255, 175, 21)} range:location2];
    }
    
    if (location3.length > 0) {
        [titleAttributed addAttributes:@{NSForegroundColorAttributeName : RGB(255, 175, 21)} range:location3];
    }
    
    return titleAttributed;
}

+(UIColor *)getRandomColor
{
    UIColor *color;
    NSArray *colorArray = @[StandardColor1,RGB(162, 202, 159),RGB(149, 173, 173),RGB(185, 149, 118),RGB(164, 99, 94),RGB(168, 161, 157),RGB(215, 193, 193),RGB(221, 227, 231),RGB(226, 221, 218),RGB(209, 204, 214),RGB(88, 174, 255),RGB(174, 216, 255),RGB(77, 211, 109),RGB(159, 243, 178),RGB(255, 192, 71),RGB(255, 226, 171),RGB(251, 174, 140),RGB(255, 218, 202)];
    
    NSInteger count = colorArray.count;
    
    int randomIndex = arc4random()%count;
    
    color = colorArray[randomIndex];
    
    return color;
}
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}
+ (CAGradientLayer *)shadowAsInverse:(UIColor *)fColor toColor:(UIColor *)tColor frame:(CGRect)rect
{
    CAGradientLayer *newShadow = [[CAGradientLayer alloc] init] ;
    CGRect newShadowFrame = rect;
    newShadow.frame = newShadowFrame;
    //添加渐变的颜色组合
    newShadow.colors = [NSArray arrayWithObjects:(id)fColor.CGColor,(id)tColor.CGColor,nil];
    return newShadow;
}
+(NSString*)addParmToURL:(NSString*)url  parm:(NSString*)parm
{
    if ([url rangeOfString:parm].length>0) {
        return url;//如果已经包含这个参数了，就不加了。
    }
    
    NSString *addString=@"";
    if ([url rangeOfString:@"?"].length>0) {
        addString=[NSString stringWithFormat:@"&%@",parm];
    }else
    {
        addString=[NSString stringWithFormat:@"?%@",parm];
    }
    NSString *rtStr=[url stringByAppendingString:addString];
    return  rtStr;
    
}
+(NSString*)addFangxingCaijianParmToURL:(NSString*)url
{
    return [WWMBaseTool addParmToURL:url parm:@"squareRect=1"];
}
+(UIImage *)getImageFromView:(UIView *)view{
    
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, 3.0);
    
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}
+ (UIImage *)addImage:(UIImage *)image1 toImage:(UIImage *)image2 rect:(CGRect)frame{
    
    CGRect rect = CGRectMake(0, 0, image1.size.width, image1.size.height+image2.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    [image2 drawInRect:frame];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}
+ (UIImage *)fixImage:(UIImage *)image1 toImage:(UIImage *)image2 rect:(CGRect)frame{
    
    CGRect rect = CGRectMake(0, 0, image1.size.width, image1.size.height);
    
    UIGraphicsBeginImageContext(rect.size);
    
    // Draw image1
    [image1 drawInRect:CGRectMake(0, 0, image1.size.width, image1.size.height)];
    
    [image2 drawInRect:frame];
    
    UIImage *resultingImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return resultingImage;
}
// 正则表达式来判断当前的手机号是否合法
+ (BOOL)validateMobile:(NSString *)mobile
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188
     * 联通：130,131,132,145,152,155,156,176,185,186
     * 电信：133,1349,153,177,180,181,189
     */
    //    NSString * MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|7[068]|8[0-9])\\d{8}$";
    
    NSString * MOBILE = @"^1\\d{10}$";//只验证11位
    
    NSPredicate *phoneTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",MOBILE];
    return [phoneTest evaluateWithObject:mobile];
}
+(float)imageHeight:(CGSize)imageSize width:(float)width
{
    float height = width * imageSize.height/imageSize.width;
    return height;
}
+(UIImage *)mosaicImage:(UIImage *)imageIn
{
    CIImage *image = [CIImage imageWithCGImage:imageIn.CGImage];
    
    // Affine
    CIFilter *affineClampFilter = [CIFilter filterWithName:@"CIAffineClamp"];
    [affineClampFilter setValue:image forKey:kCIInputImageKey];
    CGAffineTransform xform = CGAffineTransformMakeScale(1.0, 1.0);
    [affineClampFilter setValue:[NSValue valueWithBytes:&xform objCType:@encode(CGAffineTransform)] forKey:@"inputTransform"];
    
    // Pixellate
    CIFilter *pixellateFilter = [CIFilter filterWithName:@"CIPixellate"];
    [pixellateFilter setDefaults];
    [pixellateFilter setValue:affineClampFilter.outputImage forKey:kCIInputImageKey];
    
    CGFloat value = imageIn.size.width/kDeviceWidth*15;
    
    [pixellateFilter setValue:@(value) forKey:@"inputScale"];
    CIVector *center = [CIVector vectorWithCGPoint:CGPointMake(image.extent.size.width / 2.0, image.extent.size.height / 2.0)];
    [pixellateFilter setValue:center forKey:@"inputCenter"];
    
    // Crop
    CIFilter *cropFilter = [CIFilter filterWithName: @"CICrop"];
    [cropFilter setDefaults];
    [cropFilter setValue:pixellateFilter.outputImage forKey:kCIInputImageKey];
    [cropFilter setValue:[CIVector vectorWithX:0 Y:0 Z:imageIn.size.width W:imageIn.size.height] forKey:@"inputRectangle"];
    
    image = [cropFilter valueForKey:kCIOutputImageKey];
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef imgRef = [context createCGImage:image fromRect:image.extent];
    UIImage *resultImage = [UIImage imageWithCGImage:imgRef];
    CGImageRelease(imgRef);
    
    return resultImage;
}
+(NSString *)getNowTime
{
    NSDate* date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval time=[date timeIntervalSince1970];
    NSString *timeString = [NSString stringWithFormat:@"%.0f",time];
    return timeString;
}
+(BOOL)isChineseCharacter:(NSString *)string {
    NSInteger len = string.length;
    for(int i=0;i<len;i++)
    {
        unichar a=[string characterAtIndex:i];
        if(!((isalpha(a))||(isalnum(a))||((a >= 0x4e00 && a <= 0x9fa6))))
            return NO;
    }
    return YES;
}
+(NSString *)attributeToString:(NSAttributedString *)attributedText
{
    NSAttributedString *att = attributedText;
    NSMutableAttributedString *resultAtt = [[NSMutableAttributedString alloc] initWithAttributedString:att];
    
    [resultAtt enumerateAttributesInRange:NSMakeRange(0, resultAtt.length) options:NSAttributedStringEnumerationReverse usingBlock:^(NSDictionary *attrs, NSRange range, BOOL *stop) {
        NSTextAttachment *textAtt = attrs[@"NSAttachment"];
        
        if (textAtt.image) {
            
            NSString *text = [WWMBaseTool imageToString:textAtt.image];
            
            if (range.length>0) {
                [resultAtt replaceCharactersInRange:range withString:text];
            }
        }
    }];
    return resultAtt.string;
}
+ (UIViewController *)getPresentedViewController
{
    UIViewController *appRootVC = [UIApplication sharedApplication].keyWindow.rootViewController;
    UIViewController *topVC = appRootVC;
    if (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    
    return topVC;
}

+(UIViewController *) currentViewController {
    // Find best view controller
    UIViewController *viewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    
    return [WWMBaseTool findBestViewController:viewController];
}

+(UIViewController *)findBestViewController:(UIViewController *)vc {
    
    if (vc.presentedViewController) {
        // Return presented view controller
        return [WWMBaseTool findBestViewController:vc.presentedViewController];
    }
    else if ([vc isKindOfClass:[UINavigationController class]]) {
        // Return top view
        UINavigationController *svc = (UINavigationController *)vc;
        if (svc.viewControllers.count > 0)
            return [WWMBaseTool findBestViewController:svc.topViewController];
        else
            return vc;
    }
    else if ([vc isKindOfClass:[UITabBarController class]]) {
        // Return visible view
        UITabBarController *svc = (UITabBarController *) vc;
        if (svc.viewControllers.count > 0)
            return [WWMBaseTool findBestViewController:svc.selectedViewController];
        else
            return vc;
    } else {
        // Unknown view controller type, return last child view controller
        return vc;
    }
}
+(UIImage *)createQRImage:(CGFloat)width string:(NSString *)content
{
    // 二维码的生成
    // 1、创建过滤器
    CIFilter *filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 2、恢复滤镜的默认属性
    [filter setDefaults];
    // 3、设置内容
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    // 使用KVO设置属性
    [filter setValue:data forKey:@"inputMessage"];
    // 4、获取输出文件
    CIImage *outputImage = [filter outputImage];
    
    UIImage *QRImage = [WWMBaseTool createNonInterpolatedUIImageFormCIImage:outputImage withSize:width];
    
//    return QRImage;
    return [WWMBaseTool imageBlackToTransparent:QRImage withRed:0 andGreen:0 andBlue:0];
//    return  [WWMBaseTool changeImageColor:QRImage color:RGB(100, 75, 70)];
}
+ (UIImage *)createNonInterpolatedUIImageFormCIImage:(CIImage *)image withSize:(CGFloat)size
{
    CGRect extent = CGRectIntegral(image.extent);
    CGFloat scale = MIN(size/CGRectGetWidth(extent), size/CGRectGetHeight(extent));
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef bitmapImage = [context createCGImage:image fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    
    CGColorRef redRef = [UIColor redColor].CGColor;
    CGContextSetFillColorWithColor(bitmapRef, redRef);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);
    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    return [UIImage imageWithCGImage:scaledImage];
}
//改变图片颜色
+ (UIImage *)changeImageColor:(UIImage *)image color:(UIColor *)color
{
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
void ProviderReleaseData (void *info, const void *data, size_t size){
    free((void*)data);
}

+ (UIImage*)imageBlackToTransparent:(UIImage*)image withRed:(CGFloat)red andGreen:(CGFloat)green andBlue:(CGFloat)blue{
    const int imageWidth  = image.size.width;
    const int imageHeight = image.size.height;
    size_t      bytesPerRow = imageWidth * 4;
    uint32_t* rgbImageBuf = (uint32_t*)malloc(bytesPerRow * imageHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(rgbImageBuf, imageWidth, imageHeight, 8, bytesPerRow, colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaNoneSkipLast);
    CGContextDrawImage(context, CGRectMake(0, 0, imageWidth, imageHeight), image.CGImage);
    // 遍历像素
    int pixelNum = imageWidth * imageHeight;
    uint32_t* pCurPtr = rgbImageBuf;
    for (int i = 0; i < pixelNum; i++, pCurPtr++){
        if ((*pCurPtr & 0xFFFFFF00) < 0x99999900)    // 将白色变成透明
        {
            // 改成下面的代码，会将图片转成想要的颜色
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[3] = red; //0~255
            ptr[2] = green;
            ptr[1] = blue;
        }
        else
        {
            uint8_t* ptr = (uint8_t*)pCurPtr;
            ptr[0] = 0;
        }
    }
    // 输出图片
    CGDataProviderRef dataProvider = CGDataProviderCreateWithData(NULL, rgbImageBuf, bytesPerRow * imageHeight, ProviderReleaseData);
    CGImageRef imageRef = CGImageCreate(imageWidth, imageHeight, 8, 32, bytesPerRow, colorSpace,
                                        kCGImageAlphaLast | kCGBitmapByteOrder32Little, dataProvider,
                                        NULL, true, kCGRenderingIntentDefault);
    CGDataProviderRelease(dataProvider);
    UIImage* resultUIImage = [UIImage imageWithCGImage:imageRef];
    // 清理空间
    CGImageRelease(imageRef);
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    return resultUIImage;
}

+(NSString *)getCTTelephonyNetworkInfo
{
    NSString *netWorkType;
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [networkInfo subscriberCellularProvider];
    NSString * mnc = [carrier mobileNetworkCode];
    NSString * mcc = [carrier mobileCountryCode];
    
    if (mnc == nil || mnc.length <1 || [mnc isEqualToString:@"SIM Not Inserted"] ) {
        netWorkType = @"Unknown";
    }else {
        if ([mcc isEqualToString:@"460"]) {
            NSInteger MNC = [mnc intValue];
            switch (MNC) {
                case 00:
                case 02:
                case 07:
                    netWorkType = @"China Mobile";
                    break;
                case 01:
                case 06:
                    netWorkType = @"China Unicom";
                    break;
                case 03:
                case 05:
                    netWorkType = @"China Telecom";
                    break;
                case 20:
                    netWorkType = @"China Tietong";
                    break;
                default:
                    break;
            }
        }
    }
    return netWorkType;
}
+ (NSString *) getPreKey:(NSString *)key{
    
    NSString * currentTime = [WWMBaseTool getCurrentTime];
    NSInteger  randInt = arc4random()% 9000 + 1000;
    NSString * preKey = [NSString stringWithFormat:@"%@%@%ld",key,currentTime,(long)randInt];
    
    NSLog(@"preKey = %@",preKey);
    
    return preKey;
}
+ (NSString *) getCurrentTime {
    //当前年月日
    NSDate * senddate = [NSDate date];
    
    NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm:ss"];
    NSString * locationString = [dateFormatter stringFromDate:senddate] ;
    
    NSArray * componets = [locationString componentsSeparatedByString:@":"];
    NSMutableString * tmpStr = [NSMutableString string];
    for (NSString * str in componets) {
        [tmpStr appendString:str];
    }
    
    return tmpStr;
}
+ (NSMutableDictionary *)getURLParameters:(NSString *)urlStr {
    
    // 查找参数
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    // 以字典形式将参数返回
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [urlStr substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"&"];
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}
+(CGFloat)getAvailableDiskSize
{
    struct statfs buf;
    unsigned long long freeSpace = -1;
    if (statfs("/var", &buf) >= 0)
    {
        freeSpace = (unsigned long long)(buf.f_bsize * buf.f_bavail);
    }
    CGFloat freeSpaceFloat = freeSpace/1024/1024;
    return freeSpaceFloat;
}
+(CGFloat)getActionTimeSecond{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    return time;
}
@end
