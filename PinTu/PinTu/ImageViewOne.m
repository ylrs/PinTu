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
        imageView = [[UIImageView alloc] init];
        [self addSubview:imageView];
        
        imageLabel = [[UILabel alloc] init];
        imageLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.55f];
        imageLabel.font = [UIFont boldSystemFontOfSize:28];
        imageLabel.textAlignment = NSTextAlignmentCenter;
        imageLabel.textColor = [UIColor whiteColor];
        imageLabel.hidden = YES;
        imageLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:imageLabel];
        
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
    imageLabel.frame = self.bounds;
    imageLabel.text = name;
}
- (void)setLabelHidden:(BOOL)hidden
{
    imageLabel.hidden = hidden;
}
- (void)setTileImage:(UIImage *)image
{
    imageView.frame = self.bounds;
    imageLabel.frame = self.bounds;
    imageView.image = image;
}
@end
