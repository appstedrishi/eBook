#import "Question.h"
//#import "NSAttributedString+HTML.h"

@implementation Question

@synthesize text = text_, feedback = feedback_;

+ (Question *)questionWithText:(NSString *)question {
    return [[Question alloc] initWithQuestion:question];
}

+ (Question *)questionWithText:(NSString *)question html:(NSString *)html {
    Question *retval = [Question questionWithText:question];
    retval.html = html;
    return retval;
}

- (id)init {
    if (self = [super init]) {
        [self clear];
    }
    return self;
}

- (id)initWithQuestion:(NSString *)question {
	if ([self init]) {
		self.text = question;
		self.html = question;
	}
	return self;
}


- (NSString *)getHtml {
    return _html;
}

- (NSAttributedString *)attributedText {
//    DTCSSStylesheet *stylesheet = [[[DTCSSStylesheet alloc] initWithStyleBlock:@".blackText{ font-size:16px; } .keywords{ font-weight:bold; color:rgba(12, 54, 178, 0.72); }"] autorelease];
//    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:@"Helvetica", DTDefaultFontFamily, stylesheet, DTDefaultStyleSheet, nil];
//    if (self.html && self.html.length) {
//        NSData *data = [self.html dataUsingEncoding:NSUTF8StringEncoding];
//        return [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:nil];
//    } else {
//        NSData *data = [[NSString stringWithFormat:@"<span class='blackText'>%@</span>", self.text] dataUsingEncoding:NSUTF8StringEncoding];
//        return [[NSAttributedString alloc] initWithHTMLData:data options:options documentAttributes:nil];
//    }
    return [[NSAttributedString alloc] initWithString:self.text attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}];
}

- (void)clear {
    self.text = @"";
    self.html = @"";
    self.feedback = @"";
}

- (id)copyWithZone:(NSZone *)zone {
    Question *newQuestion;
    if ((newQuestion = [[Question alloc] init])) {
        newQuestion.text = self.text;
        newQuestion.html = self.html;
        newQuestion.feedback = self.feedback;
    }
    return newQuestion;
}

- (BOOL)isEqual:(id)object {
    return [self.text isEqualToString:[object text]];
}

#pragma mark NSCoding
static NSString *TEXT_KEY = @"text";
static NSString *HTML_KEY = @"html";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.text = [decoder decodeObjectForKey:TEXT_KEY];
        self.html = [decoder decodeObjectForKey:HTML_KEY];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.text forKey:TEXT_KEY];
    [coder encodeObject:self.html forKey:HTML_KEY];
}

@end
