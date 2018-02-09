#import <UIKit/UIKit.h>

@protocol HighlightPaintingViewDelegate

- (void)didBeginHighlightStrokeAtPoint:(CGPoint)point;
- (void)updateHighlightStrokeAtPoint:(CGPoint)point;
- (void)didEndHighlightStrokeAtPoint:(CGPoint)point;

@end
