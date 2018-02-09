//
//  TextSettingsTableViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 10/1/12.
//
//

#import "TextSettingsTableViewController.h"
#import "ConceptViewController.h"
#import "ContentViewController.h"

NSString *contentSelectors = @"p:not(.toc-section, .toc-sub-section, .human-authored)";

@interface TextSettingsTableViewController ()

@end

@implementation TextSettingsTableViewController

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
    
    if ([self.tableView respondsToSelector:@selector(setSectionIndexColor:)]) { // iOS 6+ only
        // attempt to replace Verdana with AvenirNext
        for (int i = 0; i < [self.tableView numberOfRowsInSection:0]; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            if ([cell.textLabel.text isEqualToString:@"Verdana"]) {
                cell.textLabel.text = @"Avenir Next";
                cell.textLabel.font = [UIFont fontWithName:@"Avenir Next" size:cell.textLabel.font.pointSize];
                break;
            }
        }
    }
}

-(void)viewDidAppear:(BOOL)animated {
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Actions

- (IBAction)textSizeChanged:(UIStepper *)sender {
    [self.theContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').css('font-size', '%fpt');", contentSelectors, sender.value] andRefreshHighlights:YES];
//    NSLog(@"set line-height to %f", ceilf(sender.value * 1.857f));
}

- (IBAction)lineSpacingChanged:(UIStepper *)sender {
    [self.theContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@";$('%@').css('line-height', '%fpt');", contentSelectors, sender.value] andRefreshHighlights:YES];
}

- (IBAction)glossaryLinkSwitchChanged:(UISwitch *)sender {
    if (sender.on) {
        [self.theContent stringByEvaluatingJavaScriptFromString:@"$('.keywords').css('border-bottom', '');" andRefreshHighlights:NO];
    } else {
        [self.theContent stringByEvaluatingJavaScriptFromString:@"$('.keywords').css('border-bottom', 'none');" andRefreshHighlights:NO];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // font selection!
        for (UITableViewCell *c in self.fontTableViewCells) {
            c.accessoryType = UITableViewCellAccessoryNone;
        }
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        [self.theContent stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"$('%@').css('font-family', '%@');", contentSelectors, cell.textLabel.text] andRefreshHighlights:YES];
        
    } else if (indexPath.section == 2) {
        
        // RESET EVERYTHING
        
        [self.theContent stringByEvaluatingJavaScriptFromString:@"$('.keywords').css('border-bottom', '');" andRefreshHighlights:NO];
        [self.theContent stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"$('%@').css('font-family', '');", contentSelectors] andRefreshHighlights:NO];
        [self.theContent stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"$('%@').css('font-size', '');", contentSelectors] andRefreshHighlights:NO];
        [self.theContent stringByEvaluatingJavaScriptFromString:
         [NSString stringWithFormat:@"$('%@').css('line-height', '');", contentSelectors] andRefreshHighlights:YES];
        [self.delegate closePopover];
    }
}


- (void)viewDidUnload {
    [self setShowGlossaryLinksSwitch:nil];
    [self setFontTableViewCells:nil];
    [self setTextSizeStepper:nil];
    self.theContent = nil;
    self.delegate = nil;
    [super viewDidUnload];
}
@end
