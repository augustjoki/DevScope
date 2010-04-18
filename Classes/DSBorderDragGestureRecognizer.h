//
//  DSBorderDragGestureRecognizer.h
//  DevScope
//
//  Created by August Joki on 4/18/10.
//  Copyright 2010 Concinnous Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

typedef enum {
  DSBorderDragGestureRecognizerLocationTopLeft,
  DSBorderDragGestureRecognizerLocationTop,
  DSBorderDragGestureRecognizerLocationTopRight,
  DSBorderDragGestureRecognizerLocationLeft,
  DSBorderDragGestureRecognizerLocationRight,
  DSBorderDragGestureRecognizerLocationBottomLeft,
  DSBorderDragGestureRecognizerLocationBottom,
  DSBorderDragGestureRecognizerLocationBottomRight,
  DSBorderDragGestureRecognizerLocationUnknown
} DSBorderDragGestureRecognizerLocation;

@interface DSBorderDragGestureRecognizer : UIGestureRecognizer {
  DSBorderDragGestureRecognizerLocation location;
}

@property(nonatomic, readonly) DSBorderDragGestureRecognizerLocation location;

@end
