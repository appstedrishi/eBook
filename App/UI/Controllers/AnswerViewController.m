#import "AnswerViewController.h"
#import "AnswerViewDelegate.h"
#import "HaloApplicationDelegate.h"
#import "QuestionAnswerRightBarButtonItemToolbarView.h"
#import "UIWebView+StylingExtensions.h"
#import "Aura.h"
#import "Question.h"
#import "Logger.h"

@interface AnswerViewController ()

@property (nonatomic, assign) id<AnswerViewDelegate> delegate;
@property (nonatomic, assign) BOOL documentIsReady;
@property (nonatomic, retain) NSMutableString *answer;

//- (NSString *)boilerplateHTML;
- (void)didTapCloseButton;
- (void)didTapNewQuestion;
- (void)didTapBackButton;
- (void)loadBoilerplate;
- (void)createOverlay;
- (NSString *)cleanStringForJavascript:(NSString *)string;
- (void)displayAnswer:(NSString *)html andIsFirstRun:(BOOL)firstRun;

@end

@implementation AnswerViewController

@synthesize webView = webView_, delegate = delegate_, documentIsReady = documentIsReady_, answer = answer_, 
questionRequestPendingOverlayView = questionRequestPendingOverlayView_;

- (id)initWithHTML:(NSMutableString *)html andDelegate:(id<AnswerViewDelegate>)delegate {
    if (self = [super init]) {
        self.delegate = delegate;
        self.answer = html;

        // This prevents the view controller from taking the status bar size into account when calculating its bounds.
        self.wantsFullScreenLayout = YES;
        self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
		self.webView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
        self.webView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
        self.webView.delegate = self;
        
        UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        backButton.frame = CGRectMake(0, 0, 44, 66);
        [backButton addTarget:self action:@selector(didTapBackButton) forControlEvents:UIControlEventTouchUpInside];
        [backButton setImage:[UIImage imageNamed:@"WebBack.png"] forState:UIControlStateNormal];
        backButton.showsTouchWhenHighlighted = YES;
        [self.webView.scrollView addSubview:backButton];

        [self loadBoilerplate];
        [self.view addSubview:self.webView];
		
		if (self.answer.length == 0) {
			[self createOverlay];
			[self.view addSubview:self.questionRequestPendingOverlayView];
		}
    }
    return self;
}

- (void)dealloc {
    self.answer = nil;
    self.webView.backgroundColor = nil;
    self.webView = nil;
	self.questionRequestPendingOverlayView = nil;
    [super dealloc];
}

- (void)displayAnswer:(NSString *)html {	
	[self displayAnswer:html andIsFirstRun:NO];
    [Logger log:@"Answered question:" withArguments:[self.delegate.question text]];
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.contentSizeForViewInPopover = CGSizeMake(768, HEIGHT_IN_POPOVER*2);;//CGSizeMake(WIDTH_IN_POPOVER, HEIGHT_IN_POPOVER*2);
    self.contentSizeForViewInPopover = CGSizeMake(WIDTH_IN_POPOVER, HEIGHT_IN_POPOVER);

    //self.navigationItem.rightBarButtonItem = [[[QuestionAnswerRightBarButtonItemToolbarView alloc] initWithTarget:self] autorelease];
    self.navigationController.navigationBar.backItem.title = @"Ask a Question";
    self.navigationItem.title = @"Answer";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                               style:UIBarButtonItemStyleDone
                                                                              target:self
                                                                              action:@selector(didTapCloseButton)] autorelease];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    if (navigationType != UIWebViewNavigationTypeLinkClicked) {
        return YES;
    }

    if ([request.URL.scheme isEqualToString:@"webviewready"]) {
        self.documentIsReady = YES;
		if (self.answer.length) {
			// if we have an answer, show it
			[self displayAnswer:self.answer andIsFirstRun:YES];
            [Logger log:@"Answered question:" withArguments:[self.delegate.question text]];
		} else {
			// otherwise display the question while we wait for the answer
			NSString *placeholder = [NSString stringWithFormat:@"<div class='answer-page'><div class='question'>%@</div></div>", self.delegate.question.text];
			[self displayAnswer:placeholder andIsFirstRun:YES];
		}
        return NO;
    }

    if ([request.URL.scheme isEqualToString:@"file"]) {
        [self.delegate dismissModalQuestionAnswerViewAndLoadRequest:request];
		
    } else if ([request.URL.scheme isEqualToString:@"question"]) {
		Question *newQuestion = [[[Question alloc] initWithQuestion:request.URL.host] autorelease];
        [Logger log:@"Asked question (SQ link):" withArguments:[newQuestion text]];
		if (newQuestion && newQuestion.text.length) {
			[self.delegate answerQuestion:newQuestion];
			[self createOverlay];
			[self.view addSubview:self.questionRequestPendingOverlayView];
		} else {
			UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:@"Unable to process question" message:request.URL.absoluteString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] autorelease];
			[alert show];
		}
	} else if ([request.URL.scheme isEqualToString:@"put"]) {
        // handle logging of glossary popup
        NSArray *pathComponents = [[[request URL] path] componentsSeparatedByString:@"/"];
        if ([pathComponents count] != 4) {
            NSLog(@"Error: dispatchRequest does not understand %@", request);
        } else {
            NSString *resource = [pathComponents objectAtIndex:1];
            NSString *resourceId = [pathComponents objectAtIndex:2];
            NSString *action = [pathComponents objectAtIndex:3];
            
            if ([resource isEqualToString:@"glossary"]) {
                if ([action isEqualToString:@"showPopup"]) {
                    [Logger log:@"Viewed glossary popup:" withArguments:[resourceId stringByReplacingOccurrencesOfString:@".html" withString:@""]];
                }
            }
        }
    }

    return NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    return;
}

