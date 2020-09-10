//  objc version for https://github.com/radianttap/CardPresentationController

#import <UIKit/UIKit.h>

@interface JFTSwipeTransitionInteractionController : UIPercentDrivenInteractiveTransition

- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;

@end
