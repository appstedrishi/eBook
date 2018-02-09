#import <UIKit/UIKit.h>

@protocol HighlightNotecardViewDelegate <UITextViewDelegate>

- (void)activateHighlight;
- (void)scrollToHighlight;
- (BOOL)hasSiblingHighlights;
- (CGFloat)stickieViewHorizontalOffsetWithIncrement:(CGFloat)increment andOnlyCountNotes:(BOOL)countOnlyNotes;

@end
