//
//  GiFHUD.m
//  GiFHUD
//
//  Created by Cem Olcay on 30/10/14.
//  Copyright (c) 2014 Cem Olcay. All rights reserved.
//


#import "GiFHUD.h"
#import "AppDelegate.h"
#import <ImageIO/ImageIO.h>


#define Size            100
#define FadeDuration    0.3
#define GifSpeed        0.3

#define APPDELEGATE     ((AppDelegate*)[[UIApplication sharedApplication] delegate])

#if __has_feature(objc_arc)
#define toCF (__bridge CFTypeRef)
#define fromCF (__bridge id)
#else
#define toCF (CFTypeRef)
#define fromCF (id)
#endif



#pragma mark - UIImage Animated GIF


@implementation UIImage (animatedGIF)

static int delayCentisecondsForImageAtIndex(CGImageSourceRef const source, size_t const i) {
    int delayCentiseconds = 1;
    CFDictionaryRef const properties = CGImageSourceCopyPropertiesAtIndex(source, i, NULL);
    if (properties) {
        CFDictionaryRef const gifProperties = CFDictionaryGetValue(properties, kCGImagePropertyGIFDictionary);
        if (gifProperties) {
            NSNumber *number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFUnclampedDelayTime);
            if (number == NULL || [number doubleValue] == 0) {
                number = fromCF CFDictionaryGetValue(gifProperties, kCGImagePropertyGIFDelayTime);
            }
            if ([number doubleValue] > 0) {
                // Even though the GIF stores the delay as an integer number of centiseconds, ImageIO “helpfully” converts that to seconds for us.
                delayCentiseconds = (int)lrint([number doubleValue] * 100);
            }
        }
        CFRelease(properties);
    }
    return delayCentiseconds;
}

static void createImagesAndDelays(CGImageSourceRef source, size_t count, CGImageRef imagesOut[count], int delayCentisecondsOut[count]) {
    for (size_t i = 0; i < count; ++i) {
        imagesOut[i] = CGImageSourceCreateImageAtIndex(source, i, NULL);
        delayCentisecondsOut[i] = delayCentisecondsForImageAtIndex(source, i);
    }
}

static int sum(size_t const count, int const *const values) {
    int theSum = 0;
    for (size_t i = 0; i < count; ++i) {
        theSum += values[i];
    }
    return theSum;
}

static int pairGCD(int a, int b) {
    if (a < b)
        return pairGCD(b, a);
    while (true) {
        int const r = a % b;
        if (r == 0)
            return b;
        a = b;
        b = r;
    }
}

static int vectorGCD(size_t const count, int const *const values) {
    int gcd = values[0];
    for (size_t i = 1; i < count; ++i) {
        // Note that after I process the first few elements of the vector, `gcd` will probably be smaller than any remaining element.  By passing the smaller value as the second argument to `pairGCD`, I avoid making it swap the arguments.
        gcd = pairGCD(values[i], gcd);
    }
    return gcd;
}

static NSArray *frameArray(size_t const count, CGImageRef const images[count], int const delayCentiseconds[count], int const totalDurationCentiseconds) {
    int const gcd = vectorGCD(count, delayCentiseconds);
    size_t const frameCount = totalDurationCentiseconds / gcd;
    UIImage *frames[frameCount];
    for (size_t i = 0, f = 0; i < count; ++i) {
        UIImage *const frame = [UIImage imageWithCGImage:images[i]];
        for (size_t j = delayCentiseconds[i] / gcd; j > 0; --j) {
            frames[f++] = frame;
        }
    }
    return [NSArray arrayWithObjects:frames count:frameCount];
}

static void releaseImages(size_t const count, CGImageRef const images[count]) {
    for (size_t i = 0; i < count; ++i) {
        CGImageRelease(images[i]);
    }
}

static UIImage *animatedImageWithAnimatedGIFImageSource(CGImageSourceRef const source) {
    size_t const count = CGImageSourceGetCount(source);
    CGImageRef images[count];
    int delayCentiseconds[count]; // in centiseconds
    createImagesAndDelays(source, count, images, delayCentiseconds);
    int const totalDurationCentiseconds = sum(count, delayCentiseconds);
    NSArray *const frames = frameArray(count, images, delayCentiseconds, totalDurationCentiseconds);
    UIImage *const animation = [UIImage animatedImageWithImages:frames duration:(NSTimeInterval)totalDurationCentiseconds / 100.0];
    releaseImages(count, images);
    return animation;
}

static UIImage *animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceRef CF_RELEASES_ARGUMENT source) {
    if (source) {
        UIImage *const image = animatedImageWithAnimatedGIFImageSource(source);
        CFRelease(source);
        return image;
    } else {
        return nil;
    }
}

+ (UIImage *)animatedImageWithAnimatedGIFData:(NSData *)data {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithData(toCF data, NULL));
}

+ (UIImage *)animatedImageWithAnimatedGIFURL:(NSURL *)url {
    return animatedImageWithAnimatedGIFReleasingImageSource(CGImageSourceCreateWithURL(toCF url, NULL));
}

@end



#pragma mark - GiFHUD Private

@interface GiFHUD ()

+ (instancetype)instance;

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView *imageViewBackground;
@property (nonatomic, assign) BOOL shown;
@property (nonatomic,  weak)WLCircleProgressView  *refreshView;

@end



#pragma mark - GiFHUD Implementation

@implementation GiFHUD


#pragma mark Lifecycle

static GiFHUD *instance;

