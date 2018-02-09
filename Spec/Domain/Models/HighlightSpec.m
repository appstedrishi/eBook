#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "HCEmptyContainer.h"
#import "PivotalCoreKit.h"
#import <PivotalSpecHelperKit/PivotalSpecHelperKit.h>
#import "Highlight.h"
#import "Question.h"

SPEC_BEGIN(HighlightSpec)

__block NSString *highlightText = @"The highlights of a cell are...";
__block NSString *highlightSection = @"section0-0";
__block NSString *highlightXOffset = @"12.1";
__block NSString *highlightYOffset = @"42.1";

sharedExamplesFor(@"a object that fetches suggested questions", ^(NSDictionary *context) {
    describe(@"fetchSuggestedQuestionsListWithDelegate:", ^{
        __block Highlight *highlight;
        __block NSURLConnection *connection;
        __block id fetchDelegate;

        beforeEach(^{
            highlight = [context objectForKey:@"highlight"];

            fetchDelegate = [OCMockObject mockForProtocol:@protocol(PCKHTTPConnectionDelegate)];
            [highlight fetchSuggestedQuestionsListWithDelegate:fetchDelegate];
            connection = [[NSURLConnection connections] lastObject];
        });

        it(@"should initiate a request to the suggested_questions_lists API", ^{
            assertThat([[[connection request] URL] path], equalTo(@"/suggested_questions_lists"));
        });

        it(@"should pass the section and highlighted text to the server", ^{
            NSString *escapedSection = [highlightSection stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];
            NSString *escapedText = [highlightText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES];

            NSString *expectedBody = [NSString stringWithFormat:@"section=%@&text=%@", escapedSection, escapedText];
            assertThat([[[NSString alloc] initWithData:[connection request].HTTPBody encoding:NSUTF8StringEncoding] autorelease], equalTo(expectedBody));
        });

        describe(@"on success", ^{
            __block NSAutoreleasePool *pool;
            __block Question *previousQuestion;

            beforeEach(^{
                previousQuestion = [[[Question alloc] init] autorelease];
                previousQuestion.text = @"Something I already asked, thank you very much.";
                [(id)highlight.suggestedQuestionsList addObject:previousQuestion];

                pool = [[NSAutoreleasePool alloc] init];

                [[fetchDelegate expect] connection:connection didReceiveResponse:[OCMArg any]];
                [[fetchDelegate expect] connectionDidFinishLoading:connection];

                PSHKFakeHTTPURLResponse *response = [[PSHKFakeResponses responsesForRequest:@"fetchSuggestedQuestionsListWithDelegate"] success];
                [connection receiveResponse:response];
            });

            afterEach(^{
                [pool drain];
            });

            it(@"should update the suggested questions", ^{
                assertThat(highlight.suggestedQuestionsList, isNot(emptyContainer()));
            });

            it(@"should clear out any previously loaded suggested questions", ^{
                assertThat(highlight.suggestedQuestionsList, isNot(hasItem(previousQuestion)));
            });

            it(@"should report success to the delegate", ^{
                [fetchDelegate verify];
            });

            describe(@"on subsequent cancelPendingRequest", ^{
                it(@"should not explode", ^{
                    [pool drain]; pool = nil;
                    [highlight cancelPendingRequest];
                });
            });
        });
    });
});

describe(@"Highlight", ^{
    __block Highlight *highlight;
    __block NSString *highlightIndex = @"8";
    __block NSString *highlightHeight = @"15.2";
    __block NSString *highlightRangeJSON = @"{range-json}";

    beforeEach(^{
        highlight = [[Highlight highlightWithIndex:highlightIndex
                                           xOffset:[highlightXOffset floatValue]
                                           yOffset:[highlightYOffset floatValue]
                                            height:[highlightHeight floatValue]
                                              text:highlightText
                                           section:highlightSection
                                         rangeJSON:highlightRangeJSON]
                     retain];
        [[SpecHelper specHelper].sharedExampleContext setObject:highlight forKey:@"highlight"];
    });

	afterEach(^{
	    [highlight release];
	});

    itShouldBehaveLike(@"a object that fetches suggested questions");

    describe(@"+highlightWithID:xOffset:yOffset:height:text:section:", ^{
        it(@"should have an ID", ^{
            assertThat(highlight.index, equalTo(highlightIndex));
        });

        it(@"should have a yOffset", ^{
            assertThatFloat(highlight.yOffset, equalToFloat([highlightYOffset floatValue]));
        });
		
        it(@"should have an xOffset", ^{
            assertThatFloat(highlight.xOffset, equalToFloat([highlightXOffset floatValue]));
        });
		
        it(@"should have a height", ^{
            assertThatFloat(highlight.height, equalToFloat([highlightHeight floatValue]));
        });

        it(@"should have an empty notecard text", ^{
            assertThat(highlight.notecardText, equalTo(@""));
        });

        it(@"should have a suggested questions collection", ^{
            assertThat(highlight.suggestedQuestionsList, notNilValue());
        });
    });

    describe(@"persistence", ^{
        __block Highlight *restoredHighlight;

        beforeEach(^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];

            highlight.notecardText = @"this is a test";

            [highlight encodeWithCoder:archiver];
            [archiver finishEncoding];

            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            restoredHighlight = [[[Highlight alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];

            [[SpecHelper specHelper].sharedExampleContext setObject:restoredHighlight forKey:@"highlight"];
        });

        itShouldBehaveLike(@"a object that fetches suggested questions");

        it(@"should restore a Highlight instance", ^{
            assertThat(restoredHighlight, notNilValue());
        });

        it(@"should restore the highlighted text", ^{
            assertThat(restoredHighlight.text, equalTo(highlight.text));
        });
		
        it(@"should restore the xOffset", ^{
            assertThatFloat(restoredHighlight.xOffset, equalToFloat(highlight.xOffset));
        });

        it(@"should restore the yOffset", ^{
            assertThatFloat(restoredHighlight.yOffset, equalToFloat(highlight.yOffset));
        });

        it(@"should restore the height", ^{
            assertThatFloat(restoredHighlight.height, equalToFloat(highlight.height));
        });

        it(@"should restore the rangeJSON", ^{
            assertThat(restoredHighlight.rangeJSON, equalTo(highlight.rangeJSON));
        });

        it(@"should restore the notecard text", ^{
            assertThat(restoredHighlight.notecardText, equalTo(highlight.notecardText));
        });

        it(@"should restore a valid suggested questions list", ^{
            assertThat(restoredHighlight.suggestedQuestionsList, notNilValue());
        });

        it(@"should restore the section text", ^{
            assertThat(restoredHighlight.section, equalTo(highlight.section));
        });
    });

    describe(@"setNotecardText:", ^{
        it(@"should strip leading and trailing whitespace", ^{
            NSString *expectedText = @"some text";
            highlight.notecardText = @"\n\t\r   some text    ";
            assertThat(highlight.notecardText, equalTo(expectedText));
        });
    });

    describe(@"KVO", ^{
        it(@"should report when the notecardText changes", ^{
            id mockObserver = [OCMockObject niceMockForClass:[NSObject class]];
            [[mockObserver expect] observeValueForKeyPath:@"notecardText" ofObject:highlight change:[OCMArg any] context:NULL];

            [highlight addObserver:mockObserver forKeyPath:@"notecardText" options:0 context:NULL];
            highlight.notecardText = @"I am Jack's new text";
            [highlight removeObserver:mockObserver forKeyPath:@"notecardText"];

            [mockObserver verify];
        });
    });
});

SPEC_END
