//
//  DetailViewController.h
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScopeDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIScrollViewDelegate> {
  
  UIPopoverController *popoverController;
  UIToolbar *toolbar;
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIImageView *imageView;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

@end
