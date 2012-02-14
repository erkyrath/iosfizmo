//
//  FizmoGlkViewController.m
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/13/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"
#import "GlkFrameView.h"

@implementation FizmoGlkViewController

- (FizmoGlkDelegate *) fizmoDelegate {
	return (FizmoGlkDelegate *)self.glkdelegate;
}

- (void) didFinishLaunching {
	[super didFinishLaunching];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	CGFloat maxwidth = [defaults floatForKey:@"FrameMaxWidth"];
	self.fizmoDelegate.maxwidth = maxwidth;
}

- (IBAction) pageDisplayChanged {
	NSLog(@"### page changed");
}

- (IBAction) showPreferences {
	NSLog(@"### preferences");
	CGFloat maxwidth = self.fizmoDelegate.maxwidth;
	if (maxwidth > 0)
		maxwidth = 0;
	else
		maxwidth = 600;
	
	self.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:maxwidth forKey:@"FrameMaxWidth"];
	
	[self.frameview setNeedsLayoutPlusSubviews];
}

@end
