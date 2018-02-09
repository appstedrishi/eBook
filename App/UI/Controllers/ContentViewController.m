//
//  ContentViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 8/30/12.
//
//

#import <objc/runtime.h>
#import "ContentViewController.h"
#import "HaloApplicationDelegate.h"
#import "Aura.h"
#import "Logger.h"
#import "Concept.h"
#import "Book.h"
#import "History.h"
#import "NSURL+PathExtensions.h"
#import "HistoryLocation.h"
#import "Highlight.h"
#import "HighlightView.h"
#import "StickieView.h"
#import "AJNotificationView.h"
#import "UIWebView+StylingExtensions.h"
#import "ConceptBackgroundView.h"
#import "HighlightPaintingView.h"

typedef enum {
    HighlightStateInvalid = 0,
    HighlightStateValidUnstarted,
    HighlightStateValidStarted
} HighlightState;

@interface ContentViewController ()
{
    BOOL boolViewWidthVar;
}

- (void)interceptScrollViewEventsFrom:(UIScrollView *)eventSource;

- (void)listenToWebViewScrollEvents;
- (void)readJavascriptLogger;
//- (void)swapWebViews;
- (void)notifyWebViewContentOfOrientation:(UIInterfaceOrientation)interfaceOrientation;

- (void)addHighlightIntoContent:(Highlight *)highlight;
- (HighlightView *)addViewForHighlight:(Highlight *)highlight;
- (void)getCreatedHighlight;
- (void)removeSupplementaryViews;
- (void)refreshYOffsetsOfHighlightViews;
- (void)refreshHighlightViewsAtYOffset:(CGFloat)yOffset;
- (void)setUpHighlightContextMenuItem;
- (void)showCurrentHighlights;
- (void)showWebViewWithNewContent;
- (NSString *)stringByEscapingJSONString:(NSString *)json;
- (HighlightView *)viewForHighlight:(Highlight *)highlight;
- (void)addHighlightModeOverlayView;
- (void)removeHighlightModeOverlayView;
- (void)setUpGestureRecognizers;
- (void)displayTouchFeedbackImageAtPoint:(CGPoint)point;

@property (nonatomic, strong) id<UIScrollViewDelegate> originalScrollDelegate;
@property (nonatomic, assign) CGFloat verticalContentOffset;
@property (nonatomic, assign) CGFloat horizontalContentOffset;
@property (nonatomic, strong) NSString *temporaryWebContentFragment;
@property (nonatomic, weak) Concept *loadingConcept;
@property (nonatomic, strong) NSMutableArray *highlightViews;
@property (nonatomic, assign) HighlightState highlightState;
@property (nonatomic, weak) AJNotificationView *titleDisplayView;
@property (nonatomic, strong) HighlightPaintingView *paintingView;
@property (nonatomic, strong) UIView *grayScrollViewBackgroundView;

@end

@implementation ContentViewController

@synthesize delegate = delegate_;
@synthesize versionNumber = versionNumber_;
@synthesize backgroundView = backgroundView_, webView = webView_, loadingOverlayView = webViewLoadingOverlayView_, answerLoadingOverlay = answerLoadingOverlay_;
@synthesize logoImageView = logoImageView_, titleDisplayView = titleDisplayView_;
@synthesize originalScrollDelegate = originalScrollDelegate_;
@synthesize verticalContentOffset = verticalContentOffset_, horizontalContentOffset = horizontalContentOffset_;
@synthesize temporaryWebContentFragment = temporaryWebContentFragment_;
@synthesize loadingConcept = loadingConcept_;
@synthesize highlightViews = highlightViews_, activeHighlightView = activeHighlightView_;
@synthesize highlightState = highlightState_;
@synthesize paintingView = paintingView_;
@synthesize grayScrollViewBackgroundView = grayScrollViewBackgroundView_;


+ (ContentViewController *)contentViewControllerWithDelegate:(ConceptViewController *)delegate {
    ContentViewController *retval = [[ContentViewController alloc] initWithNibName:@"ContentViewController" bundle:nil];
    retval.delegate = delegate;
    return retval;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
       // custom whatever
    }
    return self;
}

