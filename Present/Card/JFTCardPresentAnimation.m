//
//  JFTCardPresentAnimation.m
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import "JFTCardPresentAnimation.h"
#import "JFTCardConfiguration.h"
#import "JFTCardPresentationController.h"

#define let __auto_type

@interface UIView (JFTCard)

@end

@implementation UIView (JFTCard)

- (void)cardMaskTopCorners:(CGFloat)cornerRadius {
    self.clipsToBounds = YES;
    if (@available(iOS 11.0, *)) {
        self.layer.maskedCorners =  kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner;
    }
    self.layer.cornerRadius = cornerRadius;
}

- (void)cardUnmask {
    self.layer.cornerRadius = 0;
}

@end

@interface JFTCardSpringParameters : UISpringTimingParameters
@property (nonatomic) CGFloat damping;
@property (nonatomic) CGFloat response;
+ (instancetype)tap;
+ (instancetype)momentum;
- (instancetype)initWithDamping:(CGFloat)damping response:(CGFloat)response;
@end
@implementation JFTCardSpringParameters

- (instancetype)initWithDamping:(CGFloat)damping response:(CGFloat)response {
    return [self initWithDamping:damping response:response initialVelocity:CGVectorMake(0, 0)];
}

- (instancetype)initWithDamping:(CGFloat)damping response:(CGFloat)response initialVelocity:(CGVector)initialVelocity {
    let stiffness = pow(2 * M_PI / response, 2);
    let damp = 4 * M_PI * damping / response;
    if (self = [super initWithMass:1 stiffness:stiffness damping:damp initialVelocity:initialVelocity]) {
        _damping = damp;
        _response = response;
    }
    return self;
}

/// From amazing session 803 at WWDC 2018: https://developer.apple.com/videos/play/wwdc2018-803/?time=2238
/// Because the tap doesn't have any momentum in the direction of the presentation of Now Playing,
/// we use 100% damping to make sure it doesn't overshoot.
+ (instancetype)tap {
    return [[JFTCardSpringParameters alloc] initWithDamping:1 response:0.44];
}

///    > But, if you swipe to dismiss Now Playing,
///    > there is momentum in the direction of the dismissal,
///    > and so we use 80% damping to have a little bit of bounce and squish,
///    > making the gesture a lot more satisfying.
///
///    (note that they use momentum even when tapping to dismiss)
+ (instancetype)momentum {
    return [[JFTCardSpringParameters alloc] initWithDamping:0.8 response:0.44];
}

@end

@interface JFTCardPresentAnimation ()

@property (nonatomic, readonly) CGFloat verticalSpacing;
@property (nonatomic, readonly) CGFloat verticalInset;
@property (nonatomic, readonly) CGFloat horizontalInset;
@property (nonatomic, readonly) CGFloat cornerRadius;
@property (nonatomic, readonly) CGFloat backFadeAlpha;
@property (nonatomic, readonly) CGRect initialTransitionFrame;

@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;

@property (nonatomic) UIViewPropertyAnimator *presentationAnimator;
@property (nonatomic) UIViewPropertyAnimator *dismissAnimator;

@end

@implementation JFTCardPresentAnimation

- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration
                            direction:(JFTCardPresentAnimationDirection)direction {
    if (self = [super init]) {
        _configuration = configuration;
        _direction = direction;
    }
    return self;
}

- (UIViewPropertyAnimator *)presentationAnimator {
    if (!_presentationAnimator) {
        _presentationAnimator = [self setupAnimator:JFTCardPresentAnimationDirectionPresentation];
    }
    return _presentationAnimator;
}

- (UIViewPropertyAnimator *)dismissAnimator {
    if (!_dismissAnimator) {
        _dismissAnimator = [self setupAnimator:JFTCardPresentAnimationDirectionDismissal];
    }
    return _dismissAnimator;
}

- (CGFloat)verticalSpacing {
    return self.configuration.verticalSpacing;
}

- (CGFloat)verticalInset {
    return self.configuration.verticalInset;
}

- (CGFloat)horizontalInset {
    return self.configuration.horizontalInset;
}

- (CGFloat)cornerRadius {
    return self.configuration.cornerRadius;
}

- (CGFloat)backFadeAlpha {
    return self.configuration.backFadeAlpha;
}

- (CGRect)initialTransitionFrame {
    return self.configuration.initialTransitionFrame;
}

- (UIViewPropertyAnimator *)interactiveAnimator {
    switch (self.direction) {
        case JFTCardPresentAnimationDirectionPresentation:
            return self.presentationAnimator;
        case JFTCardPresentAnimationDirectionDismissal:
            return self.dismissAnimator;
    }
}

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.direction) {
        case JFTCardPresentAnimationDirectionPresentation:
            return 0.65;
        case JFTCardPresentAnimationDirectionDismissal:
            return 0.55;
    }
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    let pa = [self buildAnimatorForTransitionContext:transitionContext];
    [pa startAnimation];
}

- (void)animationEnded:(BOOL)transitionCompleted {
    self.isInteractive = NO;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    if (![self buildAnimatorForTransitionContext:transitionContext]) { return; }
    self.transitionContext = transitionContext;
}

