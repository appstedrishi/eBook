#import "SpecHelper.h"
#define HC_SHORTHAND
#import "OCHamcrest.h"
#import "OCMock.h"

#import "ContainerView.h"

SPEC_BEGIN(ContainerViewSpec)

describe(@"ContainerView", ^{
    __block ContainerView *view;
    CGRect containerViewFrame = CGRectMake(0, 0, 100, 100);

    beforeEach(^{
        view = [[[ContainerView alloc] initWithFrame:containerViewFrame] autorelease];
    });

    describe(@"hitTest:withEvent:", ^{
        describe(@"for a point inside a subview", ^{
            describe(@"when the point is inside the container view", ^{
                CGRect subviewFrame = CGRectMake(0, 0, 10, 10);
                CGPoint point = CGPointMake(1, 1);

                it(@"should return the subview", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];

                    assertThat([view hitTest:point withEvent:nil], equalTo(subview));
                });
            });

            describe(@"when the point is outside the container view", ^{
                CGRect subviewFrame = CGRectMake(100, 100, 10, 10);
                CGPoint point = CGPointMake(101, 101);

                it(@"should return the subview", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];

                    assertThat([view hitTest:point withEvent:nil], equalTo(subview));
                });
            });
        });

        describe(@"for a point not in a subview", ^{
            describe(@"when the point is inside the container view", ^{
                CGPoint point = CGPointMake(1, 1);

                it(@"should return nil", ^{
                    assertThat([view hitTest:point withEvent:nil], nilValue());
                });
            });

            describe(@"when the point is outside the container view", ^{
                CGPoint point = CGPointMake(101, 101);

                it(@"should return nil", ^{
                    assertThat([view hitTest:point withEvent:nil], nilValue());
                });
            });
        });
    });

    describe(@"pointInside:withEvent:", ^{
        describe(@"for a point inside a visible subview", ^{
            describe(@"when the point is inside the container view", ^{
                CGRect subviewFrame = CGRectMake(0, 0, 10, 10);
                CGPoint point = CGPointMake(1, 1);

                it(@"should return YES", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];
                    assertThatFloat(subview.alpha, equalToFloat(1.0));

                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(YES));
                });
            });

            describe(@"when the point is outside the container view", ^{
                CGRect subviewFrame = CGRectMake(100, 100, 10, 10);
                CGPoint point = CGPointMake(101, 101);

                it(@"should return YES", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];
                    assertThatFloat(subview.alpha, equalToFloat(1.0));

                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(YES));
                });
            });
        });
        
        describe(@"for a point inside an invisible subview", ^{
            describe(@"when the point is inside the container view", ^{
                CGRect subviewFrame = CGRectMake(0, 0, 10, 10);
                CGPoint point = CGPointMake(1, 1);
                
                it(@"should return NO", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];
                    subview.alpha = 0.0;
                    
                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(NO));
                });
            });
            
            describe(@"when the point is outside the container view", ^{
                CGRect subviewFrame = CGRectMake(100, 100, 10, 10);
                CGPoint point = CGPointMake(101, 101);
                
                it(@"should return NO", ^{
                    UIView *subview = [[[UIView alloc] initWithFrame:subviewFrame] autorelease];
                    [view addSubview:subview];
                    subview.alpha = 0.0;
                    
                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(NO));
                });
            });
        });

        describe(@"for a point not in a subview", ^{
            describe(@"when the point is inside the container view", ^{
                CGPoint point = CGPointMake(1, 1);

                it(@"should return NO", ^{
                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(NO));
                });
            });

            describe(@"when the point is outside the container view", ^{
                CGPoint point = CGPointMake(101, 101);

                it(@"should have return NO", ^{
                    assertThatBool([view pointInside:point withEvent:nil], equalToBool(NO));
                });
            });
        });
    });
});

SPEC_END