#pragma mark View lifecycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // config webview
    [self layOutWebViewForOrientation:[[UIApplication sharedApplication] statusBarOrientation]
];
    self.webView.dataDetectorTypes = UIDataDetectorTypeNone;
	self.webView.allowsInlineMediaPlayback = YES;
    [self.webView removeBackgroundDropShadow];
    [self.view insertSubview:self.loadingOverlayView aboveSubview:self.backgroundView];
    
    if ([self.webView respondsToSelector:@selector(setSuppressesIncrementalRendering:)]) {
        [self.webView setSuppressesIncrementalRendering:YES]; // iOS 6 only
    }
    
    // set backgrounds
    self.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"crosshatch"]];
    self.webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background"]];
    self.loadingOverlayView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background"]];
    self.loadingOverlayBackgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"crosshatch"]];
    self.loadingOverlayBackgroundView.hidden = UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]);
    
    // add cutesy webview scroll background
    self.grayScrollViewBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, -self.webView.bounds.size.height, PORTRAIT_WIDTH, self.webView.bounds.size.height)];
    self.grayScrollViewBackgroundView.backgroundColor = [UIColor colorWithRed:0.824 green:0.839 blue:0.859 alpha:1.000];
    [self.webView.scrollView insertSubview:self.grayScrollViewBackgroundView atIndex:0];
    self.grayScrollViewBackgroundView.hidden = YES;
    
    // add basic paper backgrounds to support glossary/answer page scrolling
    UIView *scrollBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, LANDSCAPE_CONTENT_WIDTH, self.webView.bounds.size.height)];
    scrollBackground.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    scrollBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background.png"]];
    [self.backgroundView insertSubview:scrollBackground atIndex:0];
    
    [self listenToWebViewScrollEvents];
    [self readJavascriptLogger]; // todo: where should this get called? is it okay here?
    
    [self setPeekStatusText];
    [self.webView.scrollView insertSubview:self.versionNumber atIndex:1];
    self.versionNumber.frame = CGRectMake(self.versionNumber.frame.origin.x, -180, 
                                          self.versionNumber.frame.size.width, self.versionNumber.frame.size.height);
    
    [self setUpHighlightContextMenuItem];
    self.highlightViews = [NSMutableArray array];
    [self.backgroundView bringSubviewToFront:self.highlightContainer];
    
    self.answerLoadingOverlay.alpha = 0;
    [self setUpGestureRecognizers];
}
-(void)getBoolVarForWidth:(BOOL)var
{
    boolViewWidthVar=var;
}
- (void)dealloc {
    self.titleDisplayView = nil;
	self.logoImageView = nil;
    self.webView.delegate = nil;
    self.webView = nil;
    self.loadingOverlayView  = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self notifyWebViewContentOfOrientation:toInterfaceOrientation];
    [self layOutWebViewForOrientation:toInterfaceOrientation];
    self.loadingOverlayBackgroundView.hidden = UIInterfaceOrientationIsPortrait(toInterfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
    
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation) || !self.delegate.leftNavViewIsOpen) {
        for (HighlightView *highlightView in self.highlightViews) {
            [highlightView willRotateToInterfaceOrientation:toInterfaceOrientation];
        }
    }
}

#pragma mark Actions

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    if (sel_isEqual(action, @selector(highlight:))) {
        if ([self.delegate.book currentConceptIsInTextbook]) {
            return [@"false" isEqualToString:[self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.isSelectionOverlappingExistingHighlight();"]];
        } else {
            return NO;
        }
    }
    return [super canPerformAction:action withSender:sender];
}

- (void)didTapBackground {
	[self.webView stringByEvaluatingJavaScriptFromString:@"Halo.dismissAllTooltips();"];
    self.activeHighlightView = nil;
    
    [self.titleDisplayView hide];
    self.titleDisplayView = nil;
}

#pragma mark - UIWebViewDelegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    if (navigationType == UIWebViewNavigationTypeLinkClicked || (navigationType == UIWebViewNavigationTypeFormSubmitted && request.URL.isFileURL)) {
		[self.delegate handleRequest:request];
		return NO;
    } else {
        return YES;
	}
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {

    [self showWebViewWithNewContent];
    self.logoImageView.alpha = 0;

    [UIView animateWithDuration:0.4 delay:0.5 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.loadingOverlayView.alpha = 0;
    } completion:nil];
	
	if ([self.delegate.book currentConceptIsInGlossary]) {
		NSString *concept = [[[[webView request] URL] lastPathComponent] stringByReplacingOccurrencesOfString:@".html" withString:@""];
        [webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.loadSuggestedQuestionsForConcept('%@', '%@');", concept, [Aura hostName]]];
        
        // check for c-map and remove button if there isn't one (HACKY)
        NSString *containingFolder = [webView.request.URL.path stringByDeletingLastPathComponent];
        NSString *fileExtension = [webView.request.URL.path pathExtension];
        NSString *fileName = [[webView.request.URL.path lastPathComponent] stringByDeletingPathExtension];
        NSString *newFileName = [fileName stringByAppendingString:@"_RelationGraph"];
        NSString *pathForCMap = [containingFolder stringByAppendingPathComponent:[newFileName stringByAppendingPathExtension:fileExtension]];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:pathForCMap] == NO){
            [webView stringByEvaluatingJavaScriptFromString:@"$('#show-graph-button').hide();"];
        }
    }
   
    [[HaloApplicationDelegate app] saveStateToArchive];
    
    [self refreshYOffsetsOfHighlightViews];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (error) {
		NSLog(@"Web view load failed with error: %@", error);
        NSString *failedUrl = [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey];
//        failedUrl = failedUrl.pathComponents.lastObject;
		[webView loadHTMLString:[NSString stringWithFormat:@"<html><body style='width:620px;margin:40px auto;font-family:Helvetica;word-break:break-all;'><p><em>%@</em></p><p>%@</p><p>%@</p></body></html>",
                                 [error localizedDescription], failedUrl, @"Tap the back arrow to return to the previous page."] baseURL:nil];
	}
}


#pragma mark Other WebView stuff

