
#import "QuestionViewController.h"
#import "Aura.h"
#import "PCKResponseParser.h"
#import "PCKXMLParser.h"
#import "PCKXMLParserDelegate.h"
#import "Question.h"
//#import "AnswerViewController.h"
#import "QuestionViewDelegate.h"
#import "ConceptViewController.h"
#import "QuestionHistoryTableViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "UIWebView+StylingExtensions.h"
#import "Logger.h"
#import "NSObject+PWObject.h"
#import "QASuggestedTriggerTableViewCell.h"
#import "TermSuggestionCollectionViewController.h"


//static const CGFloat SUGGESTED_QUESTIONS_TABLE_PADDING_TOP = 20;
//static const CGFloat SUGGESTED_QUESTIONS_TABLE_PADDING_LEFT = 45;
static const CGFloat ERROR_WEBVIEW_HEIGHT = 80;
//static const CGFloat TABLE_CONTENT_INDENT = 5;
static const NSInteger SHENANIGANS_TAG = 666;

@interface QuestionViewController ()

@property (nonatomic, weak) id<QuestionViewDelegate> delegate;
@property (nonatomic, strong) Question *question;
@property (nonatomic, strong, readwrite) NSArray *suggestedQuestionsList;
@property (nonatomic, strong, readwrite) NSMutableArray *suggestedQuestionsListInProgress;
@property (nonatomic, assign) BOOL suggestedQuestionsResponseIsSuccess;
@property (nonatomic, strong) NSMutableData *suggestedQuestionsData;
@property (nonatomic, strong) PCKXMLParser *suggestedQuestionsResponseParser;
@property (nonatomic, strong) PCKXMLParserDelegate *suggestedQuestionsResponseParserDelegate;
@property (nonatomic, strong) UIWebView *answerQuestionErrorWebView;
@property (nonatomic, strong) UILabel *serverLabel;
@property (nonatomic, assign) CGRect suggestedQuestionsTableViewFrame;
//@property (nonatomic, assign) CGRect tableWellImageViewFrame;
//@property (nonatomic, strong) UIPopoverController *questionHistoryPopover;
@property (nonatomic, strong) TermSuggestionCollectionViewController *conceptAutocompleter;
//@property (nonatomic, retain) NSMutableData *answerQuestionData;
//@property (nonatomic, assign) BOOL answerQuestionResponseIsSuccess;
@property (nonatomic, strong) QuestionHistoryTableViewController *historyTable;
- (void)fetchSuggestedQuestionsListForText:(NSString *)text withDelegate:(id<NSURLConnectionDelegate>)delegate;
- (void)enableQuestionInputs;
- (void)disableQuestionInputs;
- (BOOL)textIsEmpty:(NSString *)text;
//- (void)resetAnswerQuestionConnection;
- (void)resetSuggestedQuestionsConnection;
- (void)requestSuggestedQuestions;
- (void)registerForKeyboardNotifications;
- (void)askQuestion;
- (void)keyboardWasShown:(NSNotification*)aNotification;
- (void)keyboardWillBeHidden:(NSNotification*)aNotification;
- (void)refreshServerName:(NSNotification*)aNotification;
- (NSString *)boilerplateHTML;
- (PCKXMLParserDelegate *)makeQuestionsListParser;
- (void)updateAskButton;
- (void)didTapCloseButton;
- (void)resetPendingRequests;
- (void)setSuggestedQuestionsTableLoadingState:(BOOL)loading;
- (void)showAnswerQuestionError:(NSString *)html;
- (void)removeAnswerQuestionError:(BOOL)animate;
- (void)showShenanigans:(NSError *)error;
- (void)resetNetworkErrorOverlayView;
- (void)updateQuestions;
- (NSString *)previousWordForRange:(NSRange)range inTextView:(UITextView *)textView;
- (UITextRange *)previousWordFromPosition:(UITextPosition *)startPosition inTextView:(UITextView *)textView;
- (Question *)questionForIndexPath:(NSIndexPath *)indexPath;
@end

@implementation QuestionViewController

