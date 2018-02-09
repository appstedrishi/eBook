#import "HighlightView.h"
#import "HighlightToolbarView.h"
#import "Highlight.h"
#import "ConceptViewController.h"
#import "StickieView.h"
#import "SuggestedQuestionsView.h"
#import "HighlightNotecardView.h"
#import "Logger.h"

@interface HighlightView ()

@property (nonatomic, strong, readwrite) Highlight *highlight;
@property (nonatomic, assign) UIInterfaceOrientation orientation;

- (void)addStickieView;
- (void)addHighlightToolbarView;
- (void)addHighlightNotecardView;
- (void)addSuggestedQuestionsView;
- (void)setFrameForCurrentOrientation;
- (void)organizeSubviewsForCurrentOrientation;
- (void)adjustDropShadow;

@end

const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_X = 28;
const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_X = 28;
const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_ORIGIN_Y = -2;
const CGFloat HIGHLIGHT_FOCUSED_CARD_FRAME_ORIGIN_Y_OFFSET = 10;
const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_WIDTH = 288;
const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT = 198;

@implementation HighlightView

@synthesize stickieView = stickieView_,
highlightNotecardView = highlightNotecardView_,
highlightToolbarView = highlightToolbarView_,
suggestedQuestionsView = suggestedQuestionsView_,
highlight = highlight_,
delegate = delegate_,
orientation = orientation_;

- (id)initWithHighlight:(Highlight *)highlight orientation:(UIInterfaceOrientation)orientation delegate:(id <HighlightViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectZero]) {
        self.highlight = highlight;
        self.delegate = delegate;
        self.orientation = orientation;
        [self setFrameForCurrentOrientation];

        [self addHighlightNotecardView];
        [self addStickieView];
        [self addHighlightToolbarView];
       // [self addSuggestedQuestionsView];
        [self organizeSubviewsForCurrentOrientation];
		[self adjustDropShadow];

        self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
    }
    return self;
}


#pragma mark Public interface
- (void)showSuggestedQuestions {
    [self.delegate setActiveHighlightView:self];
	[self didTapQuestions];
}

- (void)scrollToOffset:(CGFloat)offset {
    self.frame = CGRectOffset(self.frame, 0, self.highlight.yOffset - offset - self.frame.origin.y);
}

- (CGFloat)verticalPosition {
    return self.highlight.yOffset;
}

- (BOOL)resignFirstResponder {
    return [self.highlightNotecardView resignFirstResponder];
}

#pragma mark UIView
- (void)didMoveToSuperview {
    if (!self.superview) {
        [self.highlight cancelPendingRequest];
    }
}

#pragma mark HighlightViewComponent
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
    self.orientation = orientation;
    [self setFrameForCurrentOrientation];

    for (id<HighlightViewComponent> subview in self.subviews) {
        [subview willRotateToInterfaceOrientation:self.orientation];
    }
    [self organizeSubviewsForCurrentOrientation];
	
	[self adjustDropShadow];
}

- (void)activate {
    [self.superview bringSubviewToFront:self];
	
	[self organizeSubviewsForCurrentOrientation];
	[self.subviews makeObjectsPerformSelector:@selector(activate)];
	[self organizeSubviewsForCurrentOrientation];
	[self adjustDropShadow];
	if (UIInterfaceOrientationIsPortrait(self.orientation)) {
		self.alpha = 0;
		[UIView animateWithDuration:0.25 animations:^{
			self.alpha = 1;
		}];
	} else {
		if (self.stickieView.frame.origin.x > 0) {
			// have the toolbar's sticky slide in from the real sticky's position to the usual leftmost position
			float htvXOffset = self.highlightToolbarView.toolbarImageView.frame.origin.x;
			self.highlightToolbarView.toolbarImageView.alpha = 0.25;
			self.highlightToolbarView.toolbarImageView.frame = CGRectMake(self.stickieView.frame.origin.x + htvXOffset, 
																		  self.highlightToolbarView.toolbarImageView.frame.origin.y, 
																		  self.highlightToolbarView.toolbarImageView.frame.size.width, 
																		  self.highlightToolbarView.toolbarImageView.frame.size.height);
			[UIView animateWithDuration:0.2 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
				self.highlightToolbarView.toolbarImageView.alpha = 1;
				self.highlightToolbarView.toolbarImageView.frame = CGRectMake(htvXOffset, 
																			  self.highlightToolbarView.toolbarImageView.frame.origin.y, 
																			  self.highlightToolbarView.toolbarImageView.frame.size.width, 
																			  self.highlightToolbarView.toolbarImageView.frame.size.height);
			} completion:nil];
		}
	}
    [self setFrameForCurrentOrientation];
    [Logger log:@"Viewed note card for:" withArguments:[self.highlight text]];
}