- (void)showWebViewWithNewContent {
    
    self.delegate.book.currentConcept = self.loadingConcept;
    [self notifyWebViewContentOfOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    //[self layOutWebViewForOrientation:self.interfaceOrientation];
    
    // scroll the page, if necessary
    self.verticalContentOffset = 0;
    if (self.temporaryWebContentFragment) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scroll(0, $('#%@').offset().top);", self.temporaryWebContentFragment]];
        self.temporaryWebContentFragment = nil;
        self.delegate.history.current.scrollOffset = self.verticalContentOffset;
    } else {
        if (self.delegate.history.current.scrollOffset > PANELHEIGHT) {
            // scroll a bit more and show "alert" with page title
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scroll(0, %.2f);", self.delegate.history.current.scrollOffset - PANELHEIGHT]];
            self.titleDisplayView = [AJNotificationView showNoticeInView:self.webView.scrollView title:self.loadingConcept.titleAndNumber top:self.webView.scrollView.contentOffset.y hideAfter:10];
            if ([self.delegate.book conceptIsAnswer:self.loadingConcept]) {
                self.titleDisplayView.backgroundColor = [UIColor colorWithRed:0.824 green:0.839 blue:0.859 alpha:1.000];
            }
        } else {
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"window.scroll(0, %.2f);", self.delegate.history.current.scrollOffset]];
        }
    }
    
    [self layOutWebViewForOrientation:[UIApplication sharedApplication].statusBarOrientation];
    
    if ([self.delegate.book conceptIsAnswer:self.loadingConcept]) {
        self.grayScrollViewBackgroundView.hidden = NO;
    } else {
        self.grayScrollViewBackgroundView.hidden = YES;
    }

    self.loadingConcept = nil;
    [self showCurrentHighlights];
    
    [self.delegate didLoadConcept:self.delegate.book.currentConcept];
}


- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script andRefreshHighlights:(BOOL)refresh {
    NSString *retval = [self.webView stringByEvaluatingJavaScriptFromString:script];
    
    if (retval && refresh) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.dismissAllTooltips();"];
        [self refreshYOffsetsOfHighlightViews];
    }
    return retval;
}

- (NSString *)stringByEvaluatingJavaScriptFromString:(NSString *)script {
    return [self stringByEvaluatingJavaScriptFromString:script andRefreshHighlights:NO];
}

- (BOOL)loading {
    return self.webView.loading;
}

- (void)highlight:(id)sender {
    [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.highlightSelection(); window.getSelection().removeAllRanges();"];
    [self getCreatedHighlight];
    
    // toggle editing to remove text selection handles (hack)
    self.webView.userInteractionEnabled = NO;
    self.webView.userInteractionEnabled = YES;
}

#pragma mark debug javascript
- (void)readJavascriptLogger {
    NSString *msg;
    while( (msg = [self.webView stringByEvaluatingJavaScriptFromString:@"console.shift();"]) != NULL && [msg length] != 0) {
        NSLog(@"JAVASCRIPT LOG, MAIN WEB VIEW: %@", msg);
    }
    [self performSelector:@selector(readJavascriptLogger) withObject:nil afterDelay:0.1];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    self.verticalContentOffset = scrollView.contentOffset.y;

    for (HighlightView *highlightView in self.highlightViews) {
        [highlightView scrollToOffset:self.verticalContentOffset];
    }
    
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidScroll:)]) {
        [self.originalScrollDelegate scrollViewDidScroll:scrollView];
    }
    
	if (!self.loadingConcept) {
		self.delegate.history.current.scrollOffset = self.verticalContentOffset;
        
        if (self.titleDisplayView) {
            [self.titleDisplayView hide];
            self.titleDisplayView = nil;
        }
	}
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidZoom:)]) {
        [self.originalScrollDelegate scrollViewDidZoom:scrollView];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewWillBeginDragging:)]) {
        [self.originalScrollDelegate scrollViewWillBeginDragging:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidEndDragging:willDecelerate:)]) {
        [self.originalScrollDelegate scrollViewDidEndDragging:scrollView willDecelerate:decelerate];
    }
}

- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewWillBeginDecelerating:)]) {
        [self.originalScrollDelegate scrollViewWillBeginDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidEndDecelerating:)]) {
        [self.originalScrollDelegate scrollViewDidEndDecelerating:scrollView];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidEndScrollingAnimation:)]) {
        [self.originalScrollDelegate scrollViewDidEndScrollingAnimation:scrollView];
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(viewForZoomingInScrollView:)]) {
        return [self.originalScrollDelegate viewForZoomingInScrollView:scrollView];
    }
    return nil;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewWillBeginZooming:withView:)]) {
        [self.originalScrollDelegate scrollViewWillBeginZooming:scrollView withView:view];
    }
}
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidEndZooming:withView:atScale:)]) {
        [self.originalScrollDelegate scrollViewDidEndZooming:scrollView withView:view atScale:scale];
    }
}

- (BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView {
    // || self.delegate.popoverController 
    if (self.presentedViewController || self.delegate.presentedViewController || self.paintingView) {
        return NO;
    }
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewShouldScrollToTop:)]) {
        return [self.originalScrollDelegate scrollViewShouldScrollToTop:scrollView];
    }
    return YES;
}

