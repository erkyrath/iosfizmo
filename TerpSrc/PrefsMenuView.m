/* PrefsMenuView.m: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "PrefsMenuView.h"
#import "FizmoGlkViewController.h"
#import "FizmoGlkDelegate.h"
#import "GlkFrameView.h"

@implementation PrefsMenuView

@synthesize container;
@synthesize colbut_full;
@synthesize colbut_34;
@synthesize colbut_12;
@synthesize sizebut_small;
@synthesize sizebut_big;
@synthesize fontbutton;
@synthesize colorbutton;

- (void) dealloc {
	self.container = nil;
	self.colbut_full = nil;
	self.colbut_34 = nil;
	self.colbut_12 = nil;
	self.sizebut_small = nil;
	self.sizebut_big = nil;
	self.fontbutton = nil;
	self.colorbutton = nil;
	
	[super dealloc];
}

- (void) loadContent {
	[[NSBundle mainBundle] loadNibNamed:@"PrefsMenuView" owner:self options:nil];
	[self updateButtons];
	[self resizeContentTo:container.frame.size animated:YES];
	[content addSubview:container];
}

- (void) updateButtons {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	CGFloat maxwidth = glkviewc.fizmoDelegate.maxwidth;
	
	colbut_full.selected = (maxwidth == 0);
	colbut_34.selected = (maxwidth == 624);
	colbut_12.selected = (maxwidth == 512);
}

- (IBAction) handleColumnWidth:(id)sender {
	FizmoGlkViewController *glkviewc = [FizmoGlkViewController singleton];
	
	CGFloat maxwidth;
	
	if (sender == colbut_34) {
		maxwidth = 624;
	} 
	else if (sender == colbut_12) {
		maxwidth = 512;
	}
	else {
		maxwidth = 0;
	}
	
	glkviewc.fizmoDelegate.maxwidth = maxwidth;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setFloat:maxwidth forKey:@"FrameMaxWidth"];
	
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

@end

@implementation PrefsContainerView

- (void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
}

@end
