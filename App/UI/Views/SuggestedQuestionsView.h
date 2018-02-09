#import <UIKit/UIKit.h>
#import "ContainerView.h"
#import "HighlightViewComponent.h"

static const CGFloat SUGGESTED_QUESTION_TABLE_ROW_SEPARATOR_HEIGHT = 10.0;
//static const CGFloat SUGGESTED_QUESTION_TABLE_ROW_HORIZONTAL_PADDING = 20.0;
static const CGFloat SUGGESTED_QUESTIONS_VIEW_MAX_HEIGHT = 196.0;

@class HighlightView, Highlight;

@interface SuggestedQuestionsView : ContainerView <HighlightViewComponent, UITableViewDelegate, UITableViewDataSource, NSURLConnectionDelegate>

@property (nonatomic, weak) IBOutlet HighlightView *delegate;
@property (nonatomic, weak) IBOutlet UIView *cardView;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, weak) IBOutlet UITableView *questionsTable;
@property (nonatomic, weak) IBOutlet UIView *errorMessageView;
@property (nonatomic, weak) IBOutlet UILabel *label, *noQuestionsLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeButton;
@property (nonatomic, weak) IBOutlet UIImageView *divider;

- (id)initWithOwner:(id)owner andHighlight:(Highlight *)highlight andOrientation:(UIInterfaceOrientation)orientation;

- (IBAction)didTapCloseButton:(id)sender;
- (void)close;
- (void)show;

@end