- (void)scrollViewDidScrollToTop:(UIScrollView *)scrollView {
    if ([self.originalScrollDelegate respondsToSelector:@selector(scrollViewDidScrollToTop:)]) {
        [self.originalScrollDelegate scrollViewDidScrollToTop:scrollView];
    }
}

#pragma mark - HighlightPaintingViewDelegate
- (CGFloat)calculateVerticalContentOffsetForJavascript {
    if ([[[UIDevice currentDevice] systemVersion] compare:@"5.0" options:NSNumericSearch] == NSOrderedAscending) {
        // for versions older than 5.0, return the saved verticalContentOffset
        return self.verticalContentOffset;
    } else {
        // for iOS 5+, there's no need to do an offset for the HighlightPaintingViewDelegate JS calls
        return 0;
    }
}

- (void)didBeginHighlightStrokeAtPoint:(CGPoint)point {
    NSString *response = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
    if ([response isEqualToString:@"true"]) {
        self.highlightState = HighlightStateValidUnstarted;
        response = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
        if ([response isEqualToString:@"true"]) {
            self.highlightState = HighlightStateValidStarted;
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
        }
    } else {
        self.highlightState = HighlightStateInvalid;
    }
}

- (void)updateHighlightStrokeAtPoint:(CGPoint)point {
    if (self.highlightState == HighlightStateInvalid) {
        [self didBeginHighlightStrokeAtPoint:point];
    } else if (self.highlightState == HighlightStateValidUnstarted) {
        NSString *response = [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
        if ([response isEqualToString:@"true"]) {
            self.highlightState = HighlightStateValidStarted;
            [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
        }
    } else if (self.highlightState == HighlightStateValidStarted) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
    }
}

- (void)didEndHighlightStrokeAtPoint:(CGPoint)point {
    if (self.highlightState == HighlightStateValidStarted) {
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", point.x - self.horizontalContentOffset, point.y + [self calculateVerticalContentOffsetForJavascript]]];
    }
    
    if (self.highlightState) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.touchEventHandler.touchesEnded();"];
        if (self.highlightState == HighlightStateValidStarted) {
            [self getCreatedHighlight];
            [self goToReadingMode];
        }
    }
}

#pragma mark Modes

- (void)goToHighlightMode {
	if (!self.webView.loading) {
		[self.webView stringByEvaluatingJavaScriptFromString:@"Halo.dismissAllTooltips();"];
        self.webView.scrollView.panGestureRecognizer.enabled = NO;
        
		self.activeHighlightView = nil;
        
		for (HighlightView *highlightView in self.highlightViews) {
			highlightView.stickieView.enabled = NO;
		}
        
		[self addHighlightModeOverlayView];
	}
}

- (void)goToReadingMode {
	for (HighlightView *highlightView in self.highlightViews) {
		highlightView.stickieView.enabled = YES;
	}
    
    self.webView.scrollView.panGestureRecognizer.enabled = YES;
    [self removeHighlightModeOverlayView];
    [self.delegate goToReadingMode];
}


- (void)leftViewDidOpen {
    self.highlightContainer.alpha = 0;
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, NAV_PANEL_WIDTH+1);
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.userInteractionEnabled = YES;
}

- (void)leftViewIsPanning {
    self.highlightContainer.alpha = 1;
    self.webView.scrollView.scrollEnabled = NO;
    self.webView.userInteractionEnabled = NO;
}

- (void)leftViewDidClose {
    self.highlightContainer.alpha = 1;
    self.webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
    self.webView.scrollView.scrollEnabled = YES;
    self.webView.userInteractionEnabled = YES;
}

- (void)highlightViewOpacity:(CGFloat)opacity {
//    for (HighlightView *highlightView in self.highlightViews) {
//        highlightView.alpha = opacity;
    //    }
    self.highlightContainer.alpha = opacity;
}

#pragma mark - HighlightViewDelegate

