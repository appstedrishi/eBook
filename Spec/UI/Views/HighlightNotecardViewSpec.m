#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"

#import "HighlightNotecardView.h"
#import "HighlightNotecardViewDelegate.h"
#import "Highlight.h"
#import "RepeatingBackgroundImageView.h"
#import "UnfocusedTextLabelView.h"

extern const CGFloat HIGHLIGHT_TOOLBAR_HEIGHT;
extern const CGFloat HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT;

@interface HighlightNotecardView (HighlightNotecardViewSpec)

@property (nonatomic, assign) id<HighlightNotecardViewDelegate> delegate;

@end


SPEC_BEGIN(HighlightNotecardViewSpec)

describe(@"HighlightNotecardView", ^{
    NSMutableDictionary *sharedExampleContext = [SpecHelper specHelper].sharedExampleContext;
    __block Highlight *highlight;
    __block HighlightNotecardView *view;
    __block id mockDelegate;

    beforeEach(^{
        highlight = [Highlight highlightWithIndex:@"2" xOffset:10 yOffset:23 height:5 text:@"wibble" section:@"" rangeJSON:@""];
        highlight.notecardText = @"this is the notecard text";

        mockDelegate = [OCMockObject niceMockForProtocol:@protocol(HighlightNotecardViewDelegate)];
        BOOL no = NO;
        [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(no)] hasSiblingHighlights];
        view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                  andOrientation:UIInterfaceOrientationLandscapeLeft
                                                     andDelegate:mockDelegate] autorelease];
        assertThat(view, notNilValue());
    });

    sharedExamplesFor(@"an action that displays a non-blank note in an inactive highlight in landscape orientation", ^(NSDictionary *context) {
        __block void (^executeAction)();

        beforeEach(^{
            view.textView.contentOffset = CGPointMake(0, 100);      // Required setup for the should-scroll-text-to-top test below.
            executeAction = [context objectForKey:@"executeAction"];
        });

        it(@"should set the text view to be not visible", ^{
            executeAction();

            assertThatFloat(view.textView.alpha, equalToFloat(0));
        });

        describe(@"when there is only one highlight on this line", ^{
            beforeEach(^{
                BOOL no = NO;
                [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(no)] hasSiblingHighlights];

                assertThatBool([view.delegate hasSiblingHighlights], equalToBool(NO));

                executeAction();
            });

            it(@"should set the unfocused text label to be visible", ^{
                assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(1));
            });
        });

        describe(@"when there are more than one highlight on the same line", ^{
            beforeEach(^{
                mockDelegate = [OCMockObject niceMockForProtocol:@protocol(HighlightNotecardViewDelegate)];
                BOOL yes = YES;
                [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(yes)] hasSiblingHighlights];
                view.delegate = mockDelegate;

                assertThatBool([view.delegate hasSiblingHighlights], equalToBool(YES));

                executeAction();
            });

            it(@"should not show itself)", ^{
                assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
            });
        });

        it(@"should size the unfocused text label to fit the text", ^{
            // We cannot calculate the real height without copying the code under test that actually sets that height.
            // These asserts are used instead.  The height of a notecard with no text is 8 points.
            assertThatBool(view.unfocusedTextLabel.bounds.size.height > 8, equalToBool(YES));
            assertThatBool(view.unfocusedTextLabel.bounds.size.height < HIGHLIGHT_FOCUSED_CARD_CONTENT_SIZE_HEIGHT, equalToBool(YES));
        });

        describe(@"upon tapping on the unfocused text label", ^{
            it(@"should activate the highlight", ^{
                [[mockDelegate expect] activateHighlight];

                [view didTapUnfocusedTextLabel];

                [mockDelegate verify];
            });
        });
    });

    describe(@"when initialized", ^{
        describe(@"the text view", ^{
            it(@"should exist", ^{
                assertThat(view.textView, notNilValue());
            });

            it(@"should be a child of the HighlightNotecardView", ^{
                assertThat(view.textView.superview, equalTo(view));
            });

            it(@"should be initialized with the highlight's notecard text", ^{
                assertThat(view.textView.text, equalTo(highlight.notecardText));
            });

            it(@"should set its delegate to the view", ^{
                assertThat(view.textView.delegate, equalTo(view));
            });
        });

        describe(@"the unfocused text label", ^{
            it(@"should exist", ^{
                assertThat(view.unfocusedTextLabel, notNilValue());
            });

            it(@"should be a child of the HighlightNotecardView", ^{
                assertThat(view.unfocusedTextLabel.superview, equalTo(view));
            });

            it(@"should be initialized with the highlight's notecard text", ^{
                assertThat(view.unfocusedTextLabel.text, equalTo(highlight.notecardText));
            });

            describe(@"when there is only one highlight on this line", ^{
                it(@"should be visible", ^{
                    assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(1));
                });
            });

            describe(@"when there are more than one highlight on the same line", ^{
                beforeEach(^{
                    mockDelegate = [OCMockObject niceMockForProtocol:@protocol(HighlightNotecardViewDelegate)];
                    BOOL yes = YES;
                    [[[mockDelegate stub] andReturnValue:OCMOCK_VALUE(yes)] hasSiblingHighlights];

                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                              andOrientation:UIInterfaceOrientationLandscapeLeft
                                                                 andDelegate:mockDelegate] autorelease];

                    assertThatBool([view.delegate hasSiblingHighlights], equalToBool(YES));
                });

                it(@"should not be visible", ^{
                    assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                });
            });
        });

        describe(@"the note icon", ^{
            it(@"should exist", ^{
                assertThat(view.noteIconImageView, notNilValue());
            });

            it(@"should be a child of the HighlightNotecardView", ^{
                assertThat(view.noteIconImageView.superview, equalTo(view));
            });

            describe(@"when the highlight has a note text", ^{
                describe(@"in landscape orientation", ^{
                    it(@"should not be visible", ^{
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                    });
                });

                describe(@"in portrait orientation", ^{
                    beforeEach(^{
                        view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                  andOrientation:UIInterfaceOrientationPortrait
                                                                     andDelegate:mockDelegate] autorelease];
                    });

                    it(@"should be visible", ^{
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(1));
                    });
                });
            });


            describe(@"when the highlight has no note text", ^{
                beforeEach(^{
                    highlight.notecardText = @"";
                });

                describe(@"in landscape orientation", ^{
                    beforeEach(^{
                        view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                  andOrientation:UIInterfaceOrientationLandscapeLeft
                                                                     andDelegate:mockDelegate] autorelease];
                    });

                    it(@"should not be visible", ^{
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                    });
                });

                describe(@"in portrait orientation", ^{
                    beforeEach(^{
                        view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                  andOrientation:UIInterfaceOrientationPortrait
                                                                     andDelegate:mockDelegate] autorelease];
                    });

                    it(@"should not be visible", ^{
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                    });
                });
            });
        });
    });

    describe(@"HighlightViewComponent protocol", ^{
        describe(@"activate", ^{
            describe(@"in landscape orientation", ^{
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft andDelegate:mockDelegate] autorelease];
                    [view activate];
                });

                describe(@"the text view", ^{
                    describe(@"when the highlight has a note", ^{
                        it(@"should be visible", ^{
                            assertThatFloat(view.textView.alpha, equalToFloat(1));
                        });
                    });

                    describe(@"when the highlight has no note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                            [view activate];
                        });

                        it(@"should be visible", ^{
                            assertThatFloat(view.textView.alpha, equalToFloat(1));
                        });
                    });
                });

                describe(@"the unfocused text label", ^{
                    it(@"should not be visible", ^{
                        assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                    });
                });

                describe(@"the note icon", ^{
                    it(@"should not be visible", ^{
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                    });
                });
            });

            describe(@"in portrait orientation", ^{
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight andOrientation:UIInterfaceOrientationPortrait andDelegate:mockDelegate] autorelease];
                    [view activate];
                });

                describe(@"the text view", ^{
                    it(@"should be visible", ^{
                        assertThatFloat(view.textView.alpha, equalToFloat(1));
                    });
                });

                describe(@"the unfocused text label", ^{
                    it(@"should not be visible", ^{
                        assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                    });
                });

                describe(@"the note icon", ^{
                    describe(@"when the highlight has a note", ^{
                        beforeEach(^{
                            assertThatInt(highlight.notecardText.length, isNot(equalToInt(0)));
                        });

                        it(@"should not be visible", ^{
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"when the highlight has no note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                            [view activate];
                        });

                        it(@"should not be visible", ^{
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                        });
                    });
                });
            });
        });

        describe(@"deactivate", ^{
            __block void (^deactivateAction)();

            describe(@"in landscape orientation", ^{
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight andOrientation:UIInterfaceOrientationLandscapeLeft andDelegate:mockDelegate] autorelease];
                    deactivateAction = [^{
                        [view deactivate];
                    } copy];
                    [sharedExampleContext setObject:deactivateAction forKey:@"executeAction"];
                });

                describe(@"when the highlight has a note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"This is a really interesting highlight.";
                    });

                    itShouldBehaveLike(@"an action that displays a non-blank note in an inactive highlight in landscape orientation");
                });

                describe(@"when the highlight has no note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"";
                    });

                    describe(@"the unfocused text label", ^{
                        it(@"should be hidden", ^{
                            deactivateAction();
                            assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                        });
                    });
                });

                describe(@"the text view", ^{
                    it(@"should be hidden", ^{
                        deactivateAction();
                        assertThatFloat(view.textView.alpha, equalToFloat(0));
                    });

                    it(@"should resign first responder", ^{
                        id mockTextView = [OCMockObject partialMockForObject:view.textView];
                        [[mockTextView expect] resignFirstResponder];

                        deactivateAction();

                        [mockTextView verify];
                    });
                });

                describe(@"the note icon view", ^{
                    it(@"should be hidden", ^{
                        deactivateAction();
                        assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                    });
                });
            });

            describe(@"in portrait orientation", ^{
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight andOrientation:UIInterfaceOrientationPortrait andDelegate:mockDelegate] autorelease];

                    [view deactivate];
                });

                describe(@"the text view", ^{
                    it(@"should be hidden", ^{
                        assertThatFloat(view.textView.alpha, equalToFloat(0));
                    });
                });

                describe(@"the unfocused text label", ^{
                    it(@"should be hidden", ^{
                        assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                    });
                });

                describe(@"the note icon view", ^{
                    describe(@"when the highlight has a note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"This highlight kicks butt.";
                            [view deactivate];
                        });

                        it(@"should be visible", ^{
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(1));
                        });
                    });

                    describe(@"when the highlight has no note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight andOrientation:UIInterfaceOrientationPortrait andDelegate:mockDelegate] autorelease];

                            [view deactivate];
                        });

                        it(@"should not be visible", ^{
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                        });
                    });
                });
            });
        });

        describe(@"willRotateToInterfaceOrientation:", ^{
            describe(@"from landscape to portrait", ^{
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                              andOrientation:UIInterfaceOrientationLandscapeLeft
                                                                 andDelegate:mockDelegate] autorelease];
                });

                describe(@"when activated", ^{
                    beforeEach(^{
                        [view activate];
                    });

                    describe(@"the text view", ^{
                        it(@"should be visible", ^{
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                            assertThatFloat(view.textView.alpha, equalToFloat(1));
                        });

                        it(@"should not resign first responder", ^{
                            id mockTextView = [OCMockObject partialMockForObject:view.textView];
                            [[[mockTextView stub] andDo:^(NSInvocation *invocation) { fail(@"should not be called"); }] resignFirstResponder];

                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                        });
                    });


                    describe(@"when the highlight has a note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"A note.";
                        });

                        describe(@"the note icon view", ^{
                            it(@"should not be visible", ^{
                                [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                                assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                            });
                        });
                    });

                    describe(@"when the highlight has no note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                        });

                        describe(@"the note icon view", ^{
                            it(@"should not be visible", ^{
                                [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                                assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                            });
                        });
                    });

                    describe(@"the unfocused text label", ^{
                        it(@"should be hidden", ^{
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                            assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                        });
                    });
                });

                describe(@"when deactivated", ^{
                    describe(@"the text view", ^{
                        it(@"should be hidden", ^{
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                            assertThatFloat(view.textView.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"when the highlight has a note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"A note.";
                        });

                        describe(@"the note icon view", ^{
                            it(@"should be visible", ^{
                                [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                                assertThatFloat(view.noteIconImageView.alpha, equalToFloat(1));
                            });
                        });
                    });

                    describe(@"when the highlight has no note", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                        });

                        describe(@"the note icon view", ^{
                            it(@"should not be visible", ^{
                                [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                                assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                            });
                        });
                    });

                    describe(@"the unfocused text label", ^{
                        it(@"should be hidden", ^{
                            [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                            assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                        });
                    });
                });
            });

            describe(@"from portrait to landscape", ^{
                __block void (^rotateAction)();
                beforeEach(^{
                    view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                              andOrientation:UIInterfaceOrientationPortrait
                                                                 andDelegate:mockDelegate] autorelease];
                    rotateAction = [^{
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    } copy];
                    [sharedExampleContext setObject:rotateAction forKey:@"executeAction"];
                });

                describe(@"when deactivated", ^{
                    describe(@"the text view", ^{
                        it(@"should should be hidden", ^{
                            rotateAction();
                            assertThatFloat(view.textView.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"the note icon view", ^{
                        it(@"should should be hidden", ^{
                            rotateAction();
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"when the note is non-empty", ^{
                        beforeEach(^{
                            highlight.notecardText = @"This is something clever.";
                        });

                        itShouldBehaveLike(@"an action that displays a non-blank note in an inactive highlight in landscape orientation");
                    });

                    describe(@"when the note is empty", ^{
                        beforeEach(^{
                            highlight.notecardText = @"";
                        });

                        describe(@"the unfocused text label", ^{
                            it(@"should not be visible", ^{
                                rotateAction();
                                assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                            });
                        });
                    });

                    describe(@"when the text was changed in portrait orientation", ^{
                        NSString *newText = @"some new text";

                        beforeEach(^{
                            highlight.notecardText = newText;
                        });

                        it(@"should display the new text in the unfocused text label", ^{
                            rotateAction();
                            assertThat(view.unfocusedTextLabel.text, equalTo(newText));
                        });
                    });
                });

                describe(@"when activated", ^{
                    beforeEach(^{
                        [view activate];
                        rotateAction();
                    });

                    describe(@"the note icon image view", ^{
                        it(@"should not be visible", ^{
                            assertThatFloat(view.noteIconImageView.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"the text view", ^{
                        it(@"should be visible", ^{
                            assertThatFloat(view.textView.alpha, equalToFloat(1));
                        });
                    });

                    describe(@"the unfocused text label", ^{
                        it(@"should not be visible", ^{
                            assertThatFloat(view.unfocusedTextLabel.alpha, equalToFloat(0));
                        });
                    });

                    describe(@"when the text was changed in portrait orientation", ^{
                        NSString *newText = @"some new text";

                        beforeEach(^{
                            highlight.notecardText = newText;
                        });

                        it(@"should display the new text in the text view", ^{
                            rotateAction();
                            assertThat(view.textView.text, equalTo(newText));
                        });
                    });
                });
            });
        });

        describe(@"hasVisibleCard", ^{
            __block UIInterfaceOrientation orientation;

            describe(@"in landscape mode", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationLandscapeLeft;
                });

                describe(@"when the highlight has a note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"I am a note.";
                    });

                    describe(@"when the highlight is focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view activate];
                        });

                        it(@"should return YES", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(YES));
                        });
                    });

                    describe(@"when the highlight is not focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view deactivate];
                        });

                        it(@"should return YES", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(YES));
                        });
                    });
                });

                describe(@"when the highlight does not have a note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"";
                    });

                    describe(@"when the highlight is focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view activate];
                        });

                        it(@"should return YES", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(YES));
                        });
                    });

                    describe(@"when the highlight is not focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view deactivate];
                        });

                        it(@"should return NO", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(NO));
                        });
                    });
                });
            });

            describe(@"in portrait mode", ^{
                beforeEach(^{
                    orientation = UIInterfaceOrientationPortrait;
                });

                describe(@"when the highlight has a note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"I am a note.";
                    });

                    describe(@"when the highlight is focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view activate];
                        });

                        it(@"should return YES", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(YES));
                        });
                    });

                    describe(@"when the highlight is not focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view deactivate];
                        });

                        it(@"should return NO", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(NO));
                        });
                    });
                });

                describe(@"when the highlight does not have a note", ^{
                    beforeEach(^{
                        highlight.notecardText = @"";
                    });

                    describe(@"when the highlight is focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view activate];
                        });

                        it(@"should return YES", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(YES));
                        });
                    });

                    describe(@"when the highlight is not focused", ^{
                        beforeEach(^{
                            view = [[[HighlightNotecardView alloc] initWithHighlight:highlight
                                                                      andOrientation:orientation
                                                                         andDelegate:mockDelegate] autorelease];
                            [view deactivate];
                        });

                        it(@"should return NO", ^{
                            assertThatBool([view hasVisibleCard], equalToBool(NO));
                        });
                    });
                });
            });
        });
    });

    describe(@"close", ^{
        it(@"should tell the text view to resign first responder", ^{
            id mockTextView = [OCMockObject partialMockForObject:view.textView];
            [[mockTextView expect] resignFirstResponder];

            [view close];

            [mockTextView verify];
        });
    });
});

SPEC_END
