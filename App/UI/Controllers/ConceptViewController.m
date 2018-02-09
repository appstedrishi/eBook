#import "ConceptViewController.h"

#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "HaloApplicationDelegate.h"
#import "NSURL+PathExtensions.h"
#import "History.h"
#import "HistoryLocation.h"
#import "TOCMainTableViewController.h"
#import "Aura.h"
#import "Logger.h"
#import "Question.h"
#import "Highlight.h"
#import "HighlightView.h"
#import "Concept.h"
#import "Book.h"
#import "History.h"
#import "NonConceptResourceViewController.h"
#import "QuestionViewController.h"
#import "QuestionHistoryTableViewController.h"
#import "TextSettingsTableViewController.h"
//#import "UIPopoverController+removeInnerShadow.h"
#import "MTStatusBarOverlay.h"
#include <ifaddrs.h>
#include <arpa/inet.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface ConceptViewController ()

- (NSURLRequest *)loadConcept:(Concept *)concept;
- (NonConceptResourceViewController *)createNonConceptResourceViewControllerForRequest:(NSURLRequest *)request;
- (QuestionViewController *)createQuestionViewControllerWithKeywords:(NSString *)keywords andQuestion:(Question *)question;
- (void)layoutContainedViewContainers;
- (BOOL)loadRequest:(NSURLRequest *)request withHistory:(BOOL)history;
- (void)showQuestionViewWithQuestion:(Question *)question andError:(NSString *)errorMsg;
- (void)cancelQuestionRequest;
- (void)configNavigationViewWidth:(CGFloat)width centerInteractivity:(IIViewDeckCenterHiddenInteractivity)interactivity;
- (void)updateNavigationViews;
- (UINavigationController *)makeTOCNavigationControllerWithLocation:(HistoryLocation *)location;
- (void)setNavControlsEnabled:(BOOL)enabled;
- (void)setUpGestureRecognizers;

@property (nonatomic, strong) Question *question;
@property (nonatomic, assign) BOOL questionViewVisible;
@property (nonatomic, strong) NSMutableString *answer;
@property (nonatomic, weak) NSURLConnection *answerQuestionConnection;
@property (nonatomic, strong) NSMutableData *answerQuestionData;
@property (nonatomic, assign) BOOL answerQuestionResponseIsSuccess;
//@property (nonatomic, weak) UIAlertView *qaProgressAlert;
@property (nonatomic, weak) UIAlertController *qaProgressAlert;
@property (nonatomic, strong) UINavigationController *settingsViewController;
@property (nonatomic, strong) IIViewDeckController *viewDeckViewController;
@property (nonatomic, assign) UIInterfaceOrientation initialInterfaceOrientation;
@property (nonatomic, weak) QuestionViewController *questionViewController ;

@end

@implementation ConceptViewController

@synthesize book = book_;
@synthesize answerQuestionConnection = answerQuestionConnection_;
@synthesize answerQuestionData = answerQuestionData_, qaProgressAlert = qaProgressAlert_;
@synthesize answerQuestionResponseIsSuccess = answerQuestionResponseIsSuccess_;
@synthesize toolbar = toolbar_, settingsViewController = settingsViewController_;
@synthesize viewDeckViewController = viewDeckViewController_, contentViewController = contentViewController_;
@synthesize navigationToolbar = navigationToolbar_, textToolbar = textToolbar_;
@synthesize rightNavigationViewForHighlighting = rightNavigationViewForHighlighting_, labelForHighlighting = _labelForHighlighting;
@synthesize backButton = backButton_, forwardButton = forwardButton_, highlightToolbar = highlightToolbar_;
@synthesize fontButton = fontButton_, hiliteButton = hiliteButton_, tocButton = tocButton_, historyButton = historyButton_;
@synthesize backgroundImage = backgroundImage_, toolbarNavArrow = toolbarNavArrow_;
@synthesize history = history_;
@synthesize  scrollBar = scrollBar_;
@synthesize questionViewVisible = questionViewVisible_;
@synthesize question = question_, answer = answer_;
@synthesize qaButton = qaButton_;

