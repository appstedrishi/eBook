#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "Concept.h"
#import "HCEmptyContainer.h"
#import "Highlight.h"
#import "HCThrowsException.h"
#import "PivotalCoreKit.h"

SPEC_BEGIN(ConceptSpec)

describe(@"Concept", ^{
    __block Concept *concept;
    NSString *conceptXML =
    @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    "<concept xmlns=\"http://www.w3.org/1999/xhtml\">"
    "<number>123</number>"
    "<title>Your ABCs</title>"
    "<path>chapter123/chapter123-wibble.html</path>"
    "<concept>";

    beforeEach(^{
        concept = [[[Concept alloc] init] autorelease];
    });

    describe(@"highlights", ^{
        it(@"should initially be empty", ^{
            assertThat(concept.highlights, emptyContainer());
        });
    });

    describe(@"insertHighlight:beforeHighlightWithIndex:", ^{
        __block Highlight *highlight;

        beforeEach(^{
            highlight = [[[Highlight alloc] initWithIndex:@"7" xOffset:12 yOffset:43 height:25 text:@"some text" section:@"section" rangeJSON:@"{}"] autorelease];
        });

        describe(@"with highlight index equal to -1", ^{
            it(@"should insert the new highlight at the end of the list of highlights", ^{
                [concept insertHighlight:highlight beforeHighlightWithIndex:@"-1"];
                assertThat([concept.highlights lastObject], equalTo(highlight));
            });
        });

        describe(@"with highlight index equal to the index of a highlight in the current list of highlights", ^{
            __block Highlight *firstHighlight, *lastHighlight;
            NSString *firstHighlightIndex = @"5";
            NSString *lastHighlightIndex = @"2";

            beforeEach(^{
                firstHighlight = [[[Highlight alloc] initWithIndex:firstHighlightIndex xOffset:12 yOffset:43 height:25 text:@"some text" section:@"section" rangeJSON:@"{}"] autorelease];
                [concept insertHighlight:firstHighlight beforeHighlightWithIndex:@"-1"];

                lastHighlight = [[[Highlight alloc] initWithIndex:lastHighlightIndex xOffset:12 yOffset:43 height:25 text:@"some text" section:@"section" rangeJSON:@"{}"] autorelease];
                [concept insertHighlight:lastHighlight beforeHighlightWithIndex:@"-1"];
            });

            it(@"should insert the new highlight immediately before the highlight with the specified index", ^{
                [concept insertHighlight:highlight beforeHighlightWithIndex:lastHighlightIndex];
                assertThat([concept.highlights objectAtIndex:1], equalTo(highlight));
                assertThat([concept.highlights objectAtIndex:2], equalTo(lastHighlight));
            });
        });

        describe(@"with highlight index equal to an index of no highlight in the current list of highlights", ^{
            it(@"should throw an exception", ^{
                assertThat(^{
                    [concept insertHighlight:highlight beforeHighlightWithIndex:@"anything"];
                }, throwsException([NSException class]));
            });
        });
    });

    describe(@"removeHighlight:", ^{
        __block Highlight *highlight;

        beforeEach(^{
            highlight = [[[Highlight alloc] initWithIndex:@"7" xOffset:12 yOffset:43 height:25 text:@"some text" section:@"section" rangeJSON:@"{}"] autorelease];
        });

        describe(@"when the specified highlight is in the collection of highlights", ^{
            beforeEach(^{
                [concept insertHighlight:highlight beforeHighlightWithIndex:@"-1"];
                assertThat(concept.highlights, hasItem(highlight));
            });

            it(@"should remove the highlight from the list of highlights", ^{
                [concept removeHighlight:highlight];
                assertThat(concept.highlights, isNot(hasItem(highlight)));
            });
        });

        describe(@"when the specified highlight is not in the collection of highlights", ^{
            beforeEach(^{
                assertThat(concept.highlights, isNot(hasItem(highlight)));
            });

            it(@"should not modify the collection, and not explode", ^{
                size_t highlightCount = [concept.highlights count];

                [concept removeHighlight:highlight];
                assertThatInt([concept.highlights count], equalToInt(highlightCount));
            });
        });
    });

    describe(@"parsing from XML", ^{
        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:concept] autorelease];

            NSData *indexData = [conceptXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];
        });

        it(@"should parse attributes for the concept", ^{
            assertThat(concept.title, equalTo(@"Your ABCs"));
            assertThat(concept.number, equalTo(@"123"));
            assertThatBool([concept.path hasSuffix:@"chapter123/chapter123-wibble.html"], equalToBool(YES));
        });

        it(@"should concatenate the book path and the XML path to get the concept path", ^{
            NSString *fullPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:[@"Book" stringByAppendingPathComponent:@"chapter123/chapter123-wibble.html"]];
            assertThat(concept.path, equalTo(fullPath));
        });
    });

    describe(@"persistence", ^{
        __block Concept *restoredConcept;

        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:concept] autorelease];

            NSData *indexData = [conceptXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];

            for (unsigned int i = 0; i < 2; ++i) {
                Highlight *highlight = [[[Highlight alloc] initWithIndex:@"index" xOffset:12 yOffset:43 height:25 text:@"text" section:@"section" rangeJSON:@"{}"] autorelease];
                [concept insertHighlight:highlight beforeHighlightWithIndex:@"-1"];
            }

            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
            [concept encodeWithCoder:archiver];
            [archiver finishEncoding];

            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            restoredConcept = [[[Concept alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];
        });

        it(@"should restore a Concept instance", ^{
            assertThat(restoredConcept, notNilValue());
        });

        it(@"should restore the number", ^{
            assertThat(restoredConcept.number, equalTo(concept.number));
        });

        it(@"should restore the title", ^{
            assertThat(restoredConcept.title, equalTo(concept.title));
        });

        it(@"should restore the path", ^{
            assertThat(restoredConcept.path, equalTo(concept.path));
        });

        it(@"should restore the highlights", ^{
            assertThatInt([restoredConcept.highlights count], equalToInt([concept.highlights count]));
        });
    });
});

SPEC_END
