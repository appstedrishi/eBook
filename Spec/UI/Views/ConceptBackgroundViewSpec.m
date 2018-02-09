#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import "ConceptBackgroundView.h"
#import "ConceptViewController.h"

SPEC_BEGIN(ConceptBackgroundViewSpec)

describe(@"ConceptBackgroundView", ^{
    __block ConceptBackgroundView *view;
    __block id delegate;

    beforeEach(^{
        view = [[[ConceptBackgroundView alloc] initWithFrame:CGRectZero] autorelease];
        delegate = [OCMockObject mockForClass:[ConceptViewController class]];
        view.delegate = delegate;
    });

    describe(@"touchesEnded:withEvent:", ^{
        it(@"should notify the delegate", ^{
            [[delegate expect] didTapBackground];
            [view touchesEnded:nil withEvent:nil];
            [delegate verify];
        });
    });
});

SPEC_END
