//  objc version for https://github.com/radianttap/CardPresentationController

#import "JFTSwipeTransitionInteractionController.h"

@interface JFTSwipeTransitionInteractionController ()
@property (nonatomic, weak) id<UIViewControllerContextTransitioning> transitionContext;
@property (nonatomic, strong, readonly) UIPanGestureRecognizer *gestureRecognizer;
@property (nonatomic) CGPoint startPoint;
@end


@implementation JFTSwipeTransitionInteractionController

- (instancetype)initWithGestureRecognizer:(UIPanGestureRecognizer *)gestureRecognizer {
    if (self = [super init]) {
        _gestureRecognizer = gestureRecognizer;
        [_gestureRecognizer addTarget:self action:@selector(gestureRecognizeDidUpdate:)];
    }
    return self;
}

- (void)startInteractiveTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.transitionContext = transitionContext;
    
    UIView *transitionContainerView = transitionContext.containerView;
    _startPoint = [self.gestureRecognizer locationInView:transitionContainerView];
    
    [super startInteractiveTransition:transitionContext];
}

- (CGFloat)percentForGesture:(UIScreenEdgePanGestureRecognizer *)gesture {
    UIView *transitionContainerView = self.transitionContext.containerView;
    
    CGPoint locationInSourceView = [gesture locationInView:transitionContainerView];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.startPoint = locationInSourceView;
    }
    
    CGFloat height = CGRectGetHeight(transitionContainerView.bounds);
    CGFloat y1 = MAX(0, fabs(self.startPoint.y - locationInSourceView.y));
    CGFloat leftHeight = MAX(0, fabs(height - self.startPoint.y));
    if (leftHeight < FLT_EPSILON) {
        return 0;
    }
    return y1 / (leftHeight);
}

- (void)gestureRecognizeDidUpdate:(UIScreenEdgePanGestureRecognizer *)gestureRecognizer {
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:{
            [self updateInteractiveTransition:[self percentForGesture:gestureRecognizer]];
        }
            break;
        case UIGestureRecognizerStateEnded: {
            if ([self percentForGesture:gestureRecognizer] >= 0.5f) {
                [self finishInteractiveTransition];
            } else {
                [self cancelInteractiveTransition];
            }
        }
            break;
        default:
            [self cancelInteractiveTransition];
            break;
    }
}

@end
