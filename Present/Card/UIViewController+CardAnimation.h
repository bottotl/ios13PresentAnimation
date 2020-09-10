//
//  UIViewController+CardAnimation.h
//  Present
//
//  Created by 於林涛 on 2020/9/10.
//  Copyright © 2020 於林涛. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (CardAnimation)
- (void)card_present:(UIViewController *)vc;
- (void)card_removeCardTransitionManager;
@end

NS_ASSUME_NONNULL_END
