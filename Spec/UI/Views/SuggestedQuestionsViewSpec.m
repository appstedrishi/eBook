#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import "HCEmptyContainer.h"
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"
#import "SuggestedQuestionsView.h"
#import "ConceptViewController.h"
#import "Highlight.h"
#import "Question.h"
#import "HighlightView.h"

@interface SuggestedQuestionsView (SuggestedQuestionsViewSpec)

@property (nonatomic, retain) UILabel *sizingLabel;

@end


@interface QuestionVerifier : NSObject

@property (nonatomic, retain) NSString *expectedText;

- (id)initWithExpectedText:(NSString *)expectedText;
- (BOOL)questionContainsExpectedText:(Question *)question;

@end

@implementation QuestionVerifier

@synthesize expectedText = expectedText_;

- (id)initWithExpectedText:(NSString *)expectedText {
    if (self = [super init]) {
        self.expectedText = expectedText;
    }
    return self;
}

- (void)dealloc {
    self.expectedText = nil;
    [super dealloc];
}

- (BOOL)questionContainsExpectedText:(Question *)question {
    if (NSOrderedSame != [self.expectedText compare:question.text]) {
        NSLog(@"QuestionVerifer:\n\tExpected Text:'%@'\n\tActual Text:'%@'", self.expectedText, question.text);
        return NO;
    }
    return YES;
}

@end

extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT;

SPEC_BEGIN(SuggestedQuestionsViewSpec)

