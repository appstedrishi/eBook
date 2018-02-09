//
//  QASuggestionTableViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 5/22/12.
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import "QASuggestionTableViewController.h"
#import "QASuggestedTriggerTableViewCell.h"

@interface QASuggestionTableViewController ()

@end

@implementation QASuggestionTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.tableView.backgroundColor = [UIColor clearColor];
}

//- (void)viewDidUnload
//{
//    [super viewDidUnload];
//    // Release any retained subviews of the main view.
//    // e.g. self.myOutlet = nil;
//}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    return 1;
//	if (tableView == self.searchDisplayController.searchResultsTableView) { 
//        // Return the number of sections.
//        return 1;
//    } else {
//        return 1;
//    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//	if (tableView == self.searchDisplayController.searchResultsTableView) { 
//        // Return the number of sections.
//        return 0;
//    } else {
        return 6;
   // }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if (tableView == self.searchDisplayController.searchResultsTableView) { 
//        return nil;
//    } else {
        static NSString *CellIdentifier = @"trigger-suggestion-cell";
        QASuggestedTriggerTableViewCell *cell = (QASuggestedTriggerTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        // Configure the cell...
        cell.triggerLabel.text = @"define";
        cell.questionLabel.text = @"define cellular respiration";
        
        return cell;
    //}
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
   // self.searchDisplayController.searchBar.text = @"What are the parts of a cell?";
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark UISearchDisplayController Delegate Methods

//- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
//{
//	return YES;
//}


@end
