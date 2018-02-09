#import <UIKit/UIKit.h>
#import "QuestionViewDelegate.h"
#import "BackForwardNavigationViewDelegate.h"
#import "IIViewDeckController.h"
#import "ContentViewController.h"
#import "HistoryTableViewController.h"
#import "WKVerticalScrollBarCustom.h"

static const CGFloat PORTRAIT_WIDTH = 768;
static const CGFloat LANDSCAPE_WIDTH = 1024;
static const CGFloat TOOLBAR_WIDTH = 44;
static const CGFloat SCROLLBAR_WIDTH = 3;
static const CGFloat NAV_PANEL_WIDTH = 285.0f;
static const CGFloat LANDSCAPE_CONTENT_WIDTH = LANDSCAPE_WIDTH - NAV_PANEL_WIDTH - TOOLBAR_WIDTH;
static const CGFloat LANDSCAPE_CONTENT_WIDTH_forSideImage = LANDSCAPE_WIDTH ; //- TOOLBAR_WIDTH; //Archit
static const CGFloat PORTRAIT_CONTENT_WIDTH = PORTRAIT_WIDTH - TOOLBAR_WIDTH;


@class ContentViewController;
@class Highlight, Question, Book, Concept, History;

@interface ConceptViewController : UIViewController <NSURLConnectionDelegate, UIPopoverControllerDelegate, IIViewDeckControllerDelegate, BackForwardNavigationViewDelegate, QuestionViewDelegate, UIGestureRecognizerDelegate, UIAlertViewDelegate> {

}

@property (nonatomic, strong) ContentViewController *contentViewController;
//@property (nonatomic, strong) UIPopoverController *popoverController;

@property (nonatomic, weak) Book *book;
@property (nonatomic, weak) History *history;

@property (nonatomic, weak) IBOutlet UIView *contentViewContainer, *toolbar, *navigationToolbar, *textToolbar, *highlightToolbar;
@property (nonatomic, strong) IBOutlet UIToolbar *rightNavigationViewForHighlighting;
@property (nonatomic, weak) IBOutlet UILabel *labelForHighlighting;
@property (strong, nonatomic) IBOutlet UIButton *fontButton, *hiliteButton, *tocButton, *historyButton;
@property (nonatomic, weak) IBOutlet UIButton *backButton, *qaButton, *forwardButton;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImage, *toolbarNavArrow;
@property (nonatomic, weak) IBOutlet WKVerticalScrollBarCustom *scrollBar;

- (void)closePopover;
- (void)loadConceptFromTOC:(Concept *)concept;
- (void)handleRequest:(NSURLRequest *)request;
- (void)didLoadConcept:(Concept *)concept;

- (IBAction)goBack;
- (IBAction)goForward;
- (IBAction)didTapQuestionAnswerButton;
- (IBAction)didTapHighlightButton;
- (IBAction)didTapHighlightDoneButton;
- (IBAction)didTapTOCButton:(UIButton *)tocButton;
- (IBAction)didTapHistoryButton;
- (IBAction)didTapSettingsButton:(UIBarButtonItem *)settingsButton;
- (IBAction)didTapFontButton:(UIButton *)sender;
- (IBAction)didTapCancelQuestionButton;

- (void)goToReadingMode;
- (BOOL)leftNavViewIsOpen;
//- (void)dismissModalQuestionAnswerView;

- (void)showQuestionViewWithQuestion:(Question *)question;
- (void)displayAnswer:(NSString *)answerHTML toQuestion:(Question *)question;

@end
