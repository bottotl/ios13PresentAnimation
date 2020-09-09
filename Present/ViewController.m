//
//  ViewController.m
//  Present
//
//  Created by 於林涛 on 2020/9/8.
//  Copyright © 2020 於林涛. All rights reserved.
//

#import "ViewController.h"
#import "JFTPresentationController.h"

@interface ViewControllerB : UIViewController

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
    JFTPresentationController *presentationController NS_VALID_UNTIL_END_OF_SCOPE;
    presentationController = [[JFTPresentationController alloc] initWithPresentedViewController:vc presentingViewController:self];
    vc.transitioningDelegate = presentationController;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)testPresent:(id)sender {
    [self presentTestVC];
}

@end
