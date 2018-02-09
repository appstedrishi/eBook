#import <Foundation/Foundation.h>

@interface Question : NSObject <NSCopying, NSCoding>

@property (nonatomic, strong) NSString *text, *html;
@property (nonatomic, strong) NSString *feedback;

+ (Question *)questionWithText:(NSString *)question;
+ (Question *)questionWithText:(NSString *)question html:(NSString *)html;

- (id)initWithQuestion:(NSString *)question;
- (void)clear;
- (NSAttributedString *)attributedText;

@end
