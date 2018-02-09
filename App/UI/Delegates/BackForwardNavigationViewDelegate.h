//
//  BackForwardNavigationViewDelegate.h
//  Halo
//
//  Created by Adam Overholtzer on 8/30/12.
//
//

#import <UIKit/UIKit.h>

@protocol BackForwardNavigationViewDelegate <NSObject>


- (void)goBack:(NSInteger)count;
- (void)goForward:(NSInteger)count;
- (void)dismissNavigationView;

@end
