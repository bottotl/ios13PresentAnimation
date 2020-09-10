//
//  JFTCardConfiguration.h
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface JFTCardConfiguration : NSObject

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

@property (nonatomic) CGFloat verticalSpacing;
@property (nonatomic) CGFloat verticalInset;
@property (nonatomic) CGFloat horizontalInset;
@property (nonatomic) CGFloat dismissAreaHeight;
@property (nonatomic) CGFloat cornerRadius;
@property (nonatomic) CGRect initialTransitionFrame;
@property (nonatomic) CGFloat backFadeAlpha;
@property (nonatomic) CGFloat allowInteractiveDismissal;


@end

NS_ASSUME_NONNULL_END