- (id)init {
    if (self = [super initWithNibName:@"ConceptViewController" bundle:nil]) {
        [self awakeFromNib];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.question = [[Question alloc] init];
    self.questionViewVisible = YES;
    self.answerQuestionData = [NSMutableData data];
}

- (void)dealloc {
    [self cancelQuestionRequest];
    self.book = nil;
    self.history = nil;
    self.scrollBar = nil;
    self.navigationToolbar = nil;
    self.textToolbar = nil;
    self.backgroundImage = nil;
    self.toolbarNavArrow = nil;
    self.qaButton = nil;
}

- (void)closePopover {
    //  [self.popoverController dismissPopoverAnimated:YES];
    //  self.popoverController = nil;
    [self.settingsViewController dismissViewControllerAnimated:YES completion:nil];
    
    [_questionViewController dismissViewControllerAnimated:YES completion:nil];
    
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.initialInterfaceOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    
    self.contentViewController = [ContentViewController contentViewControllerWithDelegate:self];
    [self.contentViewController getBoolVarForWidth:YES];
    self.toolbarNavArrow.alpha = 0;
    
    if (self.book.userHasNavigated && self.history.current) {
        // if we have history to show, create the history table, to be revealed on swipe
        HistoryTableViewController *history = [HistoryTableViewController historyTVCWithHistory:self.history book:self.book andDelegate:self];
        self.viewDeckViewController = [[IIViewDeckController alloc] initWithCenterViewController:self.contentViewController leftViewController:history];
        self.toolbarNavArrow.center = CGPointMake(self.toolbarNavArrow.center.x, self.historyButton.center.y);
    } else {
        // else create the TOC view, to be revealed on swipe
        UINavigationController *tocNavController = [self makeTOCNavigationControllerWithLocation:self.history.lastNavigatedLocation];
        self.viewDeckViewController = [[IIViewDeckController alloc] initWithCenterViewController:self.contentViewController leftViewController:tocNavController];
        self.toolbarNavArrow.center = CGPointMake(self.toolbarNavArrow.center.x, self.tocButton.center.y);
    }
    
    // tie the ViewDeck pan gesture to our background view, so the swipe works everywhere (toolbar, etc)
    self.viewDeckViewController.delegate = self;
    self.viewDeckViewController.panningView = self.contentViewContainer;
    self.viewDeckViewController.panningMode = IIViewDeckPanningViewPanning;
    
    // set the backgrounds
    self.viewDeckViewController.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg"]];
    self.toolbar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg-dark"]];
    self.highlightToolbar.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg-dark"]];
    
    // calculate explicit size for ViewDeck components and then add to the view
    CGFloat width, toolbarWidth = self.toolbar.frame.size.width;
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        width = PORTRAIT_WIDTH - toolbarWidth;
    } else { // landscape
        width = LANDSCAPE_WIDTH - toolbarWidth;
    }
    self.viewDeckViewController.view.frame = CGRectMake(toolbarWidth, 0, width, self.toolbar.frame.size.height);
    self.contentViewController.view.frame = CGRectMake(0, 0, width, self.toolbar.frame.size.height);
    [self layoutContainedViewContainers];
    [self addChildViewController:self.viewDeckViewController];
    [self.contentViewContainer insertSubview:self.viewDeckViewController.view atIndex:0];
    
    [self.scrollBar setScrollView:self.contentViewController.webView.scrollView];
    
    if (self.history.current) {
        [self loadRequest:self.history.current.request withHistory:NO];
    } else {
        [self loadConcept:self.book.initialConcept];
    }
    
    [self setUpGestureRecognizers];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    
    //    // style navigation buttons
    [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:[NSArray arrayWithObjects:[UINavigationController class], nil]] setTitleTextAttributes:@{  NSFontAttributeName : [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15]   } forState:UIControlStateNormal];
    
    // [[UIBarButtonItem appearanceWhenContainedInInstancesOfClasses:<#(nonnull NSArray<Class<UIAppearanceContainer>> *)#>]]
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self configNavigationViewWidth:NAV_PANEL_WIDTH centerInteractivity:IIViewDeckCenterHiddenUserInteractive];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self layoutContainedViewContainers];
}

#pragma mark - Actions
- (void)goBack {
    if (!self.contentViewController.loading) {
        if ([self.history canGoBack]) {
            [self.history goBack];
            
            //        if (self.webView.canGoBack) {
            //            self.backButton.enabled = [self.history canGoBack];
            //            self.forwardButton.enabled = [self.history canGoForward];
            //
            //            self.loadingConcept = [self.book conceptForPath:self.history.current.request.URL.path];
            //
            //            [self removePreviousHighlightViews];
            //            [Logger log:@"Go back to:" withArguments:self.history.current.request.URL.lastPathComponent];
            //            [self.webView goBack];
            //
            //        } else {
            [self loadRequest:[self.history current].request withHistory:NO];
            //        }
            //            [self.historyViewController refreshView];
            [self updateNavigationViews];
        }
    }
}

- (void)goForward {
    if (!self.contentViewController.loading && [self.history canGoForward]) {
        [self.history goForward];
        [self loadRequest:[self.history current].request withHistory:NO];
        //            [self.historyViewController refreshView];
        [self updateNavigationViews];
    }
}

- (void)goBack:(NSInteger)count {
    if (!self.contentViewController.loading && [self.history canGoBack]) {
        while (count > 0) {
            [self.history goBack];
            --count;
        }
        [self loadRequest:[self.history current].request withHistory:NO];
        [self closePopover];
    }
}
- (void)goForward:(NSInteger)count {
    if (!self.contentViewController.loading && [self.history canGoForward]) {
        while (count > 0) {
            [self.history goForward];
            --count;
        }
        [self loadRequest:[self.history current].request withHistory:NO];
        [self closePopover];
    }
}

