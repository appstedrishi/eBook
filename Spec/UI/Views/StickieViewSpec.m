#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "HCEmptyContainer.h"

#import <objc/runtime.h>
#import "StickieView.h"
#import "RepeatingBackgroundImageView.h"
#import "HighlightView.h"

SPEC_BEGIN(StickieViewSpec)

describe(@"StickieView", ^{
    __block id superview;
    __block StickieView *view;

    beforeEach(^{
        superview = [[HighlightView alloc] initWithFrame:CGRectZero];
        view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationPortrait highlightHeight:0 showDropShadow:YES] autorelease];
    });

    describe(@"outlets", ^{
        describe(@"Flag button", ^{
            it(@"should be defined", ^{
                assertThat(view.flagButton, notNilValue());
            });

            it(@"should target the didTapStickie method", ^{
                assertThat([view.flagButton actionsForTarget:superview forControlEvent:UIControlEventTouchUpInside], hasItem(@"didTapStickie"));
            });
        });

        describe(@"flagImageWithDropShadow", ^{
            it(@"should be defined", ^{
                assertThat(view.flagImageWithDropShadow, notNilValue());
            });
        });

        describe(@"flagImageWithoutDropShadow", ^{
            it(@"should be defined", ^{
                assertThat(view.flagImageWithoutDropShadow, notNilValue());
            });
        });

        describe(@"portrait mode flag", ^{
            it(@"should be defined", ^{
                assertThat(view.portraitModeFlag, notNilValue());
            });
        });

        describe(@"stickie portrait mode margin view", ^{
            it(@"should be defined", ^{
                assertThat(view.marginView, notNilValue());
            });
        });

    });

    describe(@"initWithSuperview:orientation:highlightHeight:showDropShadow:", ^{
        describe(@"in landscape orientation", ^{
            describe(@"when told to show its drop shadow", ^{
                beforeEach(^{
                    view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationLandscapeLeft highlightHeight:0 showDropShadow:YES] autorelease];
                });

                it(@"should display its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(1));
                });

                it(@"should use the drop shadow image", ^{
                    assertThat(view.flagButton.imageView.image, equalTo(view.flagImageWithDropShadow));
                });
            });

            describe(@"when told to not show its drop shadow", ^{
                beforeEach(^{
                    view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationLandscapeLeft highlightHeight:0 showDropShadow:NO] autorelease];
                });

                it(@"should display its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(1));
                });

                it(@"should use the no drop shadow image", ^{
                    assertThat(view.flagButton.imageView.image, equalTo(view.flagImageWithoutDropShadow));
                });
            });
        });

        describe(@"in portrait orientation", ^{
            beforeEach(^{
                view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationPortrait highlightHeight:0 showDropShadow:YES] autorelease];
            });

            it(@"should not display its flag", ^{
                assertThatFloat(view.flagButton.alpha, equalToFloat(0));
            });
        });

        describe(@"the stickie portrait mode margin view", ^{
            describe(@"when the highlight is only on one line", ^{
                it(@"should have a height of 0px", ^{
                    assertThatFloat(view.marginView.frame.size.height, equalToFloat(0));
                });
            });

            describe(@"when the highlight is on more than one line", ^{
                __block CGFloat highlightHeight = 72.0;

                beforeEach(^{
                    view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationPortrait highlightHeight:highlightHeight showDropShadow:YES] autorelease];
                });

                it(@"should have a height equal to the height of the highlight minus the height of the stickie portrait mode flag", ^{
                    assertThatFloat(view.marginView.frame.size.height, equalToFloat(highlightHeight - view.portraitModeFlag.frame.size.height));
                });
            });
        });
    });

    describe(@"HighlightViewComponent protocol", ^{
        describe(@"willRotateToInterfaceOrientation:", ^{
            describe(@"when inactive", ^{
                describe(@"from landscape to portrait", ^{
                    beforeEach(^{
                        view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationLandscapeLeft highlightHeight:0 showDropShadow:YES] autorelease];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
                    });

                    it(@"should hide its flag", ^{
                        assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                    });

                    it(@"should not show the portait mode flag", ^{
                        assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                    });
                });

                describe(@"from portrait to landscape", ^{
                    beforeEach(^{
                        view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationPortrait highlightHeight:0 showDropShadow:YES] autorelease];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    });

                    it(@"should show its flag", ^{
                        assertThatFloat(view.flagButton.alpha, equalToFloat(1));
                    });

                    it(@"should not show the portait mode flag", ^{
                        assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                    });
                });
            });

            describe(@"when active", ^{
                describe(@"from landscape to portrait", ^{
                    beforeEach(^{
                        view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationLandscapeLeft highlightHeight:0 showDropShadow:YES] autorelease];
                        [view activate];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortraitUpsideDown];
                    });

                    it(@"should not show its flag", ^{
                        assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                    });

                    it(@"should show the portait mode flag", ^{
                        assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(1));
                    });

                    it(@"should show the stickie portrait mode margin view", ^{
                        assertThatFloat(view.marginView.alpha, equalToFloat(1));

                    });
                });

                describe(@"from portrait to landscape", ^{
                    beforeEach(^{
                        view = [[[StickieView alloc] initWithSuperview:superview orientation:UIInterfaceOrientationPortrait highlightHeight:72.0 showDropShadow:YES] autorelease];
                        [view activate];
                        [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    });

                    it(@"should not show its flag", ^{
                        assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                    });

                    it(@"should not show the portait mode flag", ^{
                        assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                    });

                    it(@"should not show the stickie portait mode margin view", ^{
                        assertThatFloat(view.marginView.alpha, equalToFloat(0));
                    });
                });
            });
        });

        describe(@"activate", ^{
            describe(@"in landscape orientation", ^{
                beforeEach(^{
                    [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    [view activate];
                });

                it(@"should hide its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                });

                it(@"should not show the portait mode flag", ^{
                    assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                });

                it(@"should not show the stickie portrait mode margin view", ^{
                    assertThatFloat(view.marginView.alpha, equalToFloat(0));
                });

            });

            describe(@"in portrait orientation", ^{
                beforeEach(^{
                    [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                    [view activate];
                });

                it(@"should not show its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                });

                it(@"should show the portait mode flag", ^{
                    assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(1));
                });

                it(@"should show the stickie portrait mode margin view", ^{
                    assertThatFloat(view.marginView.alpha, equalToFloat(1));
                });

            });
        });

        describe(@"deactivate", ^{
            beforeEach(^{
                [view activate];
            });

            describe(@"in landscape orientation", ^{
                beforeEach(^{
                    [view willRotateToInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
                    [view deactivate];
                });

                it(@"should show its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(1));
                });

                it(@"should not show the portait mode flag", ^{
                    assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                });

                it(@"should not show the stickie portait mode margin view", ^{
                    assertThatFloat(view.marginView.alpha, equalToFloat(0));
                });
            });

            describe(@"in portrait orientation", ^{
                beforeEach(^{
                    [view willRotateToInterfaceOrientation:UIInterfaceOrientationPortrait];
                    [view deactivate];
                });

                it(@"should not show its flag", ^{
                    assertThatFloat(view.flagButton.alpha, equalToFloat(0));
                });

                it(@"should not show the portait mode flag", ^{
                    assertThatFloat(view.portraitModeFlag.alpha, equalToFloat(0));
                });

                it(@"should not show the stickie portait mode margin view", ^{
                    assertThatFloat(view.marginView.alpha, equalToFloat(0));
                });
            });

        });

        describe(@"hasVisibleCard", ^{
            it(@"should return NO", ^{
                assertThatBool([view hasVisibleCard], equalToBool(NO));
            });
        });
    });

    describe(@"setShowDropShadow:", ^{
        describe(@"when told to show its drop shadow", ^{
            beforeEach(^{
                view.showDropShadow = YES;
            });

            it(@"should use the drop shadow image", ^{
                assertThat(view.flagButton.imageView.image, equalTo(view.flagImageWithDropShadow));
            });
        });

        describe(@"when told to not show its drop shadow", ^{
            beforeEach(^{
                view.showDropShadow = NO;
            });

            it(@"should use the no drop shadow image", ^{
                assertThat(view.flagButton.imageView.image, equalTo(view.flagImageWithoutDropShadow));
            });
        });
    });
});

SPEC_END
