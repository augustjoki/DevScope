//
//  DetailViewController.h
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ScopeDetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate, UIScrollViewDelegate> {
  
  UIPopoverController *popoverController;
  UIToolbar *toolbar;
  IBOutlet UIView *containerView;
  IBOutlet UIScrollView *scrollView;
  IBOutlet UIImageView *imageView;
  IBOutlet UIBarButtonItem *aspectFitButton;
  IBOutlet UIBarButtonItem *actualSizeButton;
  
  BOOL isAspectFit;
  BOOL isActualSize;
  
  NSMutableArray *shapes;
  NSMutableArray *rects;
  
  BOOL recognizingEdit;
  CAShapeLayer *editingShape;
}

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;

- (void)aspectFitButtonPressed:(id)sender;
- (void)actualSizeButtonPressed:(id)sender;

@end
