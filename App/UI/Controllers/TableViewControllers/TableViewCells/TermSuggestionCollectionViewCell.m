//
//  TermSuggestionCollectionViewCell.m
//  Halo
//
//  Created by Adam Overholtzer on 10/22/12.
//
//

#import "TermSuggestionCollectionViewCell.h"

@implementation TermSuggestionCollectionViewCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(TERM_SUGGESTION_CELL_PADDING, 1, frame.size.width-TERM_SUGGESTION_CELL_PADDING*2, frame.size.height-1)];
        self.textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textLabel.font = [TermSuggestionCollectionViewCell font];
        self.textLabel.textAlignment= NSTextAlignmentCenter;
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.6];
        self.textLabel.shadowOffset = CGSizeMake(0, 1);
        self.textLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.textLabel];
        
        self.backgroundColor = [UIColor clearColor];
//        self.backgroundView = [[[UIView alloc] initWithFrame:CGRectMake(0, 1, frame.size.width, frame.size.height)] autorelease];
//        self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//        self.backgroundView.backgroundColor = [UIColor clearColor];
//        
//        UIView *borderRight = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width, -1, 1, frame.size.height+1)];
//        borderRight.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//        borderRight.backgroundColor = [UIColor colorWithRed:191/255. green:191/255. blue:191/255. alpha:1.];
//        [self.backgroundView addSubview:borderRight];
//        
//        UIView *borderRighter = [[UIView alloc] initWithFrame:CGRectMake(frame.size.width+1, -1, 1, frame.size.height+1)];
//        borderRighter.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleHeight;
//        borderRighter.backgroundColor = [UIColor colorWithRed:51/255. green:51/255. blue:51/255. alpha:1.];
//        [self.backgroundView addSubview:borderRighter];

        
        self.selectedBackgroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.selectedBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.selectedBackgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
    }
    return self;
}


+ (UIFont *)font {
    return [UIFont boldSystemFontOfSize:16];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
