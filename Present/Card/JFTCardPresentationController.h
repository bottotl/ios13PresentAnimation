//
//  JFTPresentationController.h
//  Present
//
//  Created by 於林涛 on 2020/9/8.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFTCardPresentAnimation;
@class JFTCardConfiguration;

@interface JFTCardPresentationController : UIPresentationController

- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration
              presentedViewController:(UIViewController *)presentedViewController
             presentingViewController:(UIViewController *)presentingViewController NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController
                       presentingViewController:(nullable UIViewController *)presentingViewController NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic, weak) UIViewController *sourceController;
@property (nonatomic, weak) JFTCardPresentAnimation *cardAnimator;
@property (nonatomic) CGFloat dismissAreaHeight;

- (void)fadeinHandle;
- (void)fadeoutHandle;

@end

NS_ASSUME_NONNULL_END
