//
//  ViewController.m
//  Present
//
//  Created by 於林涛 on 2020/9/8.
//  Copyright © 2020 於林涛. All rights reserved.
//

#import "ViewController.h"
#import "JFTCardPresentationController.h"
#import "JFTCardConfiguration.h"
#import "JFTCardTransitionManager.h"
#import "UIViewController+CardAnimation.h"

@interface ViewControllerB : UIViewController
@property (nonatomic) JFTCardTransitionManager *manager;
@end
@implementation ViewControllerB
- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}
- (BOOL)prefersStatusBarHidden {
    return NO;
}

@end

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentTestVC];
    });
}

- (void)presentTestVC  {
    UIViewController *vc = [ViewControllerB new];
    vc.view.backgroundColor = [UIColor redColor];
    vc.preferredContentSize = self.view.bounds.size;
    [self card_present:vc];
}

- (IBAction)testPresent:(id)sender {
    [self presentTestVC];
}

@end
