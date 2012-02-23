//
//  FizmoGlkWindows.m
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/22/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import "FizmoGlkWindows.h"
#import "StyledTextView.h"
#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"

@implementation FizmoGlkWinBufferView

- (id) initWithWindow:(GlkWindow *)winref frame:(CGRect)box {
	self = [super initWithWindow:winref frame:box];
	if (self) {
		FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
		int val = glkviewc.fizmoDelegate.colorscheme;
		self.textview.indicatorStyle = (val==2 ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
	}
	return self;
}

- (void) uncacheLayoutAndStyles {
	[super uncacheLayoutAndStyles];

	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	int val = glkviewc.fizmoDelegate.colorscheme;
	self.textview.indicatorStyle = (val==2 ? UIScrollViewIndicatorStyleWhite : UIScrollViewIndicatorStyleDefault);
}

@end
