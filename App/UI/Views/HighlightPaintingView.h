#import <UIKit/UIKit.h>

@protocol HighlightPaintingViewDelegate;

@interface HighlightPaintingView : UIView

- (id)initWithFrame:(CGRect)frame andDelegate:(id <HighlightPaintingViewDelegate>)delegate;

- (void)startHighlightAtPoint:(CGPoint)touch;
- (void)continueHighlightAtPoint:(CGPoint)touch;
- (void)endHighlightAtPoint:(CGPoint)touch;

@end
