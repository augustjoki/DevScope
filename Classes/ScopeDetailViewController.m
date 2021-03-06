//
//  DetailViewController.m
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright Concinnous Software 2010. All rights reserved.
//

#import "ScopeDetailViewController.h"

#import "DSBorderDragGestureRecognizer.h"
#import "UIView+NibLoading.h"
#import "DSDimView.h"

@interface ScopeDetailViewController ()

@property (nonatomic, retain) UIPopoverController *popoverController;
@property (nonatomic, assign) BOOL isAspectFit, isActualSize;
@property (nonatomic, assign) CAShapeLayer *editingShape;
@property (nonatomic, readonly) DSDimView *dimView;

- (void)recenter;
- (void)aspectFit;
- (void)aspectFitAnimated:(BOOL)animated;
- (void)actualSize;
- (void)actualSizeAnimated:(BOOL)animated;
- (CGFloat)aspectFitScale;
- (void)doubleTap:(UITapGestureRecognizer *)recognizer;
- (void)twoFingerTap:(UITapGestureRecognizer *)recognizer;
- (CGRect)zoomRectWithScale:(float)scale withCenter:(CGPoint)center;
- (void)longPress:(UILongPressGestureRecognizer *)recognizer;
- (void)border:(DSBorderDragGestureRecognizer *)recognizer;
- (void)pan:(UIPanGestureRecognizer *)recognizer;
- (void)pinch:(UIPinchGestureRecognizer *)recognizer;
- (void)tap:(UITapGestureRecognizer *)recognizer;

@end



@implementation ScopeDetailViewController

@synthesize toolbar, popoverController;
@synthesize isAspectFit, isActualSize, editingShape;
@synthesize rects;



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
  if (editingShape == nil) {
    return containerView;
  }
  else {
    return nil;
  }
}


- (void)scrollViewDidZoom:(UIScrollView *)inScrollView {
  [self recenter];
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
  CGRect frame = containerView.frame;
  frame.origin = CGPointZero;
  containerView.frame = frame;
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
  
  CGRect frame = containerView.frame;
  frame.origin = CGPointZero;
  frame.size = exampleImage.size;
  containerView.frame = frame;
  containerView.layer.shadowOpacity = 0.5f;
  containerView.layer.shadowRadius = 10.0f;
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, imageView.bounds);
  containerView.layer.shadowPath = path;
  CGPathRelease(path);
  
  scrollView.contentSize = exampleImage.size;
  
  [self aspectFitAnimated:NO];
  
  UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTap:)];
  tapGesture.numberOfTapsRequired = 2;
  [scrollView addGestureRecognizer:tapGesture];
  [tapGesture release];
  
  tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(twoFingerTap:)];
  tapGesture.numberOfTouchesRequired = 2;
  [scrollView addGestureRecognizer:tapGesture];
  [tapGesture release];
  
  shapes = [[NSMutableArray alloc] init];
  rects = [[NSMutableArray alloc] init];
  
  UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
  [containerView addGestureRecognizer:longPressGesture];
  [longPressGesture release];
  
  tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
  [containerView addGestureRecognizer:tapGesture];
  [tapGesture release];
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  
  CAShapeLayer *shape = [[CAShapeLayer alloc] init];
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, imageView.bounds);
  shape.path = path;
  CGPathRelease(path);
  shape.fillColor = [UIColor colorWithRed:51.0f/255.0f green:52.0f/255.0f blue:255.0f/255.0f alpha:0.5f].CGColor;
  shape.lineWidth = 3.0f;
  shape.strokeColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
  [containerView.layer addSublayer:shape];
  [shapes addObject:shape];
  [shape release];
  [rects addObject:[NSValue valueWithCGRect:imageView.bounds]];
  
  self.editingShape = shape;
}

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
  [shapes release];
  shapes = nil;
}


#pragma mark -
#pragma mark IBAction

- (void)aspectFitButtonPressed:(id)sender {
  [self aspectFit];
}


- (void)actualSizeButtonPressed:(id)sender {
  [self actualSize];
}


