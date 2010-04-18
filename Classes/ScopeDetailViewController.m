//
//  DetailViewController.m
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import "ScopeDetailViewController.h"


@interface ScopeDetailViewController ()
@property (nonatomic, retain) UIPopoverController *popoverController;
@end



@implementation ScopeDetailViewController

@synthesize toolbar, popoverController;



#pragma mark -
#pragma mark Split view support

- (void)splitViewController: (UISplitViewController*)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem*)barButtonItem forPopoverController: (UIPopoverController*)pc {
  
  barButtonItem.title = @"Scopes";
  NSMutableArray *items = [[toolbar items] mutableCopy];
  [items insertObject:barButtonItem atIndex:0];
  [toolbar setItems:items animated:YES];
  [items release];
  self.popoverController = pc;
}


// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController: (UISplitViewController*)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
  
  NSMutableArray *items = [[toolbar items] mutableCopy];
  [items removeObjectAtIndex:0];
  [toolbar setItems:items animated:YES];
  [items release];
  self.popoverController = nil;
}

#pragma mark -
#pragma mark Scroll View

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
  return imageView;
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  
  UIImage *exampleImage = [UIImage imageNamed:@"example.png"];
  imageView.image = exampleImage;
  [imageView sizeToFit];
  CGRect imageFrame = imageView.frame;
  imageFrame.origin = CGPointZero;
  imageView.frame = imageFrame;
  
  scrollView.contentSize = exampleImage.size;
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

- (void)viewDidUnload {
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.popoverController = nil;
}


#pragma mark -
#pragma mark Memory management

/*
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}
*/

- (void)dealloc {
  [popoverController release];
  [toolbar release];
  [super dealloc];
}

@end
