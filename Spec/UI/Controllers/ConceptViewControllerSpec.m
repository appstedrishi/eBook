#import "SpecHelper+Halo.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import <objc/runtime.h>
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"
#import "HCEmptyContainer.h"
#import "NSURL+PathExtensions.h"
#import "UIView+FindSubviews.h"
#import "UIWebView+Spec.h"

#import "ConceptViewController.h"
#import "Question.h"
#import "Highlight.h"
#import "HighlightView.h"
#import "SuggestedQuestionsView.h"

#import "HTMLContentVerifier.h"
#import "MockArgumentRecorder.h"
#import "Concept.h"
#import "Book.h"
#import "History.h"
#import "NonConceptResourceViewController.h"
#import "ConceptBackgroundView.h"
#import "QuestionViewController.h"
#import "AnswerViewController.h"
#import "CustomNavigationBar.h";

static UIInterfaceOrientation controllerOrientation = UIInterfaceOrientationLandscapeRight;

@interface Book (ConceptViewControllerSpec)
@property (nonatomic, retain) NSMutableArray *orderedConcepts;
@end

@interface ConceptViewController (ConceptViewControllerSpec)

@property (nonatomic, retain) Question *question;
@property (nonatomic, retain) NSMutableString *answer;
@property (nonatomic, assign) CGFloat verticalContentOffset;
@property (nonatomic, assign) CGFloat horizontalContentOffset;
@property (nonatomic, assign) BOOL questionViewVisible;
@property (nonatomic, assign) BOOL inSwipeAnimation;
@property (nonatomic, retain) NSMutableArray *highlightViews;

- (UIWebView *)createTemporaryWebView;
- (NonConceptResourceViewController *)createNonConceptResourceViewControllerForRequest:(NSURLRequest *)request;
- (QuestionViewController *)createQuestionViewControllerWithKeywords:(NSString *)keywords andQuestion:(Question *)question;
- (void)loadRequest:(NSURLRequest *)request withHistory:(BOOL)history;
- (void)highlight:(id)sender;
- (void)didSwipeLeft:(UISwipeGestureRecognizer *)recognizer;
- (void)didSwipeRight:(UISwipeGestureRecognizer *)recognizer;
- (void)swapWebViews;
- (void)getCreatedHighlight;
- (void)goToReadingMode;
- (void)refreshHighlightViewsAtYOffset:(CGFloat)yOffset;

@end

SPEC_BEGIN(ConceptViewControllerSpec)

