//
//  JFTCardTransitionManager.h
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class JFTCardConfiguration;

@interface JFTCardTransitionManager : NSObject <UIViewControllerTransitioningDelegate>
- (instancetype)initWithConfiguration:(JFTCardConfiguration *)configuration;
@end

NS_ASSUME_NONNULL_END
