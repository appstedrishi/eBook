#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "PivotalCoreKit.h"
#import "HCEmptyContainer.h"
#import "Chapter.h"
#import "Concept.h"

SPEC_BEGIN(ChapterSpec)

describe(@"Chapter", ^{
    __block Chapter *chapter;
    NSString *chapterXML =
    @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    "<chapter xmlns=\"http://www.w3.org/1999/xhtml\">"
    "<number>664</number>"
    "<title>The Neighbor of the Beast</title>"
    "<overview></overview>"
    "<concept></concept>"
    "<concept></concept>"
    "<review></review>"
    "<chapter>";

    beforeEach(^{
        chapter = [[[Chapter alloc] init] autorelease];
    });

    describe(@"concepts", ^{
        it(@"should initially be empty", ^{
            assertThat(chapter.concepts, emptyContainer());
        });
    });

    describe(@"parsing from XML", ^{
        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:chapter] autorelease];

            NSData *indexData = [chapterXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];
        });

        it(@"should parse attributes for the chapter", ^{
            assertThat(chapter.title, equalTo(@"The Neighbor of the Beast"));
            assertThat(chapter.number, equalTo(@"664"));
        });

        it(@"should parse the concepts for the chapter, including overview and review elements", ^{
            assertThatInt(chapter.concepts.count, equalToInt(4));
        });
    });

    describe(@"persistence", ^{
        __block Chapter *restoredChapter;

        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:chapter] autorelease];

            NSData *indexData = [chapterXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];

            NSMutableData *data = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
            [chapter encodeWithCoder:archiver];
            [archiver finishEncoding];

            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            restoredChapter = [[[Chapter alloc] initWithCoder:unarchiver] autorelease];
            [unarchiver finishDecoding];
        });

        it(@"should restore a Chapter instance", ^{
            assertThat(restoredChapter, notNilValue());
        });

        it(@"should restore the number", ^{
            assertThat(restoredChapter.number, equalTo(chapter.number));
        });

        it(@"should restore the title", ^{
            assertThat(restoredChapter.title, equalTo(chapter.title));
        });

        it(@"should restore the concepts", ^{
            assertThatInt([restoredChapter.concepts count], equalToInt([chapter.concepts count]));
        });
    });

});

SPEC_END
