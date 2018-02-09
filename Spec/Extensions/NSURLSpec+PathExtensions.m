#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "NSURL+PathExtensions.h"

SPEC_BEGIN(NSURLSpec_PathExtensions)

describe(@"NSURL+PathExtensions", ^{
    __block NSURL *url;

    describe(@"relativePathWithFragment", ^{
        describe(@"with a fragment on the original URL", ^{
            NSString *path = @"/foo/bar.html#fragment";

            beforeEach(^{
                url = [NSURL URLWithString:path];
            });

            it(@"should include the fragment", ^{
                assertThat([url relativePathWithFragment], equalTo(path));
            });
        });

        describe(@"without a fragment on the original URL", ^{
            NSString *path = @"/foo/no-fragment.html";

            beforeEach(^{
                url = [NSURL URLWithString:path];
            });

            it(@"should not include the hash", ^{
                NSUInteger expectedLocation = NSNotFound;
                assertThatInt([[url relativePathWithFragment] rangeOfString:@"#"].location, equalToInt(expectedLocation));
            });
        });
    });
});

SPEC_END
