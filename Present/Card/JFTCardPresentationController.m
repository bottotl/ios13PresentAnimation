//
//  JFTPresentationController.m
//  Present
//
//  Created by 於林涛 on 2020/9/8.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import "JFTCardPresentationController.h"
#import "JFTCardConfiguration.h"
#import "JFTCardPresentAnimation.h"
#import "UIViewController+CardAnimation.h"

#define let __auto_type

@interface JFTCardPresentationController() <UIGestureRecognizerDelegate>
@property (nonatomic) JFTCardConfiguration *configuration;
@property (nonatomic) UIView *handleView;
@property (nonatomic) UIButton *handleButton;
@property (nonatomic) NSLayoutConstraint *handleTopConstraint;


@property (nonatomic) UIPanGestureRecognizer *panGR;
@property (nonatomic) BOOL hasStartedPan;

@end

@implementation JFTCardPresentationController

- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration
              presentedViewController:(UIViewController *)presentedViewController
             presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        _dismissAreaHeight = 16.f;
        _configuration = configuration;
        
        presentedViewController.modalPresentationStyle = UIModalPresentationCustom;
        presentedViewController.modalPresentationCapturesStatusBarAppearance = true;
    }
    
    return self;
}

- (UIView *)handleView {
    if (!_handleView) {
        _handleView = [UIView new];
        _handleView.translatesAutoresizingMaskIntoConstraints = NO;
        _handleView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.5];
        _handleView.layer.cornerRadius = 3;
        _handleView.alpha = 0;
    }
    return _handleView;
}

- (UIButton *)handleButton {
    if (!_handleButton) {
        _handleButton = [UIButton new];
        _handleButton.translatesAutoresizingMaskIntoConstraints = NO;
        _handleButton.backgroundColor = UIColor.clearColor;
    }
    return _handleButton;
}

- (BOOL)usesDismissHandle {
    return ![self.presentedViewController isKindOfClass:UINavigationController.class];
}

#pragma mark - PresentationController

- (void)presentationTransitionWillBegin {
    [self setupDismissHandle];
    [super presentationTransitionWillBegin];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
    if (!completed) {
        return;
    }
    [self showDismissHandle];
    [self setupPanToDismiss];
}

- (void)dismissalTransitionWillBegin {
    [self fadeoutHandle];
    [super dismissalTransitionWillBegin];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    if (!completed) {
        return;
    }
    [self.sourceController card_removeCardTransitionManager];
}

#pragma mark - Public

- (void)fadeinHandle {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.handleView.alpha = 1;
        }
    }];
}

- (void)fadeoutHandle {
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.15 animations:^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf) {
            strongSelf.handleView.alpha = 0;
        }
    }];
}

#pragma mark - Internal

- (void)handleTapped {
    self.handleView.alpha = 0;
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setupDismissHandle {
    if (![self usesDismissHandle]) {
        return;
    }
    let containerView = self.containerView;
    let handleView = self.handleView;
    [containerView addSubview:self.handleView];
    [handleView.widthAnchor constraintEqualToConstant:50].active = YES;
    [handleView.heightAnchor constraintEqualToConstant:5].active = YES;
    [handleView.centerXAnchor constraintEqualToAnchor:containerView.centerXAnchor].active = YES;
    
    self.handleTopConstraint = [handleView.topAnchor constraintEqualToAnchor:containerView.topAnchor constant:10];
    self.handleTopConstraint.active = true;

    [containerView addSubview:self.handleButton];
    [self.handleButton.widthAnchor constraintEqualToAnchor:handleView.widthAnchor].active = YES;
    [self.handleButton.heightAnchor constraintEqualToAnchor:handleView.widthAnchor].active = YES;// 这个是不是原作者写错了？先照抄，有问题再说
    [self.handleButton.centerYAnchor constraintEqualToAnchor:handleView.centerYAnchor].active = YES;
    [self.handleButton.centerXAnchor constraintEqualToAnchor:handleView.centerXAnchor].active = YES;
    
    [self.handleButton addTarget:self action:@selector(handleTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showDismissHandle {
    if (![self usesDismissHandle]) {
        return;
    }
    let containerView = self.containerView;
    let handleView = self.handleView;
    let handleButton = self.handleButton;

    [containerView bringSubviewToFront:handleView];
    [containerView bringSubviewToFront:handleButton];

    //    Center dismiss handle in the (hopefully empty) area at the top of the presented card.
    //    Place in the middle of that space.
    let v = self.presentedViewController.view;
    if (v) {
        let handleCenterY = CGRectGetMinY(v.frame) + self.dismissAreaHeight / 2;
        self.handleTopConstraint.constant = handleCenterY - handleView.frame.size.height / 2;
    }

    if (handleView.superview) {
        [handleView layoutIfNeeded];
    }
    [self fadeinHandle];
}

#pragma mark - Pan to dismiss

- (void)setupPanToDismiss {
    if (!self.configuration.allowInteractiveDismissal) { return; }

    let gr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panned:)];
    gr.delegate = self;

    [self.containerView addGestureRecognizer:gr];
    self.panGR = gr;
}

- (void)panned:(UIPanGestureRecognizer *)gr {
    if (!self.containerView) { return; }

    let containerView = self.containerView;
    let verticalMove = [gr translationInView:containerView].y;
    let pct = verticalMove / containerView.bounds.size.height;
    let verticalVelocity = [gr velocityInView:containerView];

    switch (gr.state) {
        case UIGestureRecognizerStateBegan:{
            //    do not start dismiss until pan goes down
            if (verticalMove <= 0) { return; }
            //    setup flag that pan has finally started in the correct direction
            self.hasStartedPan = true;
            
            //    and reset the movement so far
            [gr setTranslation:CGPointZero inView:containerView];

            //    tell Animator that this will be interactive
            self.cardAnimator.isInteractive = true;

            //    and then initiate dismissal
            [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (!self.hasStartedPan) { return; }
            [self.cardAnimator updateInteractiveTransition:pct];
        //            handleView.alpha = max(0, 1 - pct * 4)    //    handle disappears 4x faster
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            
            if (!self.hasStartedPan) { return; }
            
            let vector = CGVectorMake(verticalVelocity.x, verticalVelocity.y);

            if (verticalVelocity.y < 0) {
                [self.cardAnimator cancelInteractiveTransition:vector];
                self.handleView.alpha = 1;

            } else if (verticalVelocity.y > 0) {
                [self.cardAnimator finishInteractiveTransition:vector];
                self.handleView.alpha = 0;

            } else {
                if (pct < 0.5) {
                    [self.cardAnimator cancelInteractiveTransition:vector];
                    self.handleView.alpha = 1;
                } else {
                    [self.cardAnimator finishInteractiveTransition:vector];
                    self.handleView.alpha = 0;
                }
            }
            self.hasStartedPan = NO;
            break;
        }
        default:
            break;
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer != self.panGR) {
        return YES;
    }
    let otherView = otherGestureRecognizer.view;
    
    
    //    allow unconditional panning if that other view is not `UIScrollView`
    if (![otherView isKindOfClass:UIScrollView.class]) {
        return YES;
    }
    
    UIScrollView *scrollView = (UIScrollView *)otherView;

    //    if it is `UIScrollView`,
    //    allow panning only if its content is at the very top
    if ((scrollView.contentOffset.y + scrollView.contentInset.top) == 0) {
        return YES;
    }

    //    otherwise, disallow pan to dismiss
    return NO;
}

@end