@synthesize mstrXMLString;
@synthesize delegate = delegate_;
//@synthesize answerQuestionConnection = answerQuestionConnection_;
//@synthesize answerQuestionData = answerQuestionData_;
//@synthesize answerQuestionResponseIsSuccess = answerQuestionResponseIsSuccess_;
@synthesize askButton = askButton_, clearQuestionButton = clearQuestionButton_;
//@synthesize cancelButton = cancelButton_;
@synthesize historyButton = historyButton_;
//@synthesize questionRequestPendingOverlayView = questionRequestPendingOverlayView_;
@synthesize suggestedQuestionsResponseParser = suggestedQuestionsResponseParser_;
@synthesize suggestedQuestionsResponseParserDelegate = suggestedQuestionsResponseParserDelegate_;
@synthesize question = question_, askRequested = askRequested_;
@synthesize answer = answer_;
@synthesize keywords = keywords_;
@synthesize serverLabel = serverLabel_;
@synthesize questionTextView = questionTextView_;
@synthesize suggestedQuestionsTableView = suggestedQuestionsTableView_;
@synthesize spinner = spinner_;
@synthesize suggestedQuestionsRequestPendingOverlayView = suggestedQuestionsRequestPendingOverlayView_;
@synthesize suggestedQuestionsConnection = suggestedQuestionsConnection_;
@synthesize suggestedQuestionsData = suggestedQuestionsData_;
@synthesize suggestedQuestionsList = suggestedQuestionsList_;
@synthesize suggestedQuestionsListInProgress = suggestedQuestionsListInProgress_;
@synthesize suggestedQuestionsResponseIsSuccess = suggestedQuestionsResponseIsSuccess_;
@synthesize answerQuestionErrorWebView = answerQuestionErrorWebView_;
@synthesize suggestedQuestionsTableViewFrame = suggestedQuestionsTableViewFrame_;
@synthesize networkErrorOverlayView = networkErrorOverlayView_;
@synthesize networkErrorMessageLabel = networkErrorMessageLabel_;
@synthesize closeAnswerQuestionErrorButton = closeAnswerQuestionErrorButton_;
@synthesize hintLabel = hintLabel_;


- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithKeywords:(NSString *)keywords question:(Question *)question delegate:(id<QuestionViewDelegate>)delegate {
    if (self = [super initWithNibName:@"QuestionViewController" bundle:nil]) {
        self.delegate = delegate;
        if (question) {
            self.question = question;
        } else {
            self.question = [[Question alloc] init];
        }
        self.suggestedQuestionsData = [NSMutableData data];
        self.keywords = keywords;

        if (question && question.text.length) {
            self.suggestedQuestionsList = [NSMutableArray array];
        } else {
            self.suggestedQuestionsList = [NSMutableArray arrayWithArray:[self getDefaultSuggestions]];
        }
		self.suggestedQuestionsListInProgress = [NSMutableArray array];
        self.suggestedQuestionsResponseParserDelegate = [self makeQuestionsListParser];
        self.suggestedQuestionsResponseParser = [[PCKXMLParser alloc] initWithDelegate:self.suggestedQuestionsResponseParserDelegate];
    }
    return self;
}

- (void)registerForKeyboardNotifications {
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshServerName:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)dealloc {
	self.closeAnswerQuestionErrorButton = nil;
	self.clearQuestionButton = nil;
	self.historyButton = nil;
//    self.answerQuestionData = nil;
    self.question = nil;
    self.answer = nil;
    self.delegate = nil;
    self.hintLabel = nil;
}

- (void)displayQuestion:(Question *)question andRefreshSQ:(BOOL)refresh {
	self.question.text = [question text];
	if (self.questionTextView) {
		[self.questionTextView setText:self.question.text];
        [self.conceptAutocompleter filterForString:@""];
	}
    [self updateAskButton];
    if (refresh) {
        [self fetchSuggestedQuestionsListForText:self.question.text withDelegate:self];
    }
}

- (void)updateTextWithSuggestion:(NSString *)termSuggestion {
    UITextRange *currentSelectedRange = [self.questionTextView selectedTextRange];
    UITextPosition *position = [currentSelectedRange start];
    UITextRange *replacementRange = [self previousWordFromPosition:position inTextView:self.questionTextView];
    [self.questionTextView replaceRange:replacementRange withText:[termSuggestion stringByAppendingString:@" "]];
    
    [self fetchSuggestedQuestionsListForText:self.questionTextView.text withDelegate:self];
}

- (void)answerQuestion:(Question *)question {
	self.question.text = [question text];
	[self requestAnswerToQuestion:question.text];
}

- (UIColor *)grayColor {
    return [UIColor colorWithRed:0.824 green:0.839 blue:0.859 alpha:1.000];
}

- (UIColor *)lightGrayColor {
    return [UIColor colorWithHue:0.583 saturation:0.008 brightness:0.965 alpha:1.000];
}

- (CGSize)preferredContentSize {
    return CGSizeMake(WIDTH_IN_POPOVER, HEIGHT_IN_POPOVER);
   }

