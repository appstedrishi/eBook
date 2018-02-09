#import "TOCGlossaryTableViewController.h"
#import "Book.h"
#import "Concept.h"

static const NSUInteger SECTION_COUNT = 27, SEARCH_INDEX_OFFSET = 1, SEARCH_INDEX_THRESHHOLD = 30;

@interface TOCGlossaryTableViewController ()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) Concept *previousTerm;
@property (nonatomic, weak) id<TOCNavigationDelegate> delegate;
@property (nonatomic, strong) NSMutableArray *containsFilteredList, *startsWithFilteredList;
@property (nonatomic, strong) NSArray *sectionIndices;
@property (nonatomic, strong) UISearchBar *searchBar; 
//@property (nonatomic, strong) UISearchDisplayController *searchController;
@property (strong, nonatomic) UISearchController *searchController;
- (NSArray *)sectionTitles;
- (NSString *)letterForSection:(NSInteger)section;
- (NSUInteger)indexOfFirstGlossaryConceptForSection:(NSInteger)section;

@end

@implementation TOCGlossaryTableViewController

@synthesize book = book_, previousTerm = previousTerm_, delegate = delegate_, containsFilteredList = containsFilteredList_;
@synthesize searchController = searchController_, searchBar = searchBar_;
@synthesize sectionIndices = sectionIndices_, startsWithFilteredList = startsWithFilteredList_;

- (id)init {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithStyle:(UITableViewStyle)style {
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}

- (id)initWithBook:(Book *)book andDelegate:(id<TOCNavigationDelegate>)delegate {
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.book = book;
        self.delegate = delegate;
		
		// There are too many glossary entries to figure out the index positions on-the-fly. So we'll do
		// it here and store them for later. We go backwards to facilitate empty sections.
		id indices = [NSMutableArray arrayWithCapacity:SECTION_COUNT];
		for (int i = SECTION_COUNT-1; i > 0; --i) {
            NSUInteger index = [self.book indexOfFirstGlossaryConceptStartingWithLetter:[self letterForSection:i]];
            if (NSNotFound != index) {
                [indices insertObject:[NSNumber numberWithInteger:index] atIndex:0];
            } else {
				// This section will be empty!
				if ([indices count] == 0) {
					// If it's the last section, just give it the full count of concepts
					[indices addObject:[NSNumber numberWithInteger:[self.book.glossaryConcepts count]]];
				} else {
					// Otherwise, give it the same index as its successor
					[indices insertObject:[indices objectAtIndex:0] atIndex:0];
				}
			}
        }
		// Last, insert the first index (0) for the first group ("#")
		[indices insertObject:[NSNumber numberWithInt:0] atIndex:0];
		self.sectionIndices = [NSArray arrayWithArray:indices];
    }
	return self;
}

- (id)initWithBook:(Book *)book term:(id)term andDelegate:(id<TOCNavigationDelegate>)delegate {
    if (self = [self initWithBook:book andDelegate:delegate]) {
        if (term && [book conceptIsInGlossary:term]) {
            self.previousTerm = term;
        }
    }
    return self;
}

- (void)dealloc {
    self.delegate = nil;
    self.searchController.delegate = nil;
    self.searchController.searchBar.delegate=nil;
//	self.searchDisplayController.delegate = nil;
//	self.searchDisplayController.searchResultsDelegate = nil;
//	self.searchDisplayController.searchResultsDataSource = nil;
}

