#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "PivotalCoreKit.h"
#import "PivotalSpecHelperKit.h"

#import "HighlightPaintingView.h"
#import "HighlightPaintingViewDelegate.h"

SPEC_BEGIN(HighlightPaintingViewSpec)

describe(@"HighlightPaintingView", ^{
    __block HighlightPaintingView *view;
    __block id mockDelegate;

    beforeEach(^{
        mockDelegate = [OCMockObject mockForProtocol:@protocol(HighlightPaintingViewDelegate)];
        view = [[HighlightPaintingView alloc] initWithFrame:CGRectZero andDelegate:mockDelegate];
    });

    describe(@"touch events", ^{
        __block id fakeEvent;
        CGPoint point = CGPointMake(10, 20);

        beforeEach(^{
            id fakeTouch = [OCMockObject mockForClass:[UITouch class]];
            [[[fakeTouch stub] andDo:^(NSInvocation *invocation) {
                [invocation setReturnValue:(void *)&point];
            }] locationInView:view];

            NSSet *touches = [NSSet setWithObject:fakeTouch];

            fakeEvent = [OCMockObject mockForClass:[UIEvent class]];
            [[[fakeEvent stub] andReturn:touches] touchesForView:view];
        });

        describe(@"touchesBegan:withEvent", ^{
            it(@"should notify the delegate", ^{
                [[mockDelegate expect] didBeginHighlightStrokeAtPoint:point];
                [view touchesBegan:[NSSet set] withEvent:fakeEvent];
                [mockDelegate verify];
            });
        });

        describe(@"touchesEnded:withEvent:", ^{
            it(@"should notify the delegate", ^{
                [[mockDelegate expect] didEndHighlightStrokeAtPoint:point];
                [view touchesEnded:[NSSet set] withEvent:fakeEvent];
                [mockDelegate verify];
            });
        });
    });
});

SPEC_END