#pragma mark view lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self.suggestedQuestionsTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
	self.suggestedQuestionsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    self.suggestedQuestionsTableViewFrame = self.suggestedQuestionsTableView.frame;
    [self setSuggestedQuestionsTableLoadingState:NO];

    self.questionTextView.text = self.question.text;
	[self updateAskButton];
    
    // set the hidden host name label (scroll beyond the top of the SQ list to see)
    self.serverLabel = [[UILabel alloc] initWithFrame:CGRectMake(15,-80,self.suggestedQuestionsTableView.frame.size.width-20, 20)];
    self.serverLabel.font = [UIFont systemFontOfSize:14];
    self.serverLabel.backgroundColor = self.suggestedQuestionsTableView.backgroundColor;
    self.serverLabel.textColor = [UIColor colorWithWhite:0 alpha:0.45];
    self.serverLabel.text = [NSString stringWithFormat:@"Inquire server: %@", [Aura serverName]];
    [self.suggestedQuestionsTableView addSubview:self.serverLabel];

	if (self.question.feedback && self.question.feedback.length) {
        // we have feedback, show it 
        [self showAnswerQuestionError:self.question.feedback];
        self.question.feedback = nil;
    }
    
    if (/* DISABLES CODE */ (NO)) { // busted on iOS 7, so I disabled it for now
        self.conceptAutocompleter = [[TermSuggestionCollectionViewController alloc] initWithConcepts:self.conceptList andDelegate:self];
        self.conceptAutocompleter.view.frame = CGRectMake(0, 0, 100, TERM_SUGGESTION_CELL_HEIGHT);
        self.questionTextView.inputAccessoryView = self.conceptAutocompleter.collectionView;
        [self.conceptAutocompleter filterForString:@""];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [self enableQuestionInputs];
    [self.questionTextView becomeFirstResponder];
    if (self.suggestedQuestionsList.count == 0) {
        [self fetchSuggestedQuestionsListForText:self.question.text withDelegate:self];
    }
    [self refreshServerName:nil];
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self closeHistoryPopover];
    [self disableQuestionInputs];
    [self resetSuggestedQuestionsConnection];
	[self removeAnswerQuestionError:animated];
    [self setSuggestedQuestionsTableLoadingState:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

//- (BOOL)disablesAutomaticKeyboardDismissal {
//    return YES;
//}

#pragma mark IBActions
- (IBAction)didTapAskButton {
    [self askQuestion];
    [Logger log:@"Asked question:" withArguments:self.questionTextView.text];
}

- (IBAction)didTapCancelButton {
    [self enableQuestionInputs];
    [self.questionTextView becomeFirstResponder];
}

- (IBAction)didTapNewQuestion {
    [self newQuestion];
}

- (IBAction)didTapClearErrorButton {
	[self removeAnswerQuestionError:YES];
}

- (IBAction)didTapHistoryButton:(UIButton *)sender {
	// This works around a (presumed) bug in the UIPopoverController; it improperly resets the
    // passthroughViews property upon display or push/pop inside the navigation controller.
    // See Apple bugs 8584810 and 8584543 (if you can).
    if (_historyTable) {
       // [self closeHistoryPopover];
        [_historyTable dismissViewControllerAnimated:YES completion:nil];
        return;
    }
	
	_historyTable = [[QuestionHistoryTableViewController alloc] init];
	_historyTable.delegate = self;
//    self.questionHistoryPopover = [[UIPopoverController alloc] initWithContentViewController:historyTable];
//	self.questionHistoryPopover.delegate = self;
//    self.questionHistoryPopover.passthroughViews = nil;
//    [self.questionHistoryPopover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    
    _historyTable.modalPresentationStyle                   = UIModalPresentationPopover;
    _historyTable.popoverPresentationController.sourceView = sender;//self.view;
    _historyTable.popoverPresentationController.sourceRect = CGRectMake(0, 1, 40, 44);//self.qaButton.frame;
    [self presentViewController:_historyTable animated:YES completion:nil];
    
   
}

#pragma mark UITextViewDelegate
- (void) _fetchSuggestedQuestionsListForText:(NSString *)text {
	[self fetchSuggestedQuestionsListForText:text withDelegate:self];
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateAskButton];
}

