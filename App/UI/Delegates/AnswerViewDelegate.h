#import <UIKit/UIKit.h>
#import "QuestionViewDelegate.h"

@protocol AnswerViewDelegate <QuestionViewDelegate>

- (void)newQuestion;
- (void)displayQuestion:(Question *)question andRefreshSQ:(BOOL)refresh;
- (void)answerQuestion:(Question *)question;

@property (nonatomic, assign) Question *question;

@end
