#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import <objc/runtime.h>
#import "NonConceptResourceViewController.h"
#import "PivotalSpecHelperKit.h"

SPEC_BEGIN(NonConceptResourceViewControllerSpec)

describe(@"NonConceptResourceViewController", ^{
    __block NonConceptResourceViewController *controller;
    __block NSURLRequest *request;

    beforeEach(^{
        NSURL *url = [NSURL URLWithString:@"a-url"];
        request = [NSURLRequest requestWithURL:url];
        controller = [[[NonConceptResourceViewController alloc] initWithRequest:request] autorelease];

        assertThat(controller.view, notNilValue());
    });

    describe(@"outlets", ^{
        it(@"should have a web view", ^{
            assertThat(controller.webView, notNilValue());
        });

        describe(@"closeButton", ^{
            it(@"should be defined", ^{
                assertThat(controller.closeButton, notNilValue());
            });

            it(@"should have the controller as its target", ^{
                assertThat(controller.closeButton.target, equalTo(controller));
            });

            it(@"should have a defined action", ^{
                assertThatBool(sel_isEqual(controller.closeButton.action, @selector(close:)), equalToBool(YES));
            });
        });
    });

    describe(@"viewDidLoad", ^{
        it(@"should load the specified request into the web view", ^{
            assertThatBool(controller.webView.loading, equalToBool(YES));
            assertThat(controller.webView.request, equalTo(request));
        });
    });

    describe(@"close:", ^{
        it(@"should close the modal view controller", ^{
            id mockController = [OCMockObject partialMockForObject:controller];
            [[mockController expect] dismissModalViewControllerAnimated:YES];

            [controller close:controller];

            [mockController verify];
        });
    });
});

SPEC_END