- (BOOL)wantsInteractiveStart {
    return self.isInteractive;
}

- (void)updateInteractiveTransition:(CGFloat)percentComplete {
    let pa = self.interactiveAnimator;

    pa.fractionComplete = percentComplete;
    [self.transitionContext updateInteractiveTransition:percentComplete];
}

- (void)cancelInteractiveTransition:(CGVector)velocity {
    if (!self.isInteractive) { return; }
    
    [self.transitionContext cancelInteractiveTransition];
    self.interactiveAnimator.reversed = YES;
    
    let pct = self.interactiveAnimator.fractionComplete;
    [self endInteraction:pct withVelocity:velocity durationFactor:1 - pct];
    
}

- (void)finishInteractiveTransition:(CGVector)velocity {
    if (!self.isInteractive) { return; }
    
    [self.transitionContext finishInteractiveTransition];
    let pct = [self.interactiveAnimator fractionComplete];
    [self endInteraction:pct withVelocity:velocity durationFactor:pct];
}

- (void)insetBackCards:(JFTCardPresentationController *)pc {
    let pcView = pc.presentingViewController.view;
    
    if (![pc isKindOfClass:JFTCardPresentationController.class] || !pcView) { return; }

    let frame = pcView.frame;
    
    pcView.frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, self.horizontalInset, 0, self.horizontalInset));
    pcView.alpha *= self.backFadeAlpha;
    [self insetBackCards:(JFTCardPresentationController *)pc.presentingViewController.presentationController];
}

- (void)outsetBackCards:(JFTCardPresentationController *)pc {
    let pcView = pc.presentingViewController.view;
    
    if (![pc isKindOfClass:JFTCardPresentationController.class] || !pcView) { return; }
    let frame = pcView.frame;
    
    pcView.frame = UIEdgeInsetsInsetRect(frame, UIEdgeInsetsMake(0, -self.horizontalInset, 0, -self.horizontalInset));
    pcView.alpha /= self.backFadeAlpha;
    [self outsetBackCards:(JFTCardPresentationController *)pc.presentingViewController.presentationController];
}

- (CGRect)offscreenFrameInside:(UIView *)containerView {
    if (!CGRectEqualToRect(self.initialTransitionFrame, CGRectZero)) {
        return self.initialTransitionFrame;
    }
    
    CGRect f = containerView.frame;
    return CGRectMake(f.origin.x, f.size.height, f.size.width, f.size.height);
}

- (void)endInteraction:(CGFloat)percentComplete withVelocity:(CGVector)velocity durationFactor:(CGFloat)durationFactor {
    switch (self.interactiveAnimator.state) {
        case UIViewAnimatingStateInactive:
            [self.interactiveAnimator startAnimation];
        default:    //    case .active, .stopped, @unknown-futures
            [self.interactiveAnimator continueAnimationWithTimingParameters:nil durationFactor:durationFactor];
    }
}

- (UIViewPropertyAnimator *)setupAnimator:(JFTCardPresentAnimationDirection)direction {
    JFTCardSpringParameters *params = nil;

    switch (self.direction) {
        case JFTCardPresentAnimationDirectionPresentation:
            params = [JFTCardSpringParameters tap];
        case JFTCardPresentAnimationDirectionDismissal:
            params = [JFTCardSpringParameters momentum];
    }

    //    entire spring animation should not last more than transitionDuration
    let damping = params.damping;
    let response = params.response;
    let timingParameters = [[JFTCardSpringParameters alloc] initWithDamping:damping response:response];

    let pa = [[UIViewPropertyAnimator alloc] initWithDuration:0.65 timingParameters:timingParameters];

    return pa;
}


- (UIViewPropertyAnimator *)buildAnimatorForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    switch (self.direction) {
        case JFTCardPresentAnimationDirectionPresentation:
            return [self buildPresentAnimatorForTransitionContext:transitionContext];
        case JFTCardPresentAnimationDirectionDismissal:
            return [self buildDismissAnimatorForTransitionContext:transitionContext];
    }
}

