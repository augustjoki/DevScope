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
@property (nonatomic, assign) BOOL isAspectFit, isActualSize;

- (void)recenter;
- (void)aspectFit;
- (void)actualSize;
- (CGFloat)aspectFitScale;
- (void)programaticZoomDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context;

@end



@implementation ScopeDetailViewController

@synthesize toolbar, popoverController, isAspectFit, isActualSize;



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


- (void)scrollViewDidZoom:(UIScrollView *)inScrollView {
  if (!programaticZoom) {
    [self recenter];
  }
}


- (void)scrollViewDidEndZooming:(UIScrollView *)inScrollView withView:(UIView *)view atScale:(float)scale {
  if (scrollView.zoomScale == 1.0) {
    self.isActualSize = YES;
  }
  else {
    self.isActualSize = NO;
  }
  
  if (scrollView.zoomScale == [self aspectFitScale]) {
    self.isAspectFit = YES;
  }
  else {
    self.isAspectFit = NO;
  }
}


#pragma mark -
#pragma mark Rotation support

// Ensure that the view controller supports rotation and that the split view can therefore show in both portrait and landscape.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
  return YES;
}


- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
  CGRect frame = imageView.frame;
  frame.origin = CGPointZero;
  imageView.frame = frame;
  if (isAspectFit) {
    [self aspectFit];
  }
  else if (isActualSize) {
    [self actualSize];
  }
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
  
  CGSize imageSize = exampleImage.size;
  scrollView.contentSize = imageSize;
  
  [self aspectFit];
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
#pragma mark IBAction

- (void)aspectFitButtonPressed:(id)sender {
  programaticZoom = YES;
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(programaticZoomDidStop:finished:context:)];
  [self aspectFit];
  [self recenter];
  [UIView commitAnimations];
}


- (void)actualSizeButtonPressed:(id)sender {
  programaticZoom = YES;
  [UIView beginAnimations:nil context:NULL];
  [UIView setAnimationDelegate:self];
  [UIView setAnimationDidStopSelector:@selector(programaticZoomDidStop:finished:context:)];
  [self actualSize];
  [self recenter];
  [UIView commitAnimations];
}


- (void)programaticZoomDidStop:(NSString *)animationId finished:(NSNumber *)finished context:(void *)context {
  programaticZoom = NO;
}


#pragma mark -
#pragma mark Private


- (void) recenter {
  CGSize imageSize = imageView.frame.size;
  UIEdgeInsets imageInsets = (scrollView.zoomScale < 1.0f) ? UIEdgeInsetsMake((scrollView.bounds.size.height - imageSize.height) / 2.0f,
                                                                              (scrollView.bounds.size.width - imageSize.width) / 2.0f,
                                                                              0.0f, 0.0f) : UIEdgeInsetsZero;
  if (imageInsets.top < 0.0f) {
    imageInsets.top = 0.0f;
  }
  if (imageInsets.left < 0.0f) {
    imageInsets.left = 0.0f;
  }
  
  scrollView.contentInset = imageInsets;
  
}

- (void)aspectFit {
  CGFloat minScale = [self aspectFitScale];
  scrollView.zoomScale = minScale;
  
  self.isAspectFit = YES;
  if (minScale != 1.0) {
    self.isActualSize = NO;
  }
  else {
    self.isActualSize = YES;
  }
}


- (CGFloat) aspectFitScale {
  CGSize scrollSize = scrollView.bounds.size;
  CGSize imageSize = imageView.image.size;
  
  CGFloat scaleX = scrollSize.width / imageSize.width;
  CGFloat scaleY = scrollSize.height / imageSize.height;
  
  return MIN(scaleX, scaleY);
}


- (void)actualSize {
  scrollView.zoomScale = 1.0;
  self.isActualSize = YES;
  
  CGFloat minScale = [self aspectFitScale];

  if (minScale == 1.0) {
    self.isAspectFit = YES;
  }
  else {
    self.isAspectFit = NO;
  }
}


#pragma mark -
#pragma mark Memory management

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    [self addObserver:self forKeyPath:@"isAspectFit" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"isActualSize" options:0 context:NULL];
  }
  return self;
}


- (void)dealloc {
  [popoverController release];
  [toolbar release];
  [super dealloc];
}


#pragma mark -
#pragma mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if (object == self) {
    if ([keyPath isEqualToString:@"isAspectFit"]) {
      aspectFitButton.enabled = !isAspectFit;
    }
    else if ([keyPath isEqualToString:@"isActualSize"]) {
      actualSizeButton.enabled = !isActualSize;
    }
  }
}


@end