- (void)setActiveHighlightView:(HighlightView *)highlightView {
	if (self.activeHighlightView != highlightView) {
        if ([self.highlightViews containsObject:self.activeHighlightView]) {
            [self.activeHighlightView deactivate];
        }
		[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.highlighter.defocusHighlights();"]];
        
		activeHighlightView_ = highlightView;
		[activeHighlightView_ activate];
        
		if (self.activeHighlightView) {
            [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.dismissAllTooltips();"];
			[self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.highlighter.focusHighlight(%@);", self.activeHighlightView.highlight.index]];
            
            [self.delegate performSelector:@selector(dismissNavigationView) withObject:nil afterDelay:0.1]; // I don't know if I like this behavior or not :-/
		}
	}
}

- (void)removeHighlight:(Highlight *)highlight {
    [self.delegate.book.currentConcept removeHighlight:highlight];
    
    self.activeHighlightView = nil;
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"Halo.highlighter.removeHighlight(%@);", highlight.index]];
    
    HighlightView *highlightView = [self viewForHighlight:highlight];
	[highlightView removeFromSuperview];
	[self.highlightViews removeObject:highlightView];
	[self refreshHighlightViewsAtYOffset:highlight.yOffset];
    
    [[HaloApplicationDelegate app] saveStateToArchive];
}

- (void)scrollToHighlight:(HighlightView *)highlightView {
    CGFloat padding = 10;
    CGRect frame = CGRectMake(10, highlightView.frame.origin.y + self.verticalContentOffset - padding, 100, highlightView.frame.size.height + 360 + padding*2);
    [self.webView.scrollView scrollRectToVisible:frame animated:YES];
}

- (void)highlightViewDeactivated:(HighlightView *)highlightView {
    [self refreshHighlightViewsAtYOffset:highlightView.highlight.yOffset];
}

- (void)requestAnswerToQuestion:(NSString *)question {
//    self.question = [[question copy] autorelease];
    [self.delegate requestAnswerToQuestion:question];
}

- (CGFloat)stickieViewHorizontalOffsetForHighlight:(Highlight *)highlight withIncrement:(CGFloat)increment {
	return [self stickieViewHorizontalOffsetForHighlight:highlight withIncrement:increment andOnlyCountNotes:NO];
}

- (CGFloat)stickieViewHorizontalOffsetForHighlight:(Highlight *)highlight withIncrement:(CGFloat)increment andOnlyCountNotes:(BOOL)onlyCountNotes {
    CGFloat defaultHorizontalOffset = 0;
    CGFloat additionalStickieOffset = increment;
    __block NSUInteger count = 0;
	__block BOOL encounteredSelf = NO;
    
    [self.delegate.book.currentConcept.highlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Highlight *enumeratedHighlight = (Highlight *)obj;
		if(enumeratedHighlight == highlight) {
			encounteredSelf = YES;
		}
		if (enumeratedHighlight != highlight && enumeratedHighlight.yOffset == highlight.yOffset) {
			if (enumeratedHighlight.xOffset < highlight.xOffset ||
                (enumeratedHighlight.xOffset == highlight.xOffset && !encounteredSelf)) {
				if (!onlyCountNotes || enumeratedHighlight.notecardText.length) {
					++count;
				}
			}
        }
    }];
    
    return defaultHorizontalOffset + additionalStickieOffset * count;
}

- (BOOL)hasMultipleHighlightsAtHighlight:(Highlight *)highlight {
    __block BOOL hasMultipleHighlights = NO;
    
    [self.delegate.book.currentConcept.highlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Highlight *enumeratedHighlight = (Highlight *)obj;
        if (enumeratedHighlight == highlight) {
            ;
        } else if (enumeratedHighlight.yOffset == highlight.yOffset) {
            hasMultipleHighlights = YES;
            *stop = YES;
        }
    }];
    
    return hasMultipleHighlights;
}

#pragma mark Private Highlight stuff

- (void)showCurrentHighlights {
    for (int i = 0; i < [self.delegate.book.currentConcept.highlights count]; ++i) {
        Highlight *highlight = [self.delegate.book.currentConcept.highlights objectAtIndex:i];
        
        highlight.index = [NSString stringWithFormat:@"%d", i];
        [self addViewForHighlight:highlight];
        [self addHighlightIntoContent:highlight];
    }
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.addMarkupForAllHighlights();"];
}

- (void)addHighlightIntoContent:(Highlight *)highlight {
    NSString *escapedJSON = [self stringByEscapingJSONString:highlight.rangeJSON];
    NSString *js = [NSString stringWithFormat:@"var highlight = Halo.Highlight.fromJSON(%@, \"%@\"); Halo.highlighter.addHighlight(highlight);", highlight.index, escapedJSON];
    
    [self.webView stringByEvaluatingJavaScriptFromString:js];
}

- (NSString *)stringByEscapingJSONString:(NSString *)json {
    NSString *escapedJSON = [json stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    return [escapedJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
}

- (HighlightView *)viewForHighlight:(Highlight *)highlight {
    for (HighlightView *highlightView in self.highlightViews) {
        if (highlightView.highlight == highlight) {
            return highlightView;
        }
    }
    return nil;
}


- (void)getCreatedHighlight {
    // TODO: return JSON and have the Highlight object parse it.
    NSString *highlightIndex = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.index;"];
    NSString *highlightXOffset = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.xOffset;"];
    NSString *highlightYOffset = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.yOffset;"];
    NSString *highlightHeight = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.height;"];
    NSString *highlightText = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.text;"];
    NSString *highlightSection = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.section;"];
	NSString *currentFilename = [[self.webView.request URL] lastPathComponent];
    NSString *highlightRangeJSON = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.currentHighlight.rangeJSON;"];
    NSString *previousHighlightIndex = [self.webView stringByEvaluatingJavaScriptFromString:@"Halo.highlighter.precedingSiblingHighlightIndex;"];
    Highlight *highlight = [Highlight highlightWithIndex:highlightIndex
                                                 xOffset:[highlightXOffset floatValue]
                                                 yOffset:[highlightYOffset floatValue]
                                                  height:[highlightHeight floatValue]
                                                    text:highlightText
                                                 section:[NSString stringWithFormat:@"%@#%@", currentFilename, highlightSection]
                                                   color:[Highlight YELLOW]
                                               rangeJSON:highlightRangeJSON];
    
    NSLog(@"made highlite with index %@", highlightIndex);
    
    [self.delegate.book.currentConcept insertHighlight:highlight beforeHighlightWithIndex:previousHighlightIndex];
    [Logger log:@"Created highlight:" withArguments:highlightText];
    
    HighlightView *newHighlightView = [self addViewForHighlight:highlight];
	if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
		[newHighlightView showSuggestedQuestions];
		
		// animate in the card
		newHighlightView.frame = CGRectMake(self.highlightContainer.frame.size.height, newHighlightView.frame.origin.y, newHighlightView.frame.size.width, newHighlightView.frame.size.height);
		[UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
			newHighlightView.frame = CGRectMake(LANDSCAPE_ORIGIN_X, newHighlightView.frame.origin.y, newHighlightView.frame.size.width, newHighlightView.frame.size.height);
		} completion:nil ];
	}
    else
    {
        [newHighlightView showSuggestedQuestions];
        
        // animate in the card
        newHighlightView.frame = CGRectMake(self.highlightContainer.frame.size.height, newHighlightView.frame.origin.y, newHighlightView.frame.size.width, newHighlightView.frame.size.height);
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            newHighlightView.frame = CGRectMake(PORTRAIT_ORIGIN_X, newHighlightView.frame.origin.y, newHighlightView.frame.size.width, newHighlightView.frame.size.height);
        } completion:nil ];
    }
    [[HaloApplicationDelegate app] saveStateToArchive];
}