- (void)deactivate {
//	id cleanupBlock = ^{
//		[self.subviews makeObjectsPerformSelector:@selector(deactivate)];
//		[self organizeSubviewsForCurrentOrientation];
//		[self adjustDropShadow];
//		[self.delegate highlightViewDeactivated:self];
//	};
//	
//	if (UIInterfaceOrientationIsPortrait(self.orientation)) {
//		[UIView animateWithDuration:0.25 animations:^{
//			self.alpha = 0;
//		} completion:^(BOOL finished){ cleanupBlock; }];
//	} else {
//		cleanupBlock;
//    }
    BOOL viewingQuestions = self.highlightToolbarView.questionsButton.selected;
    
    [self.subviews makeObjectsPerformSelector:@selector(deactivate)];
    [self organizeSubviewsForCurrentOrientation];
    [self setFrameForCurrentOrientation];
    [self adjustDropShadow];
    [self.delegate highlightViewDeactivated:self];
    
	if (viewingQuestions) {
        [Logger log:@"Closed suggested questions (blue) card."];
	} else {
        [Logger log:@"Closed note card."];
    }
}

- (void)refresh {
	[self organizeSubviewsForCurrentOrientation];
    for (UIView <HighlightViewComponent> *view in self.subviews) {
        if ([view respondsToSelector:@selector(refresh)]) {
            [view refresh];
        }
    }
}

- (BOOL)hasVisibleCard {
    BOOL hasVisibleCard = NO;
    for (UIView <HighlightViewComponent> *subview in self.subviews) {
        hasVisibleCard = hasVisibleCard || [subview hasVisibleCard];
    }
    return hasVisibleCard;
}

- (void)updateStickieViewHorizontalOffset {
    CGFloat horizontalOffset = (UIInterfaceOrientationIsPortrait(self.orientation)) ? 0 : [self.delegate stickieViewHorizontalOffsetForHighlight:self.highlight withIncrement:STACK_INCREMENT];
    CGRect newRect = CGRectMake(horizontalOffset, self.stickieView.frame.origin.y, self.stickieView.frame.size.width, self.stickieView.frame.size.height);
    self.stickieView.frame = newRect;
}

#pragma mark Actions
- (IBAction)didTapDelete {
	[UIView animateWithDuration:0.2 animations:^{
		self.alpha = 0;
	} completion:^(BOOL finished){
		[self.delegate removeHighlight:self.highlight];
        [Logger log:@"Deleted highlight:" withArguments:[self.highlight text]];
	}];
}

- (IBAction)didTapAskToDelete {
    [self.highlightNotecardView resignFirstResponder];
    [self.highlightToolbarView confirmDeletion];
}

- (IBAction)didTapNotes {
	if (self.highlightToolbarView.questionsButton.selected) {
		self.highlightToolbarView.questionsButton.selected = NO;
        [self.suggestedQuestionsView close];
		[self.highlightToolbarView updateTabsAndShowDeleteButton:YES];
        [Logger log:@"Closed suggested questions (blue) card."];
        [Logger log:@"Viewed note card for:" withArguments:[self.highlight text]];
	}
}

- (IBAction)didTapQuestions {
	if (!self.highlightToolbarView.questionsButton.selected) {
		self.highlightToolbarView.questionsButton.selected = YES;
        [self.highlightNotecardView close];
        [self.suggestedQuestionsView show];
		[self.highlightToolbarView updateTabsAndShowDeleteButton:YES];
        [Logger log:@"Viewed suggested questions (blue card) for:" withArguments:[self.highlight text]];
	}
}

