#import <Cedar/SpecHelper.h>
#define HC_SHORTHAND
#import <OCHamcrest/OCHamcrest.h>
#import <OCMock/OCMock.h>
#import <PivotalSpecHelperKit/PivotalSpecHelperKit.h>

#import "HCEmptyContainer.h"
#import "HCThrowsException.h"
#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"

SPEC_BEGIN(BookSpec)

describe(@"Book", ^{
    __block Book *book;

    typedef id (^ConceptFinder)();
    __block ConceptFinder firstConcept;
    __block ConceptFinder lastConcept;
    __block ConceptFinder someConcept;
    __block ConceptFinder conceptAfterSomeConcept;
    __block ConceptFinder conceptBeforeSomeConcept;

    beforeEach(^{
        NSData *indexData = [NSData dataWithContentsOfFile:[[PSHKFixtures directory] stringByAppendingPathComponent:@"bookIndex.xml"]];
        NSData *glossaryIndexData = [NSData dataWithContentsOfFile:[[PSHKFixtures directory] stringByAppendingPathComponent:@"glossaryIndex.xml"]];

        book = [[[Book alloc] initWithIndexData:indexData andGlossaryIndexData:glossaryIndexData] autorelease];

        firstConcept = [[^{ return [[[[[book.units objectAtIndex:0] chapters] objectAtIndex:0] concepts] objectAtIndex:0]; } copy] autorelease];

        // TODO: Fix this when the appendix has concepts.
        lastConcept = [[^{ return [[[[[book.units objectAtIndex:book.units.count - 2] chapters] lastObject] concepts] lastObject]; } copy] autorelease];
        someConcept = [[^{ return [[[[[book.units objectAtIndex:1] chapters] objectAtIndex:2] concepts] objectAtIndex:1]; } copy] autorelease];
        conceptAfterSomeConcept = [[^{ return [[[[[book.units objectAtIndex:1] chapters] objectAtIndex:2] concepts] objectAtIndex:2]; } copy] autorelease];
        conceptBeforeSomeConcept = [[^{ return [[[[[book.units objectAtIndex:1] chapters] objectAtIndex:2] concepts] objectAtIndex:0]; } copy] autorelease];
    });

    describe(@"initialConcept", ^{
        describe(@"when the current concept has been set", ^{
            __block Concept *concept;

            beforeEach(^{
                concept = someConcept();
                [book setCurrentConcept:concept];
            });

            it(@"should return the current concept", ^{
                assertThat(book.initialConcept, equalTo(concept));
            });
        });
    });

    describe(@"currentConcept", ^{
        it(@"should return the most recently set value", ^{
            assertThat(book.currentConcept, nilValue());

            Concept *concept = someConcept();
            book.currentConcept = concept;
            assertThat(book.currentConcept, equalTo(concept));
        });
    });

    sharedExamplesFor(@"concept navigation and lookup", ^(NSDictionary *context) {
        describe(@"hasNextConcept", ^{
            describe(@"for the first concept", ^{
                beforeEach(^{
                    book.currentConcept = firstConcept();
                });

                it(@"should return YES", ^{
                    assertThatBool([book hasNextConcept], equalToBool(YES));
                });
            });

            describe(@"for the last concept", ^{
                beforeEach(^{
                    book.currentConcept = lastConcept();
                });

                it(@"should return NO", ^{
                    assertThatBool([book hasNextConcept], equalToBool(NO));
                });
            });

            describe(@"for a middle concept", ^{
                beforeEach(^{
                    book.currentConcept = someConcept();
                });

                it(@"should return YES", ^{
                    assertThatBool([book hasNextConcept], equalToBool(YES));
                });
            });
        });

        describe(@"hasPreviousConcept", ^{
            describe(@"for the first concept", ^{
                beforeEach(^{
                    book.currentConcept = firstConcept();
                });

                it(@"should return NO", ^{
                    assertThatBool([book hasPreviousConcept], equalToBool(NO));
                });
            });

            describe(@"for the last concept", ^{
                beforeEach(^{
                    book.currentConcept = lastConcept();
                });

                it(@"should return YES", ^{
                    assertThatBool([book hasPreviousConcept], equalToBool(YES));
                });
            });

            describe(@"for a middle concept", ^{
                beforeEach(^{
                    book.currentConcept = someConcept();
                });

                it(@"should return YES", ^{
                    assertThatBool([book hasPreviousConcept], equalToBool(YES));
                });
            });
        });

        describe(@"nextConcept", ^{
            describe(@"when current concept is not set", ^{
                beforeEach(^{
                    assertThat(book.currentConcept, nilValue());
                });

                it(@"should raise an exception", ^{
                    assertThat(^{ [book nextConcept]; }, throwsException([NSException class]));
                });
            });

            describe(@"when the current concept is set", ^{
                describe(@"to something other than the last concept", ^{
                    beforeEach(^{
                        book.currentConcept = someConcept();
                        assertThatBool([book hasNextConcept], equalToBool(YES));
                    });

                    it(@"should return the next concept", ^{
                        assertThat([book nextConcept], equalTo(conceptAfterSomeConcept()));
                    });
                });

                describe(@"to the last concept", ^{
                    beforeEach(^{
                        book.currentConcept = lastConcept();
                        assertThatBool([book hasNextConcept], equalToBool(NO));
                    });

                    it(@"should raise an exception", ^{
                        assertThat(^{ [book nextConcept]; }, throwsException([NSException class]));
                    });
                });
            });
        });

        describe(@"previousConcept", ^{
            describe(@"when current concept is not set", ^{
                beforeEach(^{
                    assertThat(book.currentConcept, nilValue());
                });

                it(@"should raise an exception", ^{
                    assertThat(^{ [book previousConcept]; }, throwsException([NSException class]));
                });
            });

            describe(@"when the current concept is set", ^{
                describe(@"to something other than the first concept", ^{
                    beforeEach(^{
                        book.currentConcept = someConcept();
                        assertThatBool([book hasPreviousConcept], equalToBool(YES));
                    });

                    it(@"should return the previous concept", ^{
                        assertThat([book previousConcept], equalTo(conceptBeforeSomeConcept()));
                    });
                });

                describe(@"to the first concept", ^{
                    beforeEach(^{
                        book.currentConcept = firstConcept();
                        assertThatBool([book hasPreviousConcept], equalToBool(NO));
                    });

                    it(@"should raise an exception", ^{
                        assertThat(^{ [book previousConcept]; }, throwsException([NSException class]));
                    });
                });
            });
        });

        describe(@"conceptForPath", ^{
            describe(@"with a path for which there is a concept", ^{
                it(@"should return the concept for that path", ^{
                    Concept *concept = someConcept();

                    assertThat([book conceptForPath:concept.path], equalTo(concept));
                });
            });

            describe(@"with a path for which there is no concept", ^{
                it(@"should return nil", ^{
                    assertThat([book conceptForPath:@"/not/a/valid/path"], nilValue());
                });
            });
        });
    });

    describe(@"for standard concepts", ^{
        itShouldBehaveLike(@"concept navigation and lookup");

        describe(@"currentConceptIsInGlossary", ^{
           it(@"should return NO", ^{
               book.currentConcept = someConcept();
               assertThatBool([book currentConceptIsInGlossary], equalToBool(NO));
           });
        });
    });

    describe(@"for glossary concepts", ^{
        beforeEach(^{
            firstConcept = [[^{ return [[book glossaryConcepts] objectAtIndex:0]; } copy] autorelease];
            lastConcept = [[^{ return [[book glossaryConcepts] lastObject]; } copy] autorelease];
            someConcept = [[^{ return [[book glossaryConcepts] objectAtIndex:3]; } copy] autorelease];
            conceptAfterSomeConcept = [[^{ return [[book glossaryConcepts] objectAtIndex:4]; } copy] autorelease];
            conceptBeforeSomeConcept = [[^{ return [[book glossaryConcepts] objectAtIndex:2]; } copy] autorelease];
        });

        itShouldBehaveLike(@"concept navigation and lookup");

        describe(@"currentConceptIsInGlossary", ^{
            it(@"should return YES", ^{
                book.currentConcept = someConcept();
                assertThatBool([book currentConceptIsInGlossary], equalToBool(YES));
            });
        });
    });

    describe(@"persistence", ^{
        __block Book *restoredBook;

        describe(@"when the current Concept is a non-glossary Concept", ^{
            beforeEach(^{
                book.currentConcept = book.initialConcept;
                book.currentConcept = [book nextConcept];

                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [book encodeWithCoder:archiver];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
                restoredBook = [[[Book alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            });

            it(@"should restore a book instance", ^{
                assertThat(restoredBook, notNilValue());
            });

            it(@"should persist the units", ^{
                assertThatInt([restoredBook.units count], equalToInt([book.units count]));
            });

            it(@"should restore the initial concept", ^{
                assertThat(restoredBook.initialConcept.path, equalTo(book.initialConcept.path));
            });

            it(@"should restore the glossary concepts", ^{
                assertThatInt([restoredBook.glossaryConcepts count], equalToInt([book.glossaryConcepts count]));
            });

            it(@"should re-index all concepts", ^{
                // The indexing is used for moving to next and previous concepts from the current concept.
                // Try doing that to make sure the index has been restored.
                restoredBook.currentConcept = restoredBook.initialConcept;
                assertThatBool([restoredBook hasNextConcept], equalToBool(YES));
                assertThat([restoredBook nextConcept], notNilValue());
            });
        });

        describe(@"when the current Concept is a glossary Concept", ^{
            beforeEach(^{
                book.currentConcept = [book.glossaryConcepts objectAtIndex:0];
                book.currentConcept = [book nextConcept];

                NSMutableData *data = [NSMutableData data];
                NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
                [book encodeWithCoder:archiver];
                [archiver finishEncoding];

                NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
                restoredBook = [[[Book alloc] initWithCoder:unarchiver] autorelease];
                [unarchiver finishDecoding];
            });

            it(@"should restore the initial concept", ^{
                assertThat(restoredBook.initialConcept.path, equalTo(book.initialConcept.path));
            });
        });
    });

    describe(@"parsing from XML", ^{
        it(@"should parse a unit element", ^{
            NSString *xml =
                @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
                "<book xmlns=\"http://www.w3.org/1999/xhtml\">"
                    "<unit>"
                        "<number>42</number>"
                        "<title>Unit Forty-Two</title>"
                    "</unit>"
                "</book>";

            NSData *indexData = [xml dataUsingEncoding:NSUTF8StringEncoding];

            book = [[[Book alloc] initWithIndexData:indexData andGlossaryIndexData:[NSData data]] autorelease];

            assertThatInt(book.units.count, equalToInt(1));
        });

        it(@"should parse multiple unit elements", ^{
            NSString *xml =
            @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<book xmlns=\"http://www.w3.org/1999/xhtml\">"
                "<unit>"
                "</unit>"
                "<unit>"
                "</unit>"
            "</book>";

            NSData *indexData = [xml dataUsingEncoding:NSUTF8StringEncoding];

            book = [[[Book alloc] initWithIndexData:indexData andGlossaryIndexData:[NSData data]] autorelease];

            assertThatInt(book.units.count, equalToInt(2));
        });

        it(@"should index the parsed book's concepts", ^{
            // The indexing is used for moving to next and previous concepts from the current concept.
            // Try doing that to make sure the index has been restored.
            book.currentConcept = book.initialConcept;
            assertThatBool([book hasNextConcept], equalToBool(YES));
            assertThat([book nextConcept], notNilValue());
        });

        it(@"should set the first concept as the initial concept", ^{
            assertThat(book.initialConcept, equalTo(firstConcept()));
        });

        it(@"should parse the glossary concepts", ^{
            NSString *xml =
            @"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"
            "<glossary>"
            "<concept>"
            "<path>path1</path>"
            "</concept>"
            "<concept>"
            "<path>path2</path>"
            "</concept>"
            "</glossary>";

            NSData *glossaryIndexData = [xml dataUsingEncoding:NSUTF8StringEncoding];

            Book *book = [[[Book alloc] initWithIndexData:[[[NSData alloc] init] autorelease] andGlossaryIndexData:glossaryIndexData] autorelease];

            assertThatInt(book.glossaryConcepts.count, equalToInt(2));
        });
    });

    describe(@"indexOfFirstGlossaryConceptStartingWithLetter:", ^{
        describe(@"for a letter that some glossary Concept starts with", ^{
            it(@"should do pretty much what you'd expect", ^{
                assertThatInt([book indexOfFirstGlossaryConceptStartingWithLetter:@"A"], equalToInt(1));
                assertThatInt([book indexOfFirstGlossaryConceptStartingWithLetter:@"B"], equalToInt(3));
            });
        });

        describe(@"for a letter that no glossary Concept starts with", ^{
            it(@"should return NSNotFound", ^{
                assertThatInt([book indexOfFirstGlossaryConceptStartingWithLetter:@"&"], equalToInt((int)NSNotFound));
            });
        });
    });
});

SPEC_END
