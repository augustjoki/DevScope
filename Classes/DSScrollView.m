//
//  DSScrollView.m
//  DevScope
//
//  Created by August Joki on 4/17/10.
//  Copyright 2010 Concinnous Software. All rights reserved.
//

#import "DSScrollView.h"


@implementation DSScrollView

- (void)layoutSubviews {
  [super layoutSubviews];
  
  CGSize imageSize = imageView.frame.size;
  UIEdgeInsets imageInsets = (self.zoomScale < 1.0f) ? UIEdgeInsetsMake((self.bounds.size.height - imageSize.height) / 2.0f,
                                                                        (self.bounds.size.width - imageSize.width) / 2.0f,
                                                                        0.0f, 0.0f) : UIEdgeInsetsZero;
  if (imageInsets.top < 0.0f) {
    imageInsets.top = 0.0f;
  }
  if (imageInsets.left < 0.0f) {
    imageInsets.left = 0.0f;
  }
  
  self.contentInset = imageInsets;
}

@end
