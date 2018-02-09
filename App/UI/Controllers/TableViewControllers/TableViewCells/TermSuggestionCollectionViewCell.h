//
//  TermSuggestionCollectionViewCell.h
//  Halo
//
//  Created by Adam Overholtzer on 10/22/12.
//
//

#import <UIKit/UIKit.h>

static const CGFloat TERM_SUGGESTION_CELL_PADDING = 15;

@interface TermSuggestionCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) IBOutlet UILabel *textLabel;

+ (UIFont *)font;

@end
