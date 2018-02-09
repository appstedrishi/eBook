#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>

#import "HCEmptyContainer.h"
#import "Unit.h"
#import "Chapter.h"
#import "PCKXMLParser.h";

SPEC_BEGIN(UnitSpec)

describe(@"Unit", ^{
    NSString *unitXML =
    @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
    "<unit xmlns=\"http://www.w3.org/1999/xhtml\">"
    "<number>42</number>"
    "<title>Unit Forty-Two</title>"
    "<chapter>"
    "</chapter>"
    "<chapter>"
    "</chapter>"
    "</unit>";

    __block Unit *unit;

    beforeEach(^{
        unit = [[[Unit alloc] init] autorelease];
    });

    describe(@"chapters", ^{
        it(@"should initially be empty", ^{
            assertThat(unit.chapters, emptyContainer());
        });
    });

    describe(@"parsing from XML", ^{
        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:unit] autorelease];

            NSData *indexData = [unitXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];
        });

        it(@"should parse the unit attributes", ^{
            assertThat(unit.title, equalTo(@"Unit Forty-Two"));
            assertThat(unit.number, equalTo(@"42"));
        });

        it(@"should parse multiple chapters", ^{
            assertThatInt(unit.chapters.count, equalToInt(2));
        });
    });

    describe(@"persistence", ^{
        __block Unit *restoredUnit;

        beforeEach(^{
            PCKXMLParser *parser = [[[PCKXMLParser alloc] initWithDelegate:unit] autorelease];

            NSData *indexData = [unitXML dataUsingEncoding:NSUTF8StringEncoding];
            [parser parseChunk:indexData];
        });

        describe(@"with all attributes specified", ^{
            beforeEach(^{
                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [unit encodeWithCoder:archiver];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
                restoredUnit = [[[Unit alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            });

            it(@"should restore a Unit instance", ^{
                assertThat(restoredUnit, notNilValue());
            });

            it(@"should restore the number", ^{
                assertThat(restoredUnit.number, equalTo(unit.number));
            });

            it(@"should restore the title", ^{
                assertThat(restoredUnit.title, equalTo(unit.title));
            });

            it(@"should restore the chapters", ^{
                assertThatInt([restoredUnit.chapters count], equalToInt([unit.chapters count]));
            });
        });

        describe(@"with no number", ^{
            beforeEach(^{
                [unit setValue:nil forKey:@"number"];

                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [unit encodeWithCoder:archiver];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
                restoredUnit = [[[Unit alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            });

            it(@"should restore the number to nil", ^{
                assertThat(restoredUnit.number, nilValue());
            });
        });
    });
});

SPEC_END
