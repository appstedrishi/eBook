#import <Foundation/Foundation.h>

@interface Highlight : NSObject <NSURLConnectionDelegate, NSCoding,NSXMLParserDelegate> {
    NSMutableArray *suggestedQuestionsList_;
    NSString *notecardText_;
}

@property (nonatomic, strong) NSString *index;
@property (nonatomic, assign) float xOffset;
@property (nonatomic, assign) float yOffset;
@property (nonatomic, assign) float height;
@property (nonatomic, strong, readonly) NSString *text;
@property (nonatomic, strong, readonly) NSString *section;
@property (nonatomic, strong) NSString *rangeJSON;
@property (nonatomic, strong, readonly) NSArray *suggestedQuestionsList;
@property (nonatomic, strong) NSString *notecardText;
@property (nonatomic, strong) NSDate *creationDate;
@property (nonatomic, strong) NSString *color;

//..
@property (nonatomic, strong) NSMutableDictionary *dictData;
@property (nonatomic,strong) NSMutableArray *marrXMLData;
@property (nonatomic,strong) NSMutableString *mstrXMLString;

typedef void (^QuestionArray)(BOOL success,NSMutableArray *arr);
//..
+ (NSString *)YELLOW;
+ (NSString *)GREEN;
+ (NSString *)BLUE;

+ (id)highlightWithIndex:(NSString *)index xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset height:(CGFloat)height text:(NSString *)text section:(NSString *)section color:(NSString *)color rangeJSON:(NSString *)rangeJSON;
- (id)initWithIndex:(NSString *)index xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset height:(CGFloat)height text:(NSString *)text section:(NSString *)section color:(NSString *)color rangeJSON:(NSString *)rangeJSON;

-(void)fetchSuggestedQuestionNew:(BOOL)var completionHandler:(QuestionArray)responsearray;
- (void)cancelPendingRequest;

@end
