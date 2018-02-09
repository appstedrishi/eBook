#import <UIKit/UIKit.h>
#import "Question.h"
#import "History.h"

static const CGFloat WIDTH_IN_POPOVER = 696;//768.0;
static const CGFloat HEIGHT_IN_POPOVER = 496;//665.0;

@protocol QuestionViewDelegate

- (void)requestAnswerToQuestion:(NSString *)question;

- (void)addQuestionToQuestionHistory:(Question *)question;
- (History *)history;
- (void)dismissModalQuestionAnswerView;
- (void)dismissModalQuestionAnswerViewAndLoadRequest:(NSURLRequest *)request;
- (UIDeviceOrientation)orientation;
- (NSArray *)conceptList;

@end
