//
//  QASuggestedTriggerTableViewCell.m
//  Halo
//
//  Created by Adam Overholtzer on 5/22/12.
//  Copyright (c) 2012 SRI International. All rights reserved.
//

#import "QASuggestedTriggerTableViewCell.h"

@implementation QASuggestedTriggerTableViewCell

@synthesize questionLabel = questionLabel_, triggerLabel = triggerLabel_;


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.triggerLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 80, 21)];
        self.triggerLabel.font = [UIFont boldSystemFontOfSize:16];
        self.triggerLabel.textColor = [UIColor blackColor];
        self.triggerLabel.highlightedTextColor = [UIColor whiteColor];
        [self addSubview:self.triggerLabel];
        
        self.backgroundColor = [UIColor clearColor];
        
        self.questionLabel = [[UILabel alloc] initWithFrame:CGRectMake(98, 10, 560, 21)];
//        self.questionLabel.font = [UIFont systemFontOfSize:16];
        self.questionLabel.font = [UIFont fontWithName:@"Helvetica-Oblique" size:16];
        self.questionLabel.textColor = [UIColor colorWithWhite:0.2 alpha:1];
        self.questionLabel.highlightedTextColor = [UIColor colorWithWhite:1 alpha:1];
        [self addSubview:self.questionLabel];
    }
    return self;
}

@end