- (void)addButtonPressed:(id)sender {
  if (editingShape != nil) {
    self.editingShape = nil;
  }
  static CGFloat size = 120.0f;
  CGRect frame = CGRectMake(floorf((containerView.bounds.size.width - size) / 2.0f),
                            floorf((containerView.bounds.size.height - size) / 2.0f),
                            120.0f, 120.0f);
  
  CAShapeLayer *shape = [[CAShapeLayer alloc] init];
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  shape.path = path;
  CGPathRelease(path);
  shape.fillColor = [UIColor colorWithRed:(arc4random() % 256)/255.0f green:(arc4random() % 256)/255.0f blue:(arc4random() % 256)/255.0f alpha:0.5f].CGColor;
  shape.lineWidth = 3.0f;
  shape.strokeColor = [UIColor colorWithWhite:0.0f alpha:0.5f].CGColor;
  [containerView.layer addSublayer:shape];
  [shapes addObject:shape];
  [shape release];
  [rects addObject:[NSValue valueWithCGRect:frame]];
  
  self.editingShape = shape;
}


#pragma mark -
#pragma mark Gestures

- (void)doubleTap:(UITapGestureRecognizer *)recognizer {
  if (scrollView.zoomScale == scrollView.maximumZoomScale) {
    return;
  }
  CGPoint center = [recognizer locationInView:containerView];
  CGRect zoomRect = [self zoomRectWithScale:scrollView.zoomScale * 2.0f withCenter:center];
  [scrollView zoomToRect:zoomRect animated:YES];
}


- (void)twoFingerTap:(UITapGestureRecognizer *)recognizer {
  if (scrollView.zoomScale == scrollView.minimumZoomScale) {
    return;
  }
  CGPoint center = [recognizer locationInView:containerView];
  CGRect zoomRect = [self zoomRectWithScale:scrollView.zoomScale / 2.0f withCenter:center];
  [scrollView zoomToRect:zoomRect animated:YES];
}