describe(@"ConceptViewController", ^{
    NSMutableDictionary *sharedExampleContext = [SpecHelper specHelper].sharedExampleContext;
    CGFloat scrollOffset = 473.1;
    __block ConceptViewController *controller;
    __block OCMockObject *mockController;
    __block Concept *someConcept, *someOtherConcept, *someGlossaryConcept;
    __block id stubController;
	__block id navBarBackground;

    beforeEach(^{
        controller = [[ConceptViewController alloc] init];
        controller.book = [[SpecHelper specHelper] createBook];
        controller.question = [[[Question alloc] init] autorelease];

        someConcept = [controller.book.orderedConcepts objectAtIndex:2];
        someOtherConcept = [controller.book.orderedConcepts objectAtIndex:5];
        someGlossaryConcept = [controller.book.glossaryConcepts objectAtIndex:3];

        NSArray *concepts = [NSArray arrayWithObjects:someConcept, someOtherConcept, someGlossaryConcept, nil];
        NSArray *scrollOffsets = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0], [NSNumber numberWithFloat:scrollOffset], [NSNumber numberWithFloat:0], nil];

        controller.history = [[SpecHelper specHelper] createHistoryWithConcepts:concepts andScrollOffsets:scrollOffsets];

        [controller goBack];
        [controller goBack];
        [controller goForward];

        stubController = [OCMockObject partialMockForObject:controller];
        void (^returnControllerOrientation)(NSInvocation *) = ^(NSInvocation *invocation) {
            [invocation setReturnValue:&controllerOrientation];
        };
        [[[stubController stub] andDo:returnControllerOrientation] interfaceOrientation];

        assertThat(controller.view, notNilValue());
        [controller.temporaryWebView setReturnValue:@"-1" forJavaScript:@"Halo.highlighter.precedingSiblingHighlightIndex;"];
		navBarBackground = controller.navigationBar.backgroundImage;
    });

    afterEach(^{
        [controller release];
    });

    sharedExamplesFor(@"an action that displays the modal question / answer view", ^(NSDictionary *context) {
        __block void (^executeAction)();
		__block Question *question;

        beforeEach(^{
            executeAction = [context objectForKey:@"executeAction"];
			question = [context objectForKey:@"question"];
        });

        describe(@"navigation controller", ^{

            it(@"should display the appropriate question/answer view controller", ^{
                [[stubController expect] presentModalViewController:[OCMArg checkWithBlock:^(id childController) {
                    if ([childController isKindOfClass:[UINavigationController class]]) {
                        if (controller.answer.length) {
                            return (BOOL)[[childController topViewController] isKindOfClass:[AnswerViewController class]];
                        } else {
                            return (BOOL)[[childController topViewController] isKindOfClass:[QuestionViewController class]];
                        }
                    } else {
                        return NO;
                    }
                }] animated:YES];

                executeAction();

                [stubController verify];
            });
        });

        it(@"should pass the keywords for the current page and question to the question view controller", ^{
            NSString *keywords = @"Your mother is so fat, sir.";
            [controller.webView setReturnValue:keywords forJavaScript:@"$('.content-summary').text();"];
            [[[stubController expect] andForwardToRealObject] createQuestionViewControllerWithKeywords:keywords andQuestion:question];

            executeAction();

            [stubController verify];
        });

        it(@"should prevent the active web view from scrolling to top when the user taps the status bar", ^{
            executeAction();
            // Modal view controller property doesn't actually get set in test:
            id fakeController = [OCMockObject mockForClass:[UIViewController class]];
            [[[stubController stub] andReturn:fakeController] modalViewController];

            assertThatBool([controller scrollViewShouldScrollToTop:nil], equalToBool(NO));
        });
    });

    describe(@"outlets", ^{
        describe(@"backgroundView", ^{
            it(@"should be defined", ^{
                assertThat(controller.backgroundView, notNilValue());
            });

            it(@"should be a child of the main view", ^{
                assertThat(controller.backgroundView.superview, equalTo(controller.view));
            });

            it(@"should have the controller as its delegate", ^{
                assertThat(controller.backgroundView.delegate, equalTo(controller));
            });

			it(@"should have a left swipe gesture recognizer", ^{
				assertThatBool([[controller.backgroundView.gestureRecognizers objectAtIndex:0] direction] == UISwipeGestureRecognizerDirectionLeft, equalToBool(YES));
			});

			it(@"should have a right swipe gesture recognizer", ^{
				assertThatBool([[controller.backgroundView.gestureRecognizers objectAtIndex:1] direction] == UISwipeGestureRecognizerDirectionRight, equalToBool(YES));
			});

			it(@"should have a two-finger double-tap gesture recognizer", ^{
				assertThatBool([[controller.backgroundView.gestureRecognizers objectAtIndex:2] numberOfTapsRequired] == 2, equalToBool(YES));
				assertThatBool([[controller.backgroundView.gestureRecognizers objectAtIndex:2] numberOfTouchesRequired] == 2, equalToBool(YES));
			});
        });

        describe(@"webView", ^{
            it(@"should be defined", ^{
                assertThat(controller.webView, notNilValue());
            });

            it(@"should be a child of the background view", ^{
                assertThat(controller.webView.superview, equalTo(controller.backgroundView));
            });
        });

        describe(@"navigationBar", ^{
            it(@"should be defined", ^{
                assertThat(controller.navigationBar, notNilValue());
            });
        });

        describe(@"navigationTitle", ^{
            it(@"should be defined", ^{
                assertThat(controller.navigationTitle, notNilValue());
            });

            it(@"should be the titleView for the navigationBar's top item", ^{
                assertThat(controller.navigationTitle, equalTo(controller.navigationBar.topItem.titleView));
            });
        });

        describe(@"leftNavigationToolbar", ^{
            it(@"should be defined", ^{
                assertThat(controller.leftNavigationToolbar, notNilValue());
            });
        });

        describe(@"rightNavigationToolbar", ^{
            it(@"should be defined", ^{
                assertThat(controller.rightNavigationToolbar, notNilValue());
            });
        });

        describe(@"leftNavigationViewForHighlighting", ^{
            it(@"should be defined", ^{
                assertThat(controller.leftNavigationViewForHighlighting, notNilValue());
            });
        });

        describe(@"rightNavigationViewForHighlighting", ^{
            it(@"should be defined", ^{
                assertThat(controller.rightNavigationViewForHighlighting, notNilValue());
            });
        });

        describe(@"backButton", ^{
            it(@"should be defined", ^{
                assertThat(controller.backButton, notNilValue());
            });

            it(@"should be included on the left navigation toolbar", ^{
                assertThat(controller.leftNavigationToolbar.items, hasItem(controller.backButton));
            });

            it(@"should target the goBack method on the controller", ^{
                assertThatBool(sel_isEqual(controller.backButton.action, @selector(goBack)), equalToBool(true));
                assertThat(controller.backButton.target, equalTo(controller));
            });
        });

        describe(@"forwardButton", ^{
            it(@"should be defined", ^{
                assertThat(controller.forwardButton, notNilValue());
            });

            it(@"should be included on the left navigation toolbar", ^{
                assertThat(controller.leftNavigationToolbar.items, hasItem(controller.forwardButton));
            });

            it(@"should target the goForward method on the controller", ^{
                assertThatBool(sel_isEqual(controller.forwardButton.action, @selector(goForward)), equalToBool(true));
                assertThat(controller.forwardButton.target, equalTo(controller));
            });
        });
    });

    describe(@"viewDidLoad", ^{
        describe(@"with a history", ^{
            it(@"should lay out the web view for the current interface orientation", ^{
                assertThatFloat(controller.webView.frame.origin.x, equalToFloat(24.0));
            });

            it(@"should have initiated a load of the webview", ^{
                assertThatBool(controller.temporaryWebView.loading, equalToBool(YES));
            });

            it(@"should have NO inSwipeAnimation", ^{
                assertThatBool(controller.inSwipeAnimation, equalToBool(NO));
            });

            it(@"should initialize the currentTOCIndexPath property to 0:0", ^{
                assertThat(controller.currentTOCIndexPath, equalTo([NSIndexPath indexPathForRow:0 inSection:0]));
            });

            it(@"should load the last concept from history", ^{
                [controller.temporaryWebView finishLoad];

                assertThat(controller.webView.request.URL.path, equalTo(someOtherConcept.path));
            });

            it(@"should scroll the webview to the previous scroll position for the concept", ^{
                [controller.temporaryWebView finishLoad];

                assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"window.scroll(0, %0.2f);", scrollOffset]));
            });
        });

        describe(@"with no restored history", ^{
            beforeEach(^{
                controller.history = [[[History alloc] init] autorelease];
                assertThat(controller.view, notNilValue());
            });

            it(@"should load the first concept in the book", ^{
                [controller.temporaryWebView finishLoad];

                assertThat(controller.webView.request.URL.path, equalTo(controller.book.initialConcept.path));
            });

        });
    });

    describe(@"history", ^{
        CGFloat newScrollOffset = 17;

        beforeEach(^{
            // Finish initial load.
            [controller.temporaryWebView finishLoad];

            // Load page with fragment.  This will be the page we goBack to.
            NSString *absolutePath = [NSString stringWithFormat:@"file://%@#a-fragment", [someConcept.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURL *url = [NSURL URLWithString:absolutePath];
            NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];
            [controller.webView sendClickRequest:request];
            [controller.temporaryWebView finishLoad];

            // Scroll around.
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
            scrollView.contentOffset = CGPointMake(0, newScrollOffset);
            [controller scrollViewDidScroll:scrollView];

            // Load some other page.
            [controller loadConcept:someOtherConcept];
            [controller.temporaryWebView finishLoad];
        });

        describe(@"goBack", ^{
            beforeEach(^{
                [controller goBack];
                [controller.temporaryWebView finishLoad];
            });

            describe(@"when returning to a scrolled page", ^{
                it(@"should return the scroll position to the previously scrolled position", ^{
                    assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"window.scroll(0, %0.2f);", newScrollOffset]));
                });
            });

            describe(@"when at the first point in history", ^{
                beforeEach(^{
                    while ([controller.history canGoBack]) {
                        [controller goBack];
                    }
                });

                it(@"should disable the back button", ^{
                    assertThatBool(controller.backButton.enabled, equalToBool(NO));
                });

                it(@"should enable the forward button", ^{
                    assertThatBool(controller.forwardButton.enabled, equalToBool(YES));
                });
            });
        });

        describe(@"goForward", ^{
            beforeEach(^{
                [controller goBack];
                [controller goForward];
            });

            describe(@"when at the last point in history", ^{
                it(@"should enable the back button", ^{
                    assertThatBool(controller.backButton.enabled, equalToBool(YES));
                });

                it(@"should disable the forward button", ^{
                    assertThatBool(controller.forwardButton.enabled, equalToBool(NO));
                });
            });
        });
    });

    describe(@"navigation", ^{
        __block NSURLRequest *request;
        __block UIWebViewNavigationType navigationType;

        beforeEach(^{
            // Complete the initial page load.
            [controller.temporaryWebView finishLoad];
        });

        describe(@"on a non-link request", ^{
            beforeEach(^{
                navigationType = UIWebViewNavigationTypeOther;
            });

            it(@"should allow the web view to load the request", ^{
                assertThatBool([controller webView:controller.webView shouldStartLoadWithRequest:request navigationType:navigationType], equalToBool(YES));
            });
        });

        describe(@"on a link request", ^{
            beforeEach(^{
                navigationType = UIWebViewNavigationTypeLinkClicked;
                assertThat(controller.temporaryWebView, nilValue());
            });

            sharedExamplesFor(@"a link request to a new concept page", ^(NSDictionary *context) {
                __block NSURLRequest *request;

                beforeEach(^{
                    [controller highlight:nil];

                    request = [context objectForKey:@"request"];
                    assertThat([controller.book conceptForPath:request.URL.path], notNilValue());
                });

                it(@"should not allow the web view to load the request", ^{
                    [controller.webView sendClickRequest:request];
                    assertThatBool(controller.webView.loading, equalToBool(NO));
                });

                it(@"should create a temporary web view for loading the new page", ^{
                    [controller.webView sendClickRequest:request];
                    assertThat(controller.temporaryWebView, notNilValue());
                });

                it(@"should remove all highlight views for the previous page", ^{
                    assertThat([controller.backgroundView findSubviewsByClass:[HighlightView class]], isNot(emptyContainer()));

                    [controller.webView sendClickRequest:request];

                    assertThat([controller.backgroundView findSubviewsByClass:[HighlightView class]], is(emptyContainer()));
                });

                it(@"should clear the active highlight view", ^{
                    [controller.webView sendClickRequest:request];

                    // Creating a new highlight will attempt to close the suggested questions view for the active highlight view.
                    // Since we just removed all views, there should be no active highlight view.  If the pointer is still pointing
                    // at something that has been deallocated this will explode.
                    [controller highlight:nil];
                });

                describe(@"on completion of the load", ^{
                    beforeEach(^{
                        [controller.webView sendClickRequest:request];
                    });

                    it(@"should swap the new web view for the old web view", ^{
                        UIWebView *originalTemporaryWebView = controller.temporaryWebView;
                        [controller.temporaryWebView finishLoad];
                        assertThat(controller.webView, equalTo(originalTemporaryWebView));
                    });

                    it(@"should eliminate the temporary web view", ^{
                        [controller.temporaryWebView finishLoad];
                        assertThat(controller.temporaryWebView, nilValue());
                    });

                    describe(@"in landscape orientation", ^{
                        beforeEach(^{
                            controllerOrientation = UIInterfaceOrientationLandscapeRight;
                        });

                        it(@"should set the class name on the body element to 'landscape'", ^{
                            [controller.temporaryWebView finishLoad];
                            assertThat(controller.webView.executedJavaScripts, hasItem(@"document.body.className = 'landscape';"));
                        });
                    });

                    describe(@"in portrait orientation", ^{
                        beforeEach(^{
                            controllerOrientation = UIInterfaceOrientationPortrait;
                        });

                        it(@"should remove any class name on the body element", ^{
                            [controller.temporaryWebView finishLoad];
                            assertThat(controller.webView.executedJavaScripts, hasItem(@"document.body.className = '';"));
                        });
                    });

                    describe(@"when the concept contains a highlight", ^{
                        __block Concept *concept;
                        __block Highlight *highlight;
                        NSString *rangeJSON = @"{\"startContainer\":{}}";

                        beforeEach(^{
                            highlight = [Highlight highlightWithIndex:@"10" xOffset:10 yOffset:7 height:5 text:@"text" section:@"section" rangeJSON:rangeJSON];

                            concept = [controller.book conceptForPath:controller.temporaryWebView.request.URL.path];
                            [concept insertHighlight:highlight beforeHighlightWithIndex:@"-1"];

                            [controller.temporaryWebView finishLoad];
                        });

                        it(@"should add highlight views associated with the new page", ^{
                            NSArray *highlightViews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];
                            assertThatInt([highlightViews count], equalToInt([concept.highlights count]));

                            for (unsigned int i = 0; i < [highlightViews count]; ++i) {
                                assertThat([[highlightViews objectAtIndex:i] highlight], equalTo([concept.highlights objectAtIndex:i]));
                            }
                        });

                        it(@"should re-index the existing highlights so the indices are contiguous", ^{
                            for (unsigned int i = 0; i < [concept.highlights count]; ++i) {
                                assertThat([[concept.highlights objectAtIndex:i] index], equalTo([NSString stringWithFormat:@"%d", i]));
                            }
                        });

                        it(@"should re-highlight the text for each highlight", ^{
                            NSString *escapedJSON = [rangeJSON stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
                            escapedJSON = [escapedJSON stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""];
                            NSString *expectedJS = [NSString stringWithFormat:@"var highlight = Halo.Highlight.fromJSON(%@, \"%@\"); Halo.highlighter.addHighlight(highlight);", highlight.index, escapedJSON];
                            assertThat(controller.webView.executedJavaScripts, hasItem(expectedJS));
                        });

                        it(@"should add markup to the content for all highlights", ^{
                            assertThat(controller.webView.executedJavaScripts, hasItem(@"Halo.highlighter.addMarkupForAllHighlights();"));
                        });
                    });
                });
            });

            describe(@"to a glossary page", ^{
                beforeEach(^{
                    NSString *absolutePath = [NSString stringWithFormat:@"file://%@", [someGlossaryConcept.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSURL *glossaryURL = [NSURL URLWithString:absolutePath];
                    request = [[[NSURLRequest alloc] initWithURL:glossaryURL] autorelease];

                    [sharedExampleContext setObject:request forKey:@"request"];
                });

                itShouldBehaveLike(@"a link request to a new concept page");

                it(@"should start loading the request in the temporary web view", ^{
                    [controller.webView sendClickRequest:request];
                    assertThatBool(controller.temporaryWebView.loading, equalToBool(YES));
                    assertThat(controller.temporaryWebView.request, equalTo(request));
                });
            });

            describe(@"with no fragment specified", ^{
                beforeEach(^{
                    NSString *absolutePath = [NSString stringWithFormat:@"file://%@", [someConcept.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                    NSURL *url = [NSURL URLWithString:absolutePath];
                    request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

                    [sharedExampleContext setObject:request forKey:@"request"];
                });

                itShouldBehaveLike(@"a link request to a new concept page");

                it(@"should start loading the request in the temporary web view", ^{
                    [controller.webView sendClickRequest:request];
                    assertThatBool(controller.temporaryWebView.loading, equalToBool(YES));
                    assertThat(controller.temporaryWebView.request, equalTo(request));
                });
            });

            describe(@"with a fragment specified", ^{
                NSString *fragment = @"i-am-a-fragment";

                beforeEach(^{
                    NSString *absolutePath = [NSString stringWithFormat:@"file://%@#%@", [someConcept.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], fragment];
                    NSURL *url = [NSURL URLWithString:absolutePath];
                    request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

                    [sharedExampleContext setObject:request forKey:@"request"];
                });

                itShouldBehaveLike(@"a link request to a new concept page");

                it(@"should remove the fragment from the request", ^{
                    [controller.webView sendClickRequest:request];
                    assertThat(controller.temporaryWebView.request.URL, equalTo([request.URL absoluteURLWithoutFragment]));
                });

                describe(@"on completion of content load into temporary web view", ^{
                    beforeEach(^{
                        [controller.webView sendClickRequest:request];
                        [controller.temporaryWebView finishLoad];
                    });

                    it(@"should execute JS to scroll to the anchor specified by the fragment", ^{
                        NSString *expectedJS = [NSString stringWithFormat:@"window.scroll(0, $('#%@').offset().top);", fragment];
                        assertThat(controller.webView.executedJavaScripts, hasItem(expectedJS));
                    });

                    describe(@"and then following history to a request with no fragment", ^{
                        beforeEach(^{
                            // Go back to the previous request.
                            [controller goBack];
                            [controller.temporaryWebView finishLoad];
                        });

                        it(@"should not try to scroll to an anchor", ^{
                            NSString *scrollJS = [NSString stringWithFormat:@"window.scroll(0, $('#%@').offset().top);", fragment];
                            assertThat(controller.webView.executedJavaScripts, isNot(hasItem(scrollJS)));
                        });
                    });
                });
            });

            describe(@"to a non-concept resource (such as an image)", ^{
                __block id stubNonConceptResourceViewController;
                __block id mockController;

                beforeEach(^{
                    NSString *path = @"/some/non-concept/resource.png";
                    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@", path]];
                    request = [NSURLRequest requestWithURL:url];
                    assertThat([controller.book conceptForPath:path], nilValue());

                    stubNonConceptResourceViewController = [OCMockObject niceMockForClass:[NonConceptResourceViewController class]];
                    mockController = [OCMockObject partialMockForObject:controller];
                    [[[mockController expect] andReturn:stubNonConceptResourceViewController] createNonConceptResourceViewControllerForRequest:request];
                });

                it(@"should not allow the web view to load the request", ^{
                    [controller.webView sendClickRequest:request];
                    assertThatBool(controller.webView.loading, equalToBool(NO));
                });

                it(@"should not create a temporary web view for loading the new page", ^{
                    [controller.webView sendClickRequest:request];
                    assertThat(controller.temporaryWebView, nilValue());
                });

                it(@"should create a non-concept resource view controller for the request", ^{
                    [controller.webView sendClickRequest:request];
                    [mockController verify];
                });

                it(@"should present the non-concept view controller as a modal view", ^{
                    [[mockController expect] presentModalViewController:stubNonConceptResourceViewController animated:YES];
                    [controller.webView sendClickRequest:request];
                    [mockController verify];
                });
            });
        });
    });
	
	//TODO: re-enable this test!
    //describe(@"on tapping question/answer bar button", ^{
//        __block void (^executeAction)();
//
//        beforeEach(^{
//            [controller.temporaryWebView finishLoad];
//
//			executeAction = [[^{
//                [controller didTapQuestionAnswerBarButton];
//            } copy] autorelease];
//
//            [sharedExampleContext setObject:executeAction forKey:@"executeAction"];
//            [sharedExampleContext setObject:controller.question forKey:@"question"];
//        });
//
//        describe(@"when there is no pre-existing answer", ^{
//            itShouldBehaveLike(@"an action that displays the modal question / answer view");
//        });
//
//        describe(@"when there is a pre-existing answer", ^{
//            beforeEach(^{
//                [controller.answer setString:@"I have all the answers."];
//            });
//
//            itShouldBehaveLike(@"an action that displays the modal question / answer view");
//        });
//    });

    describe(@"on tapping highlight button", ^{

        it(@"should change the background image of the navigation bar", ^{
            [controller didTapHighlightButton];
            assertThat(controller.navigationBar.backgroundImage, notNilValue());
            assertThat(controller.navigationBar.backgroundImage, isNot(navBarBackground));
		});

        it(@"should set the navigation bar items to the navigation items for highlighting", ^{
            [controller didTapHighlightButton];
            assertThat(controller.navigationBar.topItem.leftBarButtonItem.customView, equalTo(controller.leftNavigationViewForHighlighting));
            assertThat(controller.navigationBar.topItem.rightBarButtonItem.customView, equalTo(controller.rightNavigationViewForHighlighting));
        });

        it(@"should set the tint color of the right navigation bar item to be the same as the navigation bar", ^{
            [controller didTapHighlightButton];
            assertThat(controller.rightNavigationViewForHighlighting.tintColor, equalTo(controller.navigationBar.tintColor));
        });

        it(@"should remove the navigation bar title", ^{
            [controller didTapHighlightButton];
            assertThat(controller.navigationBar.topItem.titleView, nilValue());
        });

        it(@"should prevent the active web view from scrolling to top when the user taps the status bar", ^{
            [controller didTapHighlightButton];
            assertThatBool([controller scrollViewShouldScrollToTop:nil], equalToBool(NO));
        });

        describe(@"with an active highlight", ^{
            beforeEach(^{
                [controller.temporaryWebView finishLoad];
                [controller.webView setReturnValue:@"0" forJavaScript:@"Halo.highlighter.currentHighlight.index;"];
                [controller highlight:controller];

                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"put://device/highlights/0/focus"]];
                [controller.webView sendClickRequest:request];

                assertThat(controller.activeHighlightView, notNilValue());
            });

            it(@"should defocus the active highlight", ^{
                [controller didTapHighlightButton];
                assertThat(controller.activeHighlightView, nilValue());
            });

            it(@"should tell the web browser to defocus any previously focused highlight", ^{
                [controller didTapHighlightButton];
                assertThat([controller.webView.executedJavaScripts lastObject], equalTo(@"Halo.highlighter.defocusHighlights();"));
            });
        });
    });

    describe(@"on tapping highlight Done button", ^{
        beforeEach(^{
            [controller didTapHighlightButton];
            [controller didTapHighlightDoneButton];
        });

        it(@"should restore the background image of the navigation bar", ^{
            assertThat(controller.navigationBar.backgroundImage, equalTo(navBarBackground));
        });

        it(@"should set the navigation bar items to the navigation items for reading", ^{
            assertThat(controller.navigationBar.topItem.leftBarButtonItem.customView, equalTo(controller.leftNavigationToolbar));
            assertThat(controller.navigationBar.topItem.rightBarButtonItem.customView, equalTo(controller.rightNavigationToolbar));
        });

        it(@"should set the navigation bar title to navigationTitle", ^{
            assertThat(controller.navigationBar.topItem.titleView, equalTo(controller.navigationTitle));
        });
    });

    describe(@"Highlight context menu", ^{
        beforeEach(^{
            [controller.temporaryWebView finishLoad];
        });

        it(@"should not display the highlight option when the text selection overlaps an existing highlight", ^{
            [controller.webView setReturnValue:@"true" forJavaScript:@"Halo.highlighter.isSelectionOverlappingExistingHighlight();"];
            assertThatBool([controller canPerformAction:@selector(highlight:) withSender:nil], equalToBool(NO));
        });

        it(@"should display the highlight option when the text does not overlap an existing highlight", ^{
            [controller.webView setReturnValue:@"false" forJavaScript:@"Halo.highlighter.isSelectionOverlappingExistingHighlight();"];

            [controller.webView enableLogging];
            assertThatBool([controller canPerformAction:@selector(highlight:) withSender:nil], equalToBool(YES));
        });
    });

    sharedExamplesFor(@"an action that creates a highlight", ^(NSDictionary *context) {
        __block void (^executeAction)();

        beforeEach(^{
            executeAction = [context objectForKey:@"executeAction"];
        });

        it(@"should add the new highlight to the current concept", ^{
            assertThat(controller.book.currentConcept.highlights, emptyContainer());

            executeAction();

            assertThat(controller.book.currentConcept.highlights, isNot(emptyContainer()));
        });

        describe(@"in landscape orientation", ^{
            beforeEach(^{
                controllerOrientation = UIInterfaceOrientationLandscapeLeft;
            });

            it(@"should display a highlight at the same vertical position as the top of the highlighted text, taking into account the scroll position of the web view", ^{
                NSString *yPosition = @"42";

                float expectedVerticalPositionRelativeToWebView = 15.3;
                float verticalContentOffset = [yPosition floatValue] - expectedVerticalPositionRelativeToWebView;

                [controller.webView setReturnValue:yPosition forJavaScript:@"Halo.highlighter.currentHighlight.yOffset;"];

                controller.verticalContentOffset = verticalContentOffset;
                executeAction();

                UIView *highlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] objectAtIndex:0];

                assertThatFloat(highlightView.frame.origin.y, closeTo(expectedVerticalPositionRelativeToWebView, 0.001));
            });

            it(@"should position the highlight view horizontally HIGHLIGHT_VIEW_OVERHANG_WIDTH pixels left of the web view's right edge", ^{
                executeAction();
                UIView *highlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] objectAtIndex:0];

                assertThatFloat(CGRectGetMinX(highlightView.frame), equalToFloat(CGRectGetMaxX(controller.webView.frame) - HIGHLIGHT_VIEW_OVERHANG_WIDTH));
            });
        });

        describe(@"in portrait orientation", ^{
            beforeEach(^{
                controllerOrientation = UIInterfaceOrientationPortrait;
            });

            it(@"suggested questions for the new highlight should not be visible", ^{
                executeAction();
                HighlightView *highlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] objectAtIndex:0];

                assertThatFloat(highlightView.suggestedQuestionsView.alpha, equalToFloat(0));
            });
        });
    });

    describe(@"highlight:", ^{
        beforeEach(^{
            // Complete the initial page load.
            [controller.temporaryWebView finishLoad];

            void (^highlightAction)();
            highlightAction = [[^{
                [controller highlight:controller];
            } copy] autorelease];
            [[SpecHelper specHelper].sharedExampleContext setObject:highlightAction forKey:@"executeAction"];
        });

        it(@"should tell the webview to highlight the selection", ^{
            [controller highlight:controller];
            assertThat(controller.webView.executedJavaScripts, hasItem(@"Halo.highlighter.highlightSelection();"));
        });

        itShouldBehaveLike(@"an action that creates a highlight");
    });

    describe(@"removeHighlight:", ^{
        __block HighlightView *highlightView;
        NSString *highlightIndex = @"89";

        beforeEach(^{
            [controller.temporaryWebView finishLoad];

            [controller.webView setReturnValue:highlightIndex forJavaScript:@"Halo.highlighter.currentHighlight.index;"];

            [controller highlight:controller];

            NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
            NSArray *highlightViews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];

            highlightView = [highlightViews lastObject];

            // Force deallocation of the returned array, so it releases its elements.
            [pool drain];
        });

        it(@"should stop attempting to scroll the highlight view on scroll events", ^{
            // Guarantee the lifetime of the highlight view for the duration of this spec.
            [highlightView retain];

            CGFloat yOrigin = highlightView.frame.origin.y;
            [controller removeHighlight:highlightView.highlight];

            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
            CGFloat scrollOffset = 10.0;
            scrollView.contentOffset = CGPointMake(0, scrollOffset);
            [controller scrollViewDidScroll:scrollView];

            assertThatFloat(highlightView.frame.origin.y, equalToFloat(yOrigin));

            [highlightView release];
        });

        it(@"should subsequently not tell the view to close its suggested questions view when the user makes a new highlight", ^{
            [controller removeHighlight:highlightView.highlight];

            // Creating a new highlight will attempt to close the suggested questions view for the active highlight view.
            // Since we just removed all views, there should be no active highlight view.  If the pointer is still pointing
            // at something that has been deallocated this will explode.
            [controller highlight:controller];
        });

        it(@"should remove the highlight view from its superview", ^{
            NSArray *highlightSubviews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];
            assertThat(highlightSubviews, hasItem(highlightView));

            [controller removeHighlight:highlightView.highlight];

            highlightSubviews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];
            assertThat(highlightSubviews, isNot(hasItem(highlightView)));
        });

        it(@"should tell the webview to remove the highlight element", ^{
            [controller removeHighlight:highlightView.highlight];

            assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"Halo.highlighter.removeHighlight(%@);", highlightIndex]));
        });

        it(@"should remove the highlight from the current concept", ^{
            Highlight *highlight = highlightView.highlight;
            assertThat(controller.book.currentConcept.highlights, hasItem(highlight));

            [controller removeHighlight:highlightView.highlight];
            assertThat(controller.book.currentConcept.highlights, isNot(hasItem(highlight)));
        });

        it(@"should clear the activeHighlightView", ^{
            controller.activeHighlightView = highlightView;
            [controller removeHighlight:highlightView.highlight];
            assertThat(controller.activeHighlightView, nilValue());
        });

        it(@"should reorder the other highlight views with highlights on the same line", ^{
            id mockController = [OCMockObject partialMockForObject:controller];
            [[mockController expect] refreshHighlightViewsAtYOffset:highlightView.highlight.yOffset];

            [controller removeHighlight:highlightView.highlight];

            [mockController verify];
        });
    });

    describe(@"scrollToHighlight:", ^{
        CGFloat yOffset = 73.4;

        beforeEach(^{
            [controller.temporaryWebView finishLoad];
        });

        it(@"should expected behavior", ^{
            [controller.webView setReturnValue:[NSString stringWithFormat:@"%.1f", yOffset] forJavaScript:@"Halo.highlighter.currentHighlight.yOffset;"];

            [controller highlight:controller];
            HighlightView *highlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] lastObject];
            Highlight *highlight = highlightView.highlight;

            [controller scrollToHighlight:highlight];

            NSString *expectedJavaScript = [NSString stringWithFormat:@"window.scroll(0, %.1f);", yOffset - 20];
            assertThat(controller.webView.executedJavaScripts, hasItem(expectedJavaScript));
        });
    });

    sharedExamplesFor(@"an action that activates a highlight", ^(NSDictionary *context) {
        __block HighlightView *activatedHighlightView;

        beforeEach(^{
            activatedHighlightView = [context objectForKey:@"activatedHighlightView"];
        });

        it(@"should store the activated highlight in the controller", ^{
            assertThat(controller.activeHighlightView, notNilValue());
            assertThat(controller.activeHighlightView, is(equalTo(activatedHighlightView)));
        });

        it(@"should tell the web browser to focus the tapped highlight", ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"put://device/highlights/0/focus"]];
            [controller.webView sendClickRequest:request];

            assertThat(controller.webView.executedJavaScripts, hasItem(@"Halo.highlighter.focusHighlight(0);"));
        });
    });

    describe(@"when tapping on a highlight", ^{
        __block HighlightView *originalHighlightView;
        __block int highlightIndex;
        __block void (^tapHighlight)(int);

        beforeEach(^{
            highlightIndex = 0;
            [controller.temporaryWebView finishLoad];

            NSString *(^getHighlightIndex)() = ^{
                return (NSString *)[NSString stringWithFormat:@"%d", highlightIndex];
            };
            [controller.webView setReturnBlock:getHighlightIndex forJavaScript:@"Halo.highlighter.currentHighlight.index;"];

            [controller highlight:controller];

            originalHighlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] lastObject];
            assertThat(originalHighlightView, isNot(nilValue()));
            assertThat(originalHighlightView.highlight.index, equalTo(@"0"));

            ++highlightIndex;
            [controller highlight:controller];
            HighlightView *newHighlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] lastObject];
            assertThat(newHighlightView, isNot(equalTo(originalHighlightView)));
            assertThat(newHighlightView.highlight.index, equalTo(@"1"));

            tapHighlight = [[^(int index) {
                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"put://device/highlights/%d/focus", index]]];
                [controller.webView sendClickRequest:request];
            } copy] autorelease];
        });

        describe(@"when the highlight is tapped", ^{
            beforeEach(^{
                tapHighlight(0);
                [sharedExampleContext setObject:originalHighlightView forKey:@"activatedHighlightView"];
            });

            itShouldBehaveLike(@"an action that activates a highlight");
        });

        it(@"should tell the web browser to defocus any previously focused highlight", ^{
            tapHighlight(0);
            assertThat([controller.webView.executedJavaScripts objectAtIndex:(controller.webView.executedJavaScripts.count - 2)], equalTo(@"Halo.highlighter.defocusHighlights();"));
        });

        it(@"should not crash when activating a highlight whose highlight index is greater than the number of highlights (i.e. after a highlight was deleted)", ^{
            highlightIndex += 2;
            [controller highlight:controller];
            HighlightView *newHighlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] lastObject];
            assertThat(newHighlightView.highlight.index, equalTo(@"3"));

            tapHighlight(0);
            tapHighlight(3);

            assertThat(controller.activeHighlightView, is(equalTo(newHighlightView)));
        });
    });

    describe(@"custom web view messages", ^{
        describe(@"update highlight focus", ^{
            beforeEach(^{
                [controller.webView setReturnValue:@"0" forJavaScript:@"Halo.highlighter.currentHighlight.index;"];
                [controller highlight:controller];

                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"put://device/highlights/0/focus"]];
                [controller.webView sendClickRequest:request];
            });

            it(@"should focus the highlight with the specified highlight ID", ^{
                assertThat(controller.activeHighlightView.highlight.index, equalTo(@"0"));
            });
        });

        describe(@"update highlight defocus", ^{
            beforeEach(^{
                [controller.webView setReturnValue:@"0" forJavaScript:@"Halo.highlighter.currentHighlight.index;"];
                [controller highlight:controller];

                controller.activeHighlightView = [[controller.backgroundView findSubviewsByClass:[HighlightView class]] objectAtIndex:0];

                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"put://device/highlights//defocus"]];
                [controller.webView sendClickRequest:request];
            });

            it(@"should defocus any focused highlights", ^{
                assertThat(controller.activeHighlightView, nilValue());
            });
        });
    });

    describe(@"didTapBackground", ^{
        describe(@"with an active highlight", ^{
            beforeEach(^{
                [controller.temporaryWebView finishLoad];
                [controller.webView setReturnValue:@"0" forJavaScript:@"Halo.highlighter.currentHighlight.index;"];
                [controller highlight:controller];

                NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"put://device/highlights/0/focus"]];
                [controller.webView sendClickRequest:request];

                assertThat(controller.activeHighlightView, notNilValue());
            });

            it(@"should tell the web browser to defocus any previously focused highlight", ^{
                [controller didTapBackground];
                assertThat([controller.webView.executedJavaScripts lastObject], equalTo(@"Halo.highlighter.defocusHighlights();"));
            });
        });

        describe(@"with no active highlight", ^{
            beforeEach(^{
                assertThat(controller.activeHighlightView, nilValue());
            });

            it(@"should not explode", ^{
                [controller didTapBackground];
            });
        });
    });

    describe(@"popoverControllerDidDismissPopover", ^{
        it(@"should set the popoverController reference to nil", ^{
            UIViewController *tempViewController = [[[UIViewController alloc] init] autorelease];
            controller.popoverController = [[[UIPopoverController alloc] initWithContentViewController:tempViewController] autorelease];

            [controller popoverControllerDidDismissPopover:nil];

            assertThat(controller.popoverController, nilValue());
        });
    });

	//TODO: re-enable this test!
