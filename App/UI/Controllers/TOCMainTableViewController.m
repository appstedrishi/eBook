#import "TOCChaptersTableViewController.h"
#import "TOCUnitsTableViewController.h"
#import "TOCGlossaryTableViewController.h"
#import "TOCMainTableViewController.h"
#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"
#import "ConceptViewController.h"

@interface TOCMainTableViewController ()

@property (nonatomic, weak) ConceptViewController *delegate;

- (NSString *)sectionTitleForUnit:(Unit *)unit;
- (BOOL)isGlossaryIndexPath:(NSIndexPath *)indexPath;
@end

@implementation TOCMainTableViewController

@synthesize book = book_;
@synthesize delegate = delegate_;

- (id)initWithBook:(Book *)book andDelegate:(ConceptViewController *)delegate {
    if (self = [super initWithStyle:UITableViewStyleGrouped]) {
        self.book = book;
        self.delegate = delegate;
        self.navigationItem.title = @"Contents";
    }
    return self;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 572);
}

- (void)navigateListToConcept:(Concept *)concept {
    UIViewController *childController;
    if ([self.book conceptIsInGlossary:concept]) {
        childController = [[TOCGlossaryTableViewController alloc] initWithBook:self.book term:concept andDelegate:self];
    } else {
        Chapter *chapter = [self.book getChapterForConcept:concept];
        if (!chapter) {
            NSLog(@"Uh, why does this book concept have no chapter?");
            return;
        }
        childController = [[TOCChaptersTableViewController alloc] initWithDelegate:self andUnit:nil andChapter:chapter];
    }
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.navigationItem.title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];
    [self.navigationController popToRootViewControllerAnimated:NO];
    [self.navigationController pushViewController:childController animated:NO];
}

//- (void)setPopover:(UIPopoverController *)popover {
//	popover_ = popover;
//	self.popover.popoverContentSize = CGSizeMake(320, 572+37);
//}

- (void)dealloc {
	//self.popover = nil;
    self.delegate = nil;
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.separatorColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:0.666];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.tableView.backgroundColor = [UIColor clearColor];
}

- (void)viewDidAppear:(BOOL)animated {
//	self.contentSizeForViewInPopover = CGSizeMake(320, 572);
	// archit  self.popover.popoverContentSize = CGSizeMake(320, 572+37);
}

- (void)viewWillAppear:(BOOL)animated {
//    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *childController = nil;

    if ([self isGlossaryIndexPath:indexPath]) {
        childController = [[TOCGlossaryTableViewController alloc] initWithBook:self.book andDelegate:self];
    } else {
		if (indexPath.section == 0) {
			Unit *unit = [self.book.units objectAtIndex:indexPath.row];
			childController = [[TOCUnitsTableViewController alloc] initWithBook:self.book andUnit:unit andDelegate:self];
		}
    }

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.navigationItem.title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];

    [self.navigationController pushViewController:childController animated:YES];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section) {
		return 1;
	} else {
		return self.book.units.count;
	}
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TOC-Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont boldSystemFontOfSize:15.0];
        cell.textLabel.textColor = [UIColor whiteColor];
       // cell.textLabel.adjustsFontSizeToFitWidth = YES;
        //cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        cell.textLabel.numberOfLines=2;
        cell.detailTextLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.highlightedTextColor = [UIColor darkGrayColor];
        cell.detailTextLabel.highlightedTextColor = [UIColor darkGrayColor];
       // cell.backgroundColor = [UIColor colorWithWhite:0 alpha:0.1];
    // cell.backgroundView = [UIView new];
    }
	if ([self isGlossaryIndexPath:indexPath]) {
		cell.textLabel.text = @"Glossary";
		cell.detailTextLabel.text = nil;
	} else {
		Unit *unit = [self.book.units objectAtIndex:indexPath.row];
        NSLog(@"%@",[self sectionTitleForUnit:unit]);
       // cell.textLabel.text = [self sectionTitleForUnit:unit];
     [cell.textLabel setText:[self sectionTitleForUnit:unit]];
        NSString *firstChapter = [[unit.chapters objectAtIndex:0] number];
		NSString *lastChapter = [[unit.chapters lastObject] number];
		if (lastChapter && lastChapter.length > 0) {
			if (firstChapter != lastChapter && firstChapter && firstChapter.length > 0) {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"Chapters %@ – %@", firstChapter, lastChapter];
			} else {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"Chapter %@", lastChapter];
			}
		} else {
			if (firstChapter && firstChapter.length > 0) {
				cell.detailTextLabel.text = [NSString stringWithFormat:@"Chapter %@", firstChapter];
			} else {
				cell.detailTextLabel.text = nil;
			}
		}
	}
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableNextSelected.png"]];
    cell.accessoryView = disclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 52;
}

#pragma mark TOCNavigationDelegate
- (void)navigateToConcept:(Concept *)concept {
    if (self.book.currentConcept == concept) {
        [self.delegate dismissNavigationView];
    } else {
        [self.delegate loadConceptFromTOC:concept];
    }
   [self.delegate closePopover];
}

- (BOOL)conceptIsCurrentConcept:(Concept *)concept {
    return self.book.currentConcept == concept;
}

#pragma mark Private methods
- (NSString *)sectionTitleForUnit:(Unit *)unit {
//    if (unit.number.length) {
//        return [NSString stringWithFormat:@"Unit %@: %@", unit.number, unit.title];
//    } else {
        return [NSString stringWithFormat:@"%@", unit.title];
//    }
}
- (BOOL)isGlossaryIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == [self numberOfSectionsInTableView:self.tableView]-1 && indexPath.row == 0;
}

@end