- (void)longPress:(UILongPressGestureRecognizer *)recognizer {
  if (editingShape != nil) {
    CGPoint editingPoint = [recognizer locationInView:gestureView];
    if (![gestureView pointInside:editingPoint withEvent:nil]) {
      return;
    }
  }
  if (recognizer.state == UIGestureRecognizerStateCancelled) {
    recognizingEdit = NO;
    if (editingShape != nil) {
      self.editingShape = nil;
    }
  }
  else if (recognizer.state == UIGestureRecognizerStateEnded) {
    if (!recognizingEdit) {
      return;
    }
    recognizingEdit = NO;
    if (editingShape == nil) {
      self.editingShape = animatingShape;
    }
    else {
      self.editingShape = nil;
    }
  }
  else if (recognizer.state == UIGestureRecognizerStateBegan) {
    recognizingEdit = YES;
    CGPoint point = [recognizer locationInView:containerView];
    CGRect rect;
    if (editingShape == nil) {
      for (NSInteger ii = rects.count - 1; ii >= 0; ii--) {
        rect = [(NSValue *)[rects objectAtIndex:ii] CGRectValue];
        if (CGRectContainsPoint(rect, point)) {
          animatingShape = [shapes objectAtIndex:ii];
          break;
        }
      }
    }
    else {
      animatingShape = editingShape;
    }
    if (animatingShape != nil) {
      CAKeyframeAnimation *transform = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
      transform.values = [NSArray arrayWithObjects:
                          [NSValue valueWithCATransform3D:CATransform3DIdentity],
                          [NSValue valueWithCATransform3D:
                           CATransform3DMakeScale(1.01f, 1.01f, 1.0f)],
                          [NSValue valueWithCATransform3D:
                           CATransform3DMakeScale(0.99f, 0.99f, 1.0f)],
                          [NSValue valueWithCATransform3D:CATransform3DIdentity],
                          nil];
      transform.timingFunctions = [NSArray arrayWithObjects:
                                   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                   [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                   nil];
      
      CAKeyframeAnimation *position = [CAKeyframeAnimation animationWithKeyPath:@"position"];
      CGRect transformRect;
      CGPoint point;
      CGPoint originalPosition = animatingShape.position;
      NSMutableArray *positions = [NSMutableArray array];
      [positions addObject:[NSValue valueWithCGPoint:originalPosition]];
      
      transformRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1.01f, 1.01f));
      point = CGPointMake(floorf(originalPosition.x + (rect.size.width - transformRect.size.width) / 2.0f),
                          floorf(originalPosition.y + (rect.size.height - transformRect.size.height) / 2.0f));
      [positions addObject:[NSValue valueWithCGPoint:point]];
      
      transformRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(0.99f, 0.99f));
      point = CGPointMake(floorf(originalPosition.x + (rect.size.width - transformRect.size.width) / 2.0f),
                          floorf(originalPosition.y + (rect.size.height - transformRect.size.height) / 2.0f));
      [positions addObject:[NSValue valueWithCGPoint:point]];
      
      [positions addObject:[NSValue valueWithCGPoint:originalPosition]];
      
      position.values = positions;
      position.timingFunctions = transform.timingFunctions;
      
      CAAnimationGroup *group = [CAAnimationGroup animation];
      group.animations = [NSArray arrayWithObjects:transform,
                          //position,
                          nil];
      
      [animatingShape addAnimation:group forKey:nil];
      
      /*
      CAKeyframeAnimation *pathAnimation = [CAKeyframeAnimation animationWithKeyPath:@"path"];
      pathAnimation.timingFunctions = [NSArray arrayWithObjects:
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear],
                                       [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn],
                                       nil];
      
      CFMutableArrayRef array = CFArrayCreateMutable(NULL, 4, NULL);
      
      CFArrayAppendValue(array, animatingShape.path);
      
      CGRect rect = [(NSValue *)[rects objectAtIndex:[shapes indexOfObject:animatingShape]] CGRectValue];
      CGRect transformRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1.01f, 1.01f));
      transformRect.origin.x += floorf((rect.size.width - transformRect.size.width) / 2.0f);
      transformRect.origin.y += floorf((rect.size.height - transformRect.size.height) / 2.0f);
      CGMutablePathRef path = CGPathCreateMutable();
      CGPathAddRect(path, NULL, transformRect);
      CFArrayAppendValue(array, path);
      CGPathRelease(path);
      
      transformRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(0.99f, 0.99f));
      transformRect.origin.x += floorf((rect.size.width - transformRect.size.width) / 2.0f);
      transformRect.origin.y += floorf((rect.size.height - transformRect.size.height) / 2.0f);
      path = CGPathCreateMutable();
      CGPathAddRect(path, NULL, transformRect);
      CFArrayAppendValue(array, path);
      CGPathRelease(path);
      
      CFArrayAppendValue(array, animatingShape.path);
      
      pathAnimation.values = (NSArray *)array;
      CFRelease(array);
      
      [animatingShape addAnimation:pathAnimation forKey:nil];
      */
      /*
      CGRect rect = [(NSValue *)[rects objectAtIndex:[shapes indexOfObject:animatingShape]] CGRectValue];
      CGRect transformRect = CGRectApplyAffineTransform(rect, CGAffineTransformMakeScale(1.01f, 1.01f));
      transformRect.origin.x += floorf((rect.size.width - transformRect.size.width) / 2.0f);
      transformRect.origin.y += floorf((rect.size.height - transformRect.size.height) / 2.0f);
      CGMutablePathRef path = CGPathCreateMutable();
      CGPathAddRect(path, NULL, transformRect);
      animatingShape.path = path;
      CGPathRelease(path);
      */
    }
  }
}