- (IBAction)didTapQuestionAnswerButton {
    [self showQuestionViewWithQuestion:self.question];
}

- (IBAction)didTapHighlightDoneButton {
    [self.contentViewController goToReadingMode];
}

- (IBAction)didTapTOCButton:(UIButton *)tocButton {
    
    if (!self.contentViewController.loading) {
        BOOL opened = YES;
        if (![self.viewDeckViewController.leftController isKindOfClass:[UINavigationController class]]) {
            UINavigationController *tocNavController = [self makeTOCNavigationControllerWithLocation:self.history.lastNavigatedLocation];
            [self.viewDeckViewController setLeftController:tocNavController];
            [self configNavigationViewWidth:NAV_PANEL_WIDTH centerInteractivity:IIViewDeckCenterHiddenUserInteractive];
            [self.viewDeckViewController openLeftView];
        } else {
            if ([self.viewDeckViewController isSideClosed:IIViewDeckLeftSide]) {
                [self.viewDeckViewController openLeftView];
            } else {
                UINavigationController *tocNavController = (UINavigationController *)self.viewDeckViewController.leftController;
                if ([tocNavController.topViewController isKindOfClass:[TOCMainTableViewController class]]) {
                    // at the root, so close
                    [self.viewDeckViewController closeLeftView];
                } else {
                    [tocNavController popToRootViewControllerAnimated:YES];
                }
                opened = NO;
            }
        }
        if (opened) [UIView animateWithDuration:0.2 animations:^{
            self.toolbarNavArrow.alpha = 1;
            self.toolbarNavArrow.center = CGPointMake(self.toolbarNavArrow.center.x, self.tocButton.center.y);
        }];
    }
}

- (IBAction)didTapHistoryButton {
    if (!self.contentViewController.loading) {
        BOOL opened = YES;
        if (![self.viewDeckViewController.leftController isKindOfClass:[HistoryTableViewController class]]) {
            HistoryTableViewController *history = [HistoryTableViewController historyTVCWithHistory:self.history book:self.book andDelegate:self];
            [self.viewDeckViewController setLeftController:history];
            [self configNavigationViewWidth:NAV_PANEL_WIDTH centerInteractivity:IIViewDeckCenterHiddenUserInteractive];
            [self.viewDeckViewController openLeftView];
        } else {
            if ([self.viewDeckViewController isSideClosed:IIViewDeckLeftSide]) {
                [self.viewDeckViewController openLeftView];
            } else {
                [self.viewDeckViewController closeLeftView];
                opened = NO;
            }
        }
        if (opened) [UIView animateWithDuration:0.2 animations:^{
            self.toolbarNavArrow.alpha = 1;
            self.toolbarNavArrow.center = CGPointMake(self.toolbarNavArrow.center.x, self.historyButton.center.y);
        }];
    }
}

- (IBAction)didTapSettingsButton:(UIBarButtonItem *)settingsButton {
}

- (IBAction)didTapFontButton:(UIButton *)sender {
    if (!self.settingsViewController) {
        UIStoryboard *settingsStoryboard = [UIStoryboard storyboardWithName:@"TextSettingsView" bundle:nil];
        self.settingsViewController = [settingsStoryboard instantiateInitialViewController];
        if ([self.settingsViewController isKindOfClass:[TextSettingsTableViewController class]]) {
            TextSettingsTableViewController *tstvc = (TextSettingsTableViewController *)self.settingsViewController;
            tstvc.theContent = self.contentViewController;
            tstvc.delegate = self;
        }
    }
    
    //    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:self.settingsViewController];
    //    self.popoverController.delegate = self;
    //    [self.popoverController presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
    //    self.popoverController.passthroughViews = nil;
    self.settingsViewController.modalPresentationStyle                   = UIModalPresentationPopover;
    self.settingsViewController.popoverPresentationController.sourceView = sender;//self.view;
    self.settingsViewController.popoverPresentationController.sourceRect = CGRectMake(0, 1, 40, 44);//self.qaButton.frame;
    [self presentViewController:self.settingsViewController animated:YES completion:nil];
    
    
}

- (void)didTapCancelQuestionButton {
    [self showQuestionAnsweringOverlay:NO];
    [self cancelQuestionRequest];
    [Logger log:@"Cancelled question:" withArguments:self.question.text];
}

#pragma mark - UIPopoverControllerDelegate
// This is not called when -dismissPopoverAnimated: is called directly.
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
//    self.popoverController = nil;
//}

