//
//  HistoryTableViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 8/29/12.
//
//

#import "HistoryTableViewController.h"
#import "HistoryLocation.h"
#import "Concept.h"
#import "Chapter.h"
#import "NSObject+PWObject.h"
#import "BookConceptTableViewCell.h"

@interface HistoryTableViewController ()

@property (nonatomic, weak) id<BackForwardNavigationViewDelegate> delegate;
@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) History *history;
@property (nonatomic, strong) NSArray *historyItems;
@property (nonatomic, assign) NSInteger currentIndex;

-(void)computeRows:(BOOL)refresh;

@end

@implementation HistoryTableViewController

@synthesize delegate = delegate_, book = book_, history = history_, currentIndex = currentIndex_, historyItems = historyItems_;

+ (HistoryTableViewController *)historyTVCWithHistory:(History *)history book:(Book *)book andDelegate:(id<BackForwardNavigationViewDelegate>)delegate {
//    HistoryTableViewController *htvc = [[[HistoryTableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    HistoryTableViewController *htvc = [[HistoryTableViewController alloc] initWithStyle:UITableViewStylePlain];
    htvc.book = book;
    htvc.history = history;
    htvc.delegate = delegate;
    return htvc;
}

- (void)computeRows:(BOOL)refresh {
    NSArray *reversedForwardStack = [[self.history.forwardStack reverseObjectEnumerator] allObjects];
    self.historyItems = [[self.history.backStack arrayByAddingObject:self.history.current] arrayByAddingObjectsFromArray:reversedForwardStack];
    self.currentIndex = self.history.forwardStack.count;
//    self.historyItems = [NSArray arrayWithArray:self.history.totalHistory];
//    self.currentIndex = [self.historyItems indexOfObject:self.history.current];
    
    if (self.tableView && refresh) {
        [self.tableView reloadData];
        
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
        if (![self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
        }
    }
}

- (void)refreshView {
    [self computeRows:YES];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg.png"]];
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
    
    // make header
    UILabel *header = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 44)];
    header.font = [UIFont boldSystemFontOfSize:17];
    header.text = @"History";
    header.textAlignment = NSTextAlignmentCenter;
    header.textColor = [UIColor whiteColor];
    header.backgroundColor = [UIColor clearColor];// colorWithPatternImage:[UIImage imageNamed:@"panel-bg.png"]];
    UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(0, header.frame.size.height-1, header.frame.size.width, 1)];
    bar.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
    bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
    [header addSubview:bar];
    [self.tableView setTableHeaderView:header];
    
    // add footer to remove blank cells
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 1)];
    v.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:v];
}

- (void)viewDidAppear:(BOOL)animated {
    [self computeRows:YES];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentIndex inSection:0];
    if (![self.tableView.indexPathsForVisibleRows containsObject:indexPath]) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
//    if (self.tableView.indexPathsForVisibleRows.count > self.historyItems.count) {
//        [self.tableView flashScrollIndicators];
//    }
}

- (void)dealloc {
    self.delegate = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSInteger)invertedIndex:(NSIndexPath *)indexPath {
    return self.historyItems.count-indexPath.row-1;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.historyItems.count;
}

- (UIFont *)glossaryEntryFont {
    return [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
}
- (UIFont *)answerEntryFont {
    return [UIFont italicSystemFontOfSize:15];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    HistoryLocation *location = [self.historyItems objectAtIndex:[self invertedIndex:indexPath]];
    Concept *c = [self.book conceptForPath:location.request.URL.path];
    UITableViewCell *cell;
    
    BOOL conceptIsAnswer = [self.book conceptIsAnswer:c];
    BOOL conceptIsGlossary = [self.book conceptIsInGlossary:c];
    
//    if (conceptIsAnswer || conceptIsGlossary) {
    static NSString *CellIdentifier = @"gCell";
    cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 4;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    cell.textLabel.text = c.titleAndNumber;
    if (conceptIsAnswer) {
        cell.textLabel.font = [self answerEntryFont];
    } else if (conceptIsGlossary) {
        cell.textLabel.font = [self glossaryEntryFont];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:15.0f];
    }

//    } else { // it's a book concept
//        static NSString *CellIdentifier = @"cCell";
//        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        if (cell == nil) {
//            cell = [[BookConceptTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//        }
//        
//        [(BookConceptTableViewCell *)cell configureWithConcept:c forPath:indexPath];
//    }
    
    if (indexPath.row == self.currentIndex) {
        UIImageView *checkmark = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TSD_TableViewCheckboxImage_P.png"]];
        cell.accessoryView = checkmark;
    } else {
        cell.accessoryView = nil;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == self.currentIndex) {
        cell.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:0.333];
        cell.textLabel.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = [UIColor clearColor];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    HistoryLocation *location = [self.historyItems objectAtIndex:[self invertedIndex:indexPath]];
    Concept *c = [self.book conceptForPath:location.request.URL.path];
//    if ([self.book conceptIsInTextbook:c]) {
//        float padding = (indexPath.row == self.currentIndex) ? 26 : 0;
//        return [BookConceptTableViewCell labelHeightForConcept:c accessoryPadding:padding];
//    } else {
    UIFont *font = [UIFont systemFontOfSize:15.0f];;
    if ([self.book conceptIsInGlossary:c]) {
        font = [self glossaryEntryFont];
    } else if ([self.book conceptIsAnswer:c]) { // answer
        font = [self answerEntryFont];
    }
    CGFloat borders = 20;
    if (indexPath.row == self.currentIndex) {
        borders = 46;
    }
  //  CGSize size = [c.titleAndNumber sizeWithFont:font constrainedToSize:CGSizeMake(tableView.frame.size.width-borders, 200) lineBreakMode:NSLineBreakByWordWrapping];
    
    
    CGRect textRect = [c.titleAndNumber boundingRectWithSize:CGSizeMake(tableView.frame.size.width-borders, 200) options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:font}
                                         context:nil];
    
    CGSize size = textRect.size;

    
    
    return ceil(size.height) + 22;
//    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;// indexPath.row != self.currentIndex;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        HistoryLocation *location = [self.historyItems objectAtIndex:[self invertedIndex:indexPath]];
        [self.history.backStack removeObject:location];
        [self.history.forwardStack removeObject:location];
        [self computeRows:NO];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.currentIndex) {
        // close the panel
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self.delegate dismissNavigationView];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        [self performBlock:^{
            if (indexPath.row < self.currentIndex) {
                [self.delegate goForward:self.currentIndex - indexPath.row];
            } else { // indexPath.row > self.currentIndex
                [self.delegate goBack:indexPath.row - self.currentIndex];
            }
        } afterDelay:0.333];
//        [self performSelector:@selector(computeRows) withObject:nil afterDelay:2.5];
    }
}

@end