- (IBAction)didTapStickie {
    [self.delegate setActiveHighlightView:self];
}

#pragma mark HighlightNotecardViewDelegate
- (void)activateHighlight {
    [self.delegate setActiveHighlightView:self];
}

- (void)scrollToHighlight {
    [self.delegate scrollToHighlight:self];
}

- (BOOL)hasSiblingHighlights {
    return [self.delegate hasMultipleHighlightsAtHighlight:self.highlight];
}

- (CGFloat)stickieViewHorizontalOffsetWithIncrement:(CGFloat)increment andOnlyCountNotes:(BOOL)countOnlyNotes{
	return [self.delegate stickieViewHorizontalOffsetForHighlight:self.highlight withIncrement:increment andOnlyCountNotes:countOnlyNotes];
}

#pragma mark UITextViewDelegate
- (void)textViewDidBeginEditing:(UITextView *)textView {
    [Logger log:@"Started editing note card for:" withArguments:[self.highlight text]];
	[self.highlightToolbarView updateTabsAndShowDeleteButton:NO];
    [self scrollToHighlight];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.highlight.notecardText = textView.text;
    [Logger log:@"Edited note card:" withArguments:textView.text];
	[self.highlightToolbarView updateTabsAndShowDeleteButton:YES];
}

#pragma mark SuggestedQuestionsView delegate
- (void)suggestedQuestionsViewDidClose {
	[self adjustDropShadow];
}

- (void)showQuestionViewWithQuestion:(Question *)question {
    [self.delegate requestAnswerToQuestion:[NSString stringWithFormat:@"%@",question]];
}

#pragma mark Private interface
- (void)organizeSubviewsForCurrentOrientation {
    if (UIInterfaceOrientationIsPortrait(self.orientation)) {
        [self insertSubview:self.highlightNotecardView aboveSubview:self.stickieView];
    } else {
		if ([self.delegate hasMultipleHighlightsAtHighlight:self.highlight] && !self.highlightNotecardView.isActive) {
			[self insertSubview:self.highlightNotecardView aboveSubview:self.stickieView];
		} else {
			[self insertSubview:self.highlightNotecardView belowSubview:self.stickieView];
		}
    }
	[self insertSubview:self.suggestedQuestionsView aboveSubview:self.highlightNotecardView];
}

- (void)addStickieView {
    self.stickieView = [[StickieView alloc] initWithSuperview:self orientation:self.orientation highlightHeight:self.highlight.height showDropShadow:![self hasVisibleCard]];
    [self updateStickieViewHorizontalOffset];
    [self addSubview:self.stickieView];
}

- (void)addHighlightToolbarView {
    self.highlightToolbarView = [[HighlightToolbarView alloc] initWithSuperview:self highlight:self.highlight orientation:self.orientation];
    [self addSubview:self.highlightToolbarView];
}

- (void)addHighlightNotecardView {
    self.highlightNotecardView = [[HighlightNotecardView alloc] initWithHighlight:self.highlight andOrientation:self.orientation andDelegate:self];
    [self addSubview:self.highlightNotecardView];
}

- (void)addSuggestedQuestionsView {
    self.suggestedQuestionsView = [[SuggestedQuestionsView alloc] initWithOwner:self andHighlight:self.highlight andOrientation:self.orientation];
}

- (void)setFrameForCurrentOrientation {
	[self updateStickieViewHorizontalOffset];
    CGFloat x = UIInterfaceOrientationIsPortrait(self.orientation) ? PORTRAIT_ORIGIN_X : LANDSCAPE_ORIGIN_X;
    if ([self hasVisibleCard]) {
        self.frame = CGRectMake(x, self.frame.origin.y, SIZE_WIDTH, HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT + self.stickieView.frame.size.height);
    } else {
        self.frame = CGRectMake(x, self.frame.origin.y, SIZE_WIDTH, 0);
        
    }
}

- (void)adjustDropShadow {
	self.stickieView.showDropShadow = ![self hasVisibleCard] && ![self hasSiblingHighlights];
}

@end
