#import <Foundation/Foundation.h>
#import "ContainerView.h"
#import "HighlightViewDelegate.h"
#import "HighlightViewComponent.h"
#import "HighlightNotecardViewDelegate.h"

static const CGFloat HIGHLIGHT_VIEW_OVERHANG_WIDTH = 28;
static const CGFloat STACK_INCREMENT = 38;
static const CGFloat PORTRAIT_ORIGIN_X = 440 -44 +12 -3;
static const CGFloat LANDSCAPE_ORIGIN_X = 708 -44;
static const CGFloat SIZE_WIDTH = 305;

@class StickieView, SuggestedQuestionsView, Highlight, Question,
 HighlightNotecardView, HighlightToolbarView;

@interface HighlightView : ContainerView <HighlightViewComponent, HighlightNotecardViewDelegate>

@property (nonatomic, strong, readonly) Highlight *highlight;
@property (nonatomic, strong) StickieView *stickieView;
@property (nonatomic, strong) HighlightToolbarView *highlightToolbarView;
@property (nonatomic, strong) HighlightNotecardView *highlightNotecardView;
@property (nonatomic, strong) SuggestedQuestionsView *suggestedQuestionsView;
@property (nonatomic, readonly) CGFloat verticalPosition;
@property (nonatomic, weak) id<HighlightViewDelegate> delegate;

- (id)initWithHighlight:(Highlight *)highlight orientation:(UIInterfaceOrientation)orientation delegate:(id <HighlightViewDelegate>)delegate;

- (void)showSuggestedQuestions;
- (void)updateStickieViewHorizontalOffset;
- (void)scrollToOffset:(CGFloat)offset;
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)activate;
- (void)deactivate;

#pragma mark Actions
- (IBAction)didTapDelete;
- (IBAction)didTapAskToDelete;
- (IBAction)didTapNotes;
- (IBAction)didTapQuestions;
- (IBAction)didTapStickie;

#pragma mark SuggestedQuestionsView delegate
- (void)suggestedQuestionsViewDidClose;
- (void)showQuestionViewWithQuestion:(Question *)question;

@end
