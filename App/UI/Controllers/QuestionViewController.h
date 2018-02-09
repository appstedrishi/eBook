#import <UIKit/UIKit.h>
#import "AnswerViewDelegate.h"

@class Question;
@protocol QuestionViewDelegate;

@interface QuestionViewController : UIViewController <UITextViewDelegate, NSURLConnectionDelegate, UITableViewDataSource, UITableViewDelegate, QuestionViewDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate,NSXMLParserDelegate> {
    NSMutableArray *suggestedQuestionsList_;
	NSCache *cellCache;
}

@property (nonatomic, weak) IBOutlet UITextView *questionTextView;
@property (nonatomic, weak) IBOutlet UITableView *suggestedQuestionsTableView;
@property (nonatomic, weak) IBOutlet UIButton *askButton;
@property (nonatomic, weak) IBOutlet UIButton *clearQuestionButton;
@property (nonatomic, weak) IBOutlet UIButton *historyButton;
@property (nonatomic, weak) IBOutlet UIView *suggestedQuestionsRequestPendingOverlayView;
@property (nonatomic, weak) IBOutlet UIView *networkErrorOverlayView;
@property (nonatomic, weak) IBOutlet UILabel *networkErrorMessageLabel;
@property (nonatomic, weak) IBOutlet UIButton *closeAnswerQuestionErrorButton;
@property (nonatomic, weak) IBOutlet UILabel *hintLabel;

@property (nonatomic, weak) UIActivityIndicatorView *spinner;
//@property (nonatomic, assign) NSURLConnection *answerQuestionConnection;
@property (nonatomic, weak) NSURLConnection *suggestedQuestionsConnection;
@property (nonatomic, strong) NSString *keywords;
@property (nonatomic, weak) NSMutableString *answer;
@property (nonatomic, strong, readonly) NSArray *suggestedQuestionsList;
@property (nonatomic, assign) BOOL askRequested;


@property (nonatomic,strong) NSMutableString *mstrXMLString;
- (id)initWithKeywords:(NSString *)keywords question:(Question *)question delegate:(id<QuestionViewDelegate>)delegate;
- (IBAction)didTapAskButton;
- (IBAction)didTapNewQuestion;
- (IBAction)didTapClearErrorButton;
- (IBAction)didTapHistoryButton:(UIButton *)sender;
- (void)updateTextWithSuggestion:(NSString *)termSuggestion;
- (void)closeHistoryPopover;

@end
