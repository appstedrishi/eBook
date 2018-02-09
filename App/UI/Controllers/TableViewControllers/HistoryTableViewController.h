//
//  HistoryTableViewController.h
//  Halo
//
//  Created by Adam Overholtzer on 8/29/12.
//
//

#import <UIKit/UIKit.h>
#import "BackForwardNavigationViewDelegate.h"
#import "History.h"
#import "Book.h"

@interface HistoryTableViewController : UITableViewController

+ (HistoryTableViewController *)historyTVCWithHistory:(History *)history book:(Book *)book andDelegate:(id<BackForwardNavigationViewDelegate>)delegate;

- (void)refreshView;

@end
