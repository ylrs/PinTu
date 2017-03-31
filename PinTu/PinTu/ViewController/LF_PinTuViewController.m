//
//  LF_PinTuViewController.m
//  PinTu
//
//  Created by YLRS on 2017/3/30.
//  Copyright © 2017年 YLRS. All rights reserved.
//

#import "LF_PinTuViewController.h"
#import "PinTuView.h"
@interface LF_PinTuViewController ()<GADBannerViewDelegate>
@property(nonatomic, strong) GADBannerView *bannerView;

@end

@implementation LF_PinTuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initBackImage];
    
    [self initPinTuView];
    
    [self initAdmobBanner];
    
    [self.view bringSubviewToFront:self.navigationBar];
    // Do any additional setup after loading the view.
}
-(void)initAdmobBanner
{
    self.bannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0, 64, kDeviceWidth, 30+80)];
    self.bannerView.adUnitID = ADMOB_BANNERID_1;
    self.bannerView.rootViewController = self;
    self.bannerView.delegate = self;
    [self.view addSubview:self.bannerView];
    
    GADRequest *request = [GADRequest request];
    
    request.testDevices = @[@"ba90d1c1619ac242a05828dd2ee46fce"];

    [self.bannerView loadRequest:request];
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
-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    

}
-(void)backAction{
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    self.bannerView.hidden = NO;
}
- (void)adView:(GADBannerView *)adView didFailToReceiveAdWithError:(GADRequestError *)error {
    NSLog(@"adVi0ew:didFailToReceiveAdWithError: %@", error.localizedDescription);
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
