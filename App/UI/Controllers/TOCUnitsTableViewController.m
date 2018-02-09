#import "TOCChaptersTableViewController.h"
#import "TOCUnitsTableViewController.h"
#import "TOCGlossaryTableViewController.h"
#import "Book.h"
#import "Unit.h"
#import "Chapter.h"
#import "ConceptViewController.h"

@interface TOCUnitsTableViewController ()

@property (nonatomic, strong) Unit *unit;
@property (nonatomic, weak) id <TOCNavigationDelegate> delegate;
@end

@implementation TOCUnitsTableViewController

@synthesize book = book_;
@synthesize unit = unit_;
@synthesize delegate = delegate_;

- (id)initWithBook:(Book *)book andUnit:(Unit *)unit andDelegate:(id <TOCNavigationDelegate>)delegate {
    if (self = [super init]) {
        self.book = book;
        self.unit = unit;
        self.delegate = delegate;
		//self.navigationItem.title = unit.title;
      
		
		CGRect frame = CGRectMake(0, 0, 180, 44);
		UILabel *label = [[UILabel alloc] initWithFrame:frame];
		label.backgroundColor = [UIColor clearColor];
		label.font = [UIFont boldSystemFontOfSize:16.0];
		label.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
		label.textAlignment = NSTextAlignmentCenter;
		label.textColor = [UIColor whiteColor];
		self.navigationItem.titleView = label;
        label.numberOfLines=2;
		label.text = unit.title;
		[label sizeToFit];
		
    }
    return self;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(320, 400);
}

- (void)dealloc {
    self.delegate = nil;
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

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIViewController *childController = nil;

    Chapter *chapter = [self.unit.chapters objectAtIndex:indexPath.row];
	childController = [[TOCChaptersTableViewController alloc] initWithDelegate:self andUnit:self.unit andChapter:chapter];

    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:self.unit.title
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:nil
                                                                             action:nil];

    [self.navigationController pushViewController:childController animated:YES];
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return self.unit.chapters.count;
}

#define TITLELABEL_TAG 1
#define NUMBERLABEL_TAG 2

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"ChapterCell";

	UILabel *conceptNumberLabel;
    UILabel *conceptTitleLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];

        conceptNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(-10.0, 0.0, 50.0, 50.0)]; //Archit 0,0
        conceptTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(33.0, 0.0, 230.0, 48.0)];
        
       // conceptTitleLabel.frame = CGRectMake(20.0, 0.0, 245.0, 48.0);

        conceptTitleLabel.tag = TITLELABEL_TAG;
        conceptNumberLabel.tag = NUMBERLABEL_TAG;

        conceptTitleLabel.font = [UIFont systemFontOfSize:15.0];
        conceptTitleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        conceptTitleLabel.numberOfLines = 2;
//        conceptTitleLabel.backgroundColor = [UIColor clearColor];
        conceptTitleLabel.textColor = [UIColor whiteColor];

        conceptNumberLabel.font = [UIFont boldSystemFontOfSize:18.0];
        conceptNumberLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        conceptNumberLabel.textAlignment = NSTextAlignmentCenter;
//		conceptNumberLabel.textColor = [UIColor colorWithWhite:0.15 alpha:1];
//        conceptNumberLabel.backgroundColor = [UIColor clearColor];
        conceptNumberLabel.textColor = [UIColor colorWithWhite:0.9 alpha:1];

        [cell.contentView addSubview:conceptNumberLabel];
        [cell.contentView addSubview:conceptTitleLabel];
        
        conceptNumberLabel.highlightedTextColor = [UIColor darkGrayColor];
        conceptTitleLabel.highlightedTextColor = [UIColor darkGrayColor];
        
//        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(10, cell.frame.size.height-1, cell.frame.size.width-20, 1)];
//        bar.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
//        bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//        [cell addSubview:bar];
//        [bar release];
    } else {
        conceptTitleLabel = (UILabel *)[cell.contentView viewWithTag:TITLELABEL_TAG];
        conceptNumberLabel = (UILabel *)[cell.contentView viewWithTag:NUMBERLABEL_TAG];
    }

	Chapter *chapter = [self.unit.chapters objectAtIndex:indexPath.row];
	if (chapter.number.length) {
		conceptNumberLabel.text = [NSString stringWithFormat:@"%@%@",@" ",chapter.number];
        conceptTitleLabel.text =[NSString stringWithFormat:@"%@", chapter.title];// chapter.title;
		//conceptTitleLabel.frame = CGRectMake(50.0, 0, 240.0, 48.0);
	} else {
		conceptNumberLabel.text = @"";
		conceptTitleLabel.text = chapter.title;
		//conceptTitleLabel.frame = CGRectMake(15.0, 0, 275.0, 48.0);
	}

    // add disclosure arrow >
    UIImageView *disclosureIndicator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"UITableNextSelected.png"]];
    cell.accessoryView = disclosureIndicator;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50;
}


#pragma mark TOCNavigationDelegate
- (void)navigateToConcept:(Concept *)concept {
    [self.delegate navigateToConcept:concept];
}

- (BOOL)conceptIsCurrentConcept:(Concept *)concept {
    return [self.delegate conceptIsCurrentConcept:concept];
}

@end
