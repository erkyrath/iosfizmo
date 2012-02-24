//
//  DisplayTextViewController.h
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/23/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GlkFileThumb;

@interface DisplayTextViewController : UIViewController

@property (nonatomic, retain) IBOutlet UITextView *textview;
@property (nonatomic, retain) GlkFileThumb *thumb;

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumb bundle:(NSBundle *)nibBundle;

@end
