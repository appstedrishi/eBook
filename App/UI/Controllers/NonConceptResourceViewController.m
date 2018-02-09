#import "NonConceptResourceViewController.h"
#import "UIWebView+StylingExtensions.h"
#import "Logger.h"

@interface NonConceptResourceViewController ()
@property (nonatomic, strong) UIImageView *image;
@property (nonatomic, strong) UIBarButtonItem *backButton, *forwardButton;
@property (nonatomic, assign) UIInterfaceOrientation orientation;
@property (nonatomic, strong) ConceptViewController *delegate;

- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView;
- (void)handleTap:(UITapGestureRecognizer *)sender;
- (void)configureNavBar;
- (CGFloat)calculateMinZoom;
- (void)setNavBarHidden:(BOOL)hide;
@end

@implementation NonConceptResourceViewController

@synthesize webView = webView_, closeButton = closeButton_, request = request_, navigationBar = navigationBar_,
 imageScrollView = imageScrollView_, image = image_, orientation = orientation_, backButton = backButton_, 
 navigationBarItem = navigationBarItem_, forwardButton = forwardButton_, delegate = delegate_;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithRequest:(NSURLRequest *)request andDelegate:(ConceptViewController *)delegate {
    if ((self = [super initWithNibName:@"NonConceptResourceViewController" bundle:nil])) {
        self.request = request;
        self.delegate = delegate;
    }
    return self;
}

- (void)dealloc {
    self.webView = nil;
	self.image = nil;
    self.closeButton = nil;
	self.backButton = nil;
	self.forwardButton = nil;
	self.navigationBarItem.leftBarButtonItem = nil;
	self.navigationBarItem = nil;
	self.navigationBar = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	[self configureNavBar];
	
    self.webView.backgroundColor = [UIColor whiteColor];
	[self.webView removeBackgroundDropShadow];
//    [self.webView scrollView].contentInset = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
//	[self.webView scrollView].scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
	self.imageScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
		
    [self.webView loadRequest:self.request];
}

//- (void)viewDidUnload {
//    [super viewDidUnload];
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	self.orientation = toInterfaceOrientation;
	[UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNavBarHidden:) object:[NSNumber numberWithBool:YES]];
//	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self.delegate willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
	[self.navigationBar.topItem.titleView sizeToFit];
	if (self.navigationBar.alpha < 1) {
		// This (with matching setStatusBarHidden:NO in willRotateToInterfaceOrientation) works around a sizing bug related to the hidden toolbar.
//		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
	}
	if (self.image) {
		CGFloat newMinZoom = [self calculateMinZoom];
		
		[UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
		if (newMinZoom > 0) {
			if (self.imageScrollView.zoomScale < newMinZoom || self.imageScrollView.zoomScale == self.imageScrollView.minimumZoomScale) {
				[self.imageScrollView setMinimumZoomScale: newMinZoom];
				[self.imageScrollView setZoomScale: newMinZoom];
			} else {
				[self.imageScrollView setMinimumZoomScale: newMinZoom];
			}
		}
		self.image.frame = [self centeredFrameForScrollView:self.imageScrollView andUIView:self.image];
        [UIView commitAnimations];
	}
}

- (void)close:(id)sender {
	[UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNavBarHidden:) object:[NSNumber numberWithBool:YES]];
//	[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
//    [self dismissModalViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
    [Logger log:@"Closed image/cmap."];
}

- (void)goBack:(id)sender {
	if (self.webView.canGoBack) {
		[self.webView goBack];
	}
}

- (void)goForward:(id)sender {
	if (self.webView.canGoForward) {
		[self.webView goForward];
	}
}
#pragma mark UIWebView delegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
	
	// find and display the title
	NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
	
	// find the image (in a figure page) and display it in a scrollable image view
    NSString *imgSrc;
   // NSString *imgSrc = [self.webView stringByEvaluatingJavaScriptFromString:@"$('img:not(.fig-image)')[0].src"];
    
    if ([webView.request.URL.pathExtension isEqualToString:@"png"]) { // guess that this URL itself is an image
        title = @"Figure";
        imgSrc = webView.request.URL.absoluteString;
    }
    
	if (title.length > 0) {
//        [self.navigationBar setTitleVerticalPositionAdjustment:2 forBarMetrics:UIBarMetricsDefault];
//        self.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                          [UIColor whiteColor], NSForegroundColorAttributeName,
////                          [UIColor colorWithWhite:0.0 alpha:0.5], UITextAttributeTextShadowColor,
////                          [NSValue valueWithUIOffset:UIOffsetMake(0, -1)], UITextAttributeTextShadowOffset,
//                          [UIFont boldSystemFontOfSize:16.0], NSFontAttributeName,
//                          nil];
        self.navigationBar.topItem.title = title;
	}
    
	if (imgSrc.length > 0) {
		self.webView = nil;
		self.navigationBarItem.leftBarButtonItem = nil;
		
		UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
		[self.imageScrollView addGestureRecognizer:tapRecognizer];
		
		NSData* imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:imgSrc]];
		UIImage* img = [[UIImage alloc] initWithData:imageData];
       // UIImage *img = [self imageWithImage:myIcon scaledToSize:CGSizeMake(self.imageScrollView.frame.size.width-10, self.imageScrollView.frame.size.height-10)];
		self.image = [[UIImageView alloc] initWithImage:img];
		
		self.imageScrollView.contentSize = self.image.frame.size;
        
		[self.imageScrollView addSubview:self.image];
		
		self.imageScrollView.maximumZoomScale = 3.0 / [[UIScreen mainScreen] scale];
		self.imageScrollView.minimumZoomScale = [self calculateMinZoom];
		self.image.frame = [self centeredFrameForScrollView:self.imageScrollView andUIView:self.image];
        [self.imageScrollView setZoomScale:self.imageScrollView.minimumZoomScale];
		[self.imageScrollView setHidden:NO];
