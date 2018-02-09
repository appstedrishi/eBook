#import "SpecHelper+Halo.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import "TOCChaptersTableViewController.h"
#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"
#import "TOCNavigationDelegate.h"

SPEC_BEGIN(TOCChaptersTableViewControllerSpec)

describe(@"TOCChaptersTableViewController", ^{
    __block TOCChaptersTableViewController *controller;
    __block id mockDelegate;
    __block Unit *unit;
    __block Chapter *chapter;

    beforeEach(^{
        mockDelegate = [OCMockObject mockForProtocol:@protocol(TOCNavigationDelegate)];
        Book *book = [[SpecHelper specHelper] createBook];
        unit = [book.units objectAtIndex:1];
        chapter = [unit.chapters objectAtIndex:1];
        controller = [[[TOCChaptersTableViewController alloc] initWithDelegate:mockDelegate
                                                                       andUnit:(Unit *)unit
                                                                    andChapter:(Chapter *)chapter] autorelease];
    });

    describe(@"display", ^{
        it(@"should show the chapter number in popover title", ^{
            assertThat(controller.navigationItem.title, equalTo([NSString stringWithFormat:@"Chapter %@", chapter.number]));
        });

        it(@"should contain one section", ^{
            assertThatInt([controller.tableView numberOfSections], equalToInt(1));
        });

        it(@"should not display a section header", ^{
            assertThatBool([controller respondsToSelector:@selector(tableView:viewForHeaderInSection:)], equalToBool(NO));
        });

        it(@"should contain one row for each concept in the chapter", ^{
            assertThatInt([controller.tableView numberOfRowsInSection:0], equalToInt([chapter.concepts count]));
        });

        it(@"should display the concept title in each row but the first", ^{
            for (int i = 1; i < [chapter.concepts count]; ++i) {
                UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                UIView *contentView = cell.contentView;

                UILabel *conceptTitleView = [[contentView subviews] objectAtIndex:1];

                assertThat(conceptTitleView.text, equalTo([[chapter.concepts objectAtIndex:i] title]));
            }
        });
		
        it(@"should display the chapter title in the first row", ^{
			UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
			UIView *contentView = cell.contentView;
			
			UILabel *conceptTitleView = [[contentView subviews] objectAtIndex:1];
			
			assertThat(conceptTitleView.text, equalTo(chapter.title));
        });

        describe(@"concept number label", ^{
            __block Concept *concept;
            __block UILabel *conceptLabel;

            describe(@"for a concept with a number", ^{
                beforeEach(^{
                    concept = [chapter.concepts objectAtIndex:1];
                    assertThatInt(concept.number.length, isNot(equalToInt(0)));

                    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
                    conceptLabel = [cell.contentView.subviews objectAtIndex:0];
                });

                it(@"should display <chapter number>.<concept number>", ^{
                    assertThat(conceptLabel.text, equalTo([NSString stringWithFormat:@"%@.%@", chapter.number, concept.number]));
                });
            });

            describe(@"for a concept with an empty string for the number", ^{
                beforeEach(^{
                    concept = [chapter.concepts objectAtIndex:0];
                    assertThatInt(concept.number.length, equalToInt(0));

                    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
                    conceptLabel = [cell.contentView.subviews objectAtIndex:0];
                });

                it(@"should display nothing", ^{
                    assertThat(conceptLabel.text, equalTo(@""));
                });
            });

            describe(@"for a concept with no number", ^{
                beforeEach(^{
                    concept = [chapter.concepts objectAtIndex:2];
                    assertThat(concept.number, nilValue());

                    UITableViewCell *cell = [controller tableView:controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
                    conceptLabel = [cell.contentView.subviews objectAtIndex:0];
                });

                it(@"should display nothing", ^{
                    assertThat(conceptLabel.text, equalTo(@""));
                });
            });
        });
    });

    describe(@"navigation", ^{
        it(@"should navigate to the selected chapter concept", ^{
            [[mockDelegate expect] navigateToConcept:[chapter.concepts objectAtIndex:1]];

            [controller tableView:controller.tableView didSelectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];

            [mockDelegate verify];
        });
    });
});

SPEC_END
