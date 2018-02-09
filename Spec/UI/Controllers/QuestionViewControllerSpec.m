#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import <objc/runtime.h>
#import "HCEmptyContainer.h"
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"
#import "HTMLContentVerifier.h"
#import "UIView+FindSubviews.h"
#import "UIWebView+Spec.h"

#import "Aura.h"
#import "Question.h"
#import "QuestionViewController.h"
#import "AnswerViewController.h"
#import "QuestionViewDelegate.h"
#import <Three20/Three20.h>

@interface QuestionViewController (QuestionViewControllerSpecImpl)

@property (nonatomic, retain) UIWebView *answerQuestionErrorWebView;
- (void)fetchSuggestedQuestionsListForText:(NSString *)text withDelegate:(id<PCKHTTPConnectionDelegate>)delegate;
- (void)showShenanigans:(NSError *)error;
@end

SPEC_BEGIN(QuestionViewControllerSpec)

describe(@"QuestionViewController", ^{
    NSMutableDictionary *sharedExampleContext = [SpecHelper specHelper].sharedExampleContext;
    __block QuestionViewController *controller;
    __block id mockDelegate;
    __block Question *question;
    NSString *keywords = @"These words are key, dude.";

    sharedExamplesFor(@"a new question action", ^(NSDictionary *context) {
        __block void (^executeAction)();

        beforeEach(^{
            executeAction = [context objectForKey:@"executeAction"];
        });

        it(@"should clear the questionTextView text", ^{
            executeAction();
            assertThat(controller.questionTextView.text, equalTo(@""));
        });

        it(@"should clear the question text", ^{
            executeAction();
            assertThat(controller.question.text, equalTo(@""));
        });

        it(@"should reload the suggested questions", ^{
            NSURLConnection *existingConnection = [[[[NSURLConnection connections] lastObject] retain] autorelease];
            assertThat(existingConnection, notNilValue());

            executeAction();

            assertThat([NSURLConnection connections], isNot(hasItem(existingConnection)));

            NSURLConnection *newConnection = [[NSURLConnection connections] lastObject];
            assertThat(newConnection.request.URL.path, equalTo(@"/formatted_structured_questions_lists"));
        });

        it(@"should set focus to the questionTextView", ^{
            id mockQuestionTextView = [OCMockObject partialMockForObject:controller.questionTextView];
            [[mockQuestionTextView expect] becomeFirstResponder];

            executeAction();

            [mockQuestionTextView verify];
        });
    });

    sharedExamplesFor(@"an action that cancels any outstanding answer-question request", ^(NSDictionary *context) {
        __block NSURLConnection *existingConnection;
        __block void (^executeAction)();

        beforeEach(^{
            existingConnection = [[[[NSURLConnection connections] lastObject] retain] autorelease];
            assertThat(existingConnection.request.URL.path, equalTo(@"/answers"));

            executeAction = [context objectForKey:@"executeAction"];
            executeAction();
        });

        it(@"should cancel any outstanding answer-question requests", ^{
            assertThat([NSURLConnection connections], isNot(hasItem(existingConnection)));

            for (NSURLConnection *connection in [NSURLConnection connections]) {
                assertThat(connection.request.URL.path, isNot(equalTo(@"/answers")));
            }
        });

        it(@"should hide the question request pending overlay view", ^{
            assertThatBool(controller.questionRequestPendingOverlayView.hidden, equalToBool(YES));
        });
    });

    sharedExamplesFor(@"an action that completes the answer-question connection", ^(NSDictionary *context) {
        __block void (^executeAction)();

        beforeEach(^{
            executeAction = [context objectForKey:@"executeAction"];
            executeAction();
        });

        it(@"should set the connection reference to nil", ^{
            assertThat([controller answerQuestionConnection], nilValue());
        });

        it(@"should hide the question request pending overlay view", ^{
            assertThatBool(controller.questionRequestPendingOverlayView.hidden, equalToBool(YES));
        });
    });

    sharedExamplesFor(@"an action that completes the answer-question connection with no valid answer", ^(NSDictionary *context) {
        __block void (^executeAction)();

        beforeEach(^{
            executeAction = [context objectForKey:@"executeAction"];
            executeAction();
        });

        it(@"should enable the question text view", ^{
            assertThatBool(controller.questionTextView.editable, equalToBool(YES));
        });

        itShouldBehaveLike(@"an action that completes the answer-question connection");
    });

    sharedExamplesFor(@"an action that cancels an outstanding suggested-questions request", ^(NSDictionary *context) {
        __block NSURLConnection *existingConnection;
        __block void (^executeAction)();

        beforeEach(^{
            existingConnection = [[[[NSURLConnection connections] lastObject] retain] autorelease];
            assertThat(existingConnection.request.URL.path, equalTo(@"/formatted_structured_questions_lists"));

            executeAction = [context objectForKey:@"executeAction"];
            executeAction();
        });

        it(@"should cancel the existing suggested-questions request", ^{
            assertThat([NSURLConnection connections], isNot(hasItem(existingConnection)));
        });
    });

    sharedExamplesFor(@"an action that completes the suggested-questions connection", ^(NSDictionary *context) {
        beforeEach(^{
            void (^completionAction)();
            completionAction = [context objectForKey:@"executeAction"];
            completionAction();
        });

        it(@"should set the connection reference to nil", ^{
            assertThat([controller suggestedQuestionsConnection], nilValue());
        });

        it(@"should show the suggested questions table if the error overlay is hidden", ^{
			if (controller.networkErrorOverlayView.hidden) {
				assertThatFloat(controller.suggestedQuestionsTableView.alpha, equalToFloat(1));
			} else {
				assertThatFloat(controller.suggestedQuestionsTableView.alpha, equalToFloat(0));
			}
        });

        it(@"should hide the suggested questions request pending overlay view", ^{
            assertThatFloat(controller.suggestedQuestionsRequestPendingOverlayView.alpha, equalToFloat(0));
        });
    });

    sharedExamplesFor(@"an action that fetches structured questions from aura", ^(NSDictionary *context) {
        __block NSString *expectedText;

        beforeEach(^{
            void (^executeAction)();
            executeAction = [context objectForKey:@"executeAction"];
            expectedText = [context objectForKey:@"expectedText"];

            executeAction();
        });

        it(@"should send a request to AURA for suggested questions", ^{
            assertThat([NSURLConnection connections], isNot(emptyContainer()));
            assertThat([[[NSURLConnection connections] lastObject] request].URL.path, equalTo(@"/formatted_structured_questions_lists"));
        });

        it(@"should pass the question text as the keywords, and concept text as the text to the server", ^{
            NSURLConnection *connection = [[NSURLConnection connections] lastObject];
            NSString *expectedBody = [NSString stringWithFormat:@"concept=%@&question=%@&uuid=%@",
                                      [keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES],
                                      [expectedText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES],
									  [[Aura deviceID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThat([[[NSString alloc] initWithData:[connection request].HTTPBody encoding:NSUTF8StringEncoding] autorelease], equalTo(expectedBody));
        });

        it(@"should display an activity spinner", ^{
            assertThatFloat(controller.suggestedQuestionsRequestPendingOverlayView.alpha, equalToFloat(1));
        });
    });

    sharedExamplesFor(@"an action that hides the network error overlay view", ^(NSDictionary *context) {
        beforeEach(^{
            void (^executeAction)();
            executeAction = [context objectForKey:@"executeAction"];

            executeAction();
        });

        it(@"should hide the network error overlay view", ^{
            assertThatBool(controller.networkErrorOverlayView.hidden, equalToBool(YES));
        });
    });

    beforeEach(^{
        question = [[[Question alloc] init] autorelease];
        question.text = @"fancy question?";

        mockDelegate = [OCMockObject niceMockForProtocol:@protocol(QuestionViewDelegate)];
        controller = [[[QuestionViewController alloc] initWithKeywords:keywords question:question answer:[NSMutableString stringWithCapacity:0] delegate:mockDelegate] autorelease];
        assertThat(controller.view, notNilValue());
    });

    describe(@"outlets", ^{
        it(@"should have a questionView", ^{
            assertThat(controller.questionTextView, notNilValue());
        });

        it(@"should have an ask button", ^{
            assertThat(controller.askButton, notNilValue());
        });

        describe(@"suggested questions table view", ^{
            it(@"should exist", ^{
                assertThat(controller.suggestedQuestionsTableView, notNilValue());
            });

            it(@"should set the data source to be the view controller", ^{
                assertThat(controller.suggestedQuestionsTableView.dataSource, equalTo(controller));
            });

            it(@"should set the delegate to be the view controller", ^{
                assertThat(controller.suggestedQuestionsTableView.delegate, equalTo(controller));
            });
        });

        it(@"should have a well image view that overlays the suggested questions table", ^{
            assertThat(controller.tableWellImageView, notNilValue());
        });

        it(@"should have an overlay image for the suggested questions table", ^{
            assertThat(controller.tableOverlayImageView, notNilValue());
        });

        it(@"should have an overlay view for fading the window when a question request is pending", ^{
            assertThat(controller.questionRequestPendingOverlayView, notNilValue());
        });

        it(@"should hide the question request pending overlay view", ^{
            assertThatBool(controller.questionRequestPendingOverlayView.hidden, equalToBool(YES));
        });

        it(@"should have an overlay view for display when fetching suggested questions", ^{
            assertThat(controller.suggestedQuestionsRequestPendingOverlayView, notNilValue());
        });

        describe(@"questionTextView", ^{
            it(@"should delegate to the controller", ^{
                assertThat(controller.questionTextView.delegate, equalTo(controller));
            });
        });
    });

    describe(@"viewDidLoad:", ^{
        it(@"should initiate a request for suggested questions", ^{
            assertThat([NSURLConnection connections], isNot(emptyContainer()));
            assertThat([[[NSURLConnection connections] lastObject] request].URL.path, equalTo(@"/formatted_structured_questions_lists"));
        });

        it(@"should display the passed-in question in the text view", ^{
            assertThat(controller.questionTextView.text, equalTo(question.text));
        });

        describe(@"close button", ^{
            __block UIBarButtonItem *closeButton;

            beforeEach(^{
                id toolbar = controller.navigationItem.rightBarButtonItem.customView;
                closeButton = [[toolbar items] lastObject];
            });

            it(@"should reside as the last item in a toolbar as the rightBarButtonItem in the navigation bar", ^{
                assertThat(closeButton.title, equalTo(@"Done"));
            });
        });

        describe(@"new question button", ^{
            __block UIBarButtonItem *newQuestionButton;

            beforeEach(^{
                id toolbar = controller.navigationItem.rightBarButtonItem.customView;
                newQuestionButton = [[toolbar items] objectAtIndex:0];
            });

            it(@"should reside as the first item in a toolbar as the rightBarButtonItem in the navigation bar", ^{
                assertThat(newQuestionButton.title, equalTo(@"New Question"));
            });

            it(@"should send an appropriate message to the controller on click", ^{
                assertThatBool(sel_isEqual(newQuestionButton.action, @selector(didTapNewQuestion)), equalToBool(YES));
                assertThat(newQuestionButton.target, equalTo(controller));
            });
        });
    });

    describe(@"viewDidAppear:", ^{
        describe(@"when the passed-in question has text", ^{
            beforeEach(^{
                assertThat(question.text, isNot(equalTo(@"")));
                [controller viewDidAppear:YES];
            });

            it(@"should enable the ASK button", ^{
                assertThatBool(controller.askButton.enabled, equalToBool(YES));
            });
        });

        describe(@"when the passed-in question has no text", ^{
            beforeEach(^{
                question.text = controller.questionTextView.text = @"";
                [controller viewDidAppear:YES];
            });

            it(@"should disable the ASK button", ^{
                assertThatBool(controller.askButton.enabled, equalToBool(NO));
            });
        });
    });

    describe(@"textViewDidChange:", ^{
        it(@"should disable the Ask button if the question text view is empty", ^{
            controller.questionTextView.text = @"";
            [controller textViewDidChange:controller.questionTextView];

            assertThatBool(controller.askButton.enabled, equalToBool(NO));
        });

        it(@"should enable the Ask button if the question text view is edited", ^{
            controller.questionTextView.text = @"What is a non-empty text view?";
            [controller textViewDidChange:controller.questionTextView];

            assertThatBool(controller.askButton.enabled, equalToBool(YES));
        });
    });

    describe(@"textViewDidEndEditing:", ^{
        it(@"should store the new question text in the question property", ^{
            static NSString *questionText = @"Some new question text";
            controller.questionTextView.text = questionText;

            [controller textViewDidEndEditing:controller.questionTextView];

            assertThat(controller.question.text, equalTo(questionText));
        });
    });

    describe(@"fetchSuggestedQuestionsListForText:withDelegate:", ^{
        __block void (^executeAction)();
        __block NSURLConnection *connection;
        __block NSString *text;

        beforeEach(^{
            text = @"";

            [NSURLConnection resetAll];

            executeAction = [[^{
                [controller fetchSuggestedQuestionsListForText:text withDelegate:controller];
                connection = [[NSURLConnection connections] lastObject];
            } copy] autorelease];

            [sharedExampleContext setObject:executeAction forKey:@"executeAction"];
            [sharedExampleContext setObject:text forKey:@"expectedText"];
        });

        itShouldBehaveLike(@"an action that fetches structured questions from aura");

        describe(@"on success", ^{
            __block PSHKFakeHTTPURLResponse *successResponse;
            __block void (^successAction)();

            beforeEach(^{
                executeAction();

                successResponse = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
                successAction = [[^{
                    [[[NSURLConnection connections] lastObject] receiveResponse:successResponse];
                } copy] autorelease];
                [sharedExampleContext setObject:successAction forKey:@"executeAction"];
            });

            it(@"should populate the suggested questions list", ^{
                successAction();

                assertThatBool([controller.suggestedQuestionsList count] > 0, equalToBool(YES));
            });

            it(@"should display the suggested questions in a table view", ^{
                successAction();
                assertThatInt([controller.suggestedQuestionsTableView numberOfRowsInSection:0], equalToInt([controller.suggestedQuestionsList count]));
                for (int i = 0; i < controller.suggestedQuestionsList.count; ++i) {
					id cell = [[[controller.suggestedQuestionsTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]] subviews] objectAtIndex:0];
                    assertThat([(TTStyledTextLabel *)[[cell subviews] objectAtIndex:0] html], equalTo([[controller.suggestedQuestionsList objectAtIndex:i] text]));
                }
            });

            itShouldBehaveLike(@"an action that completes the suggested-questions connection");
        });

        describe(@"on failure response", ^{
            __block PSHKFakeHTTPURLResponse *failureResponse;
            __block void (^failureAction)();

            beforeEach(^{
                executeAction();

                failureResponse = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] badRequest];
                failureAction = [[^{
                    [[[NSURLConnection connections] lastObject] receiveResponse:failureResponse];
                } copy] autorelease];
                [sharedExampleContext setObject:failureAction forKey:@"executeAction"];
            });

            itShouldBehaveLike(@"an action that completes the suggested-questions connection");

            it(@"should display the error message overlay view", ^{
                failureAction();

                assertThatBool(controller.networkErrorOverlayView.hidden, equalToBool(NO));
            });

            it(@"should display an error message", ^{
                failureAction();

                assertThat(controller.networkErrorMessageLabel.text, equalTo(@"Failed to retrieve questions"));
            });

            describe(@"on subsequently entering a question and tapping the ask button", ^{
                __block void (^tapAskAction)();
                NSString *question = @"What are the parts of a smurf?";

                beforeEach(^{
                    controller.questionTextView.text = question;
                    [controller textViewDidEndEditing:controller.questionTextView];

                    tapAskAction = [[^{
                        [controller.askButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    } copy] autorelease];

                    [sharedExampleContext setObject:tapAskAction forKey:@"executeAction"];

                    failureAction();
                });

                itShouldBehaveLike(@"an action that hides the network error overlay view");
            });

            describe(@"on subsequently tapping the new question button", ^{
                __block UIBarButtonItem *newQuestionButton;
                __block void (^tapAction)();

                beforeEach(^{
                    id toolbar = controller.navigationItem.rightBarButtonItem.customView;
                    newQuestionButton = [[toolbar items] objectAtIndex:0];

                    assertThat(controller.questionTextView.text, isNot(equalTo(@"")));

                    tapAction = [[^{
                        objc_msgSend(newQuestionButton.target, newQuestionButton.action);
                    } copy] autorelease];

                    [sharedExampleContext setObject:tapAction forKey:@"executeAction"];

                    failureAction();
                });
            });
        });

        describe(@"on connection error", ^{
            __block void (^errorAction)();
            __block NSError *error;

            beforeEach(^{
                executeAction();

                errorAction = [^{
                    NSDictionary *underlyingErrorDict = [NSDictionary dictionaryWithObject:@"The request timed out." forKey:NSLocalizedDescriptionKey];
                    NSError *underlyingError = [NSError errorWithDomain:@"kCFErrorDomainCFNetwork" code:-1001 userInfo:underlyingErrorDict];
                    NSDictionary *dict = [NSDictionary dictionaryWithObject:underlyingError forKey:@"NSUnderlyingError"];
                    error = [NSError errorWithDomain:@"kCFErrorDomainCFNetwork" code:-1001 userInfo:dict];

                    [controller connection:[[NSURLConnection connections] lastObject] didFailWithError:error];
                } copy];
                [sharedExampleContext setObject:errorAction forKey:@"executeAction"];
            });

            it(@"should display the error message overlay view", ^{
                errorAction();

                assertThatBool(controller.networkErrorOverlayView.hidden, equalToBool(NO));
            });

            it(@"should display the error message returned by the connection response", ^{
                errorAction();

                assertThat(controller.networkErrorMessageLabel.text, equalTo([[[error userInfo] objectForKey:@"NSUnderlyingError"] localizedDescription]));
            });

            itShouldBehaveLike(@"an action that completes the suggested-questions connection");

            describe(@"on subsequently entering a question and tapping the ask button", ^{
                __block void (^tapAskAction)();
                NSString *question = @"What are the parts of a smurf?";

                beforeEach(^{
                    controller.questionTextView.text = question;
                    [controller textViewDidEndEditing:controller.questionTextView];

                    tapAskAction = [[^{
                        [controller.askButton sendActionsForControlEvents:UIControlEventTouchUpInside];
                    } copy] autorelease];

                    [sharedExampleContext setObject:tapAskAction forKey:@"executeAction"];

                    errorAction();
                });

                itShouldBehaveLike(@"an action that hides the network error overlay view");
            });

            describe(@"on subsequently tapping the new question button", ^{
                __block UIBarButtonItem *newQuestionButton;
                __block void (^tapAction)();

                beforeEach(^{
                    id toolbar = controller.navigationItem.rightBarButtonItem.customView;
                    newQuestionButton = [[toolbar items] objectAtIndex:0];

                    assertThat(controller.questionTextView.text, isNot(equalTo(@"")));

                    tapAction = [[^{
                        objc_msgSend(newQuestionButton.target, newQuestionButton.action);
                    } copy] autorelease];

                    [sharedExampleContext setObject:tapAction forKey:@"executeAction"];

                    errorAction();
                });
            });
        });
    });

    describe(@"didTapAskButton", ^{
        __block void (^tapAskAction)();
        NSString *question = @"What are the parts of a smurf?";

        beforeEach(^{
            controller.questionTextView.text = question;
            [controller textViewDidEndEditing:controller.questionTextView];

            tapAskAction = [[^{
                [controller.askButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            } copy] autorelease];
            [sharedExampleContext setObject:tapAskAction forKey:@"executeAction"];
        });

        itShouldBehaveLike(@"an action that cancels an outstanding suggested-questions request");

        it(@"should initiate a request to the answers API", ^{
            tapAskAction();
            NSURLConnection *connection = [[NSURLConnection connections] lastObject];
            assertThat([[[connection request] URL] path], equalTo(@"/answers"));
        });

        it(@"should pass the specified question to the server", ^{
            tapAskAction();
            NSURLConnection *connection = [[NSURLConnection connections] lastObject];

            NSString *expectedBody = [NSString stringWithFormat:@"question=%@&uuid=%@", 
									  [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES], 
									  [[Aura deviceID] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThat([[[NSString alloc] initWithData:[connection request].HTTPBody encoding:NSUTF8StringEncoding] autorelease], equalTo(expectedBody));
        });

        it(@"should unhide the questionRequestPendingOverlayView", ^{
            tapAskAction();
            assertThatBool(controller.questionRequestPendingOverlayView.hidden, equalToBool(NO));
        });

        it(@"should disable the Ask button", ^{
            tapAskAction();
            assertThatBool(controller.askButton.enabled, equalToBool(NO));
        });

        it(@"should tell the question text view to resign first responder", ^{
            id mockQuestionTextView = [OCMockObject partialMockForObject:controller.questionTextView];
            [[mockQuestionTextView expect] resignFirstResponder];

            tapAskAction();

            [mockQuestionTextView verify];
        });

        it(@"should disable the question text view", ^{
            tapAskAction();
            assertThatBool(controller.questionTextView.editable, equalToBool(NO));
        });

        it(@"should hide the suggested questions request pending overlay view", ^{
            tapAskAction();
            assertThatFloat(controller.suggestedQuestionsRequestPendingOverlayView.alpha, equalToFloat(0));
        });

        it(@"should reset the question error feedback text", ^{
			controller.answerQuestionErrorWebView = [[[UIWebView alloc] initWithFrame:controller.suggestedQuestionsRequestPendingOverlayView.frame] autorelease];
			tapAskAction();
			assertThat(controller.answerQuestionErrorWebView, nilValue());
		});

        describe(@"on thereafter tapping the cancel button", ^{
            __block void (^cancelAction)();

            beforeEach(^{
                tapAskAction();

                cancelAction = [[^{
                    [controller didTapCancelButton];
                } copy] autorelease];
                [sharedExampleContext setObject:cancelAction forKey:@"executeAction"];
            });

            itShouldBehaveLike(@"an action that cancels any outstanding answer-question request");

            itShouldBehaveLike(@"an action that completes the answer-question connection with no valid answer");
        });

        describe(@"on subsequently closing the question/answer window", ^{
            __block void (^closeAction)();

            beforeEach(^{
                tapAskAction();

                closeAction = [[^{
                    [controller viewWillDisappear:YES];
                } copy] autorelease];
                [sharedExampleContext setObject:closeAction forKey:@"executeAction"];
            });

            itShouldBehaveLike(@"an action that cancels any outstanding answer-question request");

            itShouldBehaveLike(@"an action that completes the answer-question connection");
        });

        describe(@"on success", ^{
            __block PSHKFakeHTTPURLResponse *successResponse;
            __block void (^successAction)();

            beforeEach(^{
                tapAskAction();

                successResponse = [[PSHKFakeResponses responsesForRequest:@"askQuestion"] success];
                successAction = [[^{
                    [[[NSURLConnection connections] lastObject] receiveResponse:successResponse];
                } copy] autorelease];
                [sharedExampleContext setObject:successAction forKey:@"executeAction"];
            });

//            it(@"should initialize an Answer View Controller with the html response and push it onto the navigation controller", ^{
//                id mockNavigationController = [OCMockObject mockForClass:[UINavigationController class]];
//                id stubController = [OCMockObject partialMockForObject:controller];
//                [[[stubController stub] andReturn:mockNavigationController] navigationController];
//
//                [[mockNavigationController expect] pushViewController:[OCMArg checkWithBlock:^(id viewController) {
//                    return (BOOL)([viewController isKindOfClass:[AnswerViewController class]]);
//                }] animated:YES];
//
//                successAction();
//
//                [mockNavigationController verify];
//            });

            it(@"should not result in a new request to Aura for structured questions", ^{
                for (NSURLConnection *connection in [NSURLConnection connections]) {
                    assertThatBool([connection.request.URL.path hasPrefix:@"/formatted_structured_questions_lists"], equalToBool(NO));
                }
            });

            describe(@"when a web view with an error message from a previous response is being displayed", ^{
                __block CGRect originalTableFrame, originalWellFrame;

                beforeEach(^{
                    originalTableFrame = controller.suggestedQuestionsTableView.frame;
					originalWellFrame = controller.tableWellImageView.frame;

                    PSHKFakeHTTPURLResponse *invalidQuestionResponse;
                    invalidQuestionResponse = [[PSHKFakeResponses responsesForRequest:@"askQuestion"] badRequest];
                    [[[NSURLConnection connections] lastObject] receiveResponse:invalidQuestionResponse];

                    tapAskAction();
                    successAction();
                });

                it(@"should close the web view", ^{
                    NSArray *webViews = [controller.view findSubviewsByClass:[UIWebView class]];
                    assertThatInt([webViews count], equalToInt(0));
                });

                it(@"should restore the suggested questions table to its original position and size", ^{
                    assertThat(NSStringFromCGRect(controller.suggestedQuestionsTableView.frame), equalTo(NSStringFromCGRect(originalTableFrame)));
                });

                it(@"should restore the well image view to its original position and size", ^{
                    assertThat(NSStringFromCGRect(controller.tableWellImageView.frame), equalTo(NSStringFromCGRect(originalWellFrame)));
                });
            });

            itShouldBehaveLike(@"an action that completes the answer-question connection");
        });

        describe(@"on invalid answer-question response", ^{
            __block PSHKFakeHTTPURLResponse *invalidQuestionResponse;
            __block void (^invalidQuestionAction)();

            beforeEach(^{
                tapAskAction();

                invalidQuestionResponse = [[PSHKFakeResponses responsesForRequest:@"askQuestion"] badRequest];
                invalidQuestionAction = [[^{
                    [[[NSURLConnection connections] lastObject] receiveResponse:invalidQuestionResponse];
                } copy] autorelease];
                [sharedExampleContext setObject:invalidQuestionAction forKey:@"executeAction"];
                [sharedExampleContext setObject:question forKey:@"expectedText"];
            });

            it(@"should not clear the question text", ^{
                invalidQuestionAction();

                assertThat(controller.questionTextView.text, equalTo(question));
            });

            it(@"should re-enable the Ask button", ^{
                invalidQuestionAction();

                assertThatBool(controller.askButton.enabled, equalToBool(YES));
            });

//            it(@"should not display the answer view controller", ^{
//                id mockNavigationController = [OCMockObject mockForClass:[UINavigationController class]];
//                id stubController = [OCMockObject partialMockForObject:controller];
//                [[[stubController stub] andReturn:mockNavigationController] navigationController];
//                [[[mockNavigationController stub] andThrow:[NSException exceptionWithName:@"Failure"
//                                                                                   reason:@"pushViewController should not be called" userInfo:nil]]
//                 pushViewController:[OCMArg any] animated:YES];
//
//                invalidQuestionAction();
//            });

            itShouldBehaveLike(@"an action that fetches structured questions from aura");

            describe(@"the web view with the error shown to the user", ^{
                __block UIWebView *webView;
                __block CGRect originalTableFrame, originalWellFrame, originalErrorFrame;
                __block CGRect newTableFrame, newWellFrame, newErrorFrame;

                beforeEach(^{
                    originalTableFrame = controller.suggestedQuestionsTableView.frame;
					originalWellFrame = controller.tableWellImageView.frame;
					originalErrorFrame = controller.networkErrorOverlayView.frame;

                    invalidQuestionAction();

                    NSArray *webViews = [controller.view findSubviewsByClass:[UIWebView class]];
                    assertThatInt([webViews count], equalToInt(1));
                    webView = [webViews lastObject];
                    newTableFrame = controller.suggestedQuestionsTableView.frame;
					newWellFrame = controller.tableWellImageView.frame;
					newErrorFrame = controller.networkErrorOverlayView.frame;
                });

                it(@"should exist", ^{
                    assertThat(webView, notNilValue());
                });

                it(@"should contain HTML with the error message returned by aura", ^{
                    assertThat(webView.loadedHTMLString, notNilValue());
                    HTMLContentVerifier *verifier = [[[HTMLContentVerifier alloc] initWithExpectedHTML:@"<html>"] autorelease];

                    assertThatBool([verifier documentContainsExpectedHTML:webView.loadedHTMLString], equalToBool(YES));

                    verifier = [[[HTMLContentVerifier alloc] initWithExpectedHTML:invalidQuestionResponse.body] autorelease];
                    assertThatBool([verifier documentContainsExpectedHTML:webView.loadedHTMLString], equalToBool(YES));
                });

                it(@"should be positioned between the question text view and the suggested questions table", ^{
                    assertThatBool(originalTableFrame.origin.y <= webView.frame.origin.y, equalToBool(YES));
                    assertThatBool(webView.frame.origin.y < newTableFrame.origin.y, equalToBool(YES));
                });

                it(@"should displace the suggested questions table down", ^{
                    assertThatFloat(newTableFrame.origin.x, equalToFloat(originalTableFrame.origin.x));
                    assertThatBool(newTableFrame.origin.y > (originalTableFrame.origin.y + webView.frame.size.height), equalToBool(YES));
                    assertThatFloat(newTableFrame.size.width, equalToFloat(originalTableFrame.size.width));
                    assertThatFloat(newTableFrame.size.height, equalToFloat(originalTableFrame.size.height));
                });

                it(@"should displace the suggested questions well overlay image", ^{
                    assertThatFloat(newWellFrame.origin.x, equalToFloat(originalWellFrame.origin.x));
                    assertThatBool(newWellFrame.origin.y > (originalWellFrame.origin.y + webView.frame.size.height), equalToBool(YES));
                    assertThatFloat(newWellFrame.size.width, equalToFloat(originalWellFrame.size.width));
                    assertThatFloat(newWellFrame.size.height, equalToFloat(originalWellFrame.size.height));
                });

                it(@"should displace the suggested questions error message", ^{
                    assertThatFloat(newErrorFrame.origin.x, equalToFloat(originalErrorFrame.origin.x));
                    assertThatBool(newErrorFrame.origin.y > (originalErrorFrame.origin.y + webView.frame.size.height), equalToBool(YES));
                    assertThatFloat(newErrorFrame.size.width, equalToFloat(originalErrorFrame.size.width));
                    assertThatFloat(newErrorFrame.size.height, equalToFloat(originalErrorFrame.size.height));
                });

                it(@"should displace the pending overlay view", ^{
                    assertThatFloat(controller.suggestedQuestionsRequestPendingOverlayView.frame.origin.y, equalToFloat(newTableFrame.origin.y));
                });
            });

            describe(@"when a web view with an error message from a previous response is being displayed", ^{
                __block UIWebView *previousWebView;
                __block CGRect tableViewFrameWhenWebViewIsDisplayed;

                beforeEach(^{
                    invalidQuestionAction();

                    previousWebView = [[controller.view findSubviewsByClass:[UIWebView class]] lastObject];
                    tableViewFrameWhenWebViewIsDisplayed = controller.suggestedQuestionsTableView.frame;

                    tapAskAction();
                    invalidQuestionAction();
                });

                it(@"should close the previous web view and open a new one", ^{
                    NSArray *webViews = [controller.view findSubviewsByClass:[UIWebView class]];
                    assertThatInt([webViews count], equalToInt(1));
                    assertThat([webViews lastObject], isNot(equalTo(previousWebView)));
                });

                it(@"should display the suggested questions table in the correct position below the web view", ^{
                    assertThat(NSStringFromCGRect(controller.suggestedQuestionsTableView.frame), equalTo(NSStringFromCGRect(tableViewFrameWhenWebViewIsDisplayed)));
                });
            });

            itShouldBehaveLike(@"an action that completes the answer-question connection with no valid answer");
        });

        describe(@"on answer-question connection error", ^{
            __block void (^errorAction)();
            __block NSError *error;

            beforeEach(^{
                error = [NSError errorWithDomain:@"Shenanigans" code:1 userInfo:nil];

                tapAskAction();

                errorAction = [[^{
                    [controller connection:[[NSURLConnection connections] lastObject] didFailWithError:error];
                } copy] autorelease];
                [sharedExampleContext setObject:errorAction forKey:@"executeAction"];
            });

            it(@"should display an error message", ^{
                id mockController = [OCMockObject partialMockForObject:controller];
                [[mockController expect] showShenanigans:error];

                errorAction();

                [mockController verify];
            });

            it(@"should not result in a new request to Aura for structured questions", ^{
                for (NSURLConnection *connection in [NSURLConnection connections]) {
                    assertThatBool([connection.request.URL.path hasPrefix:@"/formatted_structured_questions_lists"], equalToBool(NO));
                }
            });

            describe(@"when a web view with an error message from a previous response is being displayed", ^{
                __block CGRect originalTableFrame;

                beforeEach(^{
                    originalTableFrame = controller.suggestedQuestionsTableView.frame;

                    PSHKFakeHTTPURLResponse *invalidQuestionResponse;
                    invalidQuestionResponse = [[PSHKFakeResponses responsesForRequest:@"askQuestion"] badRequest];
                    [[[NSURLConnection connections] lastObject] receiveResponse:invalidQuestionResponse];

                    tapAskAction();
                    errorAction();
                });

                it(@"should close the web view", ^{
                    NSArray *webViews = [controller.view findSubviewsByClass:[UIWebView class]];
                    assertThatInt([webViews count], equalToInt(0));
                });

                it(@"should restore the suggested questions table to its original position and size", ^{
                    assertThat(NSStringFromCGRect(controller.suggestedQuestionsTableView.frame), equalTo(NSStringFromCGRect(originalTableFrame)));
                });
            });

            itShouldBehaveLike(@"an action that completes the answer-question connection with no valid answer");
        });
    });

    describe(@"tableView:didSelectRowAtIndexPath:", ^{
        __block Question *question;

        beforeEach(^{
            controller.question.text = @"";
            controller.askButton.enabled = NO;
            PSHKFakeHTTPURLResponse *successResponse = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
            [[[NSURLConnection connections] lastObject] receiveResponse:successResponse];

            question = [controller.suggestedQuestionsList objectAtIndex:1];
            assertThat(question, notNilValue());

            [controller tableView:controller.suggestedQuestionsTableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        });

        it(@"should populate the text view with the selected text in the table row", ^{
            assertThat(controller.questionTextView.text, equalTo(question.text));
        });

        it(@"should enable the Ask button", ^{
            assertThatBool(controller.askButton.enabled, equalToBool(YES));
        });

        it(@"should set the controller's current question text to be the tapped-upon question", ^{
            assertThat(controller.question.text, equalTo(question.text));
        });
    });

    describe(@"on tapping newQuestionButton", ^{
        __block UIBarButtonItem *newQuestionButton;
        __block void (^tapAction)();

        beforeEach(^{
            id toolbar = controller.navigationItem.rightBarButtonItem.customView;
            newQuestionButton = [[toolbar items] objectAtIndex:0];

            assertThat(controller.questionTextView.text, isNot(equalTo(@"")));

            tapAction = [[^{
                objc_msgSend(newQuestionButton.target, newQuestionButton.action);
            } copy] autorelease];

            [sharedExampleContext setObject:tapAction forKey:@"executeAction"];
        });

        describe(@"when a structured questions request is active", ^{
            itShouldBehaveLike(@"an action that cancels an outstanding suggested-questions request");
        });

        describe(@"when an answer-question request is active", ^{
            beforeEach(^{
                controller.questionTextView.text = @"Why is it so hard when you grill it on rye?";
                [controller textViewDidEndEditing:controller.questionTextView];

                [controller.askButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            itShouldBehaveLike(@"an action that cancels any outstanding answer-question request");
        });

        itShouldBehaveLike(@"a new question action");
    });

    describe(@"on tapping closeButton", ^{
        __block UIBarButtonItem *closeButton;
        __block void (^tapAction)();

        beforeEach(^{
            id toolbar = controller.navigationItem.rightBarButtonItem.customView;
            closeButton = [[toolbar items] objectAtIndex:1];
            tapAction = [[^{
                objc_msgSend(closeButton.target, closeButton.action);
            } copy] autorelease];

            [sharedExampleContext setObject:tapAction forKey:@"executeAction"];
        });

        itShouldBehaveLike(@"an action that cancels an outstanding suggested-questions request");

        it(@"should close the modal view", ^{
            [[mockDelegate expect] dismissModalQuestionAnswerView];
            tapAction();
            [mockDelegate verify];
        });

        describe(@"when an answer-question request is pending", ^{
            beforeEach(^{
                controller.questionTextView.text = @"What are the parts of a smurf?";
                [controller textViewDidEndEditing:controller.questionTextView];

                [controller.askButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            });

            itShouldBehaveLike(@"an action that cancels any outstanding answer-question request");
        });
    });

    describe(@"newQuestion", ^{
        beforeEach(^{
            [sharedExampleContext setObject:[[^{[controller newQuestion];} copy] autorelease] forKey:@"executeAction"];
        });

        itShouldBehaveLike(@"a new question action");
    });

    describe(@"dismissModalQuestionAnswerView", ^{
        it(@"should close the modal view", ^{
            [[mockDelegate expect] dismissModalQuestionAnswerView];
            [controller dismissModalQuestionAnswerView];
            [mockDelegate verify];
        });
    });

    describe(@"dismissModalQuestionAnswerViewAndLoadRequest:", ^{
        it(@"should load the request and dismiss the modal question answer view", ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"/path/to/some/concept"]];

            [[mockDelegate expect] dismissModalQuestionAnswerViewAndLoadRequest:request];

            [controller dismissModalQuestionAnswerViewAndLoadRequest:request];

            [mockDelegate verify];
        });
    });
});

SPEC_END
