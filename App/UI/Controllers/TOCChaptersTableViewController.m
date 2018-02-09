#import "TOCChaptersTableViewController.h"
#import "Unit.h"
#import "Chapter.h"
#import "Concept.h"
#import "TOCNavigationDelegate.h"
#import "BookConceptTableViewCell.h"

//@interface TOCChaptersTableViewController ()

//- (NSString *)numberLabelForConcept:(Concept *)concept;
//- (float)labelHeightForConcept:(Concept *)concept;
//@end


@implementation TOCChaptersTableViewController

@synthesize delegate = delegate_, unit = unit_, chapter = chapter_;

#pragma mark Initialization

- (id)initWithDelegate:(id <TOCNavigationDelegate>)delegate andUnit:(Unit *)unit andChapter:(Chapter *)chapter {
    if (self = [super init]) {
        self.delegate = delegate;
        self.unit = unit;
        self.chapter = chapter;
		if (self.chapter.number) {
			self.navigationItem.title = [NSString stringWithFormat:@"Chapter %@", self.chapter.number];
		} else {
			self.navigationItem.title = chapter.title;
		}
    }
    return self;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 400);
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg"]];
    self.tableView.separatorColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // add footer and header to remove blank cells/dividers
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 0)];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
    [self.tableView setTableHeaderView:v];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.chapter.concepts count];
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
//    if ([self.delegate conceptIsCurrentConcept:[self.chapter.concepts objectAtIndex:indexPath.row]]) {
//        cell.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:0.333];
//        cell.textLabel.backgroundColor = [UIColor clearColor];
//    } else {
//        cell.backgroundColor = [UIColor clearColor];
//    }
//}

#define TITLELABEL_TAG 1
#define NUMBERLABEL_TAG 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ConceptCell";

//    UILabel *conceptNumberLabel;
//    UILabel *conceptTitleLabel;
    BookConceptTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[BookConceptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
    }

    Concept *concept = [self.chapter.concepts objectAtIndex:indexPath.row];
    [cell configureWithConcept:concept forPath:indexPath];
	
    return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Concept *concept = [self.chapter.concepts objectAtIndex:indexPath.row];
    [self.delegate navigateToConcept:concept];
    [self performSelector:@selector(clearSelection) withObject:nil afterDelay:0.15];
}

- (void)clearSelection {
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    Concept *concept = [self.chapter.concepts objectAtIndex:indexPath.row];
//	return [self labelHeightForConcept:concept];
    return [BookConceptTableViewCell labelHeightForConcept:concept accessoryPadding:0];
}

//#pragma mark Private methods
//- (NSString *)numberLabelForConcept:(Concept *)concept {
//    if (self.chapter.number && concept.number.length) {
//        return [NSString stringWithFormat:@"%@.%@", self.chapter.number, concept.number];
//    } else if (concept.number.length) {
//        return [NSString stringWithFormat:@"%@", concept.number];
////	} else if (self.chapter.number && [self.chapter.concepts lastObject] == concept) {
////        return [NSString stringWithFormat:@"%@.R", self.chapter.number];
////	} else if (self.chapter.number && [self.chapter.concepts objectAtIndex:0] == concept) {
////        return [NSString stringWithFormat:@"intro"];
//    } else {
//        return @"";
//    }
//}
//
//- (float)labelHeightForConcept:(Concept *)concept {
////	NSString *title;
////	if ([self.chapter.concepts objectAtIndex:0] == concept) {
////		title = [NSString stringWithFormat:@"%@", self.chapter.title];
////	} else {
////		title = concept.title;
////	}
//	CGSize size = [concept.title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize: CGSizeMake(217.0, 72.0)];
//	return MAX(size.height+16, 50);
//}

@end