#pragma mark IIViewDeckControllerDelegate

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didOpenViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide) {
        if(animated) [viewDeckController.leftController viewDidAppear:animated];
        
        //    [self.contentViewController leftViewDidOpen];
        
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbarNavArrow.alpha = 1;
        }];
        
        if (self.contentViewController.activeHighlightView) {
            [self.contentViewController.activeHighlightView resignFirstResponder];
        }
        
        //        if (viewDeckController.centerhiddenInteractivity == IIViewDeckCenterHiddenNotUserInteractiveWithTapToClose) {
        //            // todo: dim view somehow?
        //        }
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didCloseViewSide:(IIViewDeckSide)viewDeckSide animated:(BOOL)animated {
    if (viewDeckSide == IIViewDeckLeftSide) {
        [UIView animateWithDuration:0.2 animations:^{
            self.toolbarNavArrow.alpha = 0;
        }];
        [viewDeckController.leftController viewWillDisappear:animated];
    }
}

- (void)viewDeckController:(IIViewDeckController *)viewDeckController didChangeOffset:(CGFloat)offset orientation:(IIViewDeckOffsetOrientation)orientation panning:(BOOL)panning {
    //    CGFloat percentComplete =  MIN ( MAX ( offset / NAV_PANEL_WIDTH, 0), 1);
    //    [self.contentViewController highlightViewOpacity:1.0f - percentComplete];
    //    self.toolbarNavArrow.alpha = percentComplete;
    
    if (offset >= NAV_PANEL_WIDTH) {
        [self.contentViewController leftViewDidOpen];
    } else if ( offset <= 10) {
        [self.contentViewController leftViewDidClose];
    } else {
        // mid-swipe
        [self.contentViewController leftViewIsPanning];
    }
}

// applies a small, gray shadow
- (void)viewDeckController:(IIViewDeckController *)viewDeckController applyShadow:(CALayer *)shadowLayer withBounds:(CGRect)rect {
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowRadius = 3;
    shadowLayer.shadowOpacity = 0.75;
    shadowLayer.shadowColor = [[UIColor darkGrayColor] CGColor];
    shadowLayer.shadowOffset = CGSizeZero;
    shadowLayer.shadowPath = [[UIBezierPath bezierPathWithRect:rect] CGPath];
}

- (BOOL)leftNavViewIsOpen {
    return [self.viewDeckController isSideOpen:IIViewDeckLeftSide];
}

#pragma mark QuestionViewDelegate
- (void)addQuestionToQuestionHistory:(Question *)question {
    [self.history pushQuestion:[question copy]];
}
- (void)dismissModalQuestionAnswerView
{
    [_questionViewController dismissViewControllerAnimated:NO completion:nil];
    [self.viewDeckViewController closeLeftView];
    
}
- (void)dismissModalQuestionAnswerView:(BOOL)var {
    
    
    [_questionViewController dismissViewControllerAnimated:NO completion:nil];
    [self.viewDeckViewController closeLeftView];
}

- (void)dismissModalQuestionAnswerViewAndLoadRequest:(NSURLRequest *)request {
    [self dismissModalQuestionAnswerView:YES];
    [self handleRequest:request];
}

- (NSArray *)conceptList {
    return self.book.glossaryConcepts;
}

- (UIDeviceOrientation)orientation {
    
    return [[UIDevice currentDevice] orientation];
}

#pragma mark Modes

- (IBAction)didTapHighlightButton {
    if (!self.contentViewController.loading) {
        
        //        // show instructions in status bar
        //        MTStatusBarOverlay *overlay = [MTStatusBarOverlay sharedInstance];
        //        overlay.animation = MTStatusBarOverlayAnimationNone;
        //        overlay.hidesActivity = YES;
        //        [overlay postMessage:@"Tap and hold on a word, then drag your finger to highlight. Lift your finger to complete the highlight." animated:NO];
        
        // config toolbar (todo: improve this someday)
        self.highlightToolbar.alpha = 0;
        self.highlightToolbar.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.navigationToolbar.alpha = 0;
            self.textToolbar.alpha = 0;
            self.highlightToolbar.alpha = 1;
        } completion:^(BOOL finished) {
            self.navigationToolbar.hidden = YES;
            self.textToolbar.hidden = YES;
        }];
        [self.highlightToolbar.superview bringSubviewToFront:self.highlightToolbar];
        
        self.viewDeckViewController.leftController.view.userInteractionEnabled = NO;
        self.viewDeckViewController.panningMode = IIViewDeckNoPanning;
        
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
            [self.viewDeckViewController closeLeftView];
        }
        
        [self.contentViewController goToHighlightMode];
    }
}

