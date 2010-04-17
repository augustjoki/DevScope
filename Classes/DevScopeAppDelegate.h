//
//  DevScopeAppDelegate.h
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>


@class ScopeListViewController;
@class ScopeDetailViewController;

@interface DevScopeAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow *window;
    
    UISplitViewController *splitViewController;
    
    ScopeListViewController *rootViewController;
    ScopeDetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UISplitViewController *splitViewController;
@property (nonatomic, retain) IBOutlet ScopeListViewController *rootViewController;
@property (nonatomic, retain) IBOutlet ScopeDetailViewController *detailViewController;

@end
