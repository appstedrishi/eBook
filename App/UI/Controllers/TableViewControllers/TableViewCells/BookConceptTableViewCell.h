//
//  BookConceptTableViewCell.h
//  Halo
//
//  Created by Adam Overholtzer on 1/25/13.
//
//

#import <UIKit/UIKit.h>

@class Concept;

@interface BookConceptTableViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *numberLabel;

- (void)configureWithConcept:(Concept *)concept forPath:(NSIndexPath *)indexPath;

+ (float)labelHeightForConcept:(Concept *)concept accessoryPadding:(float)padding;

@end

