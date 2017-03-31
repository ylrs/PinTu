//
//  PinTuView.m
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import "PinTuView.h"

@implementation PinTuView

-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageWidth = frame.size.width/4;
        self.image1  = [[ImageViewOne alloc] init];
        self.image2  = [[ImageViewOne alloc] init];
        self.image3  = [[ImageViewOne alloc] init];
        self.image4  = [[ImageViewOne alloc] init];
        self.image5  = [[ImageViewOne alloc] init];
        self.image6  = [[ImageViewOne alloc] init];
        self.image7  = [[ImageViewOne alloc] init];
        self.image8  = [[ImageViewOne alloc] init];
        self.image9  = [[ImageViewOne alloc] init];
        self.image10 = [[ImageViewOne alloc] init];
        self.image11 = [[ImageViewOne alloc] init];
        self.image12 = [[ImageViewOne alloc] init];
        self.image13 = [[ImageViewOne alloc] init];
        self.image14 = [[ImageViewOne alloc] init];
        self.image15 = [[ImageViewOne alloc] init];
        self.image16 = [[ImageViewOne alloc] init];
        
        imageFrames = [[NSMutableArray alloc] init];
        
        self.imageArrays = [NSArray arrayWithObjects:self.image1,self.image2,self.image3,self.image4,self.image5,self.image6,self.image7,self.image8,self.image9,self.image10,self.image11,self.image12,self.image13,self.image14,self.image15, nil];
    }
    return self;
}
-(void)finish
{
    for (int i = 0; i<imageFrames.count; i++) {
        NSString *strFrame = imageFrames[i];
        ImageViewOne *image = self.imageArrays[i];
        image.frame = CGRectFromString(strFrame);
    }
}
-(void)setPintuName:(NSString *)pintuName
{
    _pintuName = pintuName;
    
    [self initImagesWith:imageWidth];
}
-(void)initImagesWith:(float)width
{
    for (int i = 0; i<self.imageArrays.count; i++) {
        NSString *imageName = [NSString stringWithFormat:@"%@_%d.jpg",self.pintuName,i];
        int index_X = i%4;
        int index_Y = i/4;
        ImageViewOne *image = self.imageArrays[i];
        image.delegate = self;
        CGRect frame = CGRectMake(index_X*width, index_Y*width, width, width);
        image.frame = frame;
        image.tag = i;
        [self addSubview:image];
        [image setImage:imageName];
        [imageFrames addObject:NSStringFromCGRect(frame)];
    }
    
    self.image16.frame = CGRectMake(3*imageWidth, 3*imageWidth, imageWidth, imageWidth);
    
    //打乱顺序
    [self fixAction:HardLevel2];
    
    UILabel *lineX1 = [[UILabel alloc] init];
    lineX1.frame = CGRectMake(self.frame.size.width/4*1, 0, 1, self.frame.size.height);
    lineX1.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX1];
    
    UILabel *lineX2 = [[UILabel alloc] init];
    lineX2.frame = CGRectMake(self.frame.size.width/4*2, 0, 1, self.frame.size.height);
    lineX2.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX2];

    UILabel *lineX3 = [[UILabel alloc] init];
    lineX3.frame = CGRectMake(self.frame.size.width/4*3, 0, 1, self.frame.size.height);
    lineX3.backgroundColor = [UIColor grayColor];
    [self addSubview:lineX3];

    UILabel *lineY1 = [[UILabel alloc] init];
    lineY1.frame = CGRectMake(0, self.frame.size.height/4*1, self.frame.size.width, 1);
    lineY1.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY1];
    
    UILabel *lineY2 = [[UILabel alloc] init];
    lineY2.frame = CGRectMake(0, self.frame.size.height/4*2, self.frame.size.width, 1);
    lineY2.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY2];
    
    UILabel *lineY3 = [[UILabel alloc] init];
    lineY3.frame = CGRectMake(0, self.frame.size.height/4*3, self.frame.size.width, 1);
    lineY3.backgroundColor = [UIColor grayColor];
    [self addSubview:lineY3];
}
-(void)getDirection:(UISwipeGestureRecognizerDirection)direction Tag:(NSInteger)tag
{
    ImageViewOne *image = self.imageArrays[tag];
    CGPoint center = image.center;
    
    if (direction == UISwipeGestureRecognizerDirectionUp) {
        NSLog(@"向上");
        center = CGPointMake(center.x, center.y - imageWidth);
    }
    if (direction == UISwipeGestureRecognizerDirectionDown) {
        NSLog(@"向下");
        center = CGPointMake(center.x, center.y + imageWidth);
    }
    if (direction == UISwipeGestureRecognizerDirectionLeft) {
        NSLog(@"向左");
        center = CGPointMake(center.x - imageWidth, center.y );
    }
    if (direction == UISwipeGestureRecognizerDirectionRight) {
        NSLog(@"向右");
        center = CGPointMake(center.x + imageWidth, center.y );
    }
    if (center.x<0 || center.y<0 || center.x>self.frame.size.width || center.y>self.frame.size.height) {
        return;
    }
    for (ImageViewOne *imageOne in self.imageArrays) {
        CGPoint centerTmp = imageOne.center;
        if (center.x == centerTmp.x && center.y == centerTmp.y) {
            return;
        }
    }
    
    [UIView animateWithDuration:0.1 animations:^{
        image.center = center;
    }];
    
    [self checkComplete];
}