//    describe(@"showQuestionViewWithQuestion:", ^{
//        __block void (^executeAction)();
//        __block Question *question;
//
//        beforeEach(^{
//			// Complete the initial page load.
//            [controller.temporaryWebView finishLoad];
//
//            question = [[[Question alloc] init] autorelease];
//            question.text = @"Isn't it great?";
//
//            executeAction = [^{
//                [controller showQuestionViewWithQuestion:question];
//            } copy];
//
//            [sharedExampleContext setObject:executeAction forKey:@"executeAction"];
//			[sharedExampleContext setObject:question forKey:@"question"];
//        });
//
//        it(@"should store the question as the controller's current question", ^{
//            executeAction();
//            assertThat(controller.question, equalTo(question));
//        });
//
//        it(@"should blank out any existing answer", ^{
//			[controller.answer setString:@"I have all the answers."];
//            executeAction();
//            assertThatInt(controller.answer.length, equalToInt(0));
//        });
//
//        itShouldBehaveLike(@"an action that displays the modal question / answer view");
//
//    });

    describe(@"dismissModalQuestionAnswerViewAndLoadRequest:", ^{

        it(@"should load the request and dismiss the modal QA view navigation controller", ^{
			NSString *absolutePath = [NSString stringWithFormat:@"file://%@#a-fragment", [someConcept.path stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            NSURL *url = [NSURL URLWithString:absolutePath];
            NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:url] autorelease];

            [[stubController expect] loadRequest:request withHistory:YES];
            [[stubController expect] dismissModalQuestionAnswerView];

            [controller dismissModalQuestionAnswerViewAndLoadRequest:request];

            [stubController verify];
        });
    });

    describe(@"scrollViewDidScroll:", ^{
        describe(@"with visible highlights", ^{
            __block NSArray *highlightViews;

            beforeEach(^{
                // Complete the initial page load.
                [controller.temporaryWebView finishLoad];

                highlightViews = [NSMutableArray array];

                [controller highlight:controller];
                highlightViews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];
                assertThat(highlightViews, isNot(emptyContainer()));
            });

            it(@"should move the highlight views", ^{
                NSMutableArray *originalPositions = [NSMutableArray arrayWithCapacity:[highlightViews count]];
                for (HighlightView *highlightView in highlightViews) {
                    [originalPositions addObject:[NSNumber numberWithFloat:highlightView.verticalPosition]];
                }

                UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
                CGFloat scrollOffset = 10.0;
                scrollView.contentOffset = CGPointMake(0, scrollOffset);
                [controller scrollViewDidScroll:scrollView];

                for (int i = 0; i < [originalPositions count]; ++i) {
                    float originalPosition = [[originalPositions objectAtIndex:i] floatValue];
                    HighlightView *highlightView = [highlightViews objectAtIndex:i];
                    assertThatFloat(highlightView.frame.origin.y, equalToFloat(originalPosition - scrollOffset));
                }
            });
        });
    });

    describe(@"willRotateToInterfaceOrientation:duration:", ^{
        __block CGFloat left, width;

        beforeEach(^{
            [controller.temporaryWebView finishLoad];
            [controller highlight:controller];
        });

        describe(@"from portrait to landscape orientation", ^{
            beforeEach(^{
                left = 24.0;
                width = 708.0;

                [controller willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight duration:0.5];
            });

            it(@"should set the body class name to 'landscape'", ^{
                assertThat([controller.webView.executedJavaScripts lastObject], equalTo(@"document.body.className = 'landscape';"));
            });

            it(@"should set the x origin of the webView to 24px", ^{
                assertThatFloat(controller.webView.frame.origin.x, equalToFloat(left));
            });

            it(@"should set the width of the webView to 708px", ^{
                assertThatFloat(controller.webView.frame.size.width, equalToFloat(width));
            });

            it(@"should set the horizontalContentOffset property to 24.0", ^{
                assertThatFloat(controller.horizontalContentOffset, equalToFloat(left));
            });
        });

        describe(@"for landscape to portrait orientation", ^{
            beforeEach(^{
                left = 0.0;
                width = 768.0;

                [controller willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait duration:0.5];
            });

            it(@"should remove any body class name", ^{
                assertThat([controller.webView.executedJavaScripts lastObject], equalTo(@"document.body.className = '';"));
            });

            it(@"should set the x origin of the webView to 0px", ^{
                assertThatFloat(controller.webView.frame.origin.x, equalToFloat(left));
            });

            it(@"should set the width of the webView to 768px", ^{
                assertThatFloat(controller.webView.frame.size.width, equalToFloat(width));
            });

            it(@"should set the horizontalContentOffset property to 0", ^{
                assertThatFloat(controller.horizontalContentOffset, equalToFloat(left));
            });
        });
    });

    describe(@"willAnimateRotationToInterfaceOrientation:duration:", ^{
        __block NSArray *highlightViews;

        beforeEach(^{
            [controller.temporaryWebView finishLoad];

            highlightViews = [NSMutableArray array];

            [controller highlight:controller];

            highlightViews = [controller.backgroundView findSubviewsByClass:[HighlightView class]];
            assertThat(highlightViews, isNot(emptyContainer()));
        });

        it(@"should notify each highlight view of the current orientation", ^{
            UIInterfaceOrientation newOrientation = UIInterfaceOrientationLandscapeRight;

            id mockHighlightView = [OCMockObject partialMockForObject:[highlightViews objectAtIndex:0]];
            [[mockHighlightView expect] willRotateToInterfaceOrientation:newOrientation];

            [controller willAnimateRotationToInterfaceOrientation:newOrientation duration:0.5];

            [mockHighlightView verify];
        });

    });

    describe(@"swiping", ^{
        __block void (^executeAction)();
        __block void (^sendSwipeDidStopSelector)();
        __block NSString *(^expectedPath)();

        beforeEach(^{
            [controller.temporaryWebView finishLoad];
            [controller loadConcept:controller.book.nextConcept];
            [controller.temporaryWebView finishLoad];

            sendSwipeDidStopSelector = [[^{
                [controller performSelector:@selector(swipeAnimationDidStop)];
            } copy] autorelease];
        });

        sharedExamplesFor(@"an action that navigates concepts with swipe gestures", ^(NSDictionary *context) {
            it(@"should start loading the next or previous concept", ^{
                executeAction();
                assertThat(controller.temporaryWebView.request.URL.path, equalTo(expectedPath()));
            });

            it(@"should display the overlay view and spinner", ^{
                executeAction();
                assertThatFloat(controller.webViewLoadingOverlayView.alpha, equalToFloat(1));
            });

            describe(@"when the animation finishes before the page loads", ^{
                it(@"should display a spinner until the load completes", ^{
                    executeAction();
                    sendSwipeDidStopSelector();
                    assertThatFloat(controller.webViewLoadingOverlayView.alpha, equalToFloat(1));

                    [controller.temporaryWebView finishLoad];
                    assertThatFloat(controller.webViewLoadingOverlayView.alpha, equalToFloat(0));
                });

                it(@"should not swap the web views when the animation is complete", ^{
                    [[[stubController stub]
                      andThrow:[NSException exceptionWithName:@"Failure" reason:@"swapWebViews should not be called" userInfo:nil]]
                     swapWebViews];

                    executeAction();
                    sendSwipeDidStopSelector();
                });

                describe(@"after the page loads and the swipe animation is complete", ^{
                    it(@"should swap the web views", ^{
                        [[stubController expect] swapWebViews];

                        executeAction();
                        sendSwipeDidStopSelector();
                        //executed action doesn't actually fire the webViewDidFinishLoad message, so we need this next line:
                        [controller.temporaryWebView finishLoad];

                        [stubController verify];
                    });
                });

            });

            describe(@"when the animation finishes after the page loads", ^{
                it(@"should not display a spinner", ^{
                    executeAction();
                    [controller.temporaryWebView finishLoad];
                    assertThatFloat(controller.webViewLoadingOverlayView.alpha, equalToFloat(0));
                    sendSwipeDidStopSelector();
                    assertThatFloat(controller.webViewLoadingOverlayView.alpha, equalToFloat(0));
                });

                it(@"should swap the web views", ^{
                    [[stubController expect] swapWebViews];

                    executeAction();
                    //executed action doesn't actually fire the webViewDidFinishLoad message, so we need this next line:
                    [controller.temporaryWebView finishLoad];

                    sendSwipeDidStopSelector();

                    [stubController verify];
                });

                describe(@"when the animation has not yet finished", ^{
                    it(@"should not swap the web views when web view is loaded (allowing the animation block to call when finished)", ^{
                        [[[stubController stub]
                          andThrow:[NSException exceptionWithName:@"Failure" reason:@"swapWebViews should not be called" userInfo:nil]]
                         swapWebViews];

                        executeAction(); //executed action doesn't actually fire the webViewDidFinishLoad message, so we need this next line:
                        [controller.temporaryWebView finishLoad];
                    });
                });
            });
        });

        describe(@"didSwipeRight:", ^{
            beforeEach(^{
                executeAction = [[^{
                    [controller didSwipeRight:nil];
                } copy] autorelease];
                expectedPath = [[^{
                    return controller.book.previousConcept.path;
                } copy] autorelease];
            });

            itShouldBehaveLike(@"an action that navigates concepts with swipe gestures");

            describe(@"when at the first concept", ^{
                beforeEach(^{
                    [controller loadConcept:[controller.book.orderedConcepts objectAtIndex:0]];
                    [controller.temporaryWebView finishLoad];
                });

                it(@"should not load anything", ^{
                    [[[stubController stub]
                      andThrow:[NSException exceptionWithName:@"Failure" reason:@"loadConcept should not be called on swipe right from first concept" userInfo:nil]]
                     loadConcept:(Concept *)[OCMArg any]];

                    [controller didSwipeRight:nil];
                });
            });
        });

        describe(@"didSwipeLeft:", ^{
            beforeEach(^{
                executeAction = [[^{
                    [controller didSwipeLeft:nil];
                } copy] autorelease];
                expectedPath = [[^{
                    return controller.book.nextConcept.path;
                } copy] autorelease];
            });

            itShouldBehaveLike(@"an action that navigates concepts with swipe gestures");

            describe(@"when at the last concept", ^{
                beforeEach(^{
                    [controller loadConcept:[controller.book.orderedConcepts lastObject]];
                    [controller.temporaryWebView finishLoad];
                });

                it(@"should not load anything", ^{
                    [[[stubController stub]
                      andThrow:[NSException exceptionWithName:@"Failure" reason:@"loadConcept should not be called on swipe left from last concept" userInfo:nil]]
                     loadConcept:(Concept *)[OCMArg any]];

                    [controller didSwipeLeft:nil];
                });
            });
        });
    });

    describe(@"HighlightViewDelegate", ^{
        //TODO: move other delegate methods' tests here
        NSString *yPosition = @"42";
        float expectedVerticalPositionRelativeToWebView = 15.3;
        float verticalContentOffset = [yPosition floatValue] - expectedVerticalPositionRelativeToWebView;
        float additionalStickieOffset = 43.0;

        beforeEach(^{
            [controller.temporaryWebView finishLoad];
            [controller.webView setReturnValue:yPosition forJavaScript:@"Halo.highlighter.currentHighlight.yOffset;"];
        });

        describe(@"stickieViewHorizontalOffsetForHighlight:", ^{
            beforeEach(^{
                controller.verticalContentOffset = verticalContentOffset;
            });

            describe(@"when there is only one highlight on the same line", ^{
                beforeEach(^{
                    assertThat(controller.book.currentConcept.highlights, emptyContainer());
                });

                it(@"should return 0 (or the minimum constant value)", ^{
                    [controller highlight:controller];

                    Highlight *highlight = [controller.book.currentConcept.highlights lastObject];
                    assertThatFloat([controller stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43], closeTo(0, 0.001));
                });
            });

            describe(@"when there is another highlight on a the same", ^{
                beforeEach(^{
                    assertThat(controller.book.currentConcept.highlights, emptyContainer());

                    [controller highlight:controller];
                });

                it(@"should return the appropriate horizontal offset", ^{
                    [controller highlight:controller];

                    Highlight *highlight = [controller.book.currentConcept.highlights lastObject];
                    assertThatFloat([controller stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43], closeTo(additionalStickieOffset, 0.001));
                });
            });

            describe(@"when more than one highlight exists on the same line", ^{
                beforeEach(^{
                    assertThat(controller.book.currentConcept.highlights, emptyContainer());

                    [controller highlight:controller];
                    [controller highlight:controller];
                });

                it(@"should return the appropriate horizontal offset multiplied by the number of additional previous highlights", ^{
                    [controller highlight:controller];

                    Highlight *highlight = [controller.book.currentConcept.highlights lastObject];
                    assertThatFloat([controller stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43], closeTo(2 * additionalStickieOffset, 0.001));

                    highlight = [controller.book.currentConcept.highlights objectAtIndex:1];
                    assertThatFloat([controller stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43], closeTo(additionalStickieOffset, 0.001));
                });
            });
        });

        describe(@"highlightViewDeactivated:", ^{
            describe(@"when there are more than one highlight on the same line", ^{
                __block HighlightView *firstHighlightView;
                __block HighlightView *secondHighlightView;

                beforeEach(^{
                    [controller highlight:controller];
                    [controller highlight:controller];

                    assertThatInt([controller.book.currentConcept.highlights count], equalToInt(2));

                    firstHighlightView = [controller.highlightViews objectAtIndex:0];
                    secondHighlightView = [controller.highlightViews objectAtIndex:1];
                    [controller setActiveHighlightView:firstHighlightView];

                    assertThat([controller.backgroundView.subviews lastObject], equalTo(firstHighlightView));
                });


                it(@"should fix the highlight views' z-ordering", ^{
                    id mockBackground = [OCMockObject partialMockForObject:controller.backgroundView];
                    [[mockBackground expect] bringSubviewToFront:firstHighlightView];
                    [[mockBackground expect] bringSubviewToFront:secondHighlightView];
                    controller.activeHighlightView = nil;
                    [mockBackground verify];
                });
            });
        });

        describe(@"hasMultipleHighlightsAtHighlight", ^{
            __block Highlight *highlight;

            it(@"should return NO if the passed-in highlight is the only highlight on that line", ^{
                [controller highlight:controller];
                highlight = [controller.book.currentConcept.highlights lastObject];

                assertThatBool([controller hasMultipleHighlightsAtHighlight:highlight], equalToBool(NO));
            });

            it(@"should return YES if there are more than one highlight on the same line as the passed-in highlight", ^{
                [controller highlight:controller];
                [controller highlight:controller];
                highlight = [controller.book.currentConcept.highlights lastObject];

                assertThatBool([controller hasMultipleHighlightsAtHighlight:highlight], equalToBool(YES));
            });
        });
    });

    describe(@"HighlightPaintingViewDelegate", ^{
        float verticalScrollOffset = 123;
        CGPoint startPoint = CGPointMake(14, 17);
        CGPoint updatePoint = CGPointMake(42, 432);
        CGPoint endPoint = CGPointMake(23, 77);

        __block NSString *touchesBeganJS, *startHighlightJS, *updateHighlightJS;

        beforeEach(^{
            controllerOrientation = UIInterfaceOrientationLandscapeRight;
            // Complete initial load.
            [controller.temporaryWebView finishLoad];

            // Scroll to a non-zero vertical content offset.
            UIScrollView *scrollView = [[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease];
            scrollView.contentOffset = CGPointMake(0, verticalScrollOffset);
            [controller scrollViewDidScroll:scrollView];
            controller.horizontalContentOffset = 24.0;
        });

        sharedExamplesFor(@"an action that attempts to start a highlight", ^(NSDictionary *context) {
            __block void (^executeAction)();

            beforeEach(^{
                executeAction = [context objectForKey:@"executeAction"];
            });

            it(@"should execute JavaScript to start the highlight stroke at the given point, taking into account the current scroll offset", ^{
                executeAction();
                assertThat(controller.webView.executedJavaScripts, hasItem(touchesBeganJS));
            });

            describe(@"when the user touched inside a highlightable paragraph", ^{
                beforeEach(^{
                    [controller.webView setReturnValue:@"true" forJavaScript:touchesBeganJS];
                });

                it(@"should execute JavaScript to start the highlight, with the same point", ^{
                    executeAction();
                    assertThat(controller.webView.executedJavaScripts, hasItem(startHighlightJS));
                });

                describe(@"when the user began a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"true" forJavaScript:startHighlightJS];
                    });

                    it(@"should execute the JavaScript to update the highlight to comprise the start element", ^{
                        executeAction();
                        assertThat(controller.webView.executedJavaScripts, hasItem(updateHighlightJS));
                    });
                });

                describe(@"when the user has not yet began a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"false" forJavaScript:startHighlightJS];
                    });

                    it(@"should not execute the JavaScript to update the highlight to comprise the start element", ^{
                        executeAction();
                        assertThat(controller.webView.executedJavaScripts, isNot(hasItem(updateHighlightJS)));
                    });
                });



            });

            describe(@"when the user touched outside a highlightable paragraph", ^{
                beforeEach(^{
                    [controller.webView setReturnValue:@"false" forJavaScript:touchesBeganJS];
                });

                it(@"should not execute JavaScript to start the highlight", ^{
                    executeAction();
                    assertThat(controller.webView.executedJavaScripts, isNot(hasItem(startHighlightJS)));
                });
            });
        });

        describe(@"didBeginHighlightStrokeAtPoint:", ^{
            beforeEach(^{
                touchesBeganJS = [NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                startHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                updateHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];

                void (^beginHighlightAction)();
                beginHighlightAction = [[^{
                    [controller didBeginHighlightStrokeAtPoint:startPoint];
                } copy] autorelease];
                [[SpecHelper specHelper].sharedExampleContext setObject:beginHighlightAction forKey:@"executeAction"];
            });

            itShouldBehaveLike(@"an action that attempts to start a highlight");
        });

        describe(@"updateHighlightStrokeAtPoint:", ^{
            describe(@"when the user has touched inside a highlightable paragraph", ^{
                beforeEach(^{
                    [controller.webView setReturnValue:@"true" forJavaScript:touchesBeganJS];

                    startHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                });

                describe(@"when the user has previously started a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"true" forJavaScript:startHighlightJS];
                        [controller didBeginHighlightStrokeAtPoint:startPoint];
                    });

                    it(@"should execute JavaScript to update the current highlight stroke at the given point, taking into account the current scroll offset", ^{
                        [controller updateHighlightStrokeAtPoint:updatePoint];
                        assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", updatePoint.x - controller.horizontalContentOffset, updatePoint.y + verticalScrollOffset]));
                    });
                });

                describe(@"when the user has not yet started a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"false" forJavaScript:startHighlightJS];
                        [controller didBeginHighlightStrokeAtPoint:startPoint];
                    });

                    it(@"should execute JavaScript to start the highlight stroke at the given point, taking into account the current scroll offset", ^{
                        [controller updateHighlightStrokeAtPoint:updatePoint];
                        assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", updatePoint.x - controller.horizontalContentOffset, updatePoint.y + verticalScrollOffset]));
                    });
                });
            });

            describe(@"when the user has not yet touched inside a highlightable paragraph", ^{
                beforeEach(^{
                    touchesBeganJS = [NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", updatePoint.x - controller.horizontalContentOffset, updatePoint.y + verticalScrollOffset];
                    startHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", updatePoint.x - controller.horizontalContentOffset, updatePoint.y + verticalScrollOffset];
                    //this will never be called but is required for the shared behavior validation
                    updateHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", updatePoint.x - controller.horizontalContentOffset, updatePoint.y + verticalScrollOffset];

                    [controller.webView setReturnValue:@"false" forJavaScript:touchesBeganJS];
                    [controller didBeginHighlightStrokeAtPoint:startPoint];

                    void (^updateAction)();
                    updateAction = [[^{
                        [controller updateHighlightStrokeAtPoint:updatePoint];
                    } copy] autorelease];
                    [[SpecHelper specHelper].sharedExampleContext setObject:updateAction forKey:@"executeAction"];
                });

                itShouldBehaveLike(@"an action that attempts to start a highlight");
            });
        });

        describe(@"didEndHighlightStrokeAtPoint", ^{
            __block void (^highlightAction)();

            beforeEach(^{
                highlightAction = [[^{
                    [controller didEndHighlightStrokeAtPoint:endPoint];
                } copy] autorelease];
                [[SpecHelper specHelper].sharedExampleContext setObject:highlightAction forKey:@"executeAction"];
            });

            describe(@"when the user has touched inside a highlightable paragraph", ^{
                beforeEach(^{
                    touchesBeganJS = [NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                    [controller.webView setReturnValue:@"true" forJavaScript:touchesBeganJS];

                    startHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                });

                describe(@"when the user has previously started a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"true" forJavaScript:startHighlightJS];
                        [controller didBeginHighlightStrokeAtPoint:startPoint];
                    });

                    itShouldBehaveLike(@"an action that creates a highlight");

                    it(@"should execute JavaScript to complete the highlight stroke at the given point, taking into account the current scroll offset", ^{
                        highlightAction();
                        assertThat(controller.webView.executedJavaScripts, hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset]));
                    });

                    it(@"should execute JavaScript to remove the spans from the paragraph", ^{
                        highlightAction();
                        assertThat(controller.webView.executedJavaScripts, hasItem(@"Halo.touchEventHandler.touchesEnded();"));
                    });

                    it(@"should exit highlight mode", ^{
                        [[stubController expect] goToReadingMode];

                        highlightAction();

                        [stubController verify];
                    });
                });

                describe(@"when the user has not yet started a valid highlight", ^{
                    beforeEach(^{
                        [controller.webView setReturnValue:@"false" forJavaScript:startHighlightJS];
                        [controller didBeginHighlightStrokeAtPoint:startPoint];
                    });

                    it(@"should not execute JavaScript to complete the highlight stroke", ^{
                        highlightAction();
                        assertThat(controller.webView.executedJavaScripts, isNot(hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset])));
                    });

                    it(@"should execute JavaScript to remove the spans from the paragraph", ^{
                        highlightAction();
                        assertThat(controller.webView.executedJavaScripts, hasItem(@"Halo.touchEventHandler.touchesEnded();"));
                    });

                    it(@"should not create a highlight object", ^{
                        [[[stubController stub] andThrow:[NSException exceptionWithName:@"Failure" reason:@"getCreatedHighlight should not be called without first beginning a valid highlight" userInfo:nil]] getCreatedHighlight];
                        highlightAction();
                    });
                });
            });

            describe(@"when the user has not yet touched inside a highlightable paragraph", ^{
                beforeEach(^{
                    NSString *beginHighlightJS = [NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", startPoint.x - controller.horizontalContentOffset, startPoint.y + verticalScrollOffset];
                    [controller.webView setReturnValue:@"false" forJavaScript:beginHighlightJS];
                    [controller didBeginHighlightStrokeAtPoint:startPoint];
                });

                it(@"should not execute any Javascript for the end point", ^{
                    [controller didEndHighlightStrokeAtPoint:endPoint];

                    assertThat(controller.webView.executedJavaScripts, isNot(hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.touchesBeganAtPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset])));
                    assertThat(controller.webView.executedJavaScripts, isNot(hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.startHighlightAtPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset])));
                    assertThat(controller.webView.executedJavaScripts, isNot(hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.updateHighlightFeedbackToPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset])));
                    assertThat(controller.webView.executedJavaScripts, isNot(hasItem([NSString stringWithFormat:@"Halo.touchEventHandler.touchesEndedAtPoint(%.0f, %.0f);", endPoint.x - controller.horizontalContentOffset, endPoint.y + verticalScrollOffset])));
                });
            });
        });
    });
});

SPEC_END
