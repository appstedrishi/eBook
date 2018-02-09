#import "Highlight.h"
#import "Aura.h"
#import "Question.h"

@interface Highlight ()

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *section;

@property (nonatomic, strong, readwrite) NSArray *suggestedQuestionsList;
@property (nonatomic, weak) NSURLConnection *suggestedQuestionsConnection;
@property (nonatomic, weak) id<NSURLConnectionDelegate> delegate;

- (void)commonInit;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection;
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error;


@end

@implementation Highlight
@synthesize marrXMLData;
@synthesize mstrXMLString;


@synthesize index = index_,
xOffset = xOffset_,
yOffset = yOffset_,
height = height_,
text = text_,
section = section_,
suggestedQuestionsList = suggestedQuestionsList_,
rangeJSON = rangeJSON_,
suggestedQuestionsConnection = suggestedQuestionsConnection_,
notecardText = notecardText_,
creationDate = creationDate_,
color = color_,
delegate = delegate_;

+ (NSString *)YELLOW {
    return @"yellow";
}

+ (NSString *)BLUE {
    return @"blue";
}

+ (NSString *)GREEN {
    return @"green";
}

#pragma mark NSCoding

static NSString *X_OFFSET_KEY = @"xOffset";
static NSString *Y_OFFSET_KEY = @"yOffset";
static NSString *HEIGHT_KEY = @"height";
static NSString *RANGE_JSON_KEY = @"rangeJSON";
static NSString *NOTECARD_TEXT_KEY = @"notecardText";
static NSString *TEXT_KEY = @"text";
static NSString *SECTION_KEY = @"section";
static NSString *COLOR_KEY = @"color";
static NSString *DATE_KEY = @"date";

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.xOffset = [decoder decodeFloatForKey:X_OFFSET_KEY];
        self.yOffset = [decoder decodeFloatForKey:Y_OFFSET_KEY];
        self.height = [decoder decodeFloatForKey:HEIGHT_KEY];
        self.rangeJSON = [decoder decodeObjectForKey:RANGE_JSON_KEY];
        self.notecardText = [decoder decodeObjectForKey:NOTECARD_TEXT_KEY];
        self.text = [decoder decodeObjectForKey:TEXT_KEY];
        self.section = [decoder decodeObjectForKey:SECTION_KEY];
        self.creationDate = [decoder decodeObjectForKey:DATE_KEY];
        self.color = [decoder decodeObjectForKey:COLOR_KEY];

        [self commonInit];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeFloat:self.xOffset forKey:X_OFFSET_KEY];
    [coder encodeFloat:self.yOffset forKey:Y_OFFSET_KEY];
    [coder encodeFloat:self.height forKey:HEIGHT_KEY];
    [coder encodeObject:self.rangeJSON forKey:RANGE_JSON_KEY];
    [coder encodeObject:self.notecardText forKey:NOTECARD_TEXT_KEY];
    [coder encodeObject:self.text forKey:TEXT_KEY];
    [coder encodeObject:self.section forKey:SECTION_KEY];
    [coder encodeObject:self.creationDate forKey:DATE_KEY];
    [coder encodeObject:self.color forKey:COLOR_KEY];
}

#pragma mark init

+ (id)highlightWithIndex:(NSString *)index xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset height:(CGFloat)height text:(NSString*)text section:(NSString *)section color:(NSString *)color rangeJSON:(NSString *)rangeJSON {
    return [[[self class] alloc] initWithIndex:index xOffset:xOffset yOffset:yOffset height:height text:text section:section color:color rangeJSON:rangeJSON];
}

- (id)initWithIndex:(NSString *)index xOffset:(CGFloat)xOffset yOffset:(CGFloat)yOffset height:(CGFloat)height text:(NSString*)text section:(NSString *)section color:(NSString *)color rangeJSON:(NSString *)rangeJSON {
    if (self = [super init]) {
        self.index = index;
		self.xOffset = xOffset;
        self.yOffset = yOffset;
        self.height = height;
        self.text = text;
        self.section = section;
        self.rangeJSON = rangeJSON;
        self.notecardText = @"";
        self.creationDate = [NSDate date];
        self.color = color;

        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.suggestedQuestionsList = [NSMutableArray array];
   
}

- (void)dealloc {
    self.notecardText = nil;
    self.color = nil;
}

- (void)setColor:(NSString *)color {
    if (!color || [color isEqualToString:[Highlight YELLOW]] || [color isEqualToString:[Highlight GREEN]] || [color isEqualToString:[Highlight BLUE]]) {
        color_ = color;
    }
}

- (void)setNotecardText:(NSString *)text {
    notecardText_ = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

-(void)fetchSuggestedQuestionNew:(BOOL)var completionHandler:(QuestionArray)responsearray
{
    [[Aura aura] getSuggestedQuestionsForHighlight:self.section andText:self.text completionHandler:^(BOOL success, NSString *message, NSData *data)
     {
         if (success) {
            
         [suggestedQuestionsList_ removeAllObjects];
         NSXMLParser *xmlParser=[[NSXMLParser alloc]initWithData:data];
         [xmlParser setDelegate:self];
         [xmlParser parse];
         NSLog(@"xml data %@",marrXMLData);
         self.suggestedQuestionsList=[marrXMLData mutableCopy];
         responsearray(YES,[self.suggestedQuestionsList mutableCopy]);
         }
         else
         {
             responsearray(NO,[self.suggestedQuestionsList mutableCopy]);
         }
     }
     
     ];

}

- (void)cancelPendingRequest {
    [self.suggestedQuestionsConnection cancel]; self.suggestedQuestionsConnection = nil;
    self.delegate = nil;
}

#pragma mark NSURLConnectionDelegate
- (BOOL)respondsToSelector:(SEL)selector {
    return [super respondsToSelector:selector] || [self.delegate respondsToSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector {
    return self.delegate;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if (200 == [(NSHTTPURLResponse *)response statusCode]) {
        [suggestedQuestionsList_ removeAllObjects];
    }
    if ([self.delegate respondsToSelector:@selector(connection:didReceiveResponse:)]) {
        [(id)self.delegate connection:connection didReceiveResponse:response];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.delegate respondsToSelector:@selector(connectionDidFinishLoading:)]) {
        [(id)self.delegate connectionDidFinishLoading:connection];
    }
    self.suggestedQuestionsConnection = nil;
    self.delegate = nil;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.delegate connection:connection didFailWithError:error];
    self.suggestedQuestionsConnection = nil;
    self.delegate = nil;
}

#pragma mark -XML parsing delegate-
- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict;
{
    if([elementName isEqualToString:@"questions"])
        marrXMLData = [[NSMutableArray alloc] init];
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string;
{
    if(!mstrXMLString)
        mstrXMLString = [[NSMutableString alloc] initWithString:string];
    else
        [mstrXMLString appendString:string];
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;
{
    if([elementName isEqualToString:@"question"])
        [marrXMLData addObject:mstrXMLString];
    mstrXMLString = nil;
}

@end

