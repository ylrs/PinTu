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
        _shouldShowIndices = NO;
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
        [self initImagesWith:imageWidth];
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
-(void)initImagesWith:(float)width
{
    for (int i = 0; i<self.imageArrays.count; i++) {
        int index_X = i%4;
        int index_Y = i/4;
        ImageViewOne *image = self.imageArrays[i];
        image.delegate = self;
        CGRect frame = CGRectMake(index_X*width, index_Y*width, width, width);
        image.frame = frame;
        image.tag = i;
        [self addSubview:image];
        [image setLabelName:[NSString stringWithFormat:@"%d",i+1]];
        [image setLabelHidden:!_shouldShowIndices];
        [imageFrames addObject:NSStringFromCGRect(frame)];
    }
    
    for (int j = 0; j < self.imageArrays.count; j++) {
        int random = arc4random()%self.imageArrays.count;
        ImageViewOne *image1 = self.imageArrays[j];
        ImageViewOne *image2 = self.imageArrays[random];
        CGRect temFrame = image1.frame;
        image1.frame = image2.frame;
        image2.frame = temFrame;

    }
    
    
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

- (void)configureWithImage:(UIImage *)sourceImage
{
    if (!sourceImage) {
        return;
    }
    NSArray *tileImages = [self tileImagesFromSource:sourceImage];
    if (tileImages.count != self.imageArrays.count) {
        return;
    }
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        ImageViewOne *tileView = self.imageArrays[index];
        UIImage *tileImage = tileImages[index];
        [tileView setTileImage:tileImage];
        [tileView setLabelHidden:!_shouldShowIndices];
    }
}

- (NSArray *)tileImagesFromSource:(UIImage *)sourceImage
{
    CGImageRef cgImage = sourceImage.CGImage;
    if (!cgImage) {
        return @[];
    }
    size_t pixelWidth = CGImageGetWidth(cgImage);
    size_t pixelHeight = CGImageGetHeight(cgImage);
    size_t minSide = MIN(pixelWidth, pixelHeight);
    if (minSide == 0) {
        return @[];
    }
    CGRect squareRect = CGRectMake((pixelWidth - minSide)/2.0f, (pixelHeight - minSide)/2.0f, minSide, minSide);
    CGFloat tileSide = minSide / 4.0f;
    NSMutableArray *tiles = [NSMutableArray arrayWithCapacity:self.imageArrays.count];
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        NSInteger col = index % 4;
        NSInteger row = index / 4;
        CGRect tileRect = CGRectMake(squareRect.origin.x + col * tileSide,
                                     squareRect.origin.y + row * tileSide,
                                     tileSide,
                                     tileSide);
        CGImageRef tileRef = CGImageCreateWithImageInRect(cgImage, tileRect);
        if (tileRef) {
            UIImage *tileImage = [UIImage imageWithCGImage:tileRef scale:sourceImage.scale orientation:sourceImage.imageOrientation];
            [tiles addObject:tileImage];
            CGImageRelease(tileRef);
        } else {
            [tiles addObject:[[UIImage alloc] init]];
        }
    }
    return tiles;
}
-(void)showIndexOverlay:(BOOL)show
{
    _shouldShowIndices = show;
    for (NSInteger index = 0; index < self.imageArrays.count; index++) {
        ImageViewOne *tileView = self.imageArrays[index];
        [tileView setLabelHidden:!show];
        [tileView setLabelName:[NSString stringWithFormat:@"%ld", (long)index + 1]];
    }
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
@end