- (void)border:(DSBorderDragGestureRecognizer *)recognizer {
  DSBorderDragGestureRecognizerLocation location = recognizer.location;
  
  CGPoint point = [recognizer locationInView:containerView];
  CGRect frame = gestureView.frame;
  switch (location) {
    case DSBorderDragGestureRecognizerLocationTopLeft:
      frame.size.width = floorf(frame.size.width - (point.x - frame.origin.x));
      frame.size.height = floorf(frame.size.height - (point.y - frame.origin.y));
      frame.origin.x = floorf(point.x);
      frame.origin.y = floorf(point.y);
      break;
    case DSBorderDragGestureRecognizerLocationTop:
      frame.size.height = floorf(frame.size.height - (point.y - frame.origin.y));
      frame.origin.y = floorf(point.y);
      break;
    case DSBorderDragGestureRecognizerLocationTopRight:
      frame.size.width = floorf(point.x - frame.origin.x);
      frame.size.height = floorf(frame.size.height - (point.y - frame.origin.y));
      frame.origin.y = floorf(point.y);
      break;
    case DSBorderDragGestureRecognizerLocationLeft:
      frame.size.width = floorf(frame.size.width - (point.x - frame.origin.x));
      frame.origin.x = floorf(point.x);
      break;
    case DSBorderDragGestureRecognizerLocationRight:
      frame.size.width = floorf(point.x - frame.origin.x);
      break;
    case DSBorderDragGestureRecognizerLocationBottomLeft:
      frame.size.width = floorf(frame.size.width - (point.x - frame.origin.x));
      frame.size.height = floorf(point.y - frame.origin.y);
      frame.origin.x = floorf(point.x);
      break;
    case DSBorderDragGestureRecognizerLocationBottom:
      frame.size.height = floorf(point.y - frame.origin.y);
      break;
    case DSBorderDragGestureRecognizerLocationBottomRight:
      frame.size.width = floorf(point.x - frame.origin.x);
      frame.size.height = floorf(point.y - frame.origin.y);
    default:
      break;
  }
  
  gestureView.frame = frame;
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  editingShape.path = path;
  CGPathRelease(path);
  
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    NSValue *value = [NSValue valueWithCGRect:frame];
    [rects replaceObjectAtIndex:[shapes indexOfObject:editingShape] withObject:value];
  }
}


- (void)pan:(UIPanGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    gestureFrame = gestureView.frame;
  }
  
  CGPoint translation = [recognizer translationInView:containerView];
  CGRect frame = gestureFrame;
  frame.origin.x = floorf(frame.origin.x + translation.x);
  frame.origin.y = floorf(frame.origin.y + translation.y);
  gestureView.frame = frame;
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  editingShape.path = path;
  CGPathRelease(path);
  
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    NSValue *value = [NSValue valueWithCGRect:frame];
    [rects replaceObjectAtIndex:[shapes indexOfObject:editingShape] withObject:value];
  }
}


- (void)pinch:(UIPinchGestureRecognizer *)recognizer {
  if (recognizer.state == UIGestureRecognizerStateBegan) {
    gestureFrame = gestureView.frame;
  }
  CGPoint location = [recognizer locationInView:containerView];
  CGFloat scale = recognizer.scale;
  
  CGRect frame = gestureFrame;
  CGFloat ratioX = (location.x - frame.origin.x) / frame.size.width;
  CGFloat ratioY = (location.y - frame.origin.y) / frame.size.height;
  
  frame.size = CGSizeApplyAffineTransform(frame.size,
                                          CGAffineTransformMakeScale(scale, scale));
  
  frame.origin.x = floorf(location.x - frame.size.width * ratioX);
  frame.origin.y = floorf(location.y - frame.size.height * ratioY);
  
  gestureView.frame = frame;
  
  CGMutablePathRef path = CGPathCreateMutable();
  CGPathAddRect(path, NULL, frame);
  editingShape.path = path;
  CGPathRelease(path);
  
  if (recognizer.state == UIGestureRecognizerStateEnded) {
    NSValue *value = [NSValue valueWithCGRect:frame];
    [rects replaceObjectAtIndex:[shapes indexOfObject:editingShape] withObject:value];
  }
}


- (void)tap:(UITapGestureRecognizer *)recognizer {
  CGPoint point = [recognizer locationInView:containerView];
  CGRect rect;
  CAShapeLayer *shape = nil;
  for (NSInteger ii = rects.count - 1; ii >= 0; ii--) {
    rect = [(NSValue *)[rects objectAtIndex:ii] CGRectValue];
    if (CGRectContainsPoint(rect, point)) {
      shape = [shapes objectAtIndex:ii];
      break;
    }
  }
  [dimView removeFromSuperview];
  if (shape != nil) {
    DSDimView *dim = self.dimView;
    dim.originLabel.text = [NSString stringWithFormat:@"x: %.3f y: %.3f", rect.origin.x, rect.origin.y];
    dim.sizeLabel.text = [NSString stringWithFormat:@"w: %.3f h: %.3f", rect.size.width, rect.size.height];
    
    dim.center = point;
    [containerView addSubview:dim];
  }
}


