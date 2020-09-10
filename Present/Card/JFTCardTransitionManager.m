//
//  JFTCardTransitionManager.m
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import "JFTCardTransitionManager.h"
#import "JFTCardConfiguration.h"
#import "JFTCardPresentationController.h"
#import "JFTCardPresentAnimation.h"

@interface JFTCardTransitionManager ()
@property (nonatomic) JFTCardConfiguration *configuration;
@property (nonatomic) JFTCardPresentAnimation *cardAnimation;
@end

@implementation JFTCardTransitionManager

- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration {
    if (self = [super init]) {
        _configuration = configuration;
    }
    return self;
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    JFTCardPresentationController *controller = [[JFTCardPresentationController alloc] initWithConfiguration:self.configuration
                                                                                     presentedViewController:presented
                                                                                    presentingViewController:presenting];
    controller.cardAnimator = self.cardAnimation;
    controller.dismissAreaHeight = self.configuration.dismissAreaHeight;
    return controller;
}

- (JFTCardPresentAnimation *)cardAnimation {
    if (!_cardAnimation) {
        _cardAnimation = [[JFTCardPresentAnimation alloc] initWithConfiguration:self.configuration direction:JFTCardPresentAnimationDirectionPresentation];
    }
    return _cardAnimation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    self.cardAnimation.direction = JFTCardPresentAnimationDirectionPresentation;
    return self.cardAnimation;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    self.cardAnimation.direction = JFTCardPresentAnimationDirectionDismissal;
    return self.cardAnimation;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForPresentation:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.cardAnimation.isInteractive) {
        return self.cardAnimation;
    }
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.cardAnimation.isInteractive) {
        return self.cardAnimation;
    }
    return nil;
}

@end
