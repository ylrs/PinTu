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
#import "PuzzleViewController.h"
@interface ViewController ()
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    float width = (self.view.bounds.size.width -10 -10 -10 -10)/3.0f - 1;
    
    UICollectionViewFlowLayout * flowLayout=[[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CGSizeMake(width, width);
    flowLayout.headerReferenceSize = CGSizeMake(0, 0);
    flowLayout.footerReferenceSize = CGSizeMake(0, 0);
    flowLayout.minimumLineSpacing = 10.0f;
    flowLayout.minimumInteritemSpacing = 10.0f;
    flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 10, 10);
    
    mb_adView = [[JXBAdPageView alloc] initWithFrame:CGRectZero];
    mb_adView.iDisplayTime = 2;
    mb_adView.bWebImage = NO;
    __weak typeof(self) weakSelf = self;
    [mb_adView startAdsWithBlock:@[@"1.png",@"2.png",@"3.png",@"4.png",@"5.png",@"6.png",@"7.png",@"8.png"] block:^(NSInteger clickIndex){
        [weakSelf showPuzzleForIndex:clickIndex];
    }];
    [self.view addSubview:mb_adView];
    
    mb_collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [mb_collectionView registerClass:[CollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    mb_collectionView.backgroundColor = [UIColor whiteColor];
    mb_collectionView.delegate = self;
    mb_collectionView.dataSource = self;
    [self.view addSubview:mb_collectionView];
    
    [self layoutHomeViews];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 9;
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];
    NSString *imageName = [NSString stringWithFormat:@"Main_%ld.jpeg",(long)indexPath.row];
    cell.mb_imageView.image = [UIImage imageNamed:imageName];
    return cell;
}
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self showPuzzleForIndex:indexPath.row];
}
-(BOOL)shouldAutorotate
{
    return NO;
}
-(NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self layoutHomeViews];
}
-(void)showPuzzleForIndex:(NSInteger)index
{
    UIImage *sourceImage = [self puzzleImageForIndex:index];
    if (!sourceImage) {
        return;
    }
    PuzzleViewController *controller = [[PuzzleViewController alloc] initWithImage:sourceImage];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}
-(UIImage *)puzzleImageForIndex:(NSInteger)index
{
    NSArray *availableNames = @[@"Main_0.jpeg",@"Main_1.jpeg",@"Main_2.jpeg",@"Main_3.jpeg",@"Main_4.jpeg",@"Main_5.jpeg",@"Main_6.jpeg",@"Main_7.jpeg",@"Main_8.jpeg"];
    if (availableNames.count == 0) {
        return nil;
    }
    NSInteger normalizedIndex = index % availableNames.count;
    if (normalizedIndex < 0) {
        normalizedIndex += availableNames.count;
    }
    NSString *imageName = availableNames[normalizedIndex];
    return [UIImage imageNamed:imageName];
}
-(void)layoutHomeViews
{
    CGFloat adHeight = 200.0f;
    CGFloat safeTop = 0.0f;
    CGFloat safeBottom = 0.0f;
    if (@available(iOS 11.0, *)) {
        safeBottom = self.view.safeAreaInsets.bottom;
    }
    
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat cellWidth = (viewWidth -10 -10 -10 -10)/3.0f - 1;
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)mb_collectionView.collectionViewLayout;
    layout.itemSize = CGSizeMake(cellWidth, cellWidth);
    
    CGFloat gridHeight = cellWidth * 3 + 40;
    
    CGRect adFrame = CGRectMake(0, safeTop, viewWidth, adHeight);
    mb_adView.frame = adFrame;
    
    CGFloat collectionY = CGRectGetMaxY(adFrame);
    CGFloat availableHeight = self.view.bounds.size.height - collectionY - safeBottom;
    CGFloat collectionHeight = availableHeight > 0 ? availableHeight : gridHeight;
    if (collectionHeight < gridHeight) {
        collectionHeight = gridHeight;
    }
    
    mb_collectionView.frame = CGRectMake(0, collectionY, viewWidth, collectionHeight);
}
@end