- (void)goToReadingMode {
    self.navigationToolbar.hidden = NO;
    self.textToolbar.hidden = NO;
    [UIView animateWithDuration:0.1 animations:^{
        self.navigationToolbar.alpha = 1;
        self.textToolbar.alpha = 1;
        self.highlightToolbar.alpha = 0;
    } completion:^(BOOL finished) {
        self.highlightToolbar.hidden = YES;
    }];
    self.viewDeckViewController.panningMode = IIViewDeckPanningViewPanning;
    self.viewDeckViewController.leftController.view.userInteractionEnabled = YES;
    
    if (self.contentViewController.activeHighlightView) {
        [self.viewDeckViewController closeLeftViewAnimated:YES];
    }
    
    [[MTStatusBarOverlay sharedInstance] hide];
}

- (void)showQuestionViewWithQuestion:(Question *)question {
    [self showQuestionViewWithQuestion:question andError:nil];
}

- (void)showQuestionViewWithQuestion:(Question *)question andError:(NSString *)errorMsg {
    if (!errorMsg) {
        [Logger log:@"Opened question/answer panel"]; // don't log errors (?)
    } else {
        question.feedback = errorMsg;
    }
    
    NSString *keywords = [self.contentViewController stringByEvaluatingJavaScriptFromString:@"$('.content-summary, h1').text();"];
    
    _questionViewController = [self createQuestionViewControllerWithKeywords:keywords andQuestion:question];
    //    self.popoverController = [[UIPopoverController alloc] initWithContentViewController:questionViewController];
    //    self.popoverController.delegate = self;
    //    [self.popoverController presentPopoverFromRect:CGRectMake(0, 1, 40, 44)
    //                                            inView:self.qaButton
    //                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    //    self.popoverController.passthroughViews = nil;
    
    _questionViewController.modalPresentationStyle                   = UIModalPresentationPopover;
    
    _questionViewController.popoverPresentationController.sourceView = self.qaButton;//self.view;
    _questionViewController.popoverPresentationController.sourceRect = CGRectMake(0, 3, 40, 44);//self.qaButton.frame;
    _questionViewController.popoverPresentationController.permittedArrowDirections=UIPopoverArrowDirectionLeft;
    //_questionViewController.view.frame = CGRectMake(0, 0, 200, 400);
    _questionViewController.popoverPresentationController.popoverLayoutMargins=UIEdgeInsetsMake(100, 100, 0,0);
    [self presentViewController:_questionViewController animated:YES completion:nil];
}

