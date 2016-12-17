/* PrefsMenuView.m: A popmenu subclass that can display the preferences menu
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "PrefsMenuView.h"
#import "FizmoGlkViewController.h"
#import "IosGlkAppDelegate.h"
#import "FizmoGlkDelegate.h"
#import "GlkFrameView.h"
#import "GlkWinBufferView.h"
#import "StyledTextView.h"
#import "MButton.h"

@implementation PrefsMenuView

@synthesize container;
@synthesize fontscontainer;
@synthesize colorscontainer;
@synthesize colorsbutton;
@synthesize fontsbutton;
@synthesize brightslider;
@synthesize colbut_full;
@synthesize colbut_34;
@synthesize colbut_12;
@synthesize sizebut_small;
@synthesize sizebut_big;
@synthesize leadbut_small;
@synthesize leadbut_big;
@synthesize fontbutton;
@synthesize colorbutton;
@synthesize fontbut_sample1;
@synthesize fontbut_sample2;
@synthesize colorbut_bright;
@synthesize colorbut_quiet;
@synthesize colorbut_dark;
@synthesize supportsbrightness;
@synthesize fontnames;
@synthesize fontbuttons;

- (void) dealloc {
	self.container = nil;
	self.fontscontainer = nil;
	self.colorscontainer = nil;
	self.colorsbutton = nil;
	self.fontsbutton = nil;
	self.brightslider = nil;
	self.colbut_full = nil;
	self.colbut_34 = nil;
	self.colbut_12 = nil;
	self.sizebut_small = nil;
	self.sizebut_big = nil;
	self.leadbut_small = nil;
	self.leadbut_big = nil;
	self.fontbutton = nil;
	self.colorbutton = nil;
	self.fontbut_sample1 = nil;
	self.fontbut_sample2 = nil;
	self.colorbut_bright = nil;
	self.colorbut_quiet = nil;
	self.colorbut_dark = nil;
	
	self.fontnames = nil;
	self.fontbuttons = nil;
	
	[super dealloc];
}

- (void) loadContent {
	NSString *reqSysVer = @"5.0";
	NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
	supportsbrightness = ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending);
	
	[[NSBundle mainBundle] loadNibNamed:@"PrefsMenuView" owner:self options:nil];
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];

	UIImage *checkimage = [UIImage imageNamed:@"checkmark"];
	[colorbut_bright setSelectImage:checkimage];
	[colorbut_quiet setSelectImage:checkimage];
	[colorbut_dark setSelectImage:checkimage];
	
	checkimage = [UIImage imageNamed:@"checkmark-s"];
	[colbut_full setSelectImage:checkimage];
	[colbut_34 setSelectImage:checkimage];
	[colbut_12 setSelectImage:checkimage];
	 
	if (faderview) {
		faderview.alpha = ((glkviewc.glkdelegate.hasDarkTheme) ? 1.0 : 0.0);
		faderview.hidden = NO;
	}
	
	if (!supportsbrightness) {
		/* Shrink the container box to exclude the brightness slider. */
		CGFloat val = CGRectGetMaxY(colorsbutton.frame);
		CGRect rect = container.frame;
		rect.size.height = val - rect.origin.y;
		container.frame = rect;
	}
	
	[self updateButtons];
	[self resizeContentTo:container.frame.size animated:YES];
	[content addSubview:container];
}

- (void) updateButtons {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	CGFloat maxwidth = glkviewc.fizmoDelegate.maxwidth;
	colbut_full.selected = (maxwidth == 0);
	colbut_34.selected = (maxwidth == 1);
	colbut_12.selected = (maxwidth == 2);
	
	int colorscheme = glkviewc.fizmoDelegate.colorscheme;
	colorbut_bright.selected = (colorbut_bright.tag == colorscheme);
	colorbut_quiet.selected = (colorbut_quiet.tag == colorscheme);
	colorbut_dark.selected = (colorbut_dark.tag == colorscheme);

	if (fontnames) {
		NSString *family = glkviewc.fizmoDelegate.fontfamily;
		for (int count = 0; count < fontnames.count; count++) {
			NSString *str = [fontnames objectAtIndex:count];
			UIButton *button = [fontbuttons objectAtIndex:count];
			button.selected = [family isEqualToString:str];
		}
	}
	
	if (supportsbrightness) {
		brightslider.value = [UIScreen mainScreen].brightness;
	}
	else {
		brightslider.hidden = YES;
	}
}

