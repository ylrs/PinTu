//
//  ViewController.m
//  PinTu
//
//  Created by YLRS on 6/18/15.
//  Copyright (c) 2015 YLRS. All rights reserved.
//

#import "ViewController.h"
#import "CollectionViewCell.h"
#import "JXBAdPageView.h"
#import "LF_PinTuViewController.h"
@interface ViewController ()<UIActionSheetDelegate>

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float width = (kDeviceWidth -10 -10 -10 -10)/3.0f - 1;
    
    UICollectionViewFlowLayout * flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    flowLayout.footerReferenceSize = CGSizeMake(0, 0);
    flowLayout.minimumLineSpacing = 10.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    mb_collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kDeviceWidth, KDeviceHeight) collectionViewLayout:flowLayout];
    [mb_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    mb_collectionView.backgroundColor = [UIColor whiteColor];
    mb_collectionView.delegate = self;
    mb_collectionView.dataSource = self;
    [mb_collectionView setContentInset:UIEdgeInsetsMake(200, 0, 0, 0)];
    [self.view addSubview:mb_collectionView];
    
    mb_adView = [[JXBAdPageView alloc] initWithFrame:CGRectMake(0, -200, kDeviceWidth, 200)];
    mb_adView.iDisplayTime = 2;
    mb_adView.bWebImage = NO;
    [mb_adView startAdsWithBlock:@[@"TaiKong_7.jpg",@"TaiKong_10.jpg",@"TaiKong_15.jpg"] block:^(NSInteger clickIndex){
    }];
    [mb_collectionView addSubview:mb_adView];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 18;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"TaiKong_%ld.jpg",(long)indexPath.row];
    cell.mb_imageView.image = [UIImage imageNamed:imageName];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:@"选择难度" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"简单",@"普通",@"困难",@"地狱", nil];
    actionSheet.tag = indexPath.row;
    [actionSheet showInView:self.view];
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger hardlevel = 1;
    if (buttonIndex == 0) {
        hardlevel = HardLevel1;
    }
    else if (buttonIndex == 1){
        hardlevel = HardLevel2;
    }
    else if (buttonIndex == 2){
        hardlevel = HardLevel3;
    }
    else if (buttonIndex == 3){
        hardlevel = HardLevel4;
    }
    else if (buttonIndex == 4){
        return;
    }
    
    NSString *imageName = [NSString stringWithFormat:@"TaiKong_%ld",(long)actionSheet.tag];

    LF_PinTuViewController *pintu = [[LF_PinTuViewController alloc] init];
    pintu.pintuName = imageName;
    pintu.hardlevel = hardlevel;
    [self presentViewController:pintu animated:YES completion:nil];

}
@end
