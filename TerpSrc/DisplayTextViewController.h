//
//  DisplayTextViewController.h
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/23/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MFMailComposeViewController.h>

@class GlkFileThumb;

@interface DisplayTextViewController : UIViewController <MFMailComposeViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UITextView *textview;
@property (nonatomic, retain) IBOutlet UILabel *titlelabel;
@property (nonatomic, retain) IBOutlet UILabel *datelabel;
@property (nonatomic, retain) GlkFileThumb *thumb;

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumb bundle:(NSBundle *)nibBundle;

@end
