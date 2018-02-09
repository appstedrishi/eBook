#import "SpecHelper+Halo.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"
#import "HCEmptyContainer.h"

#import "TOCGlossaryTableViewController.h"
#import "Book.h"
#import "TOCNavigationDelegate.h"

SPEC_BEGIN(TOCGlossaryTableViewControllerSpec)

describe(@"TOCGlossaryTableViewController", ^{
    __block Book *book;
    __block TOCGlossaryTableViewController *controller;
    __block id mockDelegate;

    beforeEach(^{
        book = [[SpecHelper specHelper] createBook];
        mockDelegate = [OCMockObject mockForProtocol:@protocol(TOCNavigationDelegate)];
        controller = [[[TOCGlossaryTableViewController alloc] initWithBook:book andDelegate:mockDelegate] autorelease];
        assertThat(controller.view, notNilValue());

        assertThatInt([controller.tableView numberOfSections], isNot(equalToInt(0)));
    });

    describe(@"display", ^{
        it(@"should show 'Glossary' in the navigation bar title", ^{
            assertThat(controller.navigationItem.title, equalTo(@"Glossary"));
        });

        it(@"should contain a section for each letter of the alphabet, plus numbers and search", ^{
            assertThatInt([controller.tableView numberOfSections], equalToInt(28));
        });

        it(@"should display a section header for each section", ^{
            assertThat([controller tableView:controller.tableView titleForHeaderInSection:0], nilValue());
            assertThat([controller tableView:controller.tableView titleForHeaderInSection:1], equalTo(@"#"));
            for (unsigned int i = 1; i <= 26; ++i) {
                char c = i + 'A' - 1;
                char sz[2]; sz[0] = c; sz[1] = 0;

                assertThat([controller tableView:controller.tableView titleForHeaderInSection:i+1], equalTo([NSString stringWithCString:sz encoding:NSUTF8StringEncoding]));
            }
        });

        it(@"should contain a row for each glossary Concept, alphabatized by section", ^{
            assertThatInt([controller.tableView numberOfRowsInSection:1], equalToInt(1)); // One glossary Concept starting with a number
            assertThatInt([controller.tableView numberOfRowsInSection:2], equalToInt(2)); // Two glossary Concepts starting with 'A'
            assertThatInt([controller.tableView numberOfRowsInSection:3], equalToInt(1)); // One glossary Concept starting with 'B'
            assertThatInt([controller.tableView numberOfRowsInSection:4], equalToInt(0)); // Zero glossary Concepts starting with 'C'
            assertThatInt([controller.tableView numberOfRowsInSection:24], equalToInt(1)); // One glossary Concept starting with 'W'
            assertThatInt([controller.tableView numberOfRowsInSection:27], equalToInt(0)); // Zero glossary Concepts starting with 'Z'
        });

        it(@"should populate each section with rows for Concepts in that section", ^{
            unsigned int indexOfFirstAConcept = [book indexOfFirstGlossaryConceptStartingWithLetter:@"A"];
            unsigned int numberOfRowsInASection = [book indexOfFirstGlossaryConceptStartingWithLetter:@"B"] - [book indexOfFirstGlossaryConceptStartingWithLetter:@"A"];

            for (int i = 0; i < numberOfRowsInASection; ++i) {
                UITableViewCell *cell = [controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:2]];
                assertThat(cell.textLabel.text, equalTo([[book.glossaryConcepts objectAtIndex:i + indexOfFirstAConcept] title]));
            }
        });

        it(@"should display the concept title in each row", ^{
            for (int i = 0; i < [book indexOfFirstGlossaryConceptStartingWithLetter:@"A"]; ++i) {
                UITableViewCell *cell = [controller.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:1]];
                assertThat(cell.textLabel.text, equalTo([[book.glossaryConcepts objectAtIndex:i] title]));
            }
        });

        it(@"should have an alphabetical search bar", ^{
            NSArray *titles = [controller sectionIndexTitlesForTableView:controller.tableView];
            assertThat(titles, isNot(emptyContainer()));
        });
		
		it(@"should show a search bar", ^{
			assertThat(controller.searchDisplayController.searchBar, notNilValue());
		});
    });

    describe(@"navigation", ^{
        it(@"should navigate to the selected glossary concept", ^{
            // First 'A' glossary Concept
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:2];

            [[mockDelegate expect] navigateToConcept:[book.glossaryConcepts objectAtIndex:1]];

            [controller tableView:controller.tableView didSelectRowAtIndexPath:indexPath];

            [mockDelegate verify];
        });
    });
});

SPEC_END