-(void)checkComplete
{
    for (int i = 0; i < imageFrames.count; i++) {
        NSString *strFrame = imageFrames[i];
        ImageViewOne *image = self.imageArrays[i];
        NSString *imageFrame = NSStringFromCGRect(image.frame);
        if (![strFrame isEqualToString:imageFrame]) {
            return;
        }
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"恭喜" message:@"成功拼图" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}
//打乱操作
-(void)fixAction:(NSInteger)level
{
   __block CGPoint lastCenter = self.image16.center;
    
    NSMutableArray *fixImageArrays = [NSMutableArray arrayWithObjects:self.image1,self.image2,self.image3,self.image4,self.image5,self.image6,self.image7,self.image8,self.image9,self.image10,self.image11,self.image12,self.image13,self.image14,self.image15, nil];
    
    for (int i = 0; i < fixImageArrays.count; i++) {
        int random = arc4random()%fixImageArrays.count;
        ImageViewOne *image = fixImageArrays[random];
        [fixImageArrays removeObject:image];
        [fixImageArrays insertObject:image atIndex:0];
    }

    NSInteger tempDirection = 1;

    //打乱逻辑，通过打乱次数来划分难度等级
    for (int i = 0; i < level; i++) {
        
        for (int j = 0; j < fixImageArrays.count;j++) {
            
            ImageViewOne *imageOne = [fixImageArrays objectAtIndex:j];
            
            CGPoint imageCenter = imageOne.center;
            
            NSInteger direction = 0;//
            
            BOOL isCanReplace = NO;
            
            if (((imageCenter.x + imageWidth == lastCenter.x)&&(imageCenter.y == lastCenter.y))) {
                isCanReplace = YES;
                direction = 1;//向右
            }
            else if (((imageCenter.x - imageWidth == lastCenter.x)&&(imageCenter.y == lastCenter.y))){
                isCanReplace = YES;
                direction = 2;//向左
            }
            else if (((imageCenter.y - imageWidth == lastCenter.y)&&(imageCenter.x == lastCenter.x))){
                isCanReplace = YES;
                direction = 3;//向下
            }
            else if (((imageCenter.y + imageWidth == lastCenter.y)&&(imageCenter.x == lastCenter.x))){
                isCanReplace = YES;
                direction = 4;//向上
            }
            else{
                isCanReplace = NO;
            }
            
            if (isCanReplace && (tempDirection != direction)) {
                
                if (imageOne.lastCenter.x != lastCenter.x && imageOne.lastCenter.y != lastCenter.y) {

                    tempDirection = direction;
                    
                    imageOne.lastCenter = imageCenter;
                    
                    imageOne.center = lastCenter;
                    
                    lastCenter = imageCenter;
                }
            }
        }
    }
    
    self.image16.hidden = YES;
}
@end