//		[self performSelector:@selector(setNavBarHidden:) withObject:[NSNumber numberWithBool:YES] afterDelay:2]; REMOVED AUOT-HIDE FEATURE
	} else {
		// otherwise just display the web page
		[self.webView setHidden:NO];
		[self.webView scrollView].bounces = YES;
		[self.webView scrollView].alwaysBounceHorizontal = YES;
		self.backButton.enabled = self.webView.canGoBack;
		self.forwardButton.enabled = self.webView.canGoForward;
	}
}
//Increase uiimage size
-(UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
	if (navigationType && ![request.URL.pathExtension isEqualToString:@"html"]) {
		// for non-webpages, show the web view because webViewDidFinishLoad: may not get called
		[self.webView setHidden:NO];
	}
	return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
	if (webView == self.webView && error && [error.domain isEqualToString:NSURLErrorDomain] && error.code == -1100) {
		NSLog(@"Web view load failed with error: %@", error);
		[webView loadHTMLString:[NSString stringWithFormat:@"<html><body style='margin:80px;font-family:Helvetica;'><p><em>%@</em></p><p>%@</p><p>%@</p></body></html>",
								 [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey], @"Tap 'Done' to return to the previous page."] baseURL:nil];
	}
}

#pragma mark UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return self.image;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
	self.image.frame = [self centeredFrameForScrollView:scrollView andUIView:self.image];
}

#pragma mark private methods
- (CGRect)centeredFrameForScrollView:(UIScrollView *)scroll andUIView:(UIView *)rView {
	CGSize boundsSize = self.imageScrollView.bounds.size;
	CGRect frameToCenter = CGRectMake(rView.frame.origin.x, rView.frame.origin.y, rView.frame.size.width, rView.frame.size.height);
		
	// center horizontally
	if (frameToCenter.size.width < boundsSize.width) {
		frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
	} else {
		frameToCenter.origin.x = 0;
	}
	
	// center vertically
	if (frameToCenter.size.height < boundsSize.height) {
		frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
	} else {
		frameToCenter.origin.y = 0;
	}
	return frameToCenter;
}

- (CGFloat)calculateMinZoom {
    CGFloat zoom = MIN (1 / [[UIScreen mainScreen] scale], MIN ((self.imageScrollView.frame.size.height-150) / self.image.image.size.height,
                        (self.imageScrollView.frame.size.width-150) / self.image.image.size.width));
    return zoom;
}

- (void)handleTap:(UITapGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateEnded && !self.webView.loading) {
		[UIView cancelPreviousPerformRequestsWithTarget:self selector:@selector(setNavBarHidden:) object:[NSNumber numberWithBool:YES]];
		[self setNavBarHidden:(self.navigationBar.alpha > 0)];
	}
}

- (void)configureNavBar {
	UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 96, 44)];
    toolbar.barStyle = UIBarStyleDefault;
    if (toolbar.subviews.count > 0) [[toolbar.subviews objectAtIndex:0] removeFromSuperview];

	
	UIImage *backImage = [UIImage imageNamed:@"back-icon.png"];
	UIImage *forwardImage = [UIImage imageNamed:@"forward-icon.png"];
	
	self.backButton = [[UIBarButtonItem alloc] initWithImage:backImage
                                             style:UIBarButtonItemStylePlain
                                            target:self
											action:@selector(goBack:)];
	self.forwardButton = [[UIBarButtonItem alloc] initWithImage:forwardImage
														style:UIBarButtonItemStylePlain
													   target:self
													   action:@selector(goForward:)];
	
	NSMutableArray* buttons = [[NSMutableArray alloc] initWithCapacity:2];
	[buttons addObject:self.backButton];
	[buttons addObject:self.forwardButton];
	toolbar.items = buttons;
	
	self.backButton.enabled = NO;
	self.forwardButton.enabled = NO;
	
	self.navigationBarItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];	
}

- (void)setNavBarHidden:(BOOL)hide {
	
	BOOL isHidden = self.navigationBar.alpha < 1;
	if (hide == isHidden) {
		return;
	}
	
	[UIView animateWithDuration:0.4 animations:^{
//		[[UIApplication sharedApplication] setStatusBarHidden:hide withAnimation:UIStatusBarAnimationNone];
		self.navigationBar.alpha = hide ? 0 : 1;
		if (hide) {
			self.imageScrollView.scrollIndicatorInsets = UIEdgeInsetsZero;
		} else {
			self.imageScrollView.scrollIndicatorInsets = UIEdgeInsetsMake(self.navigationBar.frame.size.height, 0, 0, 0);
		}
	}];
	
}

@end
