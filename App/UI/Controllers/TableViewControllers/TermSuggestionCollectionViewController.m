//
//  TermSuggestionCollectionViewController.m
//  Halo
//
//  Created by Adam Overholtzer on 10/22/12.
//
//
#import <Foundation/Foundation.h>
#import "TermSuggestionCollectionViewController.h"
#import "TermSuggestionCollectionViewCell.h"
#import "Book.h"
#import "Concept.h"
#import "QuestionViewController.h"

NSString *CELL_ID = @"termSuggestionCell";

@interface TermSuggestionCollectionViewController ()

@property (nonatomic, weak) QuestionViewController *delegate;
@property (nonatomic, strong) NSMutableArray *concepts;
@property (nonatomic, strong) NSArray *filteredList, *blankList;

@end

@implementation TermSuggestionCollectionViewController

- (id)initWithConcepts:(NSArray *)concepts andDelegate:(QuestionViewController *)delegate {
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    layout.sectionInset = UIEdgeInsetsZero;
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
    if (self = [super initWithCollectionViewLayout:layout]) {
//        self.concepts = [NSArray arrayWithArray:concepts];
        self.concepts = [NSMutableArray arrayWithCapacity:concepts.count];
        [self.concepts addObjectsFromArray:@[@"what", @"is", @"are", @"the", @"relationship", @"differences", @"between"]];
        for (Concept *c in concepts) {
            [self.concepts addObject:c.title];
        }
        self.delegate = delegate;
        self.blankList = @[];
        self.filteredList = [NSArray arrayWithArray:self.blankList];
    }
	return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    int barWidth = 1024;

    self.collectionView.backgroundColor = [UIColor lightGrayColor];
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.alwaysBounceHorizontal = YES;
    
    self.collectionView.backgroundColor = [UIColor colorWithRed:156/255. green:155/255. blue:166/255. alpha:1.];
    
    UIView *border1 = [[UIView alloc] initWithFrame:CGRectMake(-barWidth, 0, barWidth*5, 1)];
    border1.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
    [self.collectionView addSubview:border1];
    
    UIView *border2 = [[UIView alloc] initWithFrame:CGRectMake(-barWidth, 1, barWidth*5, 1)];
    border2.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
    [self.collectionView addSubview:border2];

    [self.collectionView registerClass:[TermSuggestionCollectionViewCell class] forCellWithReuseIdentifier:CELL_ID];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)filterForString:(NSString *)string {
    NSMutableCharacterSet* unfilteredCharsSet = [[NSMutableCharacterSet alloc] init];
    [unfilteredCharsSet formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [unfilteredCharsSet formUnionWithCharacterSet:[NSCharacterSet punctuationCharacterSet]];
    string = [string stringByTrimmingCharactersInSet:unfilteredCharsSet];
    
    NSRange limitedRange;
    limitedRange.location = 0;
    limitedRange.length = TERM_SUGGESTION_MAX_SUGGESTIONS;
    
    if (string.length) {
        NSPredicate *startsWithPredicate = [NSPredicate predicateWithFormat: @"(self BEGINSWITH[cd] %@)", string];
        self.filteredList = [self.concepts filteredArrayUsingPredicate:startsWithPredicate];
        if (self.filteredList.count < 10) {
            NSPredicate *containsPredicate = [NSPredicate predicateWithFormat: @"(self contains[cd] %@ AND NOT self BEGINSWITH[cd] %@)", string, string];
            self.filteredList = [self.filteredList arrayByAddingObjectsFromArray:[self.concepts filteredArrayUsingPredicate:containsPredicate]];
        }
//        [UIView animateWithDuration:0.4 animations:^{
//            self.collectionView.alpha = 1;
//        }];
    } else {
        self.filteredList = [NSArray arrayWithArray:self.blankList];
//        [UIView animateWithDuration:0.4 animations:^{
//            self.collectionView.alpha = 0;
//        }];
    }
    [self.collectionView reloadData];
    
    if (self.filteredList.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft | UICollectionViewScrollPositionTop animated:NO];
    }
    
    return [self.filteredList count] > 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return MIN(self.filteredList.count, TERM_SUGGESTION_MAX_SUGGESTIONS);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TermSuggestionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CELL_ID forIndexPath:indexPath];
    cell.textLabel.text = (NSString *)[self.filteredList objectAtIndex:indexPath.row];
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *term = (NSString *)[self.filteredList objectAtIndex:indexPath.row];
  //  CGFloat width = [term sizeWithFont:[TermSuggestionCollectionViewCell font]].width;
    
    CGFloat width  = [term sizeWithAttributes:@{NSFontAttributeName: [TermSuggestionCollectionViewCell font]}].width;
   return CGSizeMake(MAX(width + TERM_SUGGESTION_CELL_PADDING*2, TERM_SUGGESTION_CELL_HEIGHT), TERM_SUGGESTION_CELL_HEIGHT);
  }

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.delegate updateTextWithSuggestion:(NSString *)[self.filteredList objectAtIndex:indexPath.row]];
    [self performSelector:@selector(filterForString:) withObject:@"" afterDelay:0.2];
}

@end
