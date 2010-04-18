//
//  UIView+NibLoading.m
//  DevScope
//
//  Copyright 2010 Concinous Software. All rights reserved.
//

#import "UIView+NibLoading.h"


@implementation UIView (NibLoading)

+ (id)loadFromNib {
  return [self loadWithNibName:NSStringFromClass(self) owner:nil options:nil];
}


+ (id)loadWithNibName:(NSString *)nibName {
  return [self loadWithNibName:nibName owner:nil options:nil];
}


+ (id)loadWithNibName:(NSString *)nibName owner:(id)owner {
  return [self loadWithNibName:nibName owner:owner options:nil];
}


+ (id)loadWithNibName:(NSString *)nibName owner:(id)owner options:(NSDictionary *)options {
  NSArray *array = [[NSBundle mainBundle] loadNibNamed:nibName owner:owner options:options];
  for (id obj in array) {
    if ([obj isKindOfClass:self]) {
      return obj;
    }
  }
  return nil;
}

@end
