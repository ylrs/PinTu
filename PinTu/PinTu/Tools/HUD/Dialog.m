
#import "Dialog.h"
#import "MBProgressHUD.h"
#import <unistd.h>
#import "GiFHUD.h"

@implementation Dialog

static Dialog *instance = nil;

+ (Dialog *)Instance
{
    @synchronized(self)
    {
        if (instance == nil) {
            instance = [self new];
        }
    }
    return instance;
}

+ (void)alert:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:nil 
                              message:message 
                              delegate:nil 
                              cancelButtonTitle:@"好的"
                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)alertWithTitle:(NSString *)title andMessage:(NSString *)message {
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:title
                              message:message
                              delegate:nil
                              cancelButtonTitle:@"好的"
                              otherButtonTitles:nil, nil];
    [alertView show];
}

+ (void)toast:(UIViewController *)controller withMessage:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:controller.view animated:YES];
	hud.mode = MBProgressHUDModeText;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

+ (void)toast:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoomOut;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = 150.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}

+ (void)simpleToast:(NSString *)message
{
    [SVProgressHUD showOnlyStatus:message withDuration:2];
}

+ (void)hideSimpleToast
{
    [SVProgressHUD dismissAfterDelay:2];
}

+ (void)toastCenter:(NSString *)message {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeText;
    hud.animationType = MBProgressHUDAnimationZoomOut;
	hud.labelText = [NSString stringWithFormat:@" %@ ",message];
    hud.userInteractionEnabled = NO;
	hud.margin = 7.f;
	hud.yOffset = -20.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2.0];
}

+ (void)progressToast:(NSString *)message
{
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
	hud.mode = MBProgressHUDModeIndeterminate;
	hud.labelText = message;
	hud.margin = 10.f;
	hud.yOffset = -20.f;
	hud.removeFromSuperViewOnHide = YES;
	[hud hide:YES afterDelay:2];
}


+ (void) showErrorMessage:(NSString *) err {
    [SVProgressHUD showErrorWithStatus:err];
}

- (void)gradient:(UIViewController *)controller seletor:(SEL)method {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
	[controller.view addSubview:HUD];
//	HUD.dimBackground = YES;
	HUD.delegate = self;
	[HUD showWhileExecuting:method onTarget:controller withObject:nil animated:YES];
}

- (void)showProgress:(UIViewController *)controller {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
//    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
}

- (void)showProgressWithView:(UIView *)view {
    HUD = [[MBProgressHUD alloc] initWithView:view];
    [view addSubview:HUD];
    //    HUD.dimBackground = YES;
    HUD.delegate = self;
    [HUD show:YES];
}
- (void)showProgress:(UIViewController *)controller withLabel:(NSString *)labelText {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
    HUD.delegate = self;
//    HUD.dimBackground = YES;
    HUD.labelText = labelText;
    [HUD show:YES];
}

- (void)showCenterProgressWithLabel:(NSString *)labelText
{
    HUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:HUD];
    HUD.delegate = self;
    HUD.color = [UIColor lightGrayColor];
//        HUD.dimBackground = YES;
    
    HUD.labelText = labelText;
    [HUD show:YES];
}

- (void)hideProgress {
    [HUD hide:YES];
}

- (void)progressWithLabel:(UIViewController *)controller seletor:(SEL)method {
    HUD = [[MBProgressHUD alloc] initWithView:controller.view];
    [controller.view addSubview:HUD];
    HUD.delegate = self;
    //HUD.labelText = @"数据加载中...";
    [HUD showWhileExecuting:method onTarget:controller withObject:nil animated:YES];
}

#pragma mark -
#pragma mark Execution code

- (void)myTask {
	sleep(3);
}

- (void)myProgressTask {
	float progress = 0.0f;
	while (progress < 1.0f) {
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
}

- (void)myMixedTask {
	sleep(2);
	HUD.mode = MBProgressHUDModeDeterminate;
	HUD.labelText = @"Progress";
	float progress = 0.0f;
	while (progress < 1.0f)
	{
		progress += 0.01f;
		HUD.progress = progress;
		usleep(50000);
	}
	HUD.mode = MBProgressHUDModeIndeterminate;
	HUD.labelText = @"Cleaning up";
	sleep(2);
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]] ;
	HUD.mode = MBProgressHUDModeCustomView;
	HUD.labelText = @"Completed";
	sleep(2);
}

#pragma mark -
#pragma mark NSURLConnectionDelegete

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	expectedLength = [response expectedContentLength];
	currentLength = 0;
	HUD.mode = MBProgressHUDModeDeterminate;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	currentLength += [data length];
	HUD.progress = currentLength / (float)expectedLength;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
	HUD.mode = MBProgressHUDModeCustomView;
	[HUD hide:YES afterDelay:2];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[HUD hide:YES];
}

#pragma mark -
#pragma mark MBProgressHUDDelegate methods

- (void)hudWasHidden:(MBProgressHUD *)hud {
	[HUD removeFromSuperview];
	HUD = nil;
}


#pragma mark -
- (void) showSystemProgressWithController:(UIViewController *)controller {
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = controller.view.center;
    [controller.view addSubview:indicatorView];
    [indicatorView startAnimating];
}

- (void) showSystemProgressInView:(UIView *) view {
    indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicatorView.center = view.center;
    [view addSubview:indicatorView];
    [indicatorView startAnimating];

}

- (UIActivityIndicatorView *) systemProgressIndicatorView {
    if (indicatorView) {
        return indicatorView;
    }
    return nil;
}
- (void) showSystemProgressInWindow {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;
    
    if (!indicatorView) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    }
    else {
        if (indicatorView.isAnimating) {
            [indicatorView stopAnimating];
        }
    }
    
    indicatorView.hidesWhenStopped = YES;
    indicatorView.center = window.center;
    [window bringSubviewToFront:indicatorView];
    [window addSubview:indicatorView];
    [indicatorView startAnimating];
}

- (void) hideSystemProgressIndicator {
    if (indicatorView) {
        [indicatorView stopAnimating];
        [indicatorView removeFromSuperview];
    }
}

- (void)showProgressWithCoverInWindow {
    UIWindow * window = [UIApplication sharedApplication].keyWindow;

    if (!cover) {
        cover = [[UIView alloc] initWithFrame:window.bounds];
        
        UIImageView * bgView = [[UIImageView alloc] initWithFrame:window.bounds];
        [cover addSubview:bgView];
        bgView.backgroundColor = [UIColor blackColor];
        bgView.alpha = 0.8;
    }
    
    [window addSubview:cover];
}

- (void) hideProgressWithCoverInWindow {
    [GiFHUD dismiss];
    
    [cover removeFromSuperview];
}

+ (void) showGifHudInWindowWithCover:(BOOL)withcover {

    [GiFHUD show];

//    if (withcover) {
//        [GiFHUD showWithOverlay];
//    }
//    else{
//        [GiFHUD show];
//    }
}
+ (void) showGifHudInViewControllerWithCover:(UIViewController *)viewController {
    
    [GiFHUD showWithViewController:viewController];
}

+ (void) hideGifHudInWindow {
    [GiFHUD dismiss];
}

@end
