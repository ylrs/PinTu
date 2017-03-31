//
//  PinTuView.h
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageViewOne.h"

#define HardLevel1      3
#define HardLevel2      5
#define HardLevel3      15
#define HardLevel4      30
#define HardLevel5      50

@interface PinTuView : UIView<ImageViewDelegate>
{
    float imageWidth;
    NSMutableArray *imageFrames;
}
@property(nonatomic,strong)ImageViewOne *image1;
@property(nonatomic,strong)ImageViewOne *image2;
@property(nonatomic,strong)ImageViewOne *image3;
@property(nonatomic,strong)ImageViewOne *image4;
@property(nonatomic,strong)ImageViewOne *image5;
@property(nonatomic,strong)ImageViewOne *image6;
@property(nonatomic,strong)ImageViewOne *image7;
@property(nonatomic,strong)ImageViewOne *image8;
@property(nonatomic,strong)ImageViewOne *image9;
@property(nonatomic,strong)ImageViewOne *image10;
@property(nonatomic,strong)ImageViewOne *image11;
@property(nonatomic,strong)ImageViewOne *image12;
@property(nonatomic,strong)ImageViewOne *image13;
@property(nonatomic,strong)ImageViewOne *image14;
@property(nonatomic,strong)ImageViewOne *image15;
@property(nonatomic,strong)ImageViewOne *image16;
@property(nonatomic,strong)NSArray *imageArrays;
@property(nonatomic,strong)NSString *pintuName;
-(void)finish;

-(void)fixAction:(NSInteger)level;
@end
