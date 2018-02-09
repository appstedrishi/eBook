@interface HTMLContentVerifier : NSObject
@property (nonatomic, retain) NSString *expectedHTML;
- (id)initWithExpectedHTML:(NSString *)expectedHTML;
- (BOOL)documentContainsExpectedHTML:(NSString *)document;
@end
