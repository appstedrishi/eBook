#import <UIKit/UIKit.h>

@protocol AnswerViewDelegate;

@interface AnswerViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, assign) IBOutlet UIView *questionRequestPendingOverlayView;

- (id)initWithHTML:(NSMutableString *)html andDelegate:(id<AnswerViewDelegate>)delegate;

- (void)displayAnswer:(NSString *)html;

@end
