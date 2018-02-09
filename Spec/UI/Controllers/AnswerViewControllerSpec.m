#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "UIWebView+Spec.h"
#import "HTMLContentVerifier.h"
#import "AnswerViewDelegate.h"

#import <objc/runtime.h>

#import "AnswerViewController.h"

SPEC_BEGIN(AnswerViewControllerSpec)

describe(@"AnswerViewController", ^{
    __block AnswerViewController *controller;
    __block NSMutableString *html = [NSMutableString stringWithString:@"<div class=\"wibble\">Forty two\nand then some</div>"];
    __block id mockDelegate;

    beforeEach(^{
        mockDelegate = [OCMockObject niceMockForProtocol:@protocol(AnswerViewDelegate)];
        controller = [[AnswerViewController alloc] initWithHTML:html andDelegate:mockDelegate];
    });

    describe(@"initialization", ^{
        it(@"should have a web view", ^{
            assertThat(controller.webView, notNilValue());
        });
    });

    describe(@"viewDidLoad:", ^{
        describe(@"close button", ^{
            __block UIBarButtonItem *closeButton;

            beforeEach(^{
                id toolbar = controller.navigationItem.rightBarButtonItem.customView;
                closeButton = [[toolbar items] objectAtIndex:1];
            });

            it(@"should exist", ^{
                assertThat(closeButton, notNilValue());
            });

            it(@"should reside as the last item in a toolbar as the rightBarButtonItem in the navigation bar", ^{
                assertThat(closeButton.title, equalTo(@"Done"));
            });
        });
    });

    describe(@"the web view", ^{
        __block HTMLContentVerifier *verifier;

        it(@"should display the boilerplate HTML", ^{
            verifier = [[[HTMLContentVerifier alloc] initWithExpectedHTML:@"javascript/answers.js\"></script>"] autorelease];
            assertThatBool([verifier documentContainsExpectedHTML:controller.webView.loadedHTMLString], equalToBool(YES));
        });

        it(@"should contain the answer html", ^{
            verifier = [[[HTMLContentVerifier alloc] initWithExpectedHTML:html] autorelease];
            assertThatBool([verifier documentContainsExpectedHTML:controller.webView.loadedHTMLString], equalToBool(YES));
        });
    });

    describe(@"on tapping the Close button", ^{
        __block UIBarButtonItem *closeButton;

        beforeEach(^{
            id toolbar = controller.navigationItem.rightBarButtonItem.customView;
            closeButton = [[toolbar items] objectAtIndex:1];
        });

        it(@"should tell the delegate to close the modal view", ^{
            [[mockDelegate expect] dismissModalQuestionAnswerView];
            objc_msgSend(closeButton.target, closeButton.action);

            [mockDelegate verify];
        });
    });

    describe(@"on tapping the New Question button", ^{
        __block UIBarButtonItem *newQuestionButton;

        beforeEach(^{
            id toolbar = controller.navigationItem.rightBarButtonItem.customView;
            newQuestionButton = [[toolbar items] objectAtIndex:0];
        });

        it(@"should tell the delegate to make a new question", ^{
            [[mockDelegate expect] newQuestion];
            objc_msgSend(newQuestionButton.target, newQuestionButton.action);

            [mockDelegate verify];
        });

        it(@"should pop the controller off the navigation stack", ^{
            id mockNavigationController = [OCMockObject mockForClass:[UINavigationController class]];

            id stubController = [OCMockObject partialMockForObject:controller];
            [[[stubController stub] andReturn:mockNavigationController] navigationController];
            [[mockNavigationController expect] popViewControllerAnimated:YES];

            objc_msgSend(newQuestionButton.target, newQuestionButton.action);

            [mockNavigationController verify];
        });
    });

    describe(@"on tapping a link to another page", ^{
        it(@"should tell the delegate to load the page and dismiss question answer mode", ^{
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"file://path/to/some/concept"]];

            [[mockDelegate expect] dismissModalQuestionAnswerViewAndLoadRequest:request];

            [controller webView:controller.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeLinkClicked];

            [mockDelegate verify];
        });
    });
});

SPEC_END
