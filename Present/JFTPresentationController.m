//
//  JFTPresentationController.m
//  Present
//
//  Created by 於林涛 on 2020/9/8.
//  Copyright © 2020 於林涛. All rights reserved.
//

#import "JFTPresentationController.h"
#import <Masonry/Masonry.h>
#import <BlocksKit/BlocksKit.h>
#import "JFTSwipeTransitionInteractionController.h"

@interface JFTPresentationController() <UIViewControllerAnimatedTransitioning, UIGestureRecognizerDelegate>

@property (nonatomic) UIView *originViewSnapshot;

@property (nonatomic, weak) UIView *presentingView;
@property (nonatomic) UIView *topTapView;

@property (nonatomic) UIView *contentWrapperView;

@property (nonatomic) CAShapeLayer *toMaskLayer;

@property (nonatomic) UITapGestureRecognizer *tapGestureRecognizer;
@property (nonatomic) UIPanGestureRecognizer *dismissPanGestureRecognizer;

@end

@implementation JFTPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        presentedViewController.modalPresentationCapturesStatusBarAppearance = true;
        _dismissPanGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
        _dismissPanGestureRecognizer.delegate = self;
        
        _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerAction:)];
    }
    
    return self;
}

- (void)layoutMaskLayer {
    CGRect contentRect = self.contentWrapperView.bounds;
    self.toMaskLayer.frame = contentRect;
    self.contentWrapperView.layer.mask = self.toMaskLayer;
    self.toMaskLayer.path = ({
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:contentRect byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15.f, 15.f)];
        path.CGPath;
    });
    
}

- (void)preferredContentSizeDidChangeForChildContentContainer:(id<UIContentContainer>)container {
    [super preferredContentSizeDidChangeForChildContentContainer:container];
    
    if (container == self.presentedViewController) {
        [self.containerView setNeedsLayout];
    }
}

- (BOOL)shouldPresentInFullscreen {
    return NO;
}

- (CGSize)sizeForChildContentContainer:(id<UIContentContainer>)container withParentContainerSize:(CGSize)parentSize {
    if (container == self.presentedViewController) {
        return ((UIViewController*)container).preferredContentSize;
    } else {
        return [super sizeForChildContentContainer:container withParentContainerSize:parentSize];
    }
}

- (CGRect)frameOfPresentedViewInContainerView {
    CGRect containerViewBounds = self.containerView.bounds;
    CGSize presentedViewContentSize = [self sizeForChildContentContainer:self.presentedViewController withParentContainerSize:self.presentedViewController.preferredContentSize];
    
    CGRect presentedViewControllerFrame = containerViewBounds;
    presentedViewControllerFrame.size.height = presentedViewContentSize.height;
    presentedViewControllerFrame.origin.y = 0;
    return presentedViewControllerFrame;
}


#pragma mark -
#pragma mark UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return [transitionContext isAnimated] ? 0.25 : 0;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    BOOL isPresenting = (fromViewController == self.presentingViewController);
    if (isPresenting) {
        [self presentAnimateTransition:transitionContext];
    } else {
        [self dismissAnimateTransition:transitionContext];
    }
}

- (void)presentAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.contentWrapperView = [UIView new];
    self.toMaskLayer = [CAShapeLayer new];
    __weak typeof(self) weakSelf = self;
    [self.contentWrapperView bk_addObserverForKeyPaths:@[@"bounds", @"frame"] task:^(id obj, NSString *keyPath) {
        [weakSelf layoutMaskLayer];
    }];
    
    UIView *containerView = transitionContext.containerView;
    
    UIView *toView = [transitionContext viewForKey:UITransitionContextToViewKey];
    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey] ?: [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey].view;
    self.presentingView = fromView;
    UIView *snapshot = [fromView snapshotViewAfterScreenUpdates:NO];
    self.topTapView = [UIView new];
    
    self.presentingView.alpha = 0;
    
    [toView addGestureRecognizer:self.dismissPanGestureRecognizer];
    [self.topTapView addGestureRecognizer:self.tapGestureRecognizer];
    
    self.originViewSnapshot = snapshot;
    // setup originViewSnapshot with mask
    self.originViewSnapshot.clipsToBounds = YES;
    self.originViewSnapshot.layer.cornerRadius = 0;
    
    
    UIView *contentWrapperView = self.contentWrapperView;
    
    [contentWrapperView addSubview:toView];
    [containerView addSubview:snapshot];
    [containerView addSubview:self.topTapView];
    [containerView addSubview:contentWrapperView];
    
    [self.topTapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(containerView);
    }];
    
    [toView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(contentWrapperView);
    }];
    
    CGFloat const topPadding = 20.f;
    CGRect windowBounds = containerView.bounds;
    contentWrapperView.frame = CGRectMake(0, CGRectGetMaxY(windowBounds), CGRectGetWidth(windowBounds), CGRectGetHeight(windowBounds));
    [contentWrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (@available(iOS 13.0, *)) {
            make.top.equalTo(containerView.mas_safeAreaLayoutGuideTop).offset(topPadding);
        } else {
            make.top.equalTo(containerView.mas_top).offset(topPadding);
        }
        make.left.right.bottom.equalTo(containerView);
    }];
    
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        snapshot.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.9, 0.9);
        self.originViewSnapshot.layer.cornerRadius = 15;
        [containerView setNeedsLayout];
        [containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        [transitionContext completeTransition:!wasCancelled];
    }];
}

- (void)dismissAnimateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;

    UIView *fromView = [transitionContext viewForKey:UITransitionContextFromViewKey];
    UIView *contentWrapperView = self.contentWrapperView;
    [contentWrapperView addSubview:fromView];
    
    [containerView addSubview:contentWrapperView];
    
    NSTimeInterval transitionDuration = [self transitionDuration:transitionContext];
    [contentWrapperView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(containerView);
        make.top.equalTo(containerView.mas_bottom);
        make.height.equalTo(@(CGRectGetHeight(contentWrapperView.bounds)));
    }];
    
    [UIView animateWithDuration:transitionDuration animations:^{
        self.originViewSnapshot.transform = CGAffineTransformIdentity;
        self.originViewSnapshot.layer.cornerRadius = 0;
        [containerView setNeedsLayout];
        [containerView layoutIfNeeded];
    } completion:^(BOOL finished) {
        BOOL wasCancelled = [transitionContext transitionWasCancelled];
        if (!wasCancelled) {
            self.presentingView.alpha = 1;
            [self.originViewSnapshot removeFromSuperview];
            [self.topTapView removeFromSuperview];
        }
        [transitionContext completeTransition:!wasCancelled];
    }];
}

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    NSAssert(self.presentedViewController == presented, @"You didn't initialize %@ with the correct presentedViewController.  Expected %@, got %@.",
             self, presented, self.presentedViewController);
    
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self;
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    if (self.dismissPanGestureRecognizer.state != UIGestureRecognizerStatePossible) {
        return [[JFTSwipeTransitionInteractionController alloc] initWithGestureRecognizer:self.dismissPanGestureRecognizer];
    }
    
    return nil;
}


- (void)panGestureRecognizerAction:(UIScreenEdgePanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)tapGestureRecognizerAction:(UITapGestureRecognizer *)sender {
    self.dismissPanGestureRecognizer = nil;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return YES;
}

@end
