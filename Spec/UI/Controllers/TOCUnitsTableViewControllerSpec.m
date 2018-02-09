#import "SpecHelper+Halo.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"
#import "TOCChaptersTableViewController.h"
#import "TOCUnitsTableViewController.h"
#import "TOCGlossaryTableViewController.h"
#import "ConceptViewController.h"

SPEC_BEGIN(TOCUnitsTableViewControllerSpec)

describe(@"TOCUnitsTableViewControllerSpec", ^{
    __block Book *book;
    __block TOCUnitsTableViewController *controller;
    __block id mockDelegate;
    __block UINavigationController *navigationController;

    beforeEach(^{
        mockDelegate = [OCMockObject niceMockForClass:[ConceptViewController class]];
        book = [[SpecHelper specHelper] createBook];
        controller = [[[TOCUnitsTableViewController alloc] initWithBook:book andUnit:[book.units objectAtIndex:1] andDelegate:mockDelegate] autorelease];

        // Force load of the view.
        assertThat(controller.view, notNilValue());

        // Force load of table data.
        assertThatInt([controller.tableView numberOfSections], isNot(equalToInt(0)));

        navigationController = [[[UINavigationController alloc] initWithRootViewController:controller] autorelease];
    });

    describe(@"navigation item title", ^{
        it(@"should show unit's title as the popover title", ^{
			Unit *unit = [book.units objectAtIndex:1];
            assertThat(controller.navigationItem.title, equalTo(unit.title));
        });
    });

    describe(@"displaying book", ^{
        //describe(@"units", ^{
//            it(@"should display the correct number of units as section headers", ^{
//                assertThatInt([controller.tableView numberOfSections], equalToInt([book.units count]));
//            });
//
//            it(@"should display the correct views for the unit headers", ^{
//                for (int i = 0; i < [book.units count]; ++i) {
//                    UIView *sectionView = [controller tableView:controller.tableView viewForHeaderInSection:i];
//                    UILabel *sectionTitle = [[sectionView subviews] objectAtIndex:0];
//                    assertThatBool([sectionTitle isKindOfClass:[UILabel class]], equalToBool(YES));
//                }
//            });
//
//            describe(@"section header title", ^{
//                __block Unit *unit;
//                __block UILabel *sectionTitle;
//
//                describe(@"for a unit with a number", ^{
//                    beforeEach(^{
//                        unit = [book.units objectAtIndex:1];
//                        assertThatInt([unit.number length], isNot(equalToInt(0)));
//
//                        UIView *sectionView = [controller tableView:controller.tableView viewForHeaderInSection:1];
//                        sectionTitle = [[sectionView subviews] objectAtIndex:0];
//                    });
//
//                    it(@"should be the unit number followed by the unit title", ^{
//                        assertThat(sectionTitle.text, equalTo([NSString stringWithFormat:@"Unit %@: %@", unit.number, unit.title]));
//                    });
//                });
//
//                describe(@"for a unit with an empty string for the number", ^{
//                    beforeEach(^{
//                        unit = [book.units objectAtIndex:0];
//                        assertThat(unit.number, equalTo(@""));
//
//                        UIView *sectionView = [controller tableView:controller.tableView viewForHeaderInSection:0];
//                        sectionTitle = [[sectionView subviews] objectAtIndex:0];
//                    });
//
//                    it(@"should be the unit title", ^{
//                        assertThat(sectionTitle.text, equalTo(unit.title));
//                    });
//                });
//
//                describe(@"for a unit without a number", ^{
//                    beforeEach(^{
//                        unit = [book.units objectAtIndex:2];
//                        assertThat(unit.number, nilValue());
//
//                        UIView *sectionView = [controller tableView:controller.tableView viewForHeaderInSection:2];
//                        sectionTitle = [[sectionView subviews] objectAtIndex:0];
//                    });
//
//                    it(@"should be the unit title", ^{
//                        assertThat(sectionTitle.text, equalTo(unit.title));
//                    });
//                });
//            });
//        });

        describe(@"chapters", ^{
            it(@"should display a row for each chapter in the unit, with the exception of the Appendices unit", ^{
				assertThatInt([controller.tableView numberOfRowsInSection:0],  equalToInt([[[book.units objectAtIndex:1] chapters] count]));
            });

            it(@"should display a view for each chapter", ^{
                for (int i = 0; i < [book.units count]; i++) {
                    for (int j = 0; j < [[[book.units objectAtIndex:i] chapters] count]; j++) {
                        UITableViewCell *chapterCell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:j inSection:i]];
                        assertThat(chapterCell, notNilValue());
                    }
                }
            });

            describe(@"Chapter cell text", ^{
                it(@"should be the chapter number followed by the Chapter title", ^{
                    unsigned int unitIndex = 1;
                    unsigned int chapterIndex = 2;

                    Chapter *chapter = [[[book.units objectAtIndex:unitIndex] chapters] objectAtIndex:chapterIndex];
                    UITableViewCell *chapterCell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:chapterIndex inSection:1]];
                    assertThat([(UILabel *)[chapterCell.contentView viewWithTag:1] text], equalTo(chapter.title));
                });
            });

            describe(@"when tapping on a Chapter", ^{
                __block NSIndexPath *tappedCellIndexPath;

                beforeEach(^{
                    tappedCellIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
                });

                it(@"should display the Chapter's Concepts in the popover", ^{
                    OCMockObject *mockNavigationController = [OCMockObject partialMockForObject:navigationController];
                    [[mockNavigationController expect] pushViewController:[OCMArg checkWithBlock:^(id arg) {
                        return [arg isKindOfClass:[TOCChaptersTableViewController class]];
                    }] animated:YES];

                    [controller tableView:controller.tableView didSelectRowAtIndexPath:tappedCellIndexPath];

                    [mockNavigationController verify];
                });

                it(@"should set the text of the back button to the name of the Chapter's unit", ^{
                    [controller tableView:controller.tableView didSelectRowAtIndexPath:tappedCellIndexPath];
                    Unit *unit = [book.units objectAtIndex:tappedCellIndexPath.section];

                    assertThat(controller.navigationItem.backBarButtonItem.title, equalTo(unit.title));
                });

                describe(@"and subsequently tapping on a Concept", ^{
                    it(@"should tell its delegate to save the index path to the initially tapped-upon Chapter", ^{
                        [[mockDelegate expect] setCurrentTOCIndexPath:tappedCellIndexPath];

                        // There's no way to programmatically set the selected table view cell from a spec, since
                        // it's asynchronous.  Sorry for the extra mocking.
                        id fakeTableView = [OCMockObject partialMockForObject:controller.tableView];
                        [[[fakeTableView stub] andReturn:tappedCellIndexPath] indexPathForSelectedRow];

                        [controller navigateToConcept:nil];

                        [mockDelegate verify];
                    });
                });
            });

//            describe(@"in the appendices unit", ^{
//                __block Unit *appendices;
//                __block NSIndexPath *glossaryIndexPath;
//
//                beforeEach(^{
//                    appendices = [book.units lastObject];
//
//                    NSUInteger unitCount = book.units.count;
//                    NSUInteger appendicesUnitChapterCount = [[[book.units lastObject] chapters] count];
//                    glossaryIndexPath = [NSIndexPath indexPathForRow:appendicesUnitChapterCount inSection:unitCount - 1];
//                });
//
//                it(@"should display one more than the number of appendix Concepts in the Appendices unit", ^{
//                    NSUInteger numberOfRowsForAppendicesSection = [controller.tableView numberOfRowsInSection:book.units.count - 1];
//                    NSUInteger numberOfChaptersForAppendicesUnit = [[book.units lastObject] chapters].count;
//                    assertThatInt(numberOfRowsForAppendicesSection, equalToInt(numberOfChaptersForAppendicesUnit + 1));
//                });

//                describe(@"the last row", ^{
//                    it(@"should be the glossary 'chapter'", ^{
//                        UITableViewCell *cell = [controller.tableView cellForRowAtIndexPath:glossaryIndexPath];
//                        assertThat([(UILabel *)[cell.contentView viewWithTag:1] text], equalTo(@"Glossary"));
//                    });
//
//                    describe(@"when tapped upon", ^{
//                        it(@"should display a TOC controller containing the glossary concepts", ^{
//                            OCMockObject *mockNavigationController = [OCMockObject partialMockForObject:navigationController];
//                            [[mockNavigationController expect] pushViewController:[OCMArg checkWithBlock:^(id arg) {
//                                return [arg isKindOfClass:[TOCGlossaryTableViewController class]];
//                            }] animated:YES];
//
//                            [controller tableView:controller.tableView didSelectRowAtIndexPath:glossaryIndexPath];
//
//                            [mockNavigationController verify];
//                        });
//                    });
//                });
//            });
        });
    });

    describe(@"TOCNavigationProtocol", ^{
        describe(@"navigateToConcept", ^{
            __block void (^executeAction)();
            __block Concept *concept;

            beforeEach(^{
                concept = [[[[[book.units objectAtIndex:1] chapters] objectAtIndex:2] concepts] objectAtIndex:1];

                executeAction = [[^{
                    [controller navigateToConcept:concept];
                } copy] autorelease];
            });

            it(@"should tell its delegate to load the passed-in concept", ^{
                [[mockDelegate expect] loadConcept:concept];

                executeAction();

                [mockDelegate verify];
            });

            it(@"should tell its delegate to close the popover", ^{
                [[mockDelegate expect] closePopover];

                executeAction();

                [mockDelegate verify];
            });

            it(@"should tell its delegate to store the indexPath for the previously tapped-upon chapter", ^{
                [[mockDelegate expect] setCurrentTOCIndexPath:[OCMArg any]];

                executeAction();

                [mockDelegate verify];
            });
        });
    });
});

SPEC_END
