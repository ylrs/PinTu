//
//  ImageViewOne.m
//  TestDemo
//
//  Created by yw on 15/2/27.
//  Copyright (c) 2015年 YLRS. All rights reserved.
//

#import "ImageViewOne.h"

@implementation ImageViewOne
-(id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        imageLabel = [[UILabel alloc] init];
        imageLabel.backgroundColor = [UIColor redColor];
        imageLabel.font = [UIFont systemFontOfSize:30];
        imageLabel.textAlignment = NSTextAlignmentCenter;
//        [self addSubview:imageLabel];
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        
        UISwipeGestureRecognizer *swipeGestureUp = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizer:)];
        swipeGestureUp.direction = UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipeGestureUp];
        
        UISwipeGestureRecognizer *swipeGestureDown = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizer:)];
        swipeGestureDown.direction = UISwipeGestureRecognizerDirectionDown;
        [self addGestureRecognizer:swipeGestureDown];

        UISwipeGestureRecognizer *swipeGestureLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizer:)];
        swipeGestureLeft.direction = UISwipeGestureRecognizerDirectionLeft;
        [self addGestureRecognizer:swipeGestureLeft];

        UISwipeGestureRecognizer *swipeGestureRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recognizer:)];
        swipeGestureRight.direction = UISwipeGestureRecognizerDirectionRight;
        [self addGestureRecognizer:swipeGestureRight];

    }
    return self;
}
-(void)recognizer:(UISwipeGestureRecognizer *)swipeGesture
{
    self.direction = swipeGesture.direction;
    [self.delegate getDirection:self.direction Tag:self.tag];
}
-(void)setLabelName:(NSString *)name
{
    imageLabel.frame = CGRectMake((self.frame.size.width-100)/2, (self.frame.size.height-50)/2, 100, 50);
    imageLabel.text = name;
}
-(void)setImage:(NSString *)imageName
{
    imageView.frame = self.bounds;
    imageView.image = [UIImage imageNamed:imageName];
}
@end