- (void)setNavControlsEnabled:(BOOL)enabled {
    BOOL isAnswer = self.book.currentConceptIsAnswer,
    isGlossary = self.book.currentConceptIsInGlossary;
    
    self.backButton.enabled = enabled && self.history.canGoBack;
    self.hiliteButton.enabled = enabled && !isAnswer && !isGlossary;
    self.fontButton.enabled = enabled && !isAnswer && !isGlossary;
    self.scrollBar.enabled = enabled && !isAnswer && !isGlossary;
    
    self.tocButton.enabled = enabled;
    self.historyButton.enabled = enabled;
    self.qaButton.enabled = enabled;
    BOOL boolVAr=enabled && !isAnswer && !isGlossary;
    [self.contentViewController getBoolVarForWidth:boolVAr];
    [self.contentViewController layOutWebViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    if (enabled) {
        //        self.viewDeckViewController.panningMode = IIViewDeckFullViewPanning;
        self.viewDeckViewController.leftController.view.userInteractionEnabled = YES;
        
        
        
    } else {
        //        self.viewDeckViewController.panningMode = IIViewDeckNoPanning;
        self.viewDeckViewController.leftController.view.userInteractionEnabled = NO;
        
    }
}

#pragma mark Navigation

- (void)loadConceptFromTOC:(Concept *)concept {
    NSURLRequest *request = [self loadConcept:concept];
    self.history.lastNavigatedLocation = [HistoryLocation locationForRequest:request andScrollOffset:0];
}

- (NSURLRequest *)loadConcept:(Concept *)concept {
    NSURL *url = [[NSURL alloc] initFileURLWithPath:concept.path];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    [self loadRequest:request withHistory:YES];
    return request;
}

- (void)handleRequest:(NSURLRequest *)request {
    if ([request.URL.scheme isEqualToString:@"file"]) {
        [self loadRequest:request withHistory:YES];
    } else if ([request.URL.scheme isEqualToString:@"put"]) {
        [self.contentViewController dispatchRequest:request];
    } else if ([request.URL.scheme isEqualToString:@"question"]) {
        [self requestAnswerToQuestion:request.URL.host];
        [Logger log:@"Asked question (SQ link):" withArguments:request.URL.host];
    } else {
        // unhandled type, such as HTTP, so bump it out to Safari
        [[UIApplication sharedApplication] openURL:[request URL]];
    }
}

- (void)didLoadConcept:(Concept *)concept {
    //    self.book.currentConcept = concept; // this is now done in content view controller (!)
    [self setNavControlsEnabled:YES];
    
    if ([self.viewDeckViewController isSideOpen:IIViewDeckLeftSide]) {
        //        [self.contentViewController highlightViewOpacity:0];
        [self.contentViewController leftViewDidOpen];
    } else {
        [self.contentViewController leftViewDidClose];
    }
    
    self.settingsViewController = nil;
}

- (void)dismissNavigationView {
    [self.viewDeckViewController closeLeftViewAnimated:YES];
}

#pragma mark Private interface

- (BOOL)loadRequest:(NSURLRequest *)request withHistory:(BOOL)history {
    Concept *concept = [self.book conceptForPath:request.URL.path];
    if (concept) {
        // load page (known concept)
        NSURL *url = [[request URL] absoluteURLWithoutFragment];
        NSURLRequest *newRequest = [[NSURLRequest alloc] initWithURL:url];
        
        if (history) {
            [self.history push:newRequest];
        }
        self.backButton.enabled = [self.history canGoBack];
        self.scrollBar.enabled = NO;
        
        [self.contentViewController loadConcept:concept withRequest:request];
        [self updateNavigationViews];
        
        if ([self.book conceptIsAnswer:concept]) {
            [Logger log:@"Open answer page:" withArguments:[[url lastPathComponent] stringByDeletingPathExtension]];
        } else if ([self.book conceptIsInGlossary:concept]) {
            [Logger log:@"Open glossary page:" withArguments:[[url lastPathComponent] stringByDeletingPathExtension]];
        } else {
            [Logger log:@"Open page:" withArguments:[[url lastPathComponent] stringByDeletingPathExtension]];
        }
        return YES;
    } else {
        // load image or c-map or whatever (unknown page)
        NSURL *url = [[request URL] absoluteURLWithoutFragment];
        [Logger log:@"Open image/cmap:" withArguments:[[url lastPathComponent] stringByDeletingPathExtension]];
        
        UIViewController *controller = [self createNonConceptResourceViewControllerForRequest:request];
        controller.modalPresentationStyle = UIModalPresentationFullScreen;
        controller.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        if (self.presentedViewController) {
            [self.presentedViewController presentViewController:controller animated:YES completion:nil];
            return NO;
        } else {
            [self presentViewController:controller animated:YES completion:nil];
        }
        return YES;
    }
    return NO;
}

- (void)updateNavigationViews {
    if ([self.viewDeckViewController.leftController isKindOfClass:[HistoryTableViewController class]]) {
        HistoryTableViewController *history = (HistoryTableViewController *)self.viewDeckViewController.leftController;
        [history refreshView];
    } else if ([self.viewDeckViewController.leftController isKindOfClass:[UINavigationController class]]) {
        if ([self.viewDeckViewController isSideClosed:IIViewDeckLeftSide] && self.history.lastNavigatedLocation) {
            TOCMainTableViewController *toc = (TOCMainTableViewController *) [((UINavigationController *)self.viewDeckViewController.leftController).viewControllers objectAtIndex:0];
            [toc navigateListToConcept:[self.book conceptForRequest:self.history.lastNavigatedLocation.request]];
        }
    } else {
        // do nothing, for now
    }
}

- (void)configNavigationViewWidth:(CGFloat)width centerInteractivity:(IIViewDeckCenterHiddenInteractivity)interactivity {
    self.viewDeckViewController.leftController.view.frame = CGRectMake(0, 0, width, self.toolbar.frame.size.height);
    self.viewDeckViewController.leftController.view.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    //    self.viewDeckViewController.centerhiddenInteractivity = interactivity;
    [self layoutContainedViewContainers];
}

- (void)layoutContainedViewContainers {
    CGFloat width, toolbarWidth = self.toolbar.frame.size.width, ledgeWidth = 286;//self.viewDeckViewController.leftController.view.frame.size.width;
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        width = PORTRAIT_WIDTH - toolbarWidth;
    } else { // landscape
        width = LANDSCAPE_WIDTH - toolbarWidth;
    }
    
    if (UIInterfaceOrientationIsLandscape(self.initialInterfaceOrientation) && !SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        [self.viewDeckViewController setLeftSize: width - ledgeWidth + 276 -20]; //HACK!!
    } else {
        [self.viewDeckViewController setLeftSize: width - ledgeWidth];
    }
    //    [self.viewDeckViewController setLeftSize: ledgeWidth + 20];
}

- (NonConceptResourceViewController *)createNonConceptResourceViewControllerForRequest:(NSURLRequest *)request {
    return [[NonConceptResourceViewController alloc] initWithRequest:request andDelegate:self];
}

- (QuestionViewController *)createQuestionViewControllerWithKeywords:(NSString *)keywords andQuestion:(Question *)question {
    //    return [[[QuestionViewController alloc] initWithKeywords:keywords question:question delegate:self] autorelease];
    return [[QuestionViewController alloc] initWithKeywords:keywords question:question delegate:self];
}