-(void)textViewDidChangeSelection:(UITextView *)textView {
    
    [self.conceptAutocompleter filterForString:@""];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [self didTapAskButton];
        return NO;
    } else if (YES) {
        NSString *newText = [textView.text stringByReplacingCharactersInRange:range withString:text];
        NSTimeInterval delay = 1;
        [NSObject cancelPreviousPerformRequestsWithTarget:self];
        
        NSString *currentTerm = [[self previousWordForRange:range inTextView:self.questionTextView] stringByAppendingString:text];
        
        if (text.length == 0) { // no content --> delete key
            delay = 0.4;
        } else {
            // build refresh-triggering character set
            NSMutableCharacterSet* triggerCharSet = [[NSMutableCharacterSet alloc] init];
            [triggerCharSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [triggerCharSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
            
            if ([text stringByTrimmingCharactersInSet:triggerCharSet].length == 0) { // whitespace or punctuation
                delay = 0.25; // update the suggested questions sooner rather than later
                currentTerm = @""; // cancel the term-completer
            } 
        }
        
        [self performSelector:@selector(_fetchSuggestedQuestionsListForText:) withObject:newText afterDelay:delay];
        
        if (self.conceptAutocompleter) {// requires iOS 6
            [self.conceptAutocompleter filterForString:currentTerm];
        }
    }
	return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.question.text = textView.text;
    [self updateAskButton];
}


static NSString *KEYWORD_DEFINITION = @"define";
static NSString *KEYWORD_STRUCTURE = @"structure";
static NSString *KEYWORD_FUNCTION = @"function";
static NSString *KEYWORD_COMPARE = @"compare";
static NSString *KEYWORD_RELATE = @"relate";

- (NSArray *)getDefaultSuggestions {
    return [NSArray arrayWithObjects:
            [Question questionWithText:[KEYWORD_DEFINITION stringByAppendingString:@" "]
                                                           html:@"What is photosynthesis?"],
            [Question questionWithText:[KEYWORD_STRUCTURE stringByAppendingString:@" "]
                                  html:@"What is the structure of a plasma membrane?"],
            [Question questionWithText:[KEYWORD_FUNCTION stringByAppendingString:@" "]
                                  html:@"What is the function of a chloroplast?"],
            [Question questionWithText:[KEYWORD_COMPARE stringByAppendingString:@" "]
                                  html:@"What are the differences between chloroplasts and mitochondria?"],
            [Question questionWithText:[KEYWORD_RELATE stringByAppendingString:@" "]
                                  html:@"If the chloroplasts were removed from a plant, what events would be affected?"],
//            [Question questionWithText:@"Search book for “photosynthesis”" html:@"search "],
            nil];
}

- (void)fetchSuggestedQuestionsListForText:(NSString *)text withDelegate:(id<NSURLConnectionDelegate>)delegate {
    [self.spinner startAnimating];
    if (self.suggestedQuestionsConnection) {
        [self.suggestedQuestionsConnection cancel];
        [self resetSuggestedQuestionsConnection];
    }
    
    if ([self textIsEmpty:text]) {
        self.suggestedQuestionsListInProgress = [NSMutableArray arrayWithArray:[self getDefaultSuggestions]];
        [self updateQuestions];
        [self setSuggestedQuestionsTableLoadingState:NO];
    } else {
        text = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // HACK: to semi-simulate the concept calculator UI, we will parse out KEYWORDS and replace them with question fragments
        NSString *firstWord = [[text componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] objectAtIndex:0];
        if ([firstWord compare:KEYWORD_DEFINITION options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            text = [text stringByReplacingCharactersInRange:[text rangeOfString:firstWord] withString:@"What is"];
        } else if ([firstWord compare:KEYWORD_COMPARE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            text = [text stringByReplacingCharactersInRange:[text rangeOfString:firstWord] withString:@"What is the difference between "];
        } else if ([firstWord compare:KEYWORD_RELATE options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            text = [text stringByReplacingCharactersInRange:[text rangeOfString:firstWord] withString:@"What is the relationship between"];
        }
//        } else if ([firstWord compare:KEYWORD_SEARCH options:NSCaseInsensitiveSearch] == NSOrderedSame) {
//            text = @"Implications of merger between SprintPCS and Verizon";
//        }
        
        self.suggestedQuestionsListInProgress = [NSMutableArray array];
//        self.suggestedQuestionsResponseParser = [[PCKXMLParser alloc] initWithDelegate:self.suggestedQuestionsResponseParserDelegate];
//        PCKResponseParser *responseParser = [[PCKResponseParser alloc] initWithParser:self.suggestedQuestionsResponseParser successParserDelegate:self.suggestedQuestionsResponseParserDelegate errorParserDelegate:self.suggestedQuestionsResponseParserDelegate connectionDelegate:self];
                                             //initWithParser:self.suggestedQuestionsResponseParser andDelegate:self];
       // self.suggestedQuestionsConnection = [[Aura aura] getSuggestedQuestionsForQuery:text andKeywords:self.keywords withDelegate:responseParser];
        [[Aura aura] getSuggestedQuestionsList:text andKeywords:self.keywords completionHandler:^(BOOL var,NSString *message,NSData *data)
         {
              [self.spinner stopAnimating];
             if (var) {
                 
          [self.suggestedQuestionsData setLength:0];
               [self.suggestedQuestionsData appendData:data];
             
             NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:data];
             [xmlParser setDelegate:self];
             [xmlParser parse];
             NSLog(@"xml data %@",self.suggestedQuestionsListInProgress);
             
             dispatch_async (dispatch_get_main_queue(), ^{
                 [self resetNetworkErrorOverlayView];
                 [self resetSuggestedQuestionsConnection];
                 [self updateQuestions];
                 [self setSuggestedQuestionsTableLoadingState:NO];
                 [self resetSuggestedQuestionsConnection];
             });
             
             }
             else
             {
                 self.networkErrorMessageLabel.text = @"Failed to retrieve questions";
                 self.networkErrorOverlayView.hidden = NO;
             }
         }
         ];
        
        [self setSuggestedQuestionsTableLoadingState:YES];
    };
}

#pragma mark NSURLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.suggestedQuestionsResponseIsSuccess = [(id)response statusCode] == 200;
    [self.suggestedQuestionsData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
        [self.suggestedQuestionsData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // handle suggested-questions connection
    if (self.suggestedQuestionsResponseIsSuccess) {
        // successful request, show questions
        [self resetNetworkErrorOverlayView];
        [self resetSuggestedQuestionsConnection];
        [self updateQuestions];
    } else {
        // failed to get suggestions, show error message
        self.networkErrorMessageLabel.text = @"Failed to retrieve questions";
        self.networkErrorOverlayView.hidden = NO;
    }
    [self setSuggestedQuestionsTableLoadingState:NO];
    [self resetSuggestedQuestionsConnection];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.networkErrorMessageLabel.text = [[[error userInfo] objectForKey:@"NSUnderlyingError"] localizedDescription];
    self.networkErrorOverlayView.hidden = NO;

    [self setSuggestedQuestionsTableLoadingState:NO];
    [self resetSuggestedQuestionsConnection];
}

#pragma mark UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0 && [self textIsEmpty:self.questionTextView.text]) {
        static NSString *identifier = @"trigger-cell";
        QASuggestedTriggerTableViewCell *cell = (QASuggestedTriggerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[QASuggestedTriggerTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        cell.triggerLabel.text = [[self.suggestedQuestionsList objectAtIndex:indexPath.row] text];
        cell.questionLabel.text = [[self.suggestedQuestionsList objectAtIndex:indexPath.row] html];
        
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.triggerLabel.backgroundColor = cell.contentView.backgroundColor;
        cell.questionLabel.backgroundColor = cell.contentView.backgroundColor;
//        cell.questionLabel.textColor = self.hintLabel.textColor;
        return cell;
    } else {
        Question *q = [self questionForIndexPath:indexPath];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        cell.textLabel.attributedText = q.attributedText;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        return cell;
    }
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.section > 0 || ![self textIsEmpty:self.questionTextView.text]) {
//        DTAttributedTextCell *cell = (DTAttributedTextCell *)[self tableView:tableView preparedCellForIndexPath:indexPath];
//        return [cell requiredRowHeightInTableView:tableView];
//    } else {
//        NSString *labelText = [[self questionForIndexPath:indexPath] text];
//        CGSize size = [labelText sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize:CGSizeMake(tableView.frame.size.width-TABLE_CONTENT_INDENT-20, 200) lineBreakMode:NSLineBreakByWordWrapping];
//        return size.height + 22;
//    }
//}

- (Question *)questionForIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return [self.suggestedQuestionsList objectAtIndex:indexPath.row];
    } else {
        return [self.history.questionStack objectAtIndex:indexPath.row];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([self textIsEmpty:self.questionTextView.text] && self.history.questionStack.count) {
        return 2;
    } else {
        return 1;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.suggestedQuestionsList.count;
    } else {
        return self.history.questionStack.count;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
//    CGFloat height = (section) ? 15 : 16;
//    CGFloat y = (section) ? 1 : 2;
    
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 20)];
    header.backgroundColor = [UIColor colorWithHue:0.568 saturation:0.000 brightness:0.862 alpha:1.000];
    //self.view.backgroundColor;// self.suggestedQuestionsTableView.backgroundColor;//self.view.backgroundColor;
    
    UIView *divider = [[UIView alloc] initWithFrame:CGRectMake(0, 19, tableView.frame.size.width, 1)];
    divider.backgroundColor = [UIColor colorWithHue:0.568 saturation:0.000 brightness:0.862 alpha:1.000];
    [header addSubview:divider];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 4, tableView.frame.size.width-20, 12)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor colorWithWhite:0 alpha:0.5];
    label.font = [UIFont boldSystemFontOfSize:11];
    [header addSubview:label];
    
    if (section == 0) {
        label.text = @"SUGGESTIONS";
    } else {
        label.text = @"RECENT";
    }
    return header;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
//    if ([self textIsEmpty:self.questionTextView.text]) {
//        if (section) {
//            return 15;
//        } else {
//            return 16;
//        }
    if (section) {
        return 20;
    } else {
        return 0;
    }
}

#pragma mark UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    BOOL questionTextViewIsBlank = [self textIsEmpty:self.questionTextView.text];
    
	[self displayQuestion:[self questionForIndexPath:indexPath] andRefreshSQ:NO];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (questionTextViewIsBlank) { // && indexPath.section == 0) {
        // if questionTextView was blank, then the SQ is actually just a keyword and we should trigger new SQ table
        [self setSuggestedQuestionsTableLoadingState:YES];
        [self performSelector:@selector(_fetchSuggestedQuestionsListForText:) withObject:self.questionTextView.text afterDelay:0.2];
    }
}

