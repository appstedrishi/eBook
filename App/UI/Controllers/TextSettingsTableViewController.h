//
//  TextSettingsTableViewController.h
//  Halo
//
//  Created by Adam Overholtzer on 10/1/12.
//
//

#import <UIKit/UIKit.h>

@class ConceptViewController, ContentViewController;

@interface TextSettingsTableViewController : UITableViewController

@property (strong, nonatomic) IBOutlet UIStepper *textSizeStepper, *lineSpacingStepper;
@property (strong, nonatomic) IBOutlet UISwitch *showGlossaryLinksSwitch;
@property (strong, nonatomic) IBOutletCollection(UITableViewCell) NSArray *fontTableViewCells;

@property (strong, nonatomic) ConceptViewController *delegate;
@property (strong, nonatomic) ContentViewController *theContent;

- (IBAction)textSizeChanged:(UIStepper *)sender;
- (IBAction)lineSpacingChanged:(UIStepper *)sender;
- (IBAction)glossaryLinkSwitchChanged:(UISwitch *)sender;

@end