- (UINavigationController *)makeTOCNavigationControllerWithLocation:(HistoryLocation *)location {
    TOCMainTableViewController *toc = [[TOCMainTableViewController alloc] initWithBook:self.book andDelegate:self];
    UINavigationController *tocNavController = [[UINavigationController alloc] initWithRootViewController:toc];
    
    tocNavController.navigationBar.tintColor = [UIColor whiteColor];// [UIColor colorWithRed:0.302 green:0.314 blue:0.341 alpha:1.000];
    [tocNavController.navigationBar setBackgroundImage:[UIImage imageNamed:@"tocToolbar"] forBarMetrics:UIBarMetricsDefault];
    [tocNavController.navigationBar setShadowImage:[[UIImage alloc] init]]; // iOS 6 only
    //    [tocNavController.navigationBar setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
    tocNavController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                          [UIColor whiteColor], NSForegroundColorAttributeName,
                                                          //        [UIColor colorWithWhite:0.0 alpha:0.6], UITextAttributeTextShadowColor,
                                                          //        [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
                                                          //        [UIFont boldSystemFontOfSize:16.0], NSFontAttributeName,
                                                          nil];
    
    if (location) {
        [toc navigateListToConcept:[self.book conceptForRequest:location.request]];
    }
    return tocNavController;
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    self.scrollBar.enabled = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
}

- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    self.scrollBar.enabled = YES;
}


#pragma mark Gesture recognizers
- (void)setUpGestureRecognizers {
    // long-press QA button to show question history
    UILongPressGestureRecognizer *qaButtonLongPressRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleQaButtonLongPress:)];
    qaButtonLongPressRecognizer.delegate = self;
    [self.qaButton addGestureRecognizer:qaButtonLongPressRecognizer];
}

- (void)handleQaButtonLongPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        QuestionHistoryTableViewController *historyTable = [[QuestionHistoryTableViewController alloc] init];
        historyTable.delegate = self;
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:historyTable];
        
        
        
        
        //        self.popoverController = [[UIPopoverController alloc] initWithContentViewController:nc];
        //        self.popoverController.delegate = self;
        //        self.popoverController.passthroughViews = nil;
        //        [self.popoverController presentPopoverFromRect:self.qaButton.frame inView:self.qaButton.superview permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
        
        
        
        nc.modalPresentationStyle                   = UIModalPresentationPopover;
        nc.popoverPresentationController.sourceView = self.qaButton;
        nc.popoverPresentationController.sourceRect = CGRectMake(0, 1, 40, 44);//self.qaButton.frame;
        [self presentViewController:nc animated:YES completion:nil];
    }
}