- (IBAction) handleColumnWidth:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	int maxwidth;
	
	if (sender == colbut_34) {
		maxwidth = 1;
	} 
	else if (sender == colbut_12) {
		maxwidth = 2;
	}
	else {
		maxwidth = 0;
	}
	
	glkviewc.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:maxwidth forKey:@"FrameMaxWidth"];
	
	[self updateButtons];
	[glkviewc.frameview setNeedsLayout];
}

- (IBAction) handleFontSize:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	int fontscale = glkviewc.fizmoDelegate.fontscale;
	
	if (sender == sizebut_small) {
		fontscale -= 1;
	} 
	else if (sender == sizebut_big) {
		fontscale += 1;
	}
	fontscale = MAX(fontscale, 1);
	fontscale = MIN(fontscale, FONTSCALE_MAX);

	if (fontscale == glkviewc.fizmoDelegate.fontscale)
		return;
	
	glkviewc.fizmoDelegate.fontscale = fontscale;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:fontscale forKey:@"FontScale"];
	
	[glkviewc.frameview updateWindowStyles];
}

- (IBAction) handleFontLeading:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	int leading = glkviewc.fizmoDelegate.leading;
	
	if (sender == leadbut_small) {
		leading -= 1;
	} 
	else if (sender == leadbut_big) {
		leading += 1;
	}
	leading = MAX(leading, 0);
	leading = MIN(leading, LEADING_MAX);
	
	if (leading == glkviewc.fizmoDelegate.leading)
		return;
	
	glkviewc.fizmoDelegate.leading = leading;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:leading forKey:@"FontLeading"];
	
	[glkviewc.frameview updateWindowStyles];
}

- (IBAction) handleColor:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	int val = ((UIView *)sender).tag;
	
	glkviewc.fizmoDelegate.colorscheme = val;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setInteger:val forKey:@"ColorScheme"];
	
	BOOL isdark = glkviewc.fizmoDelegate.hasDarkTheme;
	
	[self updateButtons];
	glkviewc.navigationController.navigationBar.barStyle = (isdark ? UIBarStyleBlack : UIBarStyleDefault);
	glkviewc.frameview.backgroundColor = glkviewc.fizmoDelegate.genBackgroundColor;
	[glkviewc.frameview updateWindowStyles];
	
	if (faderview) {
		if ([IosGlkAppDelegate animblocksavailable]) {
			[UIView animateWithDuration:0.15 
				animations:^{ faderview.alpha = (isdark ? 1.0 : 0.0); } ];
		}
		else {
			faderview.alpha = (isdark ? 1.0 : 0.0);
		}
	}
}

- (IBAction) handleFont:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	int val = ((UIView *)sender).tag;
	if (!fontnames || val < 0 || val >= fontnames.count)
		return;
	NSString *name = [fontnames objectAtIndex:val];
	
	glkviewc.fizmoDelegate.fontfamily = name;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setObject:name forKey:@"FontFamily"];
	
	[self updateButtons];
	[glkviewc.frameview updateWindowStyles];
}

