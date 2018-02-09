#import <UIKit/UIKit.h>
#import "ConceptViewController.h"

@interface NonConceptResourceViewController : UIViewController

@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, weak) IBOutlet UINavigationItem *navigationBarItem;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, strong) IBOutlet UIScrollView *imageScrollView;
@property (nonatomic, strong) NSURLRequest *request;

- (id)initWithRequest:(NSURLRequest *)request andDelegate:(ConceptViewController *)delegate;

- (IBAction)close:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

@end