#pragma mark View lifecycle
- (void)viewDidLoad {
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [UIView new];
    self.tableView.backgroundView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"panel-bg"]];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];

    self.tableView.sectionIndexColor = [UIColor colorWithWhite:0.9 alpha:1];
    self.tableView.sectionIndexBackgroundColor = [UIColor clearColor];
    self.tableView.sectionIndexTrackingBackgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:0.85];
    
    // add header to remove blank cell/dividers
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 22)];
    v.backgroundColor = [UIColor clearColor];
   [self.tableView setTableHeaderView:v];
   
    
    self.navigationItem.title = @"Glossary";
	self.containsFilteredList = [NSMutableArray arrayWithCapacity:[self.book.glossaryConcepts count]];
	self.startsWithFilteredList = [NSMutableArray arrayWithCapacity:100];
	
  
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    //self.searchController.searchBar.scopeButtonTitles = @[NSLocalizedString(@"ScopeButtonCountry",@"Country"), NSLocalizedString(@"ScopeButtonCapital",@"Capital")];
       self.searchController.searchBar.delegate = self;
    self.searchController.delegate = self;
   
    
     self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
   // [self.searchController.searchBar setNeedsLayout];
    self.searchController.searchBar.tintColor = [UIColor whiteColor];
        self.searchController.searchBar.backgroundColor = [UIColor colorWithRed:60.0/255 green:62.0/255 blue:70.0/255 alpha:1];
     [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setTextColor:[UIColor whiteColor]];
    self.searchController.searchBar.searchBarStyle = UISearchBarStyleMinimal;
    self.searchController.searchBar.placeholder = @"Search glossary";
   // self.searchController.searchBar.text=@"asdffd";
  self.searchController.searchBar.autocapitalizationType = UITextAutocapitalizationTypeNone;
   self.searchController.searchBar.autocorrectionType = UITextAutocorrectionTypeNo;
  
   
    //searchField.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:.70];
    


            if (self.book.glossaryConcepts.count < SEARCH_INDEX_THRESHHOLD) {
            self.searchController.searchBar.frame = CGRectMake(0.0, 0.0, 280.0, 44.0);
        } else {
            self.searchController.searchBar.frame = CGRectMake(0.0, 0.0, 260.0, 44.0);
        }
    
  
        if (@available(iOS 11.0, *)) {
           // (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]) ).defaultTextAttributes = [NSForegroundColorAttributeName: UIColor.white];
           // [[UITextField appearanceWhenContainedIn:self.searchController.searchBar, nil] setTextColor:[UIColor redColor]];
       [[UITextField appearanceWhenContainedInInstancesOfClasses:@[[UISearchBar class]]] setDefaultTextAttributes:@{NSForegroundColorAttributeName: [UIColor whiteColor]}];
            self.navigationItem.searchController = self.searchController;
             self.navigationItem.hidesSearchBarWhenScrolling = NO;
        } else {
            UITextField *searchField = [self.searchController.searchBar valueForKey:@"_searchField"];
            searchField.textColor = [UIColor whiteColor];
            // Fallback on earlier versions
              self.tableView.tableHeaderView = self.searchController.searchBar;
        }
    
        
   
   
    
       // self.searchController.searchBar.autoresizingMask = UIViewAutoresizingNone;

    if (self.previousTerm) {
        NSUInteger rawIndex = [self.book.glossaryConcepts indexOfObject:self.previousTerm];
        NSUInteger sectionIndex = 0;
        while (sectionIndex < [self numberOfSectionsInTableView:self.tableView]) {
            if ([self indexOfFirstGlossaryConceptForSection:sectionIndex] > rawIndex) {
                sectionIndex = sectionIndex - 1;
                break;
            } else {
                sectionIndex++;
            }
        }
        
        NSInteger index = rawIndex - [self indexOfFirstGlossaryConceptForSection:sectionIndex];
        if (index >= 0 && index < [self tableView:self.tableView numberOfRowsInSection:sectionIndex+SEARCH_INDEX_OFFSET]) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:sectionIndex+SEARCH_INDEX_OFFSET] atScrollPosition:UITableViewScrollPositionTop animated:NO];
            [self.tableView reloadData];
        }
    } else {
//        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:SEARCH_INDEX_OFFSET] atScrollPosition:UITableViewScrollPositionTop animated:NO];
        [self.tableView reloadData];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)didReceiveMemoryWarning {
	self.searchController = nil;
	self.containsFilteredList = nil;
	self.startsWithFilteredList = nil;
	[super didReceiveMemoryWarning];
}
- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:
(NSTimeInterval)duration {
     [self.searchController setActive:NO];
    
   
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    [self.searchController setActive:NO];
    return YES;
}

