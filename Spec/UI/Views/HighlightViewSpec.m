#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "HCEmptyContainer.h"

#import "UIView+FindSubviews.h"

#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"
#import "ConceptViewController.h"
#import "Highlight.h"
#import "HighlightView.h"
#import "HighlightToolbarView.h"
#import "Question.h"
#import "StickieView.h"
#import "SuggestedQuestionsView.h"
#import "Book.h"
#import "HighlightNotecardView.h"
#import "HighlightViewDelegate.h"

@interface HighlightView (HighlightViewSpecImpl)

@property (nonatomic, assign) UIInterfaceOrientation orientation;

@end

SPEC_BEGIN(HighlightViewSpec)

describe(@"HighlightView", ^{
    __block HighlightView *view;
    NSString *highlightIndex = @"17";
    CGFloat verticalPosition = 101.7;
    __block Highlight *highlight;
    __block id mockDelegate;

    beforeEach(^{
        highlight = [Highlight highlightWithIndex:highlightIndex xOffset:10 yOffset:verticalPosition height:2 text:nil section:nil rangeJSON:nil];
        highlight.notecardText = @"This is a note!!";

        ConceptViewController *con = [[[ConceptViewController alloc] init] autorelease];
        mockDelegate = [OCMockObject partialMockForObject:con];  //[OCMockObject mockForProtocol:@protocol(HighlightViewDelegate)];
        view = [[[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate] autorelease];
    });

    describe(@"on initialization", ^{
        describe(@"stickie view", ^{
            it(@"should exist", ^{
                assertThat(view.stickieView, notNilValue());
            });
        });

        describe(@"highlight toolbar view", ^{
            it(@"should exist", ^{
                assertThat(view.highlightToolbarView, notNilValue());
            });
        });

        describe(@"the highlight notecard view", ^{
            it(@"should exist", ^{
                assertThat(view.highlightNotecardView, notNilValue());
            });
        });

        describe(@"suggested questions view", ^{
            it(@"should exist", ^{
                assertThat(view.suggestedQuestionsView, notNilValue());
            });
        });
    });

    describe(@"stickie view horizontal offset", ^{
        it(@"should default to x when there are no other highlights at the same yOffset", ^{
            assertThatFloat(view.stickieView.frame.origin.x, equalToFloat(0));
        });

        describe(@"when there is another highlight at the same yOffset", ^{
            float stubReturn = 43;

            it(@"should set the x-offset to 43", ^{
                [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(stubReturn)] stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43];
				Highlight *hl2 = [Highlight highlightWithIndex:highlightIndex xOffset:12 yOffset:verticalPosition height:2 text:nil section:nil rangeJSON:nil];
                [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(stubReturn)] stickieViewHorizontalOffsetForHighlight:hl2 withIncrement:43];
                HighlightView *secondView = [[[HighlightView alloc] initWithHighlight:hl2 orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate] autorelease];

                assertThatFloat(secondView.stickieView.frame.origin.x, equalToFloat(stubReturn));
            });
        });
    });

    describe(@"updateStickieViewHorizontalOffset", ^{
        it(@"should ask the delegate for the horizontal offset", ^{
            [[mockDelegate expect] stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43];

            [view updateStickieViewHorizontalOffset];

            [mockDelegate verify];
        });

//        it(@"should update the stickie view's frame to respect the new horizontal offset", ^{
//            float stubReturn = 43;
//            [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(stubReturn)] stickieViewHorizontalOffsetForHighlight:highlight withIncrement:43];
//            [view updateStickieViewHorizontalOffset];
//
//            assertThatFloat(view.stickieView.frame.origin.x, equalToFloat(stubReturn));
//        });
    });

    describe(@"showSuggestedQuestions", ^{
        beforeEach(^{
            highlight.notecardText = @"";
            view = [[[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate] autorelease];
        });

        describe(@"in landscape orientation", ^{
            beforeEach(^{
                [view showSuggestedQuestions];
            });

            it(@"should create the suggested questions view", ^{
                assertThat(view.suggestedQuestionsView, notNilValue());
            });
        });

        describe(@"in portrait orientation", ^{
            beforeEach(^{
                view = [[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationPortrait delegate:mockDelegate];
                [view showSuggestedQuestions];
            });

            it(@"should create the suggested questions view", ^{
                assertThat(view.suggestedQuestionsView, notNilValue());
            });
        });

        it(@"should pass the highlight to the suggested questions view", ^{  // TODO: this description does not match what's being tested?
            [view showSuggestedQuestions];
            assertThatInt([view.suggestedQuestionsView.questionsTable numberOfRowsInSection:0], equalToInt([highlight.suggestedQuestionsList count]));
        });

        it(@"should position the suggested questions view beneath the stickie view", ^{
            [view showSuggestedQuestions];

            int stickieIndex = [view.subviews indexOfObject:view.stickieView];
            int suggestedQuestionsIndex = [view.subviews indexOfObject:view.suggestedQuestionsView];
            assertThatBool(stickieIndex > suggestedQuestionsIndex, equalToBool(YES));
        });

        it(@"should tell the stickie view to not draw a drop shadow", ^{
            id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
            [[mockStickieView expect] setShowDropShadow:NO];

            [view showSuggestedQuestions];

            [mockStickieView verify];
        });
    });

    describe(@"didMoveToSuperview", ^{
        beforeEach(^{
            [view showSuggestedQuestions];
            assertThat([NSURLConnection connections], isNot(emptyContainer()));
        });

        describe(@"when added to a superview", ^{
            beforeEach(^{
                [[[[OCMockObject partialMockForObject:view] stub] andReturn:[OCMockObject mockForClass:[UIView class]]] superview];
                assertThat(view.superview, notNilValue());

                [view didMoveToSuperview];
            });

            it(@"should not cancel any pending server requests for suggested questions", ^{
                assertThat([NSURLConnection connections], isNot(emptyContainer()));
            });
        });

        describe(@"when removed from the superview", ^{
            beforeEach(^{
                assertThat(view.superview, nilValue());

                [view didMoveToSuperview];
            });

            it(@"should cancel any pending server requests for suggested questions", ^{
                assertThat([NSURLConnection connections], emptyContainer());
            });
        });
    });

    describe(@"scrollToOffset:", ^{
        it(@"should translate the frame to the appropriate position based on the vertical position and new scroll offset", ^{
            CGFloat scrollOffset = 55.7;

            [view scrollToOffset:scrollOffset];

            assertThatFloat(view.frame.origin.y, equalToFloat(verticalPosition - scrollOffset));
        });

        it(@"should not change the size dimensions of the frame", ^{
            CGRect originalFrame = view.frame;

            [view scrollToOffset:4321];

            assertThatFloat(CGRectGetWidth(view.frame), equalToFloat(CGRectGetWidth(originalFrame)));
            assertThatFloat(CGRectGetHeight(view.frame), equalToFloat(CGRectGetHeight(originalFrame)));
        });
    });

    describe(@"showQuestionViewWithQuestion:", ^{
        it(@"should forward the message on to the delegate", ^{
            Question *question = [[Question alloc] init];
            question.text = @"Some question";
            [[mockDelegate expect] showQuestionViewWithQuestion:question];

            [view showQuestionViewWithQuestion:question];

            [mockDelegate verify];
        });
    });

    describe(@"didTapDelete", ^{
        it(@"should tell the delegate to remove the highlight", ^{
            [[mockDelegate expect] removeHighlight:view.highlight];

            [view didTapDelete];

            [mockDelegate verify];
        });
    });

    describe(@"didTapStickie", ^{
        it(@"should tell the delegate to make ourselves be the active highlight", ^{
            [[mockDelegate expect] setActiveHighlightView:view];

            [view didTapStickie];

            [mockDelegate verify];
        });
    });

    describe(@"didTapQuestions", ^{
        describe(@"when the questions button is not selected", ^{
            beforeEach(^{
                assertThatBool(view.highlightToolbarView.questionsButton.selected, equalToBool(NO));
            });

            it(@"should select the questions button", ^{
                [view didTapQuestions];
                assertThatBool(view.highlightToolbarView.questionsButton.selected, equalToBool(YES));
            });

            it(@"should close the notecard view", ^{
                id mockNotecardText = [OCMockObject partialMockForObject:view.highlightNotecardView];
                [[mockNotecardText expect] close];

                [view didTapQuestions];

                [mockNotecardText verify];
            });

            it(@"should show the suggested questions", ^{
                id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
                [[mockSuggestedQuestionsView expect] show];

                [view didTapQuestions];

                [mockSuggestedQuestionsView verify];
            });

            describe(@"and in portrait mode", ^{
                beforeEach(^{
                    view = [[[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationPortrait delegate:mockDelegate] autorelease];
                });

                it(@"should insert the notecard view above the stickie view in z-ordering", ^{
                    assertThatBool([view.subviews indexOfObject:view.highlightNotecardView] > [view.subviews indexOfObject:view.stickieView], equalToBool(YES));
                });
            });

            describe(@"and in landscape mode", ^{
                beforeEach(^{
                    view = [[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate];
                });

                it(@"should insert the notecard view below the stickie view in z-ordering", ^{
                    assertThatBool([view.subviews indexOfObject:view.highlightNotecardView] < [view.subviews indexOfObject:view.stickieView], equalToBool(YES));
                });
            });
        });
    });
	
	describe(@"didTapNotes", ^{
		describe(@"when the questions button is selected", ^{
			beforeEach(^{
				view.highlightToolbarView.questionsButton.selected = YES;
			});
			
			it(@"should deselect the questions button", ^{
				[view didTapNotes];
				assertThatBool(view.highlightToolbarView.questionsButton.selected, equalToBool(NO));
			});
			
			it(@"should hide the selected questions", ^{
				id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
				[[mockSuggestedQuestionsView expect] close];
				
				[view didTapNotes];
				
				[mockSuggestedQuestionsView verify];
			});
        });
	});
	

    describe(@"HighlightNotecardViewDelegate methods", ^{
        describe(@"activateHighlight", ^{
            it(@"should tell its delegate to activate the view", ^{
                [[mockDelegate expect] setActiveHighlightView:view];

                [view activateHighlight];

                [mockDelegate verify];
            });
        });

        describe(@"scrollToHighlight", ^{
            it(@"should tell its delegate to scroll to the view", ^{
                [[mockDelegate expect] scrollToHighlight:highlight];

                [view scrollToHighlight];

                [mockDelegate verify];
            });
        });

        describe(@"hasSiblingHighlights", ^{
            describe(@"when there is only one highlight on the line", ^{
                it(@"should return NO", ^{
                    BOOL no = NO;
                    [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(no)] hasMultipleHighlightsAtHighlight:highlight];

                    assertThatBool([view hasSiblingHighlights], equalToBool(NO));
                });
            });

            describe(@"when there is more than one highlight on the line", ^{
                it(@"should return YES", ^{
                    BOOL yes = YES;
                    [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(yes)] hasMultipleHighlightsAtHighlight:highlight];

                    assertThatBool([view hasSiblingHighlights], equalToBool(YES));
                });
            });
        });
    });

    describe(@"HighlightViewComponent protocol", ^{
        describe(@"activate", ^{
            it(@"should make the highlight appear on top of other highlights", ^{   // TODO: test the z-index instead of testing the implementation?
                UIView *superview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
                [superview addSubview:view];

                id mockSuperview = [OCMockObject partialMockForObject:superview];
                [[mockSuperview expect] bringSubviewToFront:view];

                [view activate];

                [mockSuperview verify];
            });

            describe(@"(subviews)", ^{
                it(@"should tell the stickie view to activate", ^{
                    id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                    [[mockStickieView expect] activate];

                    [view activate];

                    [mockStickieView verify];
                });

                it(@"should tell the highlight toolbar view to activate", ^{
                    id mockHighlightToolbarView = [OCMockObject partialMockForObject:view.highlightToolbarView];
                    [[mockHighlightToolbarView expect] activate];

                    [view activate];

                    [mockHighlightToolbarView verify];
                });

                it(@"should tell the highlight notecard view to activate", ^{
                    id mockHighlightNotecardView = [OCMockObject partialMockForObject:view.highlightNotecardView];
                    [[mockHighlightNotecardView expect] activate];

                    [view activate];

                    [mockHighlightNotecardView verify];
                });

                it(@"should tell the suggested questions view to activate", ^{
                    [view showSuggestedQuestions];

                    id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
                    [[mockSuggestedQuestionsView expect] activate];

                    [view activate];

                    [mockSuggestedQuestionsView verify];
                });
            });

            it(@"should tell the stickie view whether to draw a drop shadow", ^{
                id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                [[mockStickieView expect] setShowDropShadow:NO];

                [view activate];

                [mockStickieView verify];
            });
        });

        describe(@"deactivate", ^{
            beforeEach(^{
                [view activate];
            });

            describe(@"(subviews)", ^{
                it(@"should tell the stickie view to deactivate", ^{
                    id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                    [[mockStickieView expect] deactivate];

                    [view deactivate];

                    [mockStickieView verify];
                });

                it(@"should tell the highlight toolbar view to deactivate", ^{
                    id mockHighlightToolbarView = [OCMockObject partialMockForObject:view.highlightToolbarView];
                    [[mockHighlightToolbarView expect] deactivate];

                    [view deactivate];

                    [mockHighlightToolbarView verify];
                });

                it(@"should tell the highlight notecard view to deactivate", ^{
                    id mockHighlightNotecardView = [OCMockObject partialMockForObject:view.highlightNotecardView];
                    [[mockHighlightNotecardView expect] deactivate];

                    [view deactivate];

                    [mockHighlightNotecardView verify];
                });

                it(@"should tell the suggested questions view to deactivate", ^{
                    [view showSuggestedQuestions];

                    id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
                    [[mockSuggestedQuestionsView expect] deactivate];

                    [view deactivate];

                    [mockSuggestedQuestionsView verify];
                });
            });

//            it(@"should tell the stickie view whether to draw a drop shadow", ^{
//				BOOL no = NO;
//				[[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(no)] hasMultipleHighlightsAtHighlight:highlight];
//                id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
//                [[mockStickieView expect] setShowDropShadow:YES];
//
//                [view deactivate];
//
//                [mockStickieView verify];
//            });

            it(@"should notify its delegate", ^{
				BOOL no = NO;
				[[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(no)] hasMultipleHighlightsAtHighlight:highlight];
                [[mockDelegate expect] highlightViewDeactivated:view];

                [view deactivate];

                [mockDelegate verify];
            });
        });

        describe(@"willRotateToInterfaceOrientation:", ^{
            describe(@"from landscape to portrait", ^{

                beforeEach(^{
                    view = [[[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate] autorelease];
                    assertThatBool(UIInterfaceOrientationIsLandscape(view.orientation), equalToBool(YES));
                });

                describe(@"(subviews)", ^{
                    it(@"should tell the stickie view to rotate", ^{
                        id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                        [[mockStickieView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [mockStickieView verify];
                    });

                    it(@"should tell the highlight toolbar view to rotate", ^{
                        id mockHighlightToolbarView = [OCMockObject partialMockForObject:view.highlightToolbarView];
                        [[mockHighlightToolbarView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [mockHighlightToolbarView verify];
                    });

                    it(@"should tell the highlight notecard view to rotate", ^{
                        id mockHighlightNotecardView = [OCMockObject partialMockForObject:view.highlightNotecardView];
                        [[mockHighlightNotecardView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [mockHighlightNotecardView verify];
                    });

                    it(@"should tell the suggested questions view to rotate", ^{
                        [view showSuggestedQuestions];

                        id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
                        [[mockSuggestedQuestionsView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        [mockSuggestedQuestionsView verify];
                    });

                    it(@"should insert the notecard view above the stickie view in z-ordering", ^{
                        assertThatBool([view.subviews indexOfObject:view.stickieView] > [view.subviews indexOfObject:view.highlightNotecardView], equalToBool(YES));

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];

                        assertThatBool([view.subviews indexOfObject:view.highlightNotecardView] > [view.subviews indexOfObject:view.stickieView], equalToBool(YES));
                    });
                });
            });

            describe(@"from portrait to landscape", ^{
                beforeEach(^{
                    view = [[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationPortrait delegate:mockDelegate];
                });

                describe(@"(subviews)", ^{
                    it(@"should tell the stickie view to rotate", ^{
                        id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                        [[mockStickieView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [mockStickieView verify];
                    });

                    it(@"should tell the highlight toolbar view to rotate", ^{
                        id mockHighlightToolbarView = [OCMockObject partialMockForObject:view.highlightToolbarView];
                        [[mockHighlightToolbarView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [mockHighlightToolbarView verify];
                    });

                    it(@"should tell the highlight notecard view to rotate", ^{
                        id mockHighlightNotecardView = [OCMockObject partialMockForObject:view.highlightNotecardView];
                        [[mockHighlightNotecardView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [mockHighlightNotecardView verify];
                    });

                    it(@"should tell the suggested questions view to rotate", ^{
                        [view showSuggestedQuestions];

                        id mockSuggestedQuestionsView = [OCMockObject partialMockForObject:view.suggestedQuestionsView];
                        [[mockSuggestedQuestionsView expect] willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        [mockSuggestedQuestionsView verify];
                    });

                    it(@"should insert the notecard view below the stickie view in z-ordering", ^{
                        assertThatBool([view.subviews indexOfObject:view.stickieView] < [view.subviews indexOfObject:view.highlightNotecardView], equalToBool(YES));

                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                        assertThatBool([view.subviews indexOfObject:view.highlightNotecardView] < [view.subviews indexOfObject:view.stickieView], equalToBool(YES));
                    });
                });
            });

            it(@"should tell the stickie view whether to draw a drop shadow", ^{
                id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
                [[mockStickieView expect] setShowDropShadow:NO];

                [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeRight];

                [mockStickieView verify];
            });
        });
    });

    describe(@"suggestedQuestionsViewDidClose", ^{
        beforeEach(^{
            highlight.notecardText = @"";
            view = [[HighlightView alloc] initWithHighlight:highlight orientation:UIInterfaceOrientationLandscapeRight delegate:mockDelegate];
        });

        it(@"should tell the stickie view to draw a drop shadow", ^{
            id mockStickieView = [OCMockObject partialMockForObject:view.stickieView];
            [[mockStickieView expect] setShowDropShadow:YES];

            [view suggestedQuestionsViewDidClose];

            [mockStickieView verify];
        });
    });
});

SPEC_END
