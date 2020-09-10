//
//  UIViewController+CardAnimation.m
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//

#import "UIViewController+CardAnimation.h"
#import "JFTCardTransitionManager.h"
#import <BlocksKit/BlocksKit.h>
#import "JFTCardConfiguration.h"

static void *kCardTransitionManagerKey = &kCardTransitionManagerKey;

@interface UIViewController ()
@property (nonatomic) JFTCardTransitionManager *cardTransitionManager;
@end

@implementation UIViewController (CardAnimation)

- (JFTCardTransitionManager *)cardTransitionManager {
    return [self bk_associatedValueForKey:kCardTransitionManagerKey];
}

- (void)setCardTransitionManager:(JFTCardTransitionManager *)cardTransitionManager {
    [self bk_associateValue:cardTransitionManager withKey:kCardTransitionManagerKey];
}

- (void)card_present:(UIViewController *)vc {
    vc.modalPresentationStyle = UIModalPresentationCustom;
    vc.modalPresentationCapturesStatusBarAppearance = YES;
    
    JFTCardConfiguration *config = [JFTCardConfiguration shared];
    JFTCardTransitionManager *manager = [[JFTCardTransitionManager alloc] initWithConfiguration:config];
    vc.transitioningDelegate = manager;
    vc.cardTransitionManager = manager;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)card_removeCardTransitionManager {
    self.cardTransitionManager = nil;
}

@end
