//
//  UIView+NibLoading.h
//  DevScope
//
//  Copyright 2010 Concinous Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UIView (NibLoading)

+ (id)loadFromNib;
+ (id)loadWithNibName:(NSString *)nibName;
+ (id)loadWithNibName:(NSString *)nibName owner:(id)owner;
+ (id)loadWithNibName:(NSString *)nibName owner:(id)owner options:(NSDictionary *)options;

@end