- (void) setUpFontMenu {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	NSMutableArray *arr = [NSMutableArray arrayWithObjects:@"Times", @"Helvetica", @"Georgia", nil];
	/*if ([UIFont fontWithName:@"Palatino" size:14])
		[arr addObject:@"Palatino"];*/
	if ([UIFont fontWithName:@"Baskerville" size:14])
		[arr addObject:@"Baskerville"];
	if ([UIFont fontWithName:@"HoeflerText-Regular" size:14])
		[arr addObject:@"Hoefler Text"];
	if ([UIFont fontWithName:@"EuphemiaUCAS" size:14])
		[arr addObject:@"Euphemia"];
	else
		[arr addObject:@"Verdana"];
	self.fontnames = arr;
	
	CGRect baserect = fontbut_sample1.frame;
	CGFloat buttonspacing = fontbut_sample2.frame.origin.y - fontbut_sample1.frame.origin.y;
	CGFloat postbuttonspacing = fontscontainer.frame.size.height - fontbut_sample2.frame.origin.y;
	[fontbut_sample1 removeFromSuperview];
	[fontbut_sample2 removeFromSuperview];
	
	arr = [NSMutableArray arrayWithCapacity:fontnames.count];
	self.fontbuttons = arr;
	
	UIColor *normalcolor = [fontbut_sample1 titleColorForState:UIControlStateNormal];
	UIColor *selectedcolor = [fontbut_sample1 titleColorForState:UIControlStateSelected];
	UIColor *highlightedcolor = [fontbut_sample1 titleColorForState:UIControlStateHighlighted];
	
	UIImage *normalbackimg = [fontbut_sample1 backgroundImageForState:UIControlStateNormal];
	UIImage *highlightedbackimg = [fontbut_sample1 backgroundImageForState:UIControlStateHighlighted];
	
	CGFloat fontsize = fontbut_sample1.titleLabel.font.pointSize;
	UIImage *checkimage = [UIImage imageNamed:@"checkmark"];
	
	int count = 0;
	for (NSString *name in fontnames) {
		MButton *button = [MButton buttonWithType:fontbut_sample1.buttonType];
		[button setTitle:name forState:UIControlStateNormal];
		button.tag = count;
		CGRect rect = baserect;
		rect.origin.y += count*buttonspacing;
		button.frame = rect;
		[button setSelectImage:checkimage];
		button.titleLabel.font = [glkviewc.fizmoDelegate fontVariantsForSize:fontsize label:name].normal;
		button.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
		[button setTitleColor:normalcolor forState:UIControlStateNormal];
		[button setTitleColor:selectedcolor forState:UIControlStateSelected];
		[button setTitleColor:highlightedcolor forState:UIControlStateHighlighted];
		[button setBackgroundImage:normalbackimg forState:UIControlStateNormal];
		[button setBackgroundImage:highlightedbackimg forState:UIControlStateHighlighted];
		[button setBackgroundImage:highlightedbackimg forState:UIControlStateHighlighted|UIControlStateSelected];
		[button addTarget:self action:@selector(handleFont:) forControlEvents:UIControlEventTouchUpInside];
		[fontscontainer addSubview:button];
		[arr addObject:button];
		count++;
	}
	
	CGRect rect = fontscontainer.frame;
	rect.size.height = (count-1)*buttonspacing+postbuttonspacing;
	fontscontainer.frame = rect;
}

- (IBAction) handleFonts:(id)sender {
	if (!fontnames) {
		[self setUpFontMenu];
		[self updateButtons];
	}
	
	CGFloat curheight = content.frame.size.height;
	[self resizeContentTo:fontscontainer.frame.size animated:YES];
	
	if ([IosGlkAppDelegate animblocksavailable]) {
		CGRect oldrect = container.frame;
		CGRect rect = fontscontainer.frame;
		fontscontainer.frame = CGRectMake(rect.origin.x, rect.origin.y+curheight, rect.size.width, rect.size.height);
		[content addSubview:fontscontainer];
		[UIView animateWithDuration:0.35 
						 animations:^{ 
							 fontscontainer.frame = rect;
							 container.alpha = 0;
							 container.frame = CGRectMake(oldrect.origin.x, oldrect.origin.y-oldrect.size.height, oldrect.size.width, oldrect.size.height); }
						 completion: ^(BOOL finished){ [container removeFromSuperview]; } ];
	}
	else {
		[content addSubview:fontscontainer];
		container.hidden = YES;
	}
}

- (IBAction) handleColors:(id)sender {
	CGFloat curheight = content.frame.size.height;
	[self resizeContentTo:colorscontainer.frame.size animated:YES];
	
	if ([IosGlkAppDelegate animblocksavailable]) {
		CGRect oldrect = container.frame;
		CGRect rect = colorscontainer.frame;
		colorscontainer.frame = CGRectMake(rect.origin.x, rect.origin.y+curheight, rect.size.width, rect.size.height);
		[content addSubview:colorscontainer];
		[UIView animateWithDuration:0.35 
						animations:^{ 
							colorscontainer.frame = rect;
							container.alpha = 0;
							container.frame = CGRectMake(oldrect.origin.x, oldrect.origin.y-oldrect.size.height, oldrect.size.width, oldrect.size.height); } 
						 completion: ^(BOOL finished){ [container removeFromSuperview]; } ];
	}
	else {
		[content addSubview:colorscontainer];
		container.hidden = YES;
	}
}

- (IBAction) handleBrightChanged:(id)sender {
	if (supportsbrightness) {
		[UIScreen mainScreen].brightness = brightslider.value;
	}
}

@end

@implementation PrefsContainerView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
