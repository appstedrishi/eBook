#import "HaloApplicationDelegate.h"
#import "ConceptViewController.h"
#import "ContentViewController.h"
#import "Book.h"
#import "History.h"
#import "Logger.h"
#import "Aura.h"
#import "QTouchposeApplication.h"

@interface HaloApplicationDelegate ()

@property (nonatomic, strong) Book *book;
@property (nonatomic, strong) History *history;
@property (nonatomic, strong) NSString *hostName;

+ (BOOL)userDefaultsSet;
+ (NSDictionary *)defaultValuesFromSettingsBundle;

- (BOOL)stateArchiveExists;
- (void)restoreStateFromArchive;
- (NSString *)archiveFilePath;
- (void)buildInitialState;
- (void)loadIndices;

@end

extern NSString *SETTINGS_HOST_PREFERENCE_KEY;
extern NSString *SETTINGS_PORT_PREFERENCE_KEY;

static NSString *BOOK_KEY = @"book";
static NSString *HISTORY_KEY = @"history";
static NSString *ARCHIVE_FILENAME = @"stateArchive";

static HaloApplicationDelegate *app__;

@implementation HaloApplicationDelegate

@synthesize window = window_, conceptViewController = conceptViewController_;
@synthesize book = book_, history = history_, hostName = hostName_;

+ (id)app {
    return app__;
}

+ (void)initialize {
    if (![self userDefaultsSet]) {
        [[NSUserDefaults standardUserDefaults] registerDefaults:[self defaultValuesFromSettingsBundle]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }        
    
    if(getenv("NSZombieEnabled") || getenv("NSAutoreleaseFreedObjectCheckEnabled"))
        NSLog(@"NSZombieEnabled/NSAutoreleaseFreedObjectCheckEnabled enabled!");
}

- (void)dealloc {
    app__ = nil;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self loadIndices];
    [Logger  initializes];
    
//    // For demo purposes, show the touches even when not mirroring to an external display.
//    QTouchposeApplication *touchposeApplication = (QTouchposeApplication *)application;
//    touchposeApplication.alwaysShowTouches = YES;
    
	if ([self stateArchiveExists]) {
        [self restoreStateFromArchive];
    } else {
        [self buildInitialState];
    }
    self.conceptViewController.book = self.book;
    self.conceptViewController.history = self.history;

//    [self.window addSubview:self.conceptViewController.view];
    self.window.rootViewController = self.conceptViewController;
    [self.window makeKeyAndVisible];
    
    app__ = self;
        [Fabric with:@[[Crashlytics class]]];
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Logger logger] stopLogging];
    [self saveStateToArchive];
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [[Logger logger] startLogging];
	if (![self.hostName isEqualToString: [Aura hostName]]) {
		[Aura initialize];
		self.hostName = [Aura hostName];
        [self.conceptViewController.contentViewController setPeekStatusText];
	}
}

- (void)applicationWillTerminate:(UIApplication *)application {
    [[Logger logger] stopLogging];
    [self saveStateToArchive];
}

#pragma mark Private interface
+ (BOOL)userDefaultsSet {
    return [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_HOST_PREFERENCE_KEY] &&
        [[NSUserDefaults standardUserDefaults] objectForKey:SETTINGS_PORT_PREFERENCE_KEY];
}

// Fix for settings bundle weirdness.  See http://forums.bignerdranch.com/viewtopic.php?f=67&t=149 for details.
+ (NSDictionary *)defaultValuesFromSettingsBundle {
    NSString *mainBundlePath = [[NSBundle mainBundle] bundlePath];
    NSString *settingsPropertyListPath = [mainBundlePath stringByAppendingPathComponent:@"Settings.bundle/Root.plist"];

    NSDictionary *settingsPropertyList = [NSDictionary dictionaryWithContentsOfFile:settingsPropertyListPath];

    NSMutableArray *preferenceArray = [settingsPropertyList objectForKey:@"PreferenceSpecifiers"];
    NSMutableDictionary *registerableDictionary = [NSMutableDictionary dictionary];

    for (int i = 0; i < [preferenceArray count]; ++i)  {
        NSString *key = [[preferenceArray objectAtIndex:i] objectForKey:@"Key"];
        if (key)  {
            id value = [[preferenceArray objectAtIndex:i] objectForKey:@"DefaultValue"];
            [registerableDictionary setObject:value forKey:key];
        }
    }

    return registerableDictionary;
}

- (BOOL)stateArchiveExists {
    return [[NSFileManager defaultManager] fileExistsAtPath:[self archiveFilePath]];
}

- (void)restoreStateFromArchive {
    NSData *archiveData = [NSData dataWithContentsOfFile:[self archiveFilePath]];	
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:archiveData];
	
	NSString *version = [NSString stringWithFormat:@"%@", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
	
	// FIXME: Restoring the whole book doesn't allow us to update the index unless all the saved data is deleted. 
	Book *tempBook = [decoder decodeObjectForKey:BOOK_KEY];
	BOOL doFullReset = [[NSUserDefaults standardUserDefaults] boolForKey:@"reset_preference"];
	if (!doFullReset && [version isEqualToString:tempBook.version]) {
		self.book = tempBook;
		if (!(self.history = [decoder decodeObjectForKey:HISTORY_KEY])) { //TODO: remove this (Adam asks: "remove" what?)
			self.history = [[History alloc] init];
		}
	} else {
        // HARD RESET
        [self buildInitialState];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reset_preference"];
		[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"reset_log_preference"];
		[[NSUserDefaults standardUserDefaults] synchronize];
	}
    [decoder finishDecoding];
}

- (void)saveStateToArchive {
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(defaultQueue, ^{
        NSMutableData *archiveData = [NSMutableData data];
        
        NSKeyedArchiver *coder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:archiveData];
        [coder encodeObject:self.book forKey:BOOK_KEY];
        [coder encodeObject:self.history forKey:HISTORY_KEY];
        [coder finishEncoding];
        
        [archiveData writeToFile:[self archiveFilePath] atomically:YES];
    });
}

- (NSString *)archiveFilePath {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];

    return [docDirectory stringByAppendingPathComponent:ARCHIVE_FILENAME];
}

- (void)buildInitialState {
    self.history = [[History alloc] init];
}

- (void)loadIndices {
    NSData *indexData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"xml" inDirectory:@"textbook"]];
    NSData *glossaryIndexData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"xml" inDirectory:@"textbook/glossary"]];
    self.book = [[Book alloc] initWithIndexData:indexData andGlossaryIndexData:glossaryIndexData];
}

@end