#pragma mark QuestionViewDelegate
- (void)newQuestion {
    self.questionTextView.text = self.question.text = @"";

    //[self resetNetworkErrorOverlayView];
	[self updateAskButton];
	[self removeAnswerQuestionError:YES];
    [self resetPendingRequests];
    [self.conceptAutocompleter filterForString:@""];
    [self fetchSuggestedQuestionsListForText:@"" withDelegate:self];
	[self.suggestedQuestionsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:YES];
    [self enableQuestionInputs];
    [self.questionTextView becomeFirstResponder];
}

- (void)addQuestionToQuestionHistory:(Question *)question {
	[self.delegate addQuestionToQuestionHistory:question];
}

- (History *)history {
	return [self.delegate history];
}

-(NSArray *)conceptList {
    return self.delegate.conceptList;
}

- (void)dismissModalQuestionAnswerView {
    [self.delegate dismissModalQuestionAnswerView];
}

- (void)dismissModalQuestionAnswerViewAndLoadRequest:(NSURLRequest *)request {
    [self.delegate dismissModalQuestionAnswerViewAndLoadRequest:request];
}

- (UIDeviceOrientation)orientation {
    return [self.delegate orientation];
}

#pragma mark UIPopoverControllerDelegate
//- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
//	self.questionHistoryPopover = nil;
//    
//}

