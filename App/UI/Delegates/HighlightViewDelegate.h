#import <UIKit/UIKit.h>

@class Highlight, HighlightView, Question;

@protocol HighlightViewDelegate

- (void)removeHighlight:(Highlight *)highlight;
- (void)scrollToHighlight:(HighlightView *)highlightView;
- (void)highlightViewDeactivated:(HighlightView *)highlightView;
- (void)setActiveHighlightView:(HighlightView *)highlightView;
- (void)requestAnswerToQuestion:(NSString *)question;
- (CGFloat)stickieViewHorizontalOffsetForHighlight:(Highlight *)highlight withIncrement:(CGFloat)increment;
- (CGFloat)stickieViewHorizontalOffsetForHighlight:(Highlight *)highlight withIncrement:(CGFloat)increment andOnlyCountNotes:(BOOL)onlyCountNotes;
- (BOOL)hasMultipleHighlightsAtHighlight:(Highlight *)highlight;

@end