+ (instancetype)instance {
    if (!instance) {
        instance = [[GiFHUD alloc] init];
    }
    return instance;
}

- (instancetype)init {
    if ((self = [super initWithFrame:CGRectMake(0, 0, Size, Size)])) {
        
        [self setAlpha:0];
        [self setCenter:APPDELEGATE.window.center];
        [self setClipsToBounds:NO];
        
        [self.layer setBackgroundColor:[UIColor clearColor].CGColor];
        [self.layer setCornerRadius:10];
        [self.layer setMasksToBounds:YES];
        
        self.imageViewBackground = [[UIImageView alloc] initWithFrame:CGRectInset(self.bounds, 10, 10)];
        self.imageViewBackground.layer.cornerRadius = 5;
        self.imageViewBackground.layer.masksToBounds = YES;
        [self addSubview:self.imageViewBackground];
        
        self.imageView = [[UIImageView alloc] init];
        self.imageView.backgroundColor = [UIColor clearColor];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.image = [UIImage imageNamed:@"gifhud_mi_image"];
        [self addSubview:self.imageView];
        
        WS(ws);
        [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.mas_equalTo(ws);
            make.size.mas_equalTo(CGSizeMake(20, 20));
        }];
        
        WLCircleProgressView *refreshView = [WLCircleProgressView
                                             viewWithFrame:CGRectMake(0, 0, Size, Size) circlesSize:CGRectMake(30, 5, 20, 1) withColor:StandardColor1];
        refreshView.backgroundColor = [UIColor clearColor];
        refreshView.layer.cornerRadius = 10;
        refreshView.progressValue = 0.8;
        refreshView.backCircle.hidden = YES;
        [self addSubview:refreshView];
        self.refreshView = refreshView;
        
        [APPDELEGATE.window addSubview:self];
    }
    return self;
}
+(void)showRefreshLoading
{
    CABasicAnimation* rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 2.0 ];
    rotationAnimation.duration = 0.8;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = 10000;
    [[[self instance] refreshView].layer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}
+(void)hiddenRefreshLoadingAfter:(NSInteger)time
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[[self instance] refreshView].layer removeAnimationForKey:@"rotationAnimation"];
        [[self instance] refreshView].progressValue = 0.1;
        [[self instance] refreshView].hidden = YES;
    });
}



#pragma mark HUD

+ (void)showWithOverlay {
    [self dismiss:^{
        [APPDELEGATE.window addSubview:[[self instance] overlayV]];
        [self show];
    }];
}

+ (void)showWithViewController:(UIViewController *)viewController {
    [self dismiss:^{
        [viewController.view addSubview:[[self instance] overlayV]];
        [self show];
    }];
}


+ (void)show {
    
    [self showRefreshLoading];

    [self dismiss:^{
        [APPDELEGATE.window bringSubviewToFront:[self instance]];
        [[self instance] setShown:YES];
        [[self instance] fadeIn];
    }];
}


+ (void)dismiss {
//    if (![[self instance] shown])
//        return;
    
    [[[self instance] overlayV] removeFromSuperview];
    [[self instance] fadeOut];
    

}

+ (void)dismiss:(void(^)(void))complated {
    if (![[self instance] shown])
        return complated ();
    
    [[self instance] fadeOutComplate:^{
        [[[self instance] overlayV] removeFromSuperview];
        complated ();
    }];
}

#pragma mark Effects

- (void)fadeIn {
//    [self.imageView startAnimating];
    [UIView animateWithDuration:FadeDuration animations:^{
        [self setAlpha:1];
    }];
}

- (void)fadeOut {
    [UIView animateWithDuration:FadeDuration animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self setShown:NO];
//        [self.imageView stopAnimating];
    }];
}

- (void)fadeOutComplate:(void(^)(void))complated {
    [UIView animateWithDuration:FadeDuration animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [self setShown:NO];
//        [self.imageView stopAnimating];
        complated ();
    }];
}


- (UIView *)overlayV {
    
    if (!self.overlayView) {
        self.overlayView = [[UIView alloc] initWithFrame:APPDELEGATE.window.frame];
        [self.overlayView setBackgroundColor:[UIColor blackColor]];
        [self.overlayView setAlpha:0];
        
        [UIView animateWithDuration:FadeDuration animations:^{
            [self.overlayView setAlpha:0.3];
        }];
    }
    return self.overlayView;
}



#pragma mark Gif
+ (void) setGifBackgroundImage:(NSString *)imageName {
    [[[self instance] imageViewBackground] setImage:[WWMBaseTool imageWithColor:[UIColor whiteColor] size:CGSizeMake(200, 200)]];
//    [[[self instance] imageViewBackground] setImage:[UIImage imageNamed:imageName]];
}

+ (void)setGifWithImages:(NSArray *)images {
//    [[[self instance] imageView] setAnimationImages:images];
//    [[[self instance] imageView] setAnimationDuration:GifSpeed];
}

+ (void)setGifWithImageName:(NSString *)imageName {
//    [[[self instance] imageView] stopAnimating];
//    [[[self instance] imageView] setImage:[UIImage animatedImageWithAnimatedGIFURL:[[NSBundle mainBundle] URLForResource:imageName withExtension:nil]]];
}

+ (void)setGifWithURL:(NSURL *)gifUrl {
//    [[[self instance] imageView] stopAnimating];
//    [[[self instance] imageView] setImage:[UIImage animatedImageWithAnimatedGIFURL:gifUrl]];
}


@end
