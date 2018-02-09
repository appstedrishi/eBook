//
//  TermSuggestionCollectionViewController.h
//  Halo
//
//  Created by Adam Overholtzer on 10/22/12.
//
//

#import <UIKit/UIKit.h>

static const CGFloat TERM_SUGGESTION_CELL_HEIGHT = 36;
static const NSInteger TERM_SUGGESTION_MAX_SUGGESTIONS = 20;

@class Book, QuestionViewController;

@interface TermSuggestionCollectionViewController : UICollectionViewController <UICollectionViewDelegateFlowLayout>

- (id)initWithConcepts:(NSArray *)concepts andDelegate:(QuestionViewController *)delegate;

- (BOOL)filterForString:(NSString *)string;

@end