describe(@"SuggestedQuestionsView", ^{
    __block SuggestedQuestionsView *view;
    __block HighlightView *highlightView;
    __block Highlight *highlight;
    __block NSURLConnection *connection;
    __block UIInterfaceOrientation orientation;

    NSString *section = @"section0-0";
    NSString *text = @"A smurf has many parts";
    NSString *rangeJSON = @"{range-info}";

    beforeEach(^{
        id mockConceptViewController = [OCMockObject niceMockForClass:[ConceptViewController class]];
        id mockConceptView = [OCMockObject mockForClass:[UIView class]];
        orientation = UIInterfaceOrientationLandscapeLeft;
        void (^returnOrientation)(NSInvocation *) = ^(NSInvocation *invocation) {
            [invocation setReturnValue:&orientation];
        };
        [[[mockConceptViewController stub] andDo:returnOrientation] interfaceOrientation];
        [[[mockConceptViewController stub] andReturn:mockConceptView] view];
        void (^getWebViewBounds)(NSInvocation *) = ^(NSInvocation *invocation) {
            CGRect rect = CGRectMake(0, 0, 1, 1000);
            [invocation setReturnValue:&rect];
        };
        [[[mockConceptView stub] andDo:getWebViewBounds] bounds];
        highlight = [Highlight highlightWithIndex:@"5" xOffset:10 yOffset:0 height:1 text:text section:section rangeJSON:rangeJSON];
        highlightView = [[[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationPortrait delegate:mockConceptViewController] autorelease];
        view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft] autorelease];

        [highlightView addSubview:view];
    });

    describe(@"outlets", ^{
        it(@"should set its delegate to the file's owner", ^{
            assertThat(view.delegate, equalTo(highlightView));
        });

        describe(@"cardView", ^{
            it(@"should be defined", ^{
                assertThat(view.cardView, notNilValue());
            });
        });

        describe(@"spinner", ^{
            it(@"should be defined", ^{
                assertThat(view.spinner, notNilValue());
            });
        });

        describe(@"suggested questions table view", ^{
            it(@"should be defined", ^{
                assertThat(view.questionsTable, notNilValue());
            });
        });

        describe(@"errorMessageView", ^{
            it(@"should be defined", ^{
                assertThat(view.errorMessageView, notNilValue());
            });

            it(@"should be hidden", ^{
                assertThatInt(view.errorMessageView.alpha, equalToInt(0));
            });
        });

        describe(@"closeButton", ^{
            it(@"should be defined", ^{
                assertThat(view.closeButton, notNilValue());
            });
        });

        describe(@"label", ^{
            it(@"should be defined", ^{
                assertThat(view.label, notNilValue());
            });
        });

		describe(@"noQuestionsLabel", ^{
			it(@"should be defined", ^{
				assertThat(view.noQuestionsLabel, notNilValue());
			});
		});

        describe(@"divider", ^{
            it(@"should be defined", ^{
                assertThat(view.divider, notNilValue());
            });
        });
    });

    describe(@"on initialization", ^{
        it(@"should not generate a network request", ^{
            assertThat([NSURLConnection connections], emptyContainer());
        });

        it(@"should not be visible", ^{
            assertThatFloat(view.alpha, equalToFloat(0));
        });
    });

    describe(@"HighlightViewComponent protocol", ^{
        describe(@"activate", ^{
            beforeEach(^{
                [view show];
            });

            it(@"should not notify the delegate", ^{
                id mockDelegate = [OCMockObject partialMockForObject:highlightView];
                [[[mockDelegate stub] andDo:^(NSInvocation *invocation) {
                    fail(@"Should not be called");
                }] suggestedQuestionsViewDidClose];

                [view activate];
            });
        });

        describe(@"deactivate", ^{
            beforeEach(^{
                [view show];
            });

            it(@"should close the view", ^{
                [view deactivate];
                assertThatFloat(view.alpha, equalToFloat(0));
            });

            it(@"should not notify the delegate", ^{
                id mockDelegate = [OCMockObject partialMockForObject:highlightView];
                [[[mockDelegate stub] andDo:^(NSInvocation *invocation) {
                    fail(@"Should not be called");
                }] suggestedQuestionsViewDidClose];

                [view deactivate];
            });
        });

        describe(@"willRotateToInterfaceOrientation:", ^{
            describe(@"from landscape to portrait", ^{
                beforeEach(^{
                    view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft] autorelease];
                });

                describe(@"when the view is active", ^{
                    beforeEach(^{
                        [view activate];
                    });

                    describe(@"and the view has been shown", ^{
                        beforeEach(^{
                            [view show];
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                        });

                        it(@"should show the view", ^{
                            assertThatFloat(view.alpha, equalToFloat(1));
                        });
                    });
                });
            });

            describe(@"from portrait to landscape", ^{
                beforeEach(^{
                    view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationPortrait] autorelease];
                });

                describe(@"when the view is active", ^{
                    beforeEach(^{
                        [view activate];
                    });
					
                    describe(@"and the view has not been shown", ^{
						it(@"should not show the view", ^{
							assertThatFloat(view.alpha, equalToFloat(0));
						});
					});
					
                    describe(@"and the view has been shown", ^{
                        beforeEach(^{
                            [view show];
                        });
						
                        it(@"should hide the view", ^{
                            assertThatFloat(view.alpha, equalToFloat(1));
                        });
                    });
                });

                describe(@"when the view is not active", ^{
                    beforeEach(^{
                        [view deactivate];
                    });

                    describe(@"and the view has been closed", ^{
                        beforeEach(^{
                            [view show];
                            [view close];
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                        });

                        it(@"should hide the view", ^{
                            assertThatFloat(view.alpha, equalToFloat(0));
                        });
                    });
                });
            });
        });

        describe(@"hasVisibleCard", ^{
            describe(@"in landscape mode", ^{
                beforeEach(^{
                    view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft] autorelease];
                });

                describe(@"when the view is active", ^{
                    beforeEach(^{
                        [view activate];
                    });
					
                    describe(@"and the view has been shown", ^{
                        beforeEach(^{
                            [view show];
                        });
						it(@"should return YES", ^{
							assertThatBool([view hasVisibleCard], equalToBool(YES));
						});
					});
                });

                describe(@"when the view is not active", ^{
                    beforeEach(^{
                        [view deactivate];
                    });

					it(@"should return NO", ^{
						assertThatBool([view hasVisibleCard], equalToBool(NO));
					});
                });
            });

            describe(@"in portrait mode", ^{
                beforeEach(^{
                    view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationPortraitUpsideDown] autorelease];
                });

                describe(@"when the view is active and has been shown", ^{
                    beforeEach(^{
                        [view activate];
                        [view show];
                    });

					it(@"should return YES", ^{
						assertThatBool([view hasVisibleCard], equalToBool(YES));
					});
                });

                describe(@"when the view is not active", ^{
                    beforeEach(^{
                        [view deactivate];
                    });

					it(@"should return NO", ^{
						assertThatBool([view hasVisibleCard], equalToBool(NO));
					});
                });
            });
        });
    });

    describe(@"tableView:tableView didSelectRowAtIndexPath:", ^{
        beforeEach(^{
            [highlight fetchSuggestedQuestionsListWithDelegate:nil];
            connection = [[NSURLConnection connections] lastObject];
            PSHKFakeHTTPURLResponse *response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
            [connection receiveResponse:response];
        });

        it(@"should tell the delegate to ask the current question", ^{
            QuestionVerifier *verifier = [[QuestionVerifier alloc] initWithExpectedText:@"What is a smurf?"];
            id mockDelegate = [OCMockObject partialMockForObject:highlightView];
            [[mockDelegate expect] showQuestionViewWithQuestion:[OCMArg checkWithSelector:@selector(questionContainsExpectedText:) onObject:verifier]];

            [view tableView:view.questionsTable didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];

            [mockDelegate verify];
        });

        it(@"should deselect the row", ^{
            id mockTableView = [OCMockObject partialMockForObject:view.questionsTable];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [[mockTableView expect] deselectRowAtIndexPath:indexPath animated:YES];

            [view tableView:view.questionsTable didSelectRowAtIndexPath:indexPath];

            [mockTableView verify];
        });
    });

    sharedExamplesFor(@"an action that fetches suggested questions", ^(NSDictionary *context) {
        beforeEach(^{
            connection = [context objectForKey:@"connection"];
        });

        it(@"should show a spinner", ^{
            assertThatBool(view.spinner.isAnimating, equalToBool(YES));
        });

        it(@"should ask the highlight to fetch suggested questions", ^{
            assertThat(connection.request.URL.path, equalTo(@"/suggested_questions_lists"));
        });

        describe(@"on successful fetch of suggested questions", ^{
            __block PSHKFakeHTTPURLResponse *response;

            beforeEach(^{
                response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
            });

            it(@"should refresh the questions table view", ^{
                [connection receiveResponse:response];

                assertThatInt([view.questionsTable numberOfRowsInSection:0], equalToInt(3));
            });

            it(@"should display the returned questions in the table view", ^{
                [connection receiveResponse:response];

                UITableViewCell *cell = [view tableView:view.questionsTable cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                assertThatBool([cell.textLabel.text isEqualToString:@"What is a smurf?"], equalToBool(YES));
            });

            it(@"should hide the spinner", ^{
                [connection receiveResponse:response];

                assertThatBool(view.spinner.isAnimating, equalToBool(NO));
            });
        });

        describe(@"on error response from the server", ^{
            beforeEach(^{
                PSHKFakeHTTPURLResponse *response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] badRequest];
                [connection receiveResponse:response];
            });

            it(@"should show the error message view", ^{
                assertThatInt(view.errorMessageView.alpha, equalToInt(1));
            });

            it(@"should hide the table view", ^{
                assertThatInt(view.questionsTable.alpha, equalToInt(0));
            });

            it(@"should hide the spinner", ^{
                assertThatBool(view.spinner.isAnimating, equalToBool(NO));
            });
        });

        describe(@"on failure to complete the request", ^{
            beforeEach(^{
                NSError *error = nil;
                [[connection delegate] connection:connection didFailWithError:error];
            });

            it(@"should show the error message view", ^{
                assertThatInt(view.errorMessageView.alpha, equalToInt(1));
            });

            it(@"should hide the table view", ^{
                assertThatInt(view.questionsTable.alpha, equalToInt(0));
            });

            it(@"should hide the spinner", ^{
                assertThatBool(view.spinner.isAnimating, equalToBool(NO));
            });
        });
    });

    sharedExamplesFor(@"an action that shows suggested questions in an active highlight view", ^(NSDictionary *context) {
        beforeEach(^{
            [view activate];
            [view show];
            connection = [[NSURLConnection connections] lastObject];
            [[SpecHelper specHelper].sharedExampleContext setObject:connection forKey:@"connection"];
        });

        it(@"should show the view", ^{
            assertThatFloat(view.alpha, equalToFloat(1));
        });

        it(@"should hide the close button", ^{
            assertThatBool(view.closeButton.hidden, equalToBool(YES));
        });

        it(@"should hide the label", ^{
            assertThatBool(view.label.hidden, equalToBool(YES));
        });

        it(@"should hide the divider", ^{
            assertThatBool(view.divider.hidden, equalToBool(YES));
        });

        itShouldBehaveLike(@"an action that fetches suggested questions");

        describe(@"on successful fetch of suggested questions", ^{
            __block PSHKFakeHTTPURLResponse *response;

            beforeEach(^{
                response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
            });

            it(@"should properly position the table", ^{
                [connection receiveResponse:response];
                assertThatFloat(view.questionsTable.frame.origin.y, equalToFloat(0));
            });
        });

        describe(@"on error response from the server", ^{
            beforeEach(^{
                PSHKFakeHTTPURLResponse *response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] badRequest];
                [connection receiveResponse:response];
            });

            it(@"should not resize the card view", ^{
                assertThatFloat(view.cardView.frame.size.height, equalToFloat(HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT));
            });
        });
    });

    describe(@"show", ^{
        describe(@"in portrait orientation", ^{
            beforeEach(^{
                view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationPortrait] autorelease];
                [view show];
            });

            describe(@"when the view is active", ^{
                itShouldBehaveLike(@"an action that shows suggested questions in an active highlight view");
            });

            describe(@"when the view is not active", ^{
                beforeEach(^{
                    [view deactivate];
                    [view show];
                });

                it(@"should not show the view", ^{
                    assertThatFloat(view.alpha, equalToFloat(0));
                });
            });
        });

        describe(@"in landscape orientation", ^{
            beforeEach(^{
                view = [[[SuggestedQuestionsView alloc] initWithOwner:highlightView andHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft] autorelease];
            });

            describe(@"when the view is active", ^{
                itShouldBehaveLike(@"an action that shows suggested questions in an active highlight view");
            });

//            describe(@"when the view is not active", ^{
//                beforeEach(^{
//                    [view deactivate];
//                    [view show];
//                    connection = [[NSURLConnection connections] lastObject];
//                    [[SpecHelper specHelper].sharedExampleContext setObject:connection forKey:@"connection"];
//                });
//
//                it(@"should show the view", ^{
//                    assertThatFloat(view.alpha, equalToFloat(1));
//                });
//
//                it(@"should show the close button", ^{
//                    assertThatBool(view.closeButton.hidden, equalToBool(NO));
//                });
//
//                it(@"should show the label", ^{
//                    assertThatBool(view.closeButton.hidden, equalToBool(NO));
//                });
//
//                it(@"should show the divider", ^{
//                    assertThatBool(view.divider.hidden, equalToBool(NO));
//                });
//
//                itShouldBehaveLike(@"an action that fetches suggested questions");
//            });
        });
    });

    describe(@"didTapCloseButton:", ^{
        it(@"should notify the delegate", ^{
            id mockDelegate = [OCMockObject partialMockForObject:highlightView];
            [[mockDelegate expect] suggestedQuestionsViewDidClose];

            [view didTapCloseButton:view];

            [mockDelegate verify];
        });

        it(@"should close the view", ^{
            id mockView = [OCMockObject partialMockForObject:view];
            [[mockView expect] close];

            [view didTapCloseButton:view];

            [mockView verify];
        });
    });

    describe(@"close", ^{
        it(@"should cancel any pending suggested questions requests", ^{
            [view show];
            assertThat([NSURLConnection connections], isNot(emptyContainer()));

            [view close];

            assertThat([NSURLConnection connections], is(emptyContainer()));
        });

        it(@"should hide the view", ^{
            [view close];
            assertThatFloat(view.alpha, equalToFloat(0));
        });
    });
});

SPEC_END