- (UIViewPropertyAnimator *)buildPresentAnimatorForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    let fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    let fromView = fromVC.view;
    let toView = toVC.view;
    
    let containerView = transitionContext.containerView;
    
    CGRect fromEndFrame = CGRectZero;
    CGRect toEndFrame = CGRectZero;
    
    JFTCardPresentationController *sourceCardPresentationController = nil;
    if ([fromVC.presentationController isKindOfClass:JFTCardPresentationController.class]) {
        sourceCardPresentationController = (JFTCardPresentationController *)fromVC.presentationController;
        [sourceCardPresentationController fadeoutHandle];
    }
    
    if (sourceCardPresentationController) {// 最底部的
        CGRect fromBeginFrame = CGRectZero;
        if (@available(iOS 13, *)) {
            fromBeginFrame = fromView.frame;
        } else {
            //on iOS 13, origin.y for this seem to always be 0
            fromBeginFrame = [transitionContext initialFrameForViewController:fromVC];
        }
        fromEndFrame = UIEdgeInsetsInsetRect(fromBeginFrame, UIEdgeInsetsMake(0, self.horizontalInset, 0, self.horizontalInset));
        toEndFrame = UIEdgeInsetsInsetRect(fromBeginFrame, UIEdgeInsetsMake(self.verticalInset, 0, 0, 0));
    } else {
        let fromBeginFrame = CGRectZero;
        if (@available(iOS 13, *)) {
            fromBeginFrame = fromView.frame;
        } else {
            //    on iOS 13, origin.y for this seem to always be 0
            fromBeginFrame = [transitionContext initialFrameForViewController:fromVC];
        }
        fromEndFrame = UIEdgeInsetsInsetRect(fromBeginFrame, UIEdgeInsetsMake(self.verticalInset, self.horizontalInset, 0, self.horizontalInset));

        let toBaseFinalFrame = [transitionContext finalFrameForViewController:toVC];
        toEndFrame = UIEdgeInsetsInsetRect(toBaseFinalFrame, UIEdgeInsetsMake(self.verticalInset + self.verticalSpacing, 0, 0, 0));
    }
    
    let toStartFrame = [self offscreenFrameInside:containerView];
    toView.clipsToBounds = true;
    toView.frame = toStartFrame;
    [toView layoutIfNeeded];
    [containerView addSubview:toView];
    
    let pa = self.presentationAnimator;
    
    __weak typeof(self) weakSelf = self;
    [pa addAnimations:^{
        [weakSelf insetBackCards:sourceCardPresentationController];
        fromView.frame = fromEndFrame;
        toView.frame = toEndFrame;
        [fromView cardMaskTopCorners:weakSelf.cornerRadius];
        [toView cardMaskTopCorners:weakSelf.cornerRadius];

        fromView.alpha = weakSelf.backFadeAlpha;
    }];
    
    [pa addCompletion:^(UIViewAnimatingPosition animatingPosition) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        switch (animatingPosition) {
            case UIViewAnimatingPositionStart: {
                if (strongSelf) {
                    strongSelf.direction = JFTCardPresentAnimationDirectionPresentation;
                }
                
                fromView.userInteractionEnabled = YES;
                [transitionContext completeTransition:false];
            }
            
            default:{//    case .end, .current (which should not be possible), @unknown-futures
                if (strongSelf) {
                    strongSelf.direction = JFTCardPresentAnimationDirectionDismissal;
                }
                
                fromView.userInteractionEnabled = NO;
                [transitionContext completeTransition:YES];
            }
        }
    }];

    return pa;

}

- (UIViewPropertyAnimator *)buildDismissAnimatorForTransitionContext:(id<UIViewControllerContextTransitioning>)transitionContext {
    let fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    let toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    let fromView = fromVC.view;
    let toView = toVC.view;
    
    let containerView = transitionContext.containerView;
    
    JFTCardPresentationController *targetCardPresentationController = nil;
    if ([toVC.presentationController isKindOfClass:JFTCardPresentationController.class]) {
        targetCardPresentationController = (JFTCardPresentationController *)toVC.presentationController;
    }
    let isTargetAlreadyCard = (targetCardPresentationController != nil);
    
    
    let toBeginFrame = toView.frame;
    let toEndFrame = CGRectZero;
    
    if (targetCardPresentationController) {
        toEndFrame = UIEdgeInsetsInsetRect(toBeginFrame, UIEdgeInsetsMake(0, -self.horizontalInset, 0, -self.horizontalInset));
    } else {
        toEndFrame = [transitionContext finalFrameForViewController:toVC];
    }
    
    let fromEndFrame = [self offscreenFrameInside:containerView];
    let pa = self.dismissAnimator;
    
    __weak typeof(self) weakSelf = self;
    [pa addAnimations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        
        [fromView cardUnmask];
        if (!isTargetAlreadyCard) {
            [toView cardUnmask];
        }
        [strongSelf outsetBackCards:targetCardPresentationController];

        fromView.frame = fromEndFrame;
        toView.frame = toEndFrame;
        toView.alpha = 1;
        fromView.alpha = 1;
    }];
    
    [pa addCompletion:^(UIViewAnimatingPosition animatingPosition) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (!strongSelf) { return; }
        switch (animatingPosition) {
            case UIViewAnimatingPositionStart:
                strongSelf.direction = JFTCardPresentAnimationDirectionDismissal;
                strongSelf.dismissAnimator = [strongSelf setupAnimator:JFTCardPresentAnimationDirectionDismissal];
                toView.userInteractionEnabled = NO;
                [transitionContext completeTransition:NO];
                break;
                
            default:
                strongSelf.direction = JFTCardPresentAnimationDirectionPresentation;
                
                strongSelf.presentationAnimator = [strongSelf setupAnimator:JFTCardPresentAnimationDirectionPresentation];

                toView.userInteractionEnabled = YES;
                [fromView removeFromSuperview];
                

                if (targetCardPresentationController) {
                    [targetCardPresentationController fadeinHandle];
                }

                [transitionContext completeTransition:YES];
                break;
        }
    }];
    
    return pa;
}

@end
