//
//  DSBorderDragGestureRecognizer.m
//  DevScope
//
//  Created by August Joki on 4/18/10.
//  Copyright 2010 Concinnous Software. All rights reserved.
//

#import "DSBorderDragGestureRecognizer.h"


@implementation DSBorderDragGestureRecognizer

@synthesize location;

- (void)reset {
  [super reset];
  
  location = DSBorderDragGestureRecognizerLocationUnknown;
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesBegan:touches withEvent:event];
  
  if (touches.count != 1) {
    self.state = UIGestureRecognizerStateFailed;
    return;
  }
  
  UITouch *touch = [touches anyObject];
  CGPoint point = [touch locationInView:self.view];
  CGFloat buffer = 20.0f;
  short border = 0;
  if (point.x < buffer) {
    border += 1;
  }
  if (point.y < buffer) {
    border += 2;
  }
  if (point.x > self.view.bounds.size.width - buffer) {
    border += 4;
  }
  if (point.y > self.view.bounds.size.height - buffer) {
    border += 8;
  }
  
  switch (border) {
    case 1:
      location = DSBorderDragGestureRecognizerLocationLeft;
      break;
    case 2:
      location = DSBorderDragGestureRecognizerLocationTop;
      break;
    case 3:
      location = DSBorderDragGestureRecognizerLocationTopLeft;
      break;
    case 4:
      location = DSBorderDragGestureRecognizerLocationRight;
      break;
    case 6:
      location = DSBorderDragGestureRecognizerLocationTopRight;
      break;
    case 8:
      location = DSBorderDragGestureRecognizerLocationBottom;
      break;
    case 9:
      location = DSBorderDragGestureRecognizerLocationBottomLeft;
      break;
    case 12:
      location = DSBorderDragGestureRecognizerLocationBottomRight;
      break;
    default:
      location = DSBorderDragGestureRecognizerLocationUnknown;
      break;
  }
  if (location == DSBorderDragGestureRecognizerLocationUnknown) {
    self.state = UIGestureRecognizerStateFailed;
  }
  else {
    self.state = UIGestureRecognizerStateBegan;
  }
}


- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesMoved:touches withEvent:event];
  
  if (self.state == UIGestureRecognizerStateFailed) {
    return;
  }
  
  self.state = UIGestureRecognizerStateChanged;
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesEnded:touches withEvent:event];
  
  if (self.state == UIGestureRecognizerStateFailed) {
    return;
  }
  
  self.state = UIGestureRecognizerStateEnded;
}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
  [super touchesCancelled:touches withEvent:event];
  
  if (self.state == UIGestureRecognizerStateFailed) {
    return;
  }
  
  self.state = UIGestureRecognizerStateCancelled;
}


@end