- (HighlightView *)addViewForHighlight:(Highlight *)highlight {
    HighlightView *highlightView = [[HighlightView alloc] initWithHighlight:highlight orientation:[[UIApplication sharedApplication] statusBarOrientation] delegate:self];
    [highlightView scrollToOffset:self.verticalContentOffset];
    
    [self.highlightContainer addSubview:highlightView];
    [self.highlightViews addObject:highlightView];
    
    [self refreshHighlightViewsAtYOffset:highlight.yOffset];
    
    return highlightView;
}

- (void)removeSupplementaryViews {
    for (HighlightView *highlightView in self.highlightViews) {
        [highlightView removeFromSuperview];
    }
    [self.highlightViews removeAllObjects];
    self.activeHighlightView = nil;
}

- (void)refreshYOffsetsOfHighlightViews {
    for (HighlightView *highlightView in self.highlightViews) {
        NSString *highlightYOffset = [self.webView stringByEvaluatingJavaScriptFromString:
                                      [NSString stringWithFormat:@"Halo.highlighter.getHighlight(%@).yOffset;", highlightView.highlight.index]];
        if (highlightView.highlight.yOffset != [highlightYOffset floatValue]) {
            highlightView.highlight.yOffset = [highlightYOffset floatValue];
			[highlightView scrollToOffset:self.verticalContentOffset];
        }
    }
}

- (void)refreshHighlightViewsAtYOffset:(CGFloat)yOffset {
    __weak NSMutableArray *matchingHighlights = [NSMutableArray array];
    
    [self.delegate.book.currentConcept.highlights enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        Highlight *enumeratedHighlight = (Highlight *)obj;
        if (enumeratedHighlight.yOffset == yOffset) {
            [matchingHighlights addObject:enumeratedHighlight];
        }
    }];
    
    [matchingHighlights sortUsingComparator:^(id obj1, id obj2) {
        if (((Highlight *)obj1).xOffset > ((Highlight *)obj2).xOffset) {
            return (NSComparisonResult)NSOrderedDescending;
        } else {
            return (NSComparisonResult)NSOrderedAscending;
        }
    }];
    
    for (unsigned int i = 0; i < [matchingHighlights count]; ++i) {
		Highlight *highlight = [matchingHighlights objectAtIndex:i];
        HighlightView *highlightView = [self viewForHighlight:highlight];
        [highlightView updateStickieViewHorizontalOffset];
        [highlightView refresh];
        [self.highlightContainer bringSubviewToFront:highlightView];
    }
}

#pragma mark Highlighter overlay
- (void)addHighlightModeOverlayView {
    CGRect rect = self.backgroundView.frame;// CGRectMake(0, self.navigationBar.bounds.size.height, self.view.bounds.size.width, self.view.bounds.size.height - self.navigationBar.bounds.size.height);
    
    if (self.paintingView) {
        [self removeHighlightModeOverlayView];
    }
    
    self.paintingView = [[HighlightPaintingView alloc] initWithFrame:rect andDelegate:self];
    [self.backgroundView addSubview:self.paintingView];
}

- (void)removeHighlightModeOverlayView {
    [self.paintingView removeFromSuperview];
    self.paintingView = nil;
    self.highlightState = HighlightStateInvalid;
	self.webView.userInteractionEnabled = YES;
}


- (void)showAnswerOverlay:(BOOL)show withText:(NSString *)text animated:(BOOL)animate {
    boolViewWidthVar=show;
    self.answerOverlayLabel.text = [NSString stringWithFormat:@"%@", text];
    if (show) self.answerLoadingOverlay.alpha = 1;
    [UIView animateWithDuration:0.2 animations:^{
        self.loadingOverlayView.alpha = (show) ? 1 : 0;
    } completion:^(BOOL finished) {
        if (!show) self.answerLoadingOverlay.alpha = 0;
    }];
}

#pragma mark - Private interface

