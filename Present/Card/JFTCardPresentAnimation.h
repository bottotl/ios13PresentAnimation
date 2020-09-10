//
//  JFTCardPresentAnimation.h
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, JFTCardPresentAnimationDirection) {
    JFTCardPresentAnimationDirectionPresentation,
    JFTCardPresentAnimationDirectionDismissal
};

@class JFTCardConfiguration;

UIKIT_EXTERN API_AVAILABLE(ios(10.0)) @interface JFTCardPresentAnimation : NSObject <UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning>

- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration direction:(JFTCardPresentAnimationDirection)direction;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, readonly) JFTCardConfiguration *configuration;
@property (nonatomic) JFTCardPresentAnimationDirection direction;

@property (nonatomic) BOOL isInteractive;

- (UIViewPropertyAnimator *)buildAnimatorForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext;

- (void)updateInteractiveTransition:(CGFloat)percentComplete;
- (void)cancelInteractiveTransition:(CGVector)velocity;
- (void)finishInteractiveTransition:(CGVector)velocity;

@end

NS_ASSUME_NONNULL_END