#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	//if (tableView == self.searchController.view)
    if (self.searchController.active && ![self.searchController.searchBar.text isEqual:@""] ) {
        return 2;
    }
     else {
		return SECTION_COUNT + SEARCH_INDEX_OFFSET;
	}
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	//if (tableView == self.searchController.view)
     if (self.searchController.active && ![self.searchController.searchBar.text isEqual:@""] ){
		if (section == 0) {
			return [self.startsWithFilteredList count];
		} else {
			return [self.containsFilteredList count];
		}
	} else {
		if (section == 0) return 1;
		return [self indexOfFirstGlossaryConceptForSection:section+1 - SEARCH_INDEX_OFFSET] - [self indexOfFirstGlossaryConceptForSection:section - SEARCH_INDEX_OFFSET];
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	
	//if (tableView == self.searchController.view)
     if (self.searchController.active && ![self.searchController.searchBar.text isEqual:@""] ){
		if (section == 0) {
			return [NSString stringWithFormat:@"Starts with “%@”", searchController_.searchBar.text];
		} else {
			return [NSString stringWithFormat:@"Contains “%@”", searchController_.searchBar.text];
		}
	} else {
        if (section > 0 && [self tableView:self.tableView numberOfRowsInSection:section]) {
            return [[self sectionTitles] objectAtIndex:section - SEARCH_INDEX_OFFSET];
        } else {
            return nil;// "search" or empty
        }
	}
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	//if (tableView != self.searchController.view && [indexPath indexAtPosition:0] == 0)
//     if ( !self.searchController.active  && [indexPath indexAtPosition:0] == 0)
//    {
//		static NSString *cellIdentifier = @"SearchCell";
//		UITableViewCell *searchBarCell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
//		if (searchBarCell == nil) {
//            searchBarCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
////            searchBarCell.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tocToolbar"]];
//            searchBarCell.selectionStyle = UITableViewCellSelectionStyleNone;
//            searchBarCell.backgroundColor = [UIColor clearColor];
//            [searchBarCell.contentView addSubview:self.searchController.view];
//        }
//		return searchBarCell;
//	} else {
		static NSString *cellIdentifier = @"GlossaryConceptCell";
//        static NSInteger barTag = 8675309;

		UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
		if (cell == nil) {
			cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
            cell.textLabel.textColor = [UIColor whiteColor];
            cell.backgroundColor = [UIColor clearColor];
            cell.textLabel.highlightedTextColor = [UIColor darkGrayColor];
            
//            UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(10, cell.frame.size.height-1, cell.frame.size.width-20, 1)];
//            bar.tag = barTag;
//            bar.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
//            bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//            [cell addSubview:bar];
//            [bar release];
		}

		cell.textLabel.font = [UIFont systemFontOfSize:15.0];
		if (self.searchController.active) {
			if (indexPath.section == 0) {
				cell.textLabel.text = [[self.startsWithFilteredList objectAtIndex:indexPath.row] title];
			} else {
				cell.textLabel.text = [[self.containsFilteredList objectAtIndex:indexPath.row] title];
			}
		} else {
			cell.textLabel.text = [[self.book.glossaryConcepts objectAtIndex:indexPath.row + [self indexOfFirstGlossaryConceptForSection:indexPath.section - SEARCH_INDEX_OFFSET]] title];
		}
        
//        // hide the dividing bar on the last row of a section
//        [cell viewWithTag:barTag].hidden = (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1);
        
		return cell;
	//}
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (!sectionTitle) return nil;
    
    if ([tableView respondsToSelector:@selector(dequeueReusableHeaderFooterViewWithIdentifier:)]) {
        // iOS 6+
        static NSString *headerIdentifier = @"GlossaryHeader";
        UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerIdentifier];
        
        if (!header) {
            header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerIdentifier];
            
            header.backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 288, 22)];
            header.backgroundView.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
            header.textLabel.textColor = [UIColor whiteColor];
            header.textLabel.font = [UIFont boldSystemFontOfSize:13]; // BUG: This doesn't seem to change the font size??
            header.textLabel.shadowColor = [UIColor clearColor];
        }
        header.textLabel.text = sectionTitle;
        return header;
    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 288, 22)];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, backgroundView.frame.size.width-20, backgroundView.frame.size.height)];
        textLabel.backgroundColor =[UIColor clearColor];
        textLabel.font =[UIFont boldSystemFontOfSize:13];
        textLabel.textColor =[UIColor whiteColor];
        textLabel.shadowColor =[UIColor clearColor];
        textLabel.text = sectionTitle;
        [backgroundView addSubview:textLabel];
        
        return backgroundView;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    NSString *sectionTitle = [self tableView:tableView titleForHeaderInSection:section];
    if (!sectionTitle) return 0;
    else return 22;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    // if (self.searchController.active && ![self.searchController.searchBar.text isEqual:@""] )
	if ((self.searchController.active && ![self.searchController.searchBar.text isEqual:@""]) || self.book.glossaryConcepts.count < SEARCH_INDEX_THRESHHOLD) {
		return nil;
	} else {
        return [[NSArray arrayWithObject:@"{search}"] arrayByAddingObjectsFromArray:[self sectionTitles]];
	}
}

