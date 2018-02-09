#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import "Question.h"

SPEC_BEGIN(QuestionSpec)

describe(@"Question", ^{
    __block Question *question;

    beforeEach(^{
        question = [[Question alloc] init];
    });

	afterEach(^{
	    [question release];
	});

    describe(@"on initialization", ^{
        it(@"should set text to empty string", ^{
            assertThat(question.text, equalTo(@""));
        });

        it(@"should set feedback to empty string", ^{
            assertThat(question.feedback, equalTo(@""));
        });
    });

    describe(@"clear", ^{
        beforeEach(^{
            [question clear];
        });

        it(@"should set text to empty string", ^{
            assertThat(question.text, equalTo(@""));
        });

        it(@"should set feedback to empty string", ^{
            assertThat(question.feedback, equalTo(@""));
        });
    });
});

SPEC_END
