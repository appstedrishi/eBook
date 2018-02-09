#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import "History.h"
#import "HistoryLocation.h"

@interface History (HistorySpecImpl)

@property (nonatomic, retain) NSMutableArray *backStack, *forwardStack;
@property (nonatomic, retain, readwrite) HistoryLocation *current;

@end

SPEC_BEGIN(HistorySpec)

describe(@"History", ^{
    __block History *history;

    beforeEach(^{
        history = [[History alloc] init];
    });

	afterEach(^{
	    [history release];
	});

    describe(@"on initialization", ^{
        it(@"should have no back history", ^{
            assertThatBool([history canGoBack], equalToBool(NO));
        });

        it(@"should have no forward history", ^{
            assertThatBool([history canGoForward], equalToBool(NO));
        });

        it(@"should have no current request", ^{
            assertThat([history current], nilValue());
        });
    });

    describe(@"push:", ^{
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/foo/bar"]];
        NSURLRequest *anotherRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/another/url"]];

        beforeEach(^{
            [history push:request];
        });

        describe(@"once", ^{
            it(@"should have no back history", ^{
                assertThatBool([history canGoBack], equalToBool(NO));
            });
        });

        describe(@"more than once", ^{
            beforeEach(^{
                [history push:anotherRequest];
            });

            it(@"should have back history", ^{
                assertThatBool([history canGoBack], equalToBool(YES));
            });
        });

        it(@"should have no forward history", ^{
            assertThatBool([history canGoForward], equalToBool(NO));
        });

        it(@"should return the pushed request as the current request", ^{
            assertThat([history current].request, equalTo(request));
        });

        it(@"should obliterate any forward history", ^{
            [history push:anotherRequest];
            [history goBack];
            assertThatBool([history canGoForward], equalToBool(YES));

            NSURLRequest *yetAnotherRequest = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/another/url"]] autorelease];
            [history push:yetAnotherRequest];
            assertThatBool([history canGoForward], equalToBool(NO));
        });

        it(@"should store a scrollOffset of 0", ^{
            assertThatFloat(history.current.scrollOffset, equalToFloat(0.0));
        });
    });

    describe(@"push:withScrollOffset:", ^{
        CGFloat scrollOffset = 473.1;

        beforeEach(^{
            NSURLRequest *request = [[[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/foo/bar"]] autorelease];
            [history push:request withScrollOffset:scrollOffset];
        });

        it(@"should store the scrollOffset", ^{
            assertThatFloat(history.current.scrollOffset, equalToFloat(scrollOffset));
        });
    });

    describe(@"goBack", ^{
        describe(@"with no back history", ^{
            it(@"should throw an exception", ^{
                @try {
                    [history goBack];
                } @catch (NSException *x) {
                    return;
                }
                fail(@"Expected exception not thrown");
            });
        });

        describe(@"with back history", ^{
            NSURLRequest *firstRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/first/request"]];
            NSURLRequest *secondRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/second/request"]];

            beforeEach(^{
                [history push:firstRequest];
                [history push:secondRequest];
                [history goBack];
            });

            it(@"should set the previous request in the back history as the current request", ^{
                assertThat([history current].request, equalTo(firstRequest));
            });

            it(@"should move the current request to the forward history", ^{
                assertThatBool([history canGoForward], equalToBool(YES));
            });

            describe(@"when the back history is full", ^{
                NSURLRequest *initialRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/initial/request"]];

                beforeEach(^{
                    [history.backStack removeAllObjects];

                    history.current = [HistoryLocation locationForRequest:initialRequest andScrollOffset:0];

                    for (int i = [history.backStack count]; i < MAX_HISTORY; i++) {
                        [history push:firstRequest];
                    }
                    assertThatInt([history.backStack count], equalToInt(MAX_HISTORY));
                });

                it(@"should push the request onto the back stack", ^{
                    [history push:secondRequest];

                    assertThatInt([history.backStack count], equalToInt(MAX_HISTORY));
                    assertThat(history.current.request, equalTo(secondRequest));
                });

                it(@"should remove the first request from the back stack", ^{
                    [history push:secondRequest];

                    assertThat([[history.backStack objectAtIndex:0] request], isNot(equalTo(initialRequest)));
                });
            });

        });
    });

    describe(@"goForward", ^{
        describe(@"with no forward history", ^{
            it(@"should throw an exception", ^{
                @try {
                    [history goForward];
                } @catch (NSException *x) {
                    return;
                }
                fail(@"Expected exception not thrown");
            });
        });

        describe(@"with forward history", ^{
            NSURLRequest *firstRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/first/request"]];
            NSURLRequest *secondRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/second/request"]];
            NSURLRequest *thirdRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/third/request"]];

            beforeEach(^{
                [history push:firstRequest];
                [history push:secondRequest];
                [history push:thirdRequest];
                [history goBack];
                [history goBack];
                [history goForward];
            });

            it(@"should set the next request in the forward history as the current request", ^{
                assertThat([history current].request, equalTo(secondRequest));
            });

            it(@"should move the current request to the back history", ^{
                [history goBack];
                assertThat([history current].request, equalTo(firstRequest));
            });
        });
    });

    describe(@"persistence", ^{
        __block History *restoredHistory;
        NSURLRequest *firstRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/first/request"]];
        NSURLRequest *secondRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/second/request"]];
        NSURLRequest *thirdRequest = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/third/request"]];
        CGFloat scrollOffset = 473.1;


        beforeEach(^{
            [history push:firstRequest];
            [history push:secondRequest withScrollOffset:scrollOffset];
            [history push:thirdRequest];
            [history goBack];
            [history goBack];
            [history goForward];

            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
            [history encodeWithCoder:archiver];
            [archiver finishEncoding];

            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            restoredHistory = [[[History alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];
        });

        it(@"should restore the same number of requests", ^{
            assertThatInt([restoredHistory.backStack count], equalToInt([history.backStack count]));
            assertThatInt([restoredHistory.forwardStack count], equalToInt([history.forwardStack count]));
        });

        it(@"should set the currentConcept to the second request in the history", ^{
            assertThat([restoredHistory current].request.URL.path, equalTo(secondRequest.URL.path));
        });

        it(@"should set the current scrollOffset to the second request in the history", ^{
            assertThatFloat([restoredHistory current].scrollOffset, equalToFloat(scrollOffset));
        });
    });
});

SPEC_END
