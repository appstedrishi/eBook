#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"

#import "HighlightToolbarView.h"
#import "Highlight.h"

SPEC_BEGIN(HighlightToolbarViewSpec)

describe(@"HighlightToolbarView", ^{
    __block HighlightToolbarView *view;
    __block UIView *superview;
    __block Highlight *highlight;

    beforeEach(^{
        superview = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
        highlight = [[[Highlight alloc] initWithIndex:@"0" xOffset:10 yOffset:7 height:10 text:@"wibble" section:@"wobble" rangeJSON:@""] autorelease];
        view = [[[HighlightToolbarView alloc] initWithSuperview:superview highlight:highlight orientation:UIInterfaceOrientationLandscapeLeft] autorelease];
    });

    describe(@"outlets", ^{
        describe(@"toolbarImageView", ^{
            it(@"should exist", ^{
                assertThat(view.toolbarImageView, notNilValue());
            });
        });
		
		describe(@"toolbarImageViewPortrait", ^{
            it(@"should exist", ^{
                assertThat(view.toolbarImageViewPortrait, notNilValue());
            });
        });
		
        describe(@"deleteButton", ^{
            it(@"should be defined", ^{
                assertThat(view.deleteButton, notNilValue());
            });

            it(@"should have didTapAskToDelete as the action for touch up inside", ^{
                assertThat([view.deleteButton actionsForTarget:view forControlEvent:UIControlEventTouchUpInside], hasItem(@"didTapAskToDelete"));
            });
        });

        describe(@"confirmDeleteButton", ^{
            it(@"should be defined", ^{
                assertThat(view.confirmDeleteButton, notNilValue());
            });

            it(@"should have didTapDelete as the action for touch up inside", ^{
                assertThat([view.confirmDeleteButton actionsForTarget:superview forControlEvent:UIControlEventTouchUpInside], hasItem(@"didTapDelete"));
            });
        });

        describe(@"cancelDeleteButton", ^{
            it(@"should be defined", ^{
                assertThat(view.cancelDeleteButton, notNilValue());
            });

            it(@"should have didTapCancel as the action for touch up inside", ^{
                assertThat([view.cancelDeleteButton actionsForTarget:view forControlEvent:UIControlEventTouchUpInside], hasItem(@"didTapCancel"));
            });
        });
		
        describe(@"deleteConfirmationView", ^{
            it(@"should be defined", ^{
                assertThat(view.deleteConfirmationView, notNilValue());
            });
			
            it(@"should not be visible", ^{
                assertThatFloat(view.deleteConfirmationView.alpha, equalToFloat(0));
            });
        });

        describe(@"questionsButton", ^{
            it(@"should be defined", ^{
                assertThat(view.questionsButton, notNilValue());
            });

            it(@"should have didTapQuestions as the action for touch up inside", ^{
                assertThat([view.questionsButton actionsForTarget:superview forControlEvent:UIControlEventTouchUpInside], hasItem(@"didTapQuestions"));
            });
        });
    });

    describe(@"initialization", ^{
        it(@"should not be visible", ^{
            assertThatFloat(view.alpha, equalToFloat(0));
        });
    });

    describe(@"on tapping ask-to-delete button", ^{
        beforeEach(^{
            [view.deleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should show confirm deleteConfirmationView", ^{
            assertThatFloat(view.deleteConfirmationView.alpha, equalToFloat(1));
        });
    });

    describe(@"on tapping cancel-delete button", ^{
        beforeEach(^{
            [view.deleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
            [view.cancelDeleteButton sendActionsForControlEvents:UIControlEventTouchUpInside];
        });

        it(@"should hide deleteConfirmationView", ^{
            assertThatFloat(view.deleteConfirmationView.alpha, equalToFloat(0));
        });
    });

    describe(@"HighlightViewComponent protocol", ^{
        describe(@"activate", ^{
            describe(@"in landscape orientation", ^{
                beforeEach(^{
                    view = [[[HighlightToolbarView alloc] initWithSuperview:superview highlight:highlight orientation:UIInterfaceOrientationLandscapeLeft] autorelease];
                    [view activate];
                });

                it(@"should be visible", ^{
                    assertThatFloat(view.alpha, equalToFloat(1));
                });
				
				it(@"should show the landscape toolbar and hide the portrait toolbar", ^{
					assertThatBool(view.toolbarImageView.hidden, equalToBool(NO));
					assertThatBool(view.toolbarImageViewPortrait.hidden, equalToBool(YES));
				});
            });

            describe(@"in portrait orientation", ^{
                beforeEach(^{
                    view = [[[HighlightToolbarView alloc] initWithSuperview:superview highlight:highlight orientation:UIInterfaceOrientationPortrait] autorelease];
                    [view activate];
                });

                it(@"should be visible", ^{
                    assertThatFloat(view.alpha, equalToFloat(1));
                });
				
				it(@"should hide the landscape toolbar and show the portrait toolbar", ^{
					assertThatBool(view.toolbarImageView.hidden, equalToBool(YES));
					assertThatBool(view.toolbarImageViewPortrait.hidden, equalToBool(NO));
				});
            });
        });

        describe(@"deactivate", ^{
            beforeEach(^{
                [view activate];
            });

            it(@"should not be visible", ^{
                assertThatFloat(view.alpha, equalToFloat(1));

                [view deactivate];

                assertThatFloat(view.alpha, equalToFloat(0));
            });

            it(@"should deselect the Questions button", ^{
                view.questionsButton.selected = YES;

                [view deactivate];

                assertThatBool(view.questionsButton.selected, equalToBool(NO));
            });
        });

        describe(@"willRotateToInterfaceOrientation:", ^{
            describe(@"from portrait to landscape", ^{
                beforeEach(^{
                    view = [[[HighlightToolbarView alloc] initWithSuperview:superview highlight:highlight orientation:UIInterfaceOrientationPortrait] autorelease];
                });

                describe(@"when active", ^{
                    beforeEach(^{
                        [view activate];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    });

                    it(@"should be visible", ^{
                        assertThatFloat(view.alpha, equalToFloat(1));
                    });
                });

                describe(@"when inactive", ^{
                    beforeEach(^{
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    });

                    it(@"should not be visible", ^{
                        assertThatFloat(view.alpha, equalToFloat(0));
                    });
                });
            });

            describe(@"from landscape to portrait", ^{
                beforeEach(^{
                    view = [[[HighlightToolbarView alloc] initWithSuperview:superview highlight:highlight orientation:UIInterfaceOrientationLandscapeRight] autorelease];
                });

                describe(@"when active", ^{
                    beforeEach(^{
                        [view activate];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                    });

                    it(@"should be visible", ^{
                        assertThatFloat(view.alpha, equalToFloat(1));
                    });
                });

                describe(@"when inactive", ^{
                    beforeEach(^{
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                    });

                    it(@"should not be visible", ^{
                        assertThatFloat(view.alpha, equalToFloat(0));
                    });
                });

            });
        });

        describe(@"hasVisibleCard", ^{
            it(@"should return NO", ^{
                assertThatBool([view hasVisibleCard], equalToBool(NO));
            });
        });
    });
});

SPEC_END