#pragma mark NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (connection == self.answerQuestionConnection) {
        self.answerQuestionResponseIsSuccess = [(id)response statusCode] == 200;
        [self.answerQuestionData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if (connection == self.answerQuestionConnection) {
        [self.answerQuestionData appendData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if (connection == self.answerQuestionConnection) { // this was an answer-question connection
        //        [self.qaProgressAlert dismissWithClickedButtonIndex:1 animated:YES];
        //        self.qaProgressAlert = nil;
        
        NSString *response = [[NSString alloc] initWithData:self.answerQuestionData encoding:NSUTF8StringEncoding];
        if (self.answerQuestionResponseIsSuccess) {
            // successful answer, show answer
            if (self.question && self.question.text.length) {
                [Logger log:@"Answered question:" withArguments:self.question.text];
                [self displayAnswer:response toQuestion:self.question];
                [self addQuestionToQuestionHistory:self.question];
                [self.question clear];
            }
        } else {
            // answer failed, show reason and show suggestions
            [self showQuestionAnsweringOverlay:NO];
            [self showQuestionViewWithQuestion:self.question andError:response];
            [Logger log:@"Failed to answer question:" withArguments:self.question.text];
        }
        [self cancelQuestionRequest];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    if (connection == self.answerQuestionConnection) {
        [self showQuestionAnsweringOverlay:NO];
        
        NSString *msg = [error localizedDescription];
        if (error.code == NSURLErrorTimedOut) {
            msg = [msg stringByAppendingString:@"\n\nSome answers are slow the first time you ask. Try asking again."];
        }
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:msg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        //        [alert show];
        
        UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Connection error"  message:msg  preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }]];
        [self presentViewController:alertController animated:YES completion:nil];
        
        
        [self cancelQuestionRequest];
    }
}
-(void)showConectionError:(NSString *)error
{
    [self showQuestionAnsweringOverlay:NO];
    
    NSString *msg = error;
    msg = [msg stringByAppendingString:@"\n\nSome answers are slow the first time you ask. Try asking again."];
    
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Connection error"  message:msg  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
    
    
    [self cancelQuestionRequest];
    
    
}
#pragma mark Questions and Answers

- (void)requestAnswerToQuestion:(NSString *)question {
    [self dismissModalQuestionAnswerView];
    //  [self performSelectorOnMainThread:@selector(dismissModalQuestionAnswerView:) withObject:nil waitUntilDone:YES];
    [self.question clear];
    self.question.text = question;
    
    // first, see if the "question" is just the name of a glossary page concept
    question = [[question stringByReplacingOccurrencesOfString:@"define" withString:@""]
                stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSPredicate *startsWithPredicate = [NSPredicate predicateWithFormat: @"(SELF.title beginswith[cd] %@)", question];
    NSArray *filteredGlossary = [self.conceptList filteredArrayUsingPredicate:startsWithPredicate];
    if (filteredGlossary.count > 0) {
        // if so, load the glossary page from disk
        [self loadConcept:[filteredGlossary objectAtIndex:0]];
    } else {
        // otherwise, send the question to the server
        // self.answerQuestionConnection = [[Aura aura] answerQuestion:question withDelegate:self];
        //  [self showQuestionAnsweringOverlay:YES]; //XT test
        [self showQuestionAnsweringOverlay:YES];
        [[Aura aura] answerQuestionForQ:question completionHandler:^(BOOL var,NSString *message,NSData *data)
         {
             if (var) {
                 
                 [self.answerQuestionData setLength:0];
                 [self.answerQuestionData appendData:data];
                 NSString *response = [[NSString alloc] initWithData:self.answerQuestionData encoding:NSUTF8StringEncoding];
                 dispatch_async (dispatch_get_main_queue(), ^{
                     
                     [self setWebView:response];
                 });
             }
             else
             {
                 dispatch_async (dispatch_get_main_queue(), ^{
                     
                     [self showConectionError:message];
                 });
                 
             }
             
             
         }];
        
        
        
    }
}
-(void)setWebView:(NSString*)response
{
    
    // successful answer, show answer
    
    if (response.length>0) {
        
        if (self.question && self.question.text.length) {
            [Logger log:@"Answered question:" withArguments:self.question.text];
            [self displayAnswer:response toQuestion:self.question];
            [self addQuestionToQuestionHistory:self.question];
            [self.question clear];
        }
        else {
            // answer failed, show reason and show suggestions
            [self showQuestionAnsweringOverlay:NO];
            [self showQuestionViewWithQuestion:self.question andError:response];
            [Logger log:@"Failed to answer question:" withArguments:self.question.text];
        }
    }
    else {
        // answer failed, show reason and show suggestions
        [self showQuestionAnsweringOverlay:NO];
        [self showQuestionViewWithQuestion:self.question andError:response];
        [Logger log:@"Failed to answer question:" withArguments:self.question.text];
    }
    [self cancelQuestionRequest];
    //[self showQuestionAnsweringOverlay:YES];
}
- (void)showQuestionAnsweringOverlay:(BOOL)show {
    [self setNavControlsEnabled:!show];
    
    [self.contentViewController showAnswerOverlay:show withText:self.question.text animated:YES];
    
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation])) {
        [self.viewDeckViewController closeLeftView];
    }
}

// TODO: put this into NSURLConnection connectionDidTerminate/Finish/Complete/whatever
- (void)cancelQuestionRequest {
    [self.answerQuestionConnection cancel];
    [self.answerQuestionData setLength:0];
    self.answerQuestionConnection = nil;
}

- (void)displayAnswer:(NSString *)answerHTML toQuestion:(Question *)question {
    
    [self dismissModalQuestionAnswerView:YES];
    [self closePopover];
    
    // 1. read in boilerplate
    NSError* error = nil;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"answers" ofType:@"html" inDirectory:@"textbook/html"];
    NSString *boilerplateHTML = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error: &error];
    
    NSURL *resourceUrl = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/textbook/", [NSBundle mainBundle].bundlePath]];
    
    // 2. insert answerHTML into boilerplateHTML and fix links
    answerHTML = [boilerplateHTML stringByReplacingOccurrencesOfString:@"<!--replaceme-->" withString:answerHTML];
    answerHTML = [answerHTML stringByReplacingOccurrencesOfString:@"../" withString:resourceUrl.absoluteString];
    
    // 3. write new file to disk
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"answers"];
    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:&error];
    NSCharacterSet* illegalFileNameCharacters = [NSCharacterSet characterSetWithCharactersInString:@"\\?%* /|\"<>:"];
    NSString *fileNameString = [[question.text componentsSeparatedByCharactersInSet:illegalFileNameCharacters] componentsJoinedByString:@"-"];
    NSString *filepath = [documentsDirectory stringByAppendingPathComponent:[fileNameString stringByAppendingPathExtension:@"html"]];
    [answerHTML writeToFile:filepath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    // 4. save and load concept
    if (!error) {
        Concept *answerConcept = [Concept conceptWithTitle:question.text path:filepath];
        [self.book addConcept:answerConcept];
        [self loadConcept:answerConcept];
    } else {
        NSLog(@"ERROR: %@", error);
    }
}

@end
