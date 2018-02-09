//
//  QuestionHistoryTableViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 3/16/11.
//  Copyright 2011 SRI International. All rights reserved.
//

#import "QuestionHistoryTableViewController.h"
#import "History.h"

static const CGFloat WIDTH = 420.0;
static const CGFloat HEIGHT = 800.0;

@implementation QuestionHistoryTableViewController

@synthesize delegate = delegate_;

- (id)init {
    if (self = [super init]) {
		self.tableView.backgroundColor = [UIColor colorWithHue:0.000 saturation:0.000 brightness:0.969 alpha:1.000];
        self.title = @"Recent Queries";
    }
    return self;
}

- (CGSize)preferredContentSize {
    return CGSizeMake(WIDTH, HEIGHT);
}

- (void)dealloc {
    self.delegate = nil;
}

#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	//[TTStyleSheet setGlobalStyleSheet:[[[SQTableStyleSheet alloc] init] autorelease]]; 
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}


#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.delegate.history.questionStack.count == 0) {
        return 1;
    } else {
        return self.delegate.history.questionStack.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.textLabel.font = [UIFont systemFontOfSize:16];
		cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
		cell.textLabel.numberOfLines = 6;
    }
    
    if (self.delegate.history.questionStack.count > 0) {
        cell.textLabel.text = [[self.delegate.history.questionStack objectAtIndex:indexPath.row] text];
        cell.textLabel.textColor = [UIColor darkTextColor];
    } else {
        cell.textLabel.text = @"no recent questions";
        cell.textLabel.textColor = [UIColor grayColor];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize size = CGSizeMake(50, 16);
    if (self.delegate.history.questionStack.count > 0) {
//        size00 = [[[self.delegate.history.questionStack objectAtIndex:indexPath.row] text] sizeWithFont:[UIFont systemFontOfSize:16] constrainedToSize: CGSizeMake(WIDTH-20, 200)];
        
        
        NSAttributedString *attributedText =
        [[NSAttributedString alloc] initWithString:[[self.delegate.history.questionStack objectAtIndex:indexPath.row] text]
                                        attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]}];
        CGRect rect = [attributedText boundingRectWithSize:(CGSize){WIDTH-20, 200}
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                   context:nil];
       size = rect.size;
        
        
    }
	return size.height + 22;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate.history.questionStack.count > 0) {
        [self.delegate requestAnswerToQuestion:[[self.delegate.history.questionStack objectAtIndex:indexPath.row] text]];
        [self.delegate dismissModalQuestionAnswerView];
    }
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.delegate.history.questionStack.count > 0) {
        return indexPath;
    } else {
        return nil;
    }
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.delegate.history.questionStack.count > 0;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        //add code here for when you hit delete
        [self.delegate.history.questionStack removeObjectAtIndex:indexPath.row];
        if (self.delegate.history.questionStack.count > 0) {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        } else {
            [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}



@end

