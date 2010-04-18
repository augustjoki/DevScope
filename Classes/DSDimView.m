//
//  DSDimView.m
//  DevScope
//
//  Created by August Joki on 4/18/10.
//  Copyright 2010 Concinnous Software. All rights reserved.
//

#import "DSDimView.h"
#import <QuartzCore/QuartzCore.h>


@implementation DSDimView

@synthesize originLabel, sizeLabel;

- (void)awakeFromNib {
  self.layer.cornerRadius = 5.0f;
  self.layer.borderColor = [UIColor whiteColor].CGColor;
  self.layer.borderWidth = 1.0f;
  self.layer.shadowOpacity = 0.5f;
  
  self.userInteractionEnabled = NO;
}


@end
