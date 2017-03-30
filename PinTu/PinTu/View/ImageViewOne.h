//
//  ImageViewOne.h
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageViewDelegate<NSObject>
-(void)getDirection:(UISwipeGestureRecognizerDirection)direction Tag:(NSInteger)tag;
@end
@interface ImageViewOne : UIView
{
    UILabel     *imageLabel;
    UIImageView *imageView;
}
@property(nonatomic,assign)UISwipeGestureRecognizerDirection direction;
@property(nonatomic,assign)id<ImageViewDelegate>delegate;
-(void)setLabelName:(NSString *)name;
-(void)setImage:(NSString *)imageName;
@end