#pragma mark -
#pragma mark Private


- (void) recenter {
  CGSize imageSize = containerView.frame.size;
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
  [self aspectFitAnimated:YES];
}


- (void)aspectFitAnimated:(BOOL)animated {
  CGFloat minScale = [self aspectFitScale];
  [scrollView setZoomScale:minScale animated:animated];
  
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
  [self actualSizeAnimated:YES];
}


- (void)actualSizeAnimated:(BOOL)animated {
  [scrollView setZoomScale:1.0f animated:animated];
  self.isActualSize = YES;
  
  CGFloat minScale = [self aspectFitScale];

  if (minScale == 1.0) {
    self.isAspectFit = YES;
  }
  else {
    self.isAspectFit = NO;
  }
}


- (CGRect)zoomRectWithScale:(float)scale withCenter:(CGPoint)center {
  
  CGRect zoomRect;
  
  // The zoom rect is in the content view's coordinates.
  // At a zoom scale of 1.0, it would be the size of the
  // imageScrollView's bounds.
  // As the zoom scale decreases, so more content is visible,
  // the size of the rect grows.
  zoomRect.size.height = scrollView.frame.size.height / scale;
  zoomRect.size.width  = scrollView.frame.size.width  / scale;
  
  // choose an origin so as to get the right center.
  zoomRect.origin.x = center.x - (zoomRect.size.width  / 2.0);
  zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0);
  
  return zoomRect;
}


- (DSDimView *)dimView {
  if (dimView == nil) {
    dimView = [[DSDimView loadFromNib] retain];
  }
  return dimView;
}


#pragma mark -
#pragma mark Memory management

- (id)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self != nil) {
    [self addObserver:self forKeyPath:@"isAspectFit" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"isActualSize" options:0 context:NULL];
    [self addObserver:self forKeyPath:@"editingShape" options:NSKeyValueObservingOptionOld context:NULL];
  }
  return self;
}


- (void)dealloc {
  [self removeObserver:self forKeyPath:@"isAspectFit"];
  [self removeObserver:self forKeyPath:@"isActualSize"];
  [self removeObserver:self forKeyPath:@"editingShape"];
  [popoverController release];
  [toolbar release];
  [shapes release];
  [rects release];
  [gestureView release];
  [dimView release];
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
    else if ([keyPath isEqualToString:@"editingShape"]) {
      if (editingShape == nil) {
        scrollView.scrollEnabled = YES;
        if (!isAspectFit) {
          aspectFitButton.enabled = YES;
        }
        if (!isActualSize) {
          actualSizeButton.enabled = YES;
        }
        
        CAShapeLayer *oldShape = [change objectForKey:NSKeyValueChangeOldKey];
        oldShape.lineDashPattern = nil;
        
        [gestureView removeFromSuperview];
      }
      else {
        scrollView.scrollEnabled = NO;
        aspectFitButton.enabled = NO;
        actualSizeButton.enabled = NO;
        
        
        NSArray *pattern = [NSArray arrayWithObjects:[NSNumber numberWithInt:5],
                            [NSNumber numberWithInt:5],
                            nil];
        editingShape.lineDashPattern = pattern;
        
        if (gestureView == nil) {
          gestureView = [[UIView alloc] initWithFrame:CGRectZero];
          gestureView.backgroundColor = [UIColor clearColor];
          
          DSBorderDragGestureRecognizer *borderGesture = [[DSBorderDragGestureRecognizer alloc] initWithTarget:self action:@selector(border:)];
          [gestureView addGestureRecognizer:borderGesture];
          [borderGesture release];
          
          UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
          [panGesture requireGestureRecognizerToFail:borderGesture];
          [gestureView addGestureRecognizer:panGesture];
          [panGesture release];
          
          UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinch:)];
          [gestureView addGestureRecognizer:pinchGesture];
          [pinchGesture release];
        }
        
        NSValue *value = [rects objectAtIndex:[shapes indexOfObject:editingShape]];
        gestureView.frame = [value CGRectValue];
        [containerView addSubview:gestureView];
      }
    }
  }
}


@end
