#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "HistoryLocation.h"

SPEC_BEGIN(HistoryLocationSpec)

describe(@"HistoryLocation", ^{
    __block HistoryLocation *historyLocation;
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"/foo/bar"]];
    CGFloat scrollOffset = 123.45;

    beforeEach(^{
        historyLocation = [HistoryLocation locationForRequest:(NSURLRequest *)request andScrollOffset:(CGFloat)scrollOffset];
    });

    describe(@"persistence", ^{
        __block HistoryLocation *restoredHistoryLocation;

        beforeEach(^{
            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];

            [historyLocation encodeWithCoder:archiver];
            [archiver finishEncoding];

            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            restoredHistoryLocation = [[[HistoryLocation alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];
        });

        it(@"should restore the stored request", ^{
            assertThat(restoredHistoryLocation.request.URL.path, equalTo(request.URL.path));
        });

        it(@"should restore the stored scroll offset", ^{
            assertThatFloat(restoredHistoryLocation.scrollOffset, equalToFloat(scrollOffset));
        });
    });
});

SPEC_END