- (void)loadConcept:(Concept *)concept withRequest:(NSURLRequest *)request {
//    NSURL *url = [[[NSURL alloc] initFileURLWithPath:concept.path] autorelease];
//    NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
    
    NSURL *url = [[request URL] absoluteURLWithoutFragment];
    NSURLRequest *newRequest = [[NSURLRequest alloc] initWithURL:url];
    
    self.temporaryWebContentFragment = [[request URL] fragment];
    
    [UIView animateWithDuration:0.2 animations:^{
        self.answerLoadingOverlay.alpha = 0;
    }];
    self.loadingOverlayView.alpha = 1;
    
    // load new request
    [self.webView loadRequest:newRequest];
    self.loadingConcept = concept;
    
    [self removeSupplementaryViews];
//    [Logger log:@"Open page:" withArguments:[url lastPathComponent]];
    
    [self.titleDisplayView hide];
}

- (void)dispatchRequest:(NSURLRequest *)request {
    // HACK to handle the extra bits I insert into paths of answer pages :-/
    NSArray *pathComponents = [[[[request URL] path] stringByReplacingOccurrencesOfString:@"/Halo.app/textbook/" withString:@"/"] componentsSeparatedByString:@"/"];
    if ([pathComponents count] != 4) {
        NSLog(@"Error: dispatchRequest does not understand %@", request);
        return;
    }
    
    NSString *resource = [pathComponents objectAtIndex:1];
    NSString *resourceId = [pathComponents objectAtIndex:2];
    NSString *action = [pathComponents objectAtIndex:3];
    
    if ([resource isEqualToString:@"highlights"]) {
        int index = -1;
        for (int i = 0; i < [self.highlightViews count]; ++i) {
            HighlightView *highlightView = [self.highlightViews objectAtIndex:i];
            if ([highlightView.highlight.index isEqualToString:resourceId]) {
                index = i;
                break;
            }
        }
        if ([action isEqualToString:@"focus"]) {
            self.activeHighlightView = [self.highlightViews objectAtIndex:index];
        } else if ([action isEqualToString:@"defocus"]) {
            self.activeHighlightView = nil;
        }
    } else if ([resource isEqualToString:@"glossary"]) {
        if ([action isEqualToString:@"showPopup"]) {
            [Logger log:@"Viewed glossary popup:" withArguments:[resourceId stringByDeletingPathExtension]];
        }
    }
}

- (void)layOutWebViewForOrientation:(UIInterfaceOrientation)interfaceOrientation {
    CGFloat left, width, bgWidth;
    
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        left = 0.0;
        bgWidth = PORTRAIT_CONTENT_WIDTH;
        
        CGFloat scrollbarOffset = ([self.delegate.book currentConceptIsInTextbook]) ? SCROLLBAR_WIDTH : 0;
        width = PORTRAIT_CONTENT_WIDTH - scrollbarOffset;
        self.webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background.png"]];
        self.webView.opaque = YES;
    } else { // landscape
        if (boolViewWidthVar) {
            bgWidth = LANDSCAPE_CONTENT_WIDTH;
        }
        else
        {
            bgWidth = LANDSCAPE_CONTENT_WIDTH_forSideImage;
        }
       
        left = 0.0;
       
        if ([self.delegate.book currentConceptIsInTextbook]
            || [self.delegate.book currentConceptIsInGlossary]) {
            self.webView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"textbook-background.png"]];
            self.webView.opaque = YES;
                    if (boolViewWidthVar) {
                       width = LANDSCAPE_CONTENT_WIDTH;
                    }
                    else
                    {
                         width=LANDSCAPE_CONTENT_WIDTH_forSideImage;
                    
                    }
            
           // width = LANDSCAPE_CONTENT_WIDTH;
        } else {
            self.webView.backgroundColor = [UIColor clearColor];
            self.webView.opaque = NO;
            
            if (boolViewWidthVar) {
                width=LANDSCAPE_CONTENT_WIDTH - TOOLBAR_WIDTH;
            }
            else
            {
                width = LANDSCAPE_CONTENT_WIDTH_forSideImage - TOOLBAR_WIDTH;
            }

            //width = LANDSCAPE_WIDTH - TOOLBAR_WIDTH;
        }
    }
    self.horizontalContentOffset = left;
    self.webView.frame = CGRectMake(self.webView.frame.origin.x, self.webView.frame.origin.y, width, self.webView.frame.size.height);
    self.titleDisplayView.frame = CGRectMake(0, self.titleDisplayView.frame.origin.y, bgWidth, self.titleDisplayView.frame.size.height);
    self.grayScrollViewBackgroundView.frame = CGRectMake(self.grayScrollViewBackgroundView.frame.origin.x,
                                                         self.grayScrollViewBackgroundView.frame.origin.y,
                                                         bgWidth, self.grayScrollViewBackgroundView.frame.size.height);
}

- (void)listenToWebViewScrollEvents {
    self.originalScrollDelegate = nil;
    [self interceptScrollViewEventsFrom:self.webView.scrollView];
}

- (void)notifyWebViewContentOfOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.className = 'portrait';"];
    } else {
        [self.webView stringByEvaluatingJavaScriptFromString:@"document.body.className = 'landscape';"];
    }
}

