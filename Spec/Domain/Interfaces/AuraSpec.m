#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import <PivotalSpecHelperKit/PivotalSpecHelperKit.h>
#import "Aura.h"
#import "Concept.h"

SPEC_BEGIN(AuraSpec)

describe(@"Aura", ^{
    __block Aura *aura;
    __block id delegate;
    NSString *expectedHost = @"www.example.com";
    int expectedPort = 7046;
    NSInteger notFound = NSNotFound;
    NSMutableDictionary *sharedExampleContext = [SpecHelper specHelper].sharedExampleContext;

    beforeEach(^{
        aura = [[Aura alloc] init];
        delegate = [OCMockObject mockForProtocol:@protocol(PCKHTTPConnectionDelegate)];

        [[NSUserDefaults standardUserDefaults] setObject:expectedHost forKey:@"host_preference"];
        [[NSUserDefaults standardUserDefaults] setInteger:expectedPort forKey:@"port_preference"];
    });

    afterEach(^{
        [aura release];
    });

    sharedExamplesFor(@"an action that creates a POST request", ^(NSDictionary *context){
        __block NSURLConnection *connection;

        beforeEach(^{
            connection = [context objectForKey:@"connection"];
        });

        it(@"should create one request", ^{
            assertThatInt([[NSURLConnection connections] count], equalToInt(1));
        });

        it(@"should connect to the host and port specified by the user in the preferences", ^{
            assertThat(connection.request.URL.host, equalTo(expectedHost));
            assertThatInt(connection.request.URL.port.intValue, equalToInt(expectedPort));
        });

        it(@"should create a post request", ^{
            assertThat(connection.request.HTTPMethod, equalTo(@"POST"));
        });

        it(@"should escape characters in the parameters that are not valid characters in a URL", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];

            NSInteger notFound = NSNotFound;
            assertThatInt([parameters rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:@" ?()"]].location, equalToInt(notFound));
        });
    });

    describe(@"answerQuestion:withDelegate:", ^{
        __block NSURLConnection *connection;
        NSString *question = @"What are the parts of a smurf? (male and female)";

        beforeEach(^{
            connection = [aura answerQuestion:question withDelegate:delegate];
            [sharedExampleContext setObject:connection forKey:@"connection"];
        });

        itShouldBehaveLike(@"an action that creates a POST request");

        it(@"should include the question in the HTTP body as a POST parameter", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
            assertThat(parameters, equalTo([NSString stringWithFormat:@"question=%@", [question stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]]));
        });
    });

    describe(@"createStructuredQuestionsListForKeywords:andText:withDelegate", ^{
        __block NSURLConnection *connection;
        NSString *keywords = @"weebles wobble but they don't fall down (?)";
        NSString *text = @"What's up?";

        beforeEach(^{
            connection = [aura createStructuredQuestionsListsForKeywords:keywords andText:text withDelegate:delegate];
            [sharedExampleContext setObject:connection forKey:@"connection"];
        });

        itShouldBehaveLike(@"an action that creates a POST request");

        it(@"should include the keywords in the HTTP body as a POST parameter", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
            NSString *expectedKeywords = [NSString stringWithFormat:@"question=%@", [keywords stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThatInt([parameters rangeOfString:expectedKeywords].location, isNot(equalToInt(notFound)));
        });

        it(@"should include the specified text in the HTTP body as a POST parameter", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
            NSString *expectedText = [NSString stringWithFormat:@"concept=%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThatInt([parameters rangeOfString:expectedText].location, isNot(equalToInt(notFound)));
        });
    });

    describe(@"createStructuredQuestionsListForSection:andText:withDelegate:", ^{
        __block NSURLConnection *connection;
        NSString *section = @"section0-0";
        NSString *text = @"Bacteria have a single type of RNA polymerase (that synthesizes not only mRNA but also other types of RNA that function in protein synthesis)?";

        beforeEach(^{
            connection = [aura createSuggestedQuestionsListsForSection:section andText:text withDelegate:delegate];
            [sharedExampleContext setObject:connection forKey:@"connection"];
        });

        itShouldBehaveLike(@"an action that creates a POST request");

        it(@"should include the section in the HTTP body as a POST parameter", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
            NSString *expectedSection = [NSString stringWithFormat:@"section=%@", [section stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThatInt([parameters rangeOfString:expectedSection].location, isNot(equalToInt(notFound)));
        });

        it(@"should include the highlighted text in the HTTP body as a POST parameter", ^{
            NSData *body = connection.request.HTTPBody;
            NSString *parameters = [[[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding] autorelease];
            NSString *expectedText = [NSString stringWithFormat:@"text=%@", [text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding includeAll:YES]];
            assertThatInt([parameters rangeOfString:expectedText].location, isNot(equalToInt(notFound)));
        });
    });
});

SPEC_END