#pragma mark Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.searchController.active && ![self.searchController.searchBar.text isEqual:@""])
    {
		if (indexPath.section == 0) {
			Concept *concept = [self.startsWithFilteredList objectAtIndex:indexPath.row];
			[self.delegate navigateToConcept:concept];
		} else {
			Concept *concept = [self.containsFilteredList objectAtIndex:indexPath.row];
			[self.delegate navigateToConcept:concept];
		}
        [self.searchController.searchBar endEditing:NO];
	} else {
		Concept *concept = [self.book.glossaryConcepts objectAtIndex:indexPath.row + [self indexOfFirstGlossaryConceptForSection:indexPath.section - SEARCH_INDEX_OFFSET]];
		[self.delegate navigateToConcept:concept];
	}
    self.searchController.active=false;
    [self performSelector:@selector(clearSelectionForTableView:) withObject:tableView afterDelay:0.15];
}

- (void)clearSelectionForTableView:(UITableView *)tableView {
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	
    if (searchText.length!=0) {
        
        [self.containsFilteredList removeAllObjects]; // First clear the filtered array.
        [self.startsWithFilteredList removeAllObjects];
    NSPredicate *containsPredicate = [NSPredicate predicateWithFormat: @"(SELF.title contains[cd] %@ AND NOT SELF.title beginswith[cd] %@)", searchText, searchText];
	[self.containsFilteredList setArray:[self.book.glossaryConcepts filteredArrayUsingPredicate:containsPredicate]];
	NSPredicate *startsWithPredicate = [NSPredicate predicateWithFormat: @"(SELF.title beginswith[cd] %@)", searchText];
	[self.startsWithFilteredList setArray:[self.book.glossaryConcepts filteredArrayUsingPredicate:startsWithPredicate]];
    }
    else
    {
    [self.containsFilteredList setArray:self.book.glossaryConcepts ];
        [self.startsWithFilteredList setArray:self.book.glossaryConcepts ];
    }
   

}


#pragma mark UISearchDisplayController Delegate Methods

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    self.tableView.backgroundColor = 0;
    //        controller.searchResultsTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.separatorColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
    NSString *searchString = searchController.searchBar.text;
    [self filterContentForSearchText:searchString scope:@"All"];
    //[self searchForText:searchString scope:searchController.searchBar.selectedScopeButtonIndex];
    [self.tableView reloadData];
}
- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    //        controller.searchResultsTableView.backgroundColor = [UIColor clearColor];
    //        controller.searchResultsTableView.backgroundView = nil;
    
        //[self updateSearchResultsForSearchController:self.searchController];
    }
- (void)willDismissSearchController:(UISearchController *)searchController {
    // do something before the search controller is dismissed
}

#pragma mark Private interface
- (NSArray *)sectionTitles {
    static NSMutableArray *sectionTitles;
    if (!sectionTitles) {
        sectionTitles = [[NSMutableArray alloc] initWithCapacity:SECTION_COUNT];
        [sectionTitles addObject:@"#"];
        for (unsigned int i = 1; i <= SECTION_COUNT-1; ++i) {
            [sectionTitles addObject:[self letterForSection:i]];
        }
    }

    return sectionTitles;
}

- (NSString *)letterForSection:(NSInteger)section {
    char sz[2]; sz[0] = section + 'A' - 1; sz[1] = 0;
    return [NSString stringWithCString:sz encoding:NSUTF8StringEncoding];
}

- (NSUInteger)indexOfFirstGlossaryConceptForSection:(NSInteger)section {
	if (section <= 0) {
		return 0;
	} else if (section < [self.sectionIndices count]) {
		return [[self.sectionIndices objectAtIndex:section] integerValue];
    } else {
        return self.book.glossaryConcepts.count;
	}
}

@end

