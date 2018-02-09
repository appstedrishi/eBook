//
//  ContentViewController.h
//  Halo
//
//  Created by Adam Overholtzer on 8/30/12.
//
//
#import <UIKit/UIKit.h>
#import "ConceptViewController.h"
#import "HighlightViewDelegate.h"
#import "HighlightPaintingViewDelegate.h"

@class ConceptViewController, HighlightView, ConceptBackgroundView, HighlightPaintingView;
@class Highlight, Book, Concept, History;

@interface ContentViewController : UIViewController <UIWebViewDelegate, UIScrollViewDelegate, HighlightViewDelegate, HighlightPaintingViewDelegate, UIGestureRecognizerDelegate> {
    HighlightView *__weak activeHighlightView_;
}

@property (nonatomic, weak) ConceptViewController *delegate;
@property BOOL boolWidthVar;
@property (nonatomic, weak) HighlightView *activeHighlightView;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

@property (nonatomic, weak) IBOutlet ConceptBackgroundView *backgroundView;
@property (strong, nonatomic) IBOutlet UIView *highlightContainer;
@property (nonatomic, strong) IBOutlet UILabel *versionNumber, *answerOverlayLabel;
@property (nonatomic, weak) IBOutlet UIView *loadingOverlayView;
@property (strong, nonatomic) IBOutlet UIView *loadingOverlayBackgroundView;
@property (strong, nonatomic) IBOutlet UIView *answerLoadingOverlay;
@property (nonatomic, weak) IBOutlet UIImageView *logoImageView;

+ (ContentViewController *)contentViewControllerWithDelegate:(ConceptViewController *)delegate;

- (void)loadConcept:(Concept *)concept withRequest:(NSURLRequest *)request;
- (void)dispatchRequest:(NSURLRequest *)request;

- (void)didTapBackground;
- (void)setPeekStatusText;

- (void)goToHighlightMode;
- (void)goToReadingMode;

- (void)leftViewDidOpen;
- (void)leftViewIsPanning;
- (void)leftViewDidClose;
- (void)highlightViewOpacity:(CGFloat)opacity;

- (void)showAnswerOverlay:(BOOL)show withText:(NSString *)text animated:(BOOL)animate;
-(void)getBoolVarForWidth:(BOOL)var;
- (void)layOutWebViewForOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (BOOL)loading;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script;
- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script andRefreshHighlights:(BOOL)refresh;


@end
