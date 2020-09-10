//
//  JFTCardConfiguration.m
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//
//  objc version for https://github.com/radianttap/CardPresentationController

#import "JFTCardConfiguration.h"

@implementation JFTCardConfiguration

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static JFTCardConfiguration *_config = nil;
    dispatch_once(&onceToken, ^{
        _config = [[JFTCardConfiguration alloc] init];
    });
    return _config;
}

- (instancetype)init {
    if (self = [super init]) {
        _verticalSpacing = 16.f;
        _verticalInset = UIApplication.sharedApplication.statusBarFrame.size.height;// TODO: fit iOS 13
        _horizontalInset = 16.f;
        _dismissAreaHeight = 16.f;
        _cornerRadius = 12.f;
        _backFadeAlpha = 0.8f;
        _allowInteractiveDismissal = YES;
    }
    return self;
}

@end