#pragma mark Parsers
- (PCKXMLParserDelegate *)makeQuestionsListParser {
    PCKXMLParserDelegate *delegate = [[PCKXMLParserDelegate alloc] init];
    __block NSMutableString *newQuestionText = nil;

    delegate.didStartElement = ^(const char *elementName) {
        if (0 == strncmp(elementName, "question", strlen(elementName))) {
            newQuestionText = [[NSMutableString alloc] init];
        }
    };

    delegate.didEndElement = ^(const char *elementName) {
        if (0 == strncmp(elementName, "question", strlen(elementName))) {
            Question *newQuestion = [[Question alloc] init];
			id temp = [newQuestionText stringByReplacingOccurrencesOfString:@"<span class=\"keywords\">" withString:@""];
            newQuestion.text = [temp stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
            newQuestion.html = [NSString stringWithFormat:@"<span class='blackText'>%@</span>", newQuestionText];
            [suggestedQuestionsListInProgress_ addObject:newQuestion];

             newQuestionText = nil;
        }
    };

    delegate.didFindCharacters = ^(const char *characters) {
        if (newQuestionText) {
            [newQuestionText appendString:[NSString stringWithCString:characters encoding:NSUTF8StringEncoding]];
        }
    };

    return delegate;
}

#pragma mark Private interface

- (UITextRange *)previousWordFromPosition:(UITextPosition *)startPosition inTextView:(UITextView *)textView {
    if (self.conceptAutocompleter) { // requires iOS 6
        id<UITextInputTokenizer> tokenizer = [textView tokenizer];
        UITextPosition *previousWordStart = [tokenizer positionFromPosition:startPosition
                                                                 toBoundary:UITextGranularityWord
                                                                inDirection:UITextStorageDirectionBackward];
        return [textView textRangeFromPosition:startPosition toPosition:previousWordStart];
    } else {
        return nil; //archit [textView textRangeFromPosition:0 toPosition:0];
    }
}

- (NSString *)previousWordForRange:(NSRange)range inTextView:(UITextView *)textView {
    if (self.conceptAutocompleter) { // requires iOS 6
        UITextPosition *beginning = textView.beginningOfDocument;
        UITextPosition *startPosition = [textView positionFromPosition:beginning offset:range.location];
        UITextRange *wordRange = [self previousWordFromPosition:startPosition inTextView:textView];
        
        NSString *retval = [textView textInRange:wordRange];
        if (retval) {
            return retval;
        } else {
            return @"";
        }
    } else {
        return @"";
    }
}

- (BOOL)textIsEmpty:(NSString *)text {
    return [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length == 0;
}

- (void)requestAnswerToQuestion:(NSString *)question {
    [self.delegate requestAnswerToQuestion:question];
	[self closeHistoryPopover];
	
    [self.suggestedQuestionsConnection cancel];
    [self resetSuggestedQuestionsConnection];
}

- (void)enableQuestionInputs {
    self.askButton.enabled = [self.questionTextView hasText];
    self.questionTextView.editable = YES;
    self.questionTextView.selectedRange = NSMakeRange(self.questionTextView.text.length, 0);
}

- (void)disableQuestionInputs {
    self.questionTextView.editable = NO;
    self.askButton.enabled = NO;
}

- (void)requestSuggestedQuestions {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(_fetchSuggestedQuestionsListForText:) withObject:self.questionTextView.text afterDelay:0];
}

- (void)resetSuggestedQuestionsConnection {
    [self.suggestedQuestionsData setLength:0];
    self.suggestedQuestionsConnection = nil;
}

- (NSString *)boilerplateHTML {
    NSString *baseCSSPath = [NSString stringWithFormat:@"file://%@", [[NSBundle mainBundle] bundlePath]];
    NSString *commonCSSPath = [baseCSSPath stringByAppendingPathComponent:@"textbook/css/halo-common.css"];
    return [NSString stringWithFormat:@"<html>"
            "<head>"
            "<link rel=\"Stylesheet\" href=\"%@\" type=\"text/css\" media=\"screen\" />"
            "</head>"
            "<body>%%@</body></html>", commonCSSPath];
}

- (void)updateAskButton {
    self.hintLabel.hidden = [self.questionTextView hasText];
    self.askButton.enabled = [self.questionTextView hasText] && self.questionTextView.editable;
	self.clearQuestionButton.hidden = ![self.questionTextView hasText];
	self.questionTextView.showsVerticalScrollIndicator = [self.questionTextView hasText];
}

- (void)setSQAlpha:(NSNumber *)alpha {
	self.suggestedQuestionsTableView.alpha = [alpha floatValue];
}

- (void)setSuggestedQuestionsTableLoadingState:(BOOL)loading {
	CGRect newRect = CGRectMake(self.suggestedQuestionsRequestPendingOverlayView.frame.origin.x, self.suggestedQuestionsTableView.frame.origin.y,
								self.suggestedQuestionsRequestPendingOverlayView.frame.size.width, self.suggestedQuestionsRequestPendingOverlayView.frame.size.height);
	self.suggestedQuestionsRequestPendingOverlayView.frame = newRect;
	
    [UIView beginAnimations:nil context:nil];
	self.suggestedQuestionsTableView.alpha = (self.networkErrorOverlayView.hidden) ? 1 : 0;
	self.suggestedQuestionsRequestPendingOverlayView.alpha = (loading) ? 1 : 0;
    [UIView commitAnimations];
}

- (void)didTapCloseButton {
    [self resetPendingRequests];
    [self.delegate dismissModalQuestionAnswerView];
}

- (void)closeHistoryPopover {
//    if (self.questionHistoryPopover) {
//        [self.questionHistoryPopover dismissPopoverAnimated:YES];
//        self.questionHistoryPopover.delegate = nil;
//        self.questionHistoryPopover = nil;
//    }
    if (_historyTable) {
        [_historyTable dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)resetNetworkErrorOverlayView {
    self.networkErrorOverlayView.hidden = YES;
    self.networkErrorMessageLabel.text = @"";
}

- (void)resetPendingRequests {
    [self.suggestedQuestionsConnection cancel];
    [self resetSuggestedQuestionsConnection];
}

- (void)showAnswerQuestionError:(NSString *)html {
    CGRect newSuggestedQuestionsTableFrame = CGRectMake(self.suggestedQuestionsTableViewFrame.origin.x,
                                                     self.suggestedQuestionsTableViewFrame.origin.y + ERROR_WEBVIEW_HEIGHT +1,// + SUGGESTED_QUESTIONS_TABLE_PADDING_TOP,
                                                     self.suggestedQuestionsTableViewFrame.size.width,
                                                     self.view.frame.size.height - (self.suggestedQuestionsTableViewFrame.origin.y + ERROR_WEBVIEW_HEIGHT +1));
    CGRect webViewFrame = CGRectMake(self.suggestedQuestionsTableViewFrame.origin.x,
                                     self.suggestedQuestionsTableViewFrame.origin.y,
                                     self.suggestedQuestionsTableViewFrame.size.width,
                                     ERROR_WEBVIEW_HEIGHT);

	
	if (self.answerQuestionErrorWebView) {
		[self.answerQuestionErrorWebView removeFromSuperview];
	}
	self.answerQuestionErrorWebView = [[UIWebView alloc] initWithFrame:webViewFrame];
    self.answerQuestionErrorWebView.autoresizingMask = UIViewAutoresizingNone;
	self.answerQuestionErrorWebView.backgroundColor = [UIColor colorWithRed:0.824 green:0.839 blue:0.859 alpha:1.000];
	[self.answerQuestionErrorWebView removeBackgroundDropShadow];
    self.answerQuestionErrorWebView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.answerQuestionErrorWebView.alpha = 0;
    [self.answerQuestionErrorWebView loadHTMLString:[NSString stringWithFormat:@"<html><body style='background-color:#d2d6db;font-family:Helvetica;padding:0;margin:10px 15px;'>%@</body></html>", html] baseURL:nil];
	[self.view insertSubview:self.answerQuestionErrorWebView atIndex:0];	
	
	[UIView	animateWithDuration:0.3 animations:^{
		self.suggestedQuestionsTableView.frame = newSuggestedQuestionsTableFrame;
		self.networkErrorOverlayView.frame = CGRectMake(self.networkErrorOverlayView.frame.origin.x,
														self.suggestedQuestionsTableView.frame.origin.y,
														self.networkErrorOverlayView.frame.size.width,
														self.networkErrorOverlayView.frame.size.height);
		self.closeAnswerQuestionErrorButton.alpha = 1;
		self.answerQuestionErrorWebView.alpha = 1;		
	}];
}

- (void)removeAnswerQuestionError:(BOOL)animate {
    if (self.answerQuestionErrorWebView) {
		CGFloat	duration = animate? 0.3 : 0;
		[UIView animateWithDuration:duration animations:^{
            self.suggestedQuestionsTableView.frame = CGRectMake(self.suggestedQuestionsTableViewFrame.origin.x,
                                                                self.suggestedQuestionsTableViewFrame.origin.y,
                                                                self.suggestedQuestionsTableViewFrame.size.width,
                                                                self.view.frame.size.height - self.suggestedQuestionsTableViewFrame.origin.y);
			self.networkErrorOverlayView.frame = CGRectMake(self.networkErrorOverlayView.frame.origin.x,
															self.suggestedQuestionsTableView.frame.origin.y,
															self.networkErrorOverlayView.frame.size.width,
															self.networkErrorOverlayView.frame.size.height);
			self.answerQuestionErrorWebView.alpha = 0;
			self.closeAnswerQuestionErrorButton.alpha = 0;
			if (!animate) {
				[self.answerQuestionErrorWebView removeFromSuperview];
				self.answerQuestionErrorWebView = nil;
			}
		} completion:^(BOOL finished) {
			[self.answerQuestionErrorWebView removeFromSuperview];
			self.answerQuestionErrorWebView = nil;
		}];
    }
}

- (void)askQuestion {
	[self disableQuestionInputs];
	[self requestAnswerToQuestion:self.questionTextView.text];
}

- (void)updateQuestions {
	NSMutableArray *newQuestions = [NSMutableArray arrayWithCapacity:self.suggestedQuestionsListInProgress.count];
	int i = 0;
	for (Question *q in self.suggestedQuestionsListInProgress) {
		BOOL found = NO;
		for (Question *existingQ in self.suggestedQuestionsList) {
			if ([q.text isEqualToString: existingQ.text]) {
				found = YES;
				break;
			}
		}
		if (!found) {
			[newQuestions addObject:[NSIndexPath indexPathForRow:i inSection:0]];
		}
		i++;
	}
	self.suggestedQuestionsList = [NSMutableArray arrayWithArray:self.suggestedQuestionsListInProgress];
	[self.suggestedQuestionsTableView reloadData];
    if (newQuestions.count > 0) {
        [self.suggestedQuestionsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    }
//	[self.suggestedQuestionsTableView reloadRowsAtIndexPaths:newQuestions withRowAnimation:UITableViewRowAnimationNone];
}


- (void)showShenanigans:(NSError *)error {
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
//	alert.tag = SHENANIGANS_TAG;
//	[alert show];
    UIAlertController *alertController = [UIAlertController  alertControllerWithTitle:@"Connection error"  message:[error localizedDescription]  preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSLog(@"%ld",(long)SHENANIGANS_TAG);
        [self dismissViewControllerAnimated:YES completion:nil];
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}

//- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
//	if (alertView.tag == SHENANIGANS_TAG) {
//	}
//}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification {
    if (UIInterfaceOrientationIsPortrait([UIApplication sharedApplication].statusBarOrientation)) {
        [self keyboardWillBeHidden:aNotification];
    } else {
        NSDictionary* info = [aNotification userInfo];
        CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
        __block UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.width+1, 0.0); // using width because we're in landscape
        [UIView animateWithDuration:0.25 animations:^{
            self.suggestedQuestionsTableView.contentInset = contentInsets;
            self.suggestedQuestionsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, contentInsets.bottom+2, 0.0);
        }];
    }
    
//    // locate keyboard view
//    UIWindow* tempWindow = [[[UIApplication sharedApplication] windows] objectAtIndex:1];
//    UIView* keyboard;
//    
//    for(int i = 0 ; i < [tempWindow.subviews count] ; i++) 
//    {
//        keyboard = [tempWindow.subviews objectAtIndex:i];
//        if([[keyboard description] hasPrefix:@"<UIPeripheralHost"] == YES) {
//            // keyboard found, add the button
//            [keyboard addSubview:self.askButton];
//            self.askButton.hidden = NO;
//            if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
//                self.askButton.frame = CGRectMake(872, 95, 147, 79);
//            } else {
//                self.askButton.frame = CGRectMake(655, 71, 110, 59);
//            }
//        }
//    }

}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification {
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    [UIView animateWithDuration:0.25 animations:^{
        self.suggestedQuestionsTableView.contentInset = contentInsets;
        self.suggestedQuestionsTableView.scrollIndicatorInsets = UIEdgeInsetsMake(0.0, 0.0, 2.0, 0.0);
    }];
//    self.askButton.hidden = YES;
//    [self.view insertSubview:self.askButton belowSubview:self.suggestedQuestionsTableView];
}

- (void)refreshServerName:(NSNotification*)aNotification {
    self.serverLabel.text = [NSString stringWithFormat:@"Inquire server: %@", [Aura serverName]];
}
#pragma mark -XML parsing delegate-
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if([elementName isEqualToString:@"questions"])
        suggestedQuestionsListInProgress_ = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if(!mstrXMLString)
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    else
        [mstrXMLString appendString:string];
    
    
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    //if([elementName isEqualToString:@"question"])
//        [self.suggestedQuestionsListInProgress addObject:mstrXMLString];
//    mstrXMLString = nil;
    
    
   if([elementName isEqualToString:@"question"]) {
        Question *newQuestion = [[Question alloc] init];
        id temp = [mstrXMLString stringByReplacingOccurrencesOfString:@"<span class=\"keywords\">" withString:@""];
        newQuestion.text = [temp stringByReplacingOccurrencesOfString:@"</span>" withString:@""];
        newQuestion.html = [NSString stringWithFormat:@"<span class='blackText'>%@</span>", mstrXMLString];
        [suggestedQuestionsListInProgress_ addObject:newQuestion];
        
       mstrXMLString = nil;
    }

    
}


@end