- (void)interceptScrollViewEventsFrom:(UIScrollView *)eventSource {
    if ([eventSource delegate] != self) {
        self.originalScrollDelegate = [eventSource delegate];
        [eventSource setDelegate:self];
    }
}

- (void)setPeekStatusText {
	self.versionNumber.lineBreakMode = NSLineBreakByWordWrapping;
	self.versionNumber.numberOfLines = 3;
	self.versionNumber.text = [NSString stringWithFormat:@"Inquire %@ (build %@) \ndevice: %@ \nserver: %@",
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                               [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                               [Aura deviceID], [Aura hostName]];
}


- (void)setUpHighlightContextMenuItem {
    UIMenuItem *highlightMenuItem = [[UIMenuItem alloc] initWithTitle:@"Highlight" action:@selector(highlight:)];
    [UIMenuController sharedMenuController].menuItems = [NSArray arrayWithObject:highlightMenuItem];
}

#pragma mark - Gesture recognizers
- (void)setUpGestureRecognizers {
    
    // background sends scroll events to webview :)
    [self.backgroundView addGestureRecognizer:self.webView.scrollView.panGestureRecognizer];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
    tapRecognizer.delegate = self;
    [self.webView addGestureRecognizer:tapRecognizer];
    
//    // two-finger double-tap to highlight gesture
//    UITapGestureRecognizer *recognizer = [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTapGesture:)] autorelease];
//    recognizer.delegate = self;
//    recognizer.numberOfTapsRequired = 2;
//    recognizer.numberOfTouchesRequired = 2;
//    [self.backgroundView addGestureRecognizer:recognizer];
    
    // ten-finger double-tap to crash the app :P
    // TODO: disable this in final version!
    UITapGestureRecognizer *tenRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTenFingerDoubleTapGesture:)];
    tenRecognizer.delegate = self;
    tenRecognizer.numberOfTapsRequired = 2;
    tenRecognizer.numberOfTouchesRequired = 10;
    [self.backgroundView addGestureRecognizer:tenRecognizer];
    
//    // long-press to highlight gesture
//    UILongPressGestureRecognizer *lpRecognizer = [[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)] autorelease];
//    lpRecognizer.delegate = self;
//    lpRecognizer.numberOfTapsRequired = 0;
//    lpRecognizer.minimumPressDuration = 0.5;
//    [self.webView addGestureRecognizer:lpRecognizer];
}

-  (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)handleTapGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    [self.titleDisplayView hide];
    self.titleDisplayView = nil;
}

- (void)handleLongPressGesture:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint touch = [gestureRecognizer locationOfTouch:0 inView:self.webView];
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            if (touch.x > 0 && touch.y > 0) {
                self.webView.scrollView.scrollEnabled = NO;
            }
            break;
        case UIGestureRecognizerStateChanged:
            if (self.paintingView)
                [self.paintingView continueHighlightAtPoint:touch];
            else {
                if (CGRectContainsPoint(self.webView.frame, touch)) {  // warning: this touch is the moved-to point, not the original touch point!
                    self.webView.userInteractionEnabled = NO;
                    [self goToHighlightMode];
                    if (self.paintingView) [self.paintingView startHighlightAtPoint:touch];
                }
            }
            break;
        case UIGestureRecognizerStateEnded:
            if (self.paintingView) [self.paintingView endHighlightAtPoint:touch];
            self.webView.scrollView.scrollEnabled = YES;
            self.webView.userInteractionEnabled = YES;
            break;
        default:
            break;
    }
    
}

- (void)handleDoubleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        [self displayTouchFeedbackImageAtPoint:[gestureRecognizer locationOfTouch:0 inView:self.webView]];
        [self displayTouchFeedbackImageAtPoint:[gestureRecognizer locationOfTouch:1 inView:self.webView]];
        
		self.webView.userInteractionEnabled = NO;
		[self performSelector: @selector(goToHighlightMode) withObject:nil afterDelay:0.15];
    }
}

- (void)handleTenFingerDoubleTapGesture:(UIGestureRecognizer *)gestureRecognizer {
    if (UIGestureRecognizerStateEnded == gestureRecognizer.state) {
        // crash the app!
        UIImage *crashImage;
        [crashImage drawAtPoint:CGPointZero];
    }
}

- (void)displayTouchFeedbackImageAtPoint:(CGPoint)point {
    UIImage *image = [[UIImage imageNamed:@"highlight-touch-feedback.png"] copy];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    imageView.frame = CGRectMake(point.x - image.size.width / 2, point.y - image.size.height / 2, image.size.width, image.size.height);
    
    [self.backgroundView addSubview:imageView];
    
//    [UIView beginAnimations:@"touch feedback" context:imageView];
//    [UIView setAnimationDuration:0.8];
//    [UIView setAnimationDelegate:self];
//    [UIView setAnimationDidStopSelector:@selector(removeTouchFeedbackImageView:finished:context:)];
//    imageView.alpha = 0;
//    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.8 animations:^{
        imageView.alpha = 0;
    } completion:^(BOOL finished) {
        [imageView removeFromSuperview];
    }];
}

//- (void)removeTouchFeedbackImageView:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
//    UIImageView *view = (UIImageView *)context;
//    [view removeFromSuperview];
//}


 
@end