#pragma mark Private interface
- (void)displayAnswer:(NSString *)html andIsFirstRun:(BOOL)firstRun {
	
	if (firstRun) {    
        NSString *script = [NSString stringWithFormat:@"Halo.answers.loadAnswer(\"%@\", true);",
                            [self cleanStringForJavascript:html]];
        [self.webView stringByEvaluatingJavaScriptFromString:script];
    } else {
        if (self.questionRequestPendingOverlayView) { // for follow-up (non-first runs), hide overlay
            [UIView animateWithDuration:0.4 animations:^{
                self.questionRequestPendingOverlayView.alpha = 0;
            } completion:^(BOOL finished) {
                [self.questionRequestPendingOverlayView removeFromSuperview];
                self.questionRequestPendingOverlayView = nil;
            }];
        }
        [self loadBoilerplate];
	}
    [[HaloApplicationDelegate app] saveStateToArchive];
}

- (void)didTapBackButton {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)loadBoilerplate {
    NSString *boilerplatePath = [[NSBundle mainBundle] pathForResource:@"answers" ofType:@"html" inDirectory:@"textbook/html"];
    NSURL *url = [[[NSURL alloc] initFileURLWithPath:boilerplatePath] autorelease];
    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

    [self.webView loadRequest:request];
}

- (void)createOverlay {
	self.questionRequestPendingOverlayView = [[[UIView alloc] initWithFrame:self.view.frame] autorelease];
	self.questionRequestPendingOverlayView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.3];
	UIImageView *box = [[[UIImageView alloc] initWithImage: [UIImage imageNamed:@"ask-cancel-bg.png"]] autorelease];
	box.frame = CGRectMake(0, 81, self.questionRequestPendingOverlayView.frame.size.width, 250);
	box.contentMode = UIViewContentModeTop;
	box.alpha = 0.4;
	[self.questionRequestPendingOverlayView addSubview:box];
	UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)] autorelease];
	spinner.center = CGPointMake(box.center.x, 181);
	spinner.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	spinner.contentMode = UIViewContentModeTopLeft;
	[spinner startAnimating];
	[self.questionRequestPendingOverlayView addSubview:spinner];
}

- (NSString *)cleanStringForJavascript:(NSString *)string {
    NSString *cleanedString = [string stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
    cleanedString = [cleanedString stringByReplacingOccurrencesOfString:@"\\n" withString:@"\\\\n"];
    return [cleanedString stringByReplacingOccurrencesOfString:@"\n" withString:@" "];
}

- (void)didTapCloseButton {
    [self.delegate dismissModalQuestionAnswerView];
}

- (void)didTapNewQuestion {
    [self.delegate newQuestion];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
