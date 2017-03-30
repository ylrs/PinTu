//
//  GiFHUD.h
//  GiFHUD
//
//  Created by Cem Olcay on 30/10/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WLCircleProgressView.h"
@interface GiFHUD : UIView

+ (void)show;
+ (void)showWithOverlay;
+ (void)showWithViewController:(UIViewController *)viewController;
+ (void)dismiss;

+ (void)setGifWithImages:(NSArray *)images;
+ (void)setGifWithImageName:(NSString *)imageName;
+ (void)setGifWithURL:(NSURL *)gifUrl;

+ (void)setGifBackgroundImage:(NSString *) imageName;

@end
