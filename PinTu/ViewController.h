//
//  ViewController.h
//  PinTu
//
//  Created by YLRS on 6/18/15.
//  Copyright (c) 2015 YLRS. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JXBAdPageView.h"

@interface ViewController : UIViewController<UICollectionViewDataSource,UICollectionViewDelegate>
{
    UICollectionView           *mb_collectionView;
    JXBAdPageView              *mb_adView;
}
@end
