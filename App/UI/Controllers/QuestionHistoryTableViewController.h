//
//  QuestionHistoryTableViewController.h
//  Halo
//
//  Created by Adam Overholtzer on 3/16/11.
//  Copyright 2011 SRI International. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionViewDelegate.h"


@interface QuestionHistoryTableViewController : UITableViewController

@property (nonatomic, weak) id<QuestionViewDelegate> delegate;

- (id)init;

@end
