//
//  BackdoorViewController.h
//  PinTu
//
//  Created by Codex on 2024/10/05.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, BackdoorAction) {
    BackdoorActionShowTileIndices = 0,
};

@class BackdoorViewController;

@protocol BackdoorViewControllerDelegate <NSObject>
- (void)backdoorViewController:(BackdoorViewController *)controller didSelectAction:(BackdoorAction)action;
@end

@interface BackdoorViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) id<BackdoorViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL showTileIndices;

@end
