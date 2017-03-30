//
//  LF_PinTuViewController.m
//  PinTu
//
//  Created by YLRS on 2017/3/30.
//  Copyright © 2017年 YLRS. All rights reserved.
//

#import "LF_PinTuViewController.h"
#import "PinTuView.h"
@interface LF_PinTuViewController ()
@property(nonatomic,strong)IMBanner *banner;
@end

@implementation LF_PinTuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackImage];
    
    [self initPinTuView];
    
    [self initIMBanner];
    
    [self.view bringSubviewToFront:self.navigationBar];
    // Do any additional setup after loading the view.
}
-(void)initIMBanner
{
    self.banner = [[IMBanner alloc] initWithFrame:CGRectMake(0, 64, kDeviceWidth, KDeviceHeight) placementId:INMOBI_BANNERID_1];
    
    //Optional: set a delegate to be notified if the banner is loaded/failed etc.
    self.banner.delegate = self;
    
    [self.view addSubview:self.banner];
    
    [self.banner load];
}
-(void)initBackImage
{
    UIImageView *bgImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    bgImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",self.pintuName]];
    [self.view addSubview:bgImgView];
    
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, bgImgView.frame.size.width, bgImgView.frame.size.height)];
    toolbar.barStyle = UIBarStyleBlackTranslucent;
    [bgImgView addSubview:toolbar];
    
    UIImageView *smallImgView = [[UIImageView alloc] init];
    smallImgView.image = [UIImage imageNamed:[NSString stringWithFormat:@"%@.jpg",self.pintuName]];
    [self.view addSubview:smallImgView];

    [smallImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(64+30);
        make.right.mas_equalTo(-10);
        make.size.mas_equalTo(CGSizeMake(100, 100));
    }];
}
-(void)initPinTuView{
    CGFloat space = 30;
    
    CGFloat pintuW = kDeviceWidth - space * 2;
    
    UIColor *backColor = [WWMBaseTool getRandomColor];
    
    PinTuView *pintuView = [[PinTuView alloc] initWithFrame:CGRectMake(space, (KDeviceHeight-pintuW)/2+64, pintuW, pintuW)];
    pintuView.pintuName = self.pintuName;
    pintuView.backgroundColor = backColor;
    [self.view addSubview:pintuView];
    
    [YQHttpTool get:@"http://118.89.227.29:8080/HttpServlet/loginMethod" params:nil success:^(id responseObj) {
        
        NSLog(@"responseObj:%@",responseObj);
        
    } failure:^(NSError *error) {
        
    }];
}
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];

}
-(void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)bannerDidFinishLoading:(IMBanner*)banner {
    NSLog(@"InMobi Banner finished loading");
}
/**
 * Notifies the delegate that the banner has failed to load with some error.
 */
-(void)banner:(IMBanner*)banner didFailToLoadWithError:(IMRequestStatus*)error {
    NSLog(@"InMobi Banner failed to load with error %@", error);
}
/**
 * Notifies the delegate that the banner was interacted with.
 */
-(void)banner:(IMBanner*)banner didInteractWithParams:(NSDictionary*)params {
    NSLog(@"InMobi Banner did interact with params : %@", params);
}
/**
 * Notifies the delegate that the user would be taken out of the application context.
 */
-(void)userWillLeaveApplicationFromBanner:(IMBanner*)banner {
    NSLog(@"User will leave application from InMobi Banner");
}
/**
 * Notifies the delegate that the banner would be presenting a full screen content.
 */
-(void)bannerWillPresentScreen:(IMBanner*)banner {
    NSLog(@"InMobi Banner will present a screen");
}
/**
 * Notifies the delegate that the banner has finished presenting screen.
 */
-(void)bannerDidPresentScreen:(IMBanner*)banner {
    NSLog(@"InMobi Banner finished presenting a screen");
}
/**
 * Notifies the delegate that the banner will start dismissing the presented screen.
 */
-(void)bannerWillDismissScreen:(IMBanner*)banner {
    NSLog(@"InMobi Banner will dismiss a presented screen");
}
/**
 * Notifies the delegate that the banner has dismissed the presented screen.
 */
-(void)bannerDidDismissScreen:(IMBanner*)banner {
    NSLog(@"InMobi Banner dismissed a presented screen");
}
/**
 * Notifies the delegate that the user has completed the action to be incentivised with.
 */
-(void)banner:(IMBanner*)banner rewardActionCompletedWithRewards:(NSDictionary*)rewards {
    NSLog(@"InMobi Banner rewarded action completed. Rewards : %@", rewards);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
