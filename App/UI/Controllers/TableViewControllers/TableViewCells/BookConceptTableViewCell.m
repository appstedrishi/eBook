//
//  BookConceptTableViewCell.m
//  Halo
//
//  Created by Adam Overholtzer on 1/25/13.
//
//e virtual services

#import "BookConceptTableViewCell.h"
#import "Concept.h"

@implementation BookConceptTableViewCell

float NUMBER_WIDTH  = 40.0;

+ (float)labelHeightForConcept:(Concept *)concept accessoryPadding:(float)padding {
	//CGSize size = [concept.title sizeWithFont:[UIFont systemFontOfSize:15] constrainedToSize: CGSizeMake(267.0-NUMBER_WIDTH-padding, 72.0)];
    CGRect textRect = [concept.title boundingRectWithSize:CGSizeMake(267.0-NUMBER_WIDTH-padding, 72.0) options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                         context:nil];
    
    CGSize size = textRect.size;

    
	return MAX(ceil(size.height)+16, 50);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.indentationLevel = 1;
        self.indentationWidth = NUMBER_WIDTH;
        
        self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, 0.0, NUMBER_WIDTH+10, self.frame.size.height-1)];
        
        self.textLabel.font = [UIFont systemFontOfSize:15.0];
        self.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        self.textLabel.numberOfLines = 4;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.highlightedTextColor = [UIColor darkGrayColor];
        
        self.numberLabel.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        self.numberLabel.font = [UIFont boldSystemFontOfSize:18.0];
        self.numberLabel.textAlignment = NSTextAlignmentCenter;
        self.numberLabel.adjustsFontSizeToFitWidth = YES;
        self.numberLabel.backgroundColor = [UIColor clearColor];
        self.numberLabel.textColor = [UIColor colorWithWhite:0.88 alpha:1];
        self.numberLabel.highlightedTextColor = [UIColor darkGrayColor];
        
        [self.contentView addSubview:self.numberLabel];
        
//        UIView *bar = [[UIView alloc] initWithFrame:CGRectMake(10, self.frame.size.height-1, self.frame.size.width-20, 1)];
//        bar.backgroundColor = [UIColor colorWithRed:0.400 green:0.416 blue:0.439 alpha:1.000];
//        bar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//        [self addSubview:bar];
//        [bar release];
        
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    return self;
}

- (void)configureWithConcept:(Concept *)concept forPath:(NSIndexPath *)indexPath {
    
	if (concept.chapterNumber && [concept.title isEqualToString:@"Overview"]) {
		// special behavior for overview section
		self.textLabel.text = [NSString stringWithFormat:@"%@", concept.chapterTitle];
        self.numberLabel.text = concept.chapterNumber;
	} else {
		self.textLabel.text = concept.title;
        self.numberLabel.text = [self numberLabelForConcept:concept];
	}
    self.indentationLevel = (self.numberLabel.text.length) ? 1 : 0;
}

- (NSString *)numberLabelForConcept:(Concept *)concept {
    if (concept.chapterNumber && concept.number.length) {
        return [NSString stringWithFormat:@"%@.%@", concept.chapterNumber, concept.number];
	} else if (concept.chapterNumber && !concept.number.length) {
        return [NSString stringWithFormat:@"%@  ", concept.chapterNumber];
    } else if (concept.number.length) {
        return [NSString stringWithFormat:@"%@", concept.number];
    } else {
        return @"";
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
