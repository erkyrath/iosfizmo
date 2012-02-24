//
//  DisplayTextViewController.m
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/23/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import "DisplayTextViewController.h"
#import "GlkFileTypes.h"

@implementation DisplayTextViewController

@synthesize textview;
@synthesize thumb;

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumbref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.thumb = thumbref;
	}
	return self;
}

- (void) dealloc {
	self.thumb = nil;
	self.textview = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = @"Transcript"; //### localize

	NSString *str = [NSString stringWithContentsOfFile:thumb.pathname encoding:NSUTF8StringEncoding error:nil];
	if (str)
		textview.text = str;
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
