//
//  DSDimView.h
//  DevScope
//
//  Created by August Joki on 4/18/10.
//  Copyright 2010 Concinnous Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DSDimView : UIView {
  IBOutlet UILabel *originLabel;
  IBOutlet UILabel *sizeLabel;
}

@property(nonatomic, readonly) UILabel *originLabel, *sizeLabel;

@end
