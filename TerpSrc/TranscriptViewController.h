//
//  TranscriptViewController.h
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/23/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GlkFileRefPrompt;
@class GlkFileThumb;

@interface TranscriptViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate> {
	UITableView *tableView;
	
	NSMutableArray *filelist; // array of GlkFileThumb
	NSDateFormatter *dateformatter;
}

@property (nonatomic, retain) IBOutlet UITableView *tableView;
@property (nonatomic, retain) NSMutableArray *filelist;
@property (nonatomic, retain) NSDateFormatter *dateformatter;

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle;
- (void) addBlankThumb;

@end
