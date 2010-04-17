//
//  RootViewController.h
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface RootViewController : UITableViewController {
    DetailViewController *detailViewController;
}

@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
