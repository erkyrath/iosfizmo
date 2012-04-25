/* FizmoGlkDelegate.m: Fizmo-specific delegate for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkDelegate.h"
#import "IosGlkLibDelegate.h"
#import "FizmoGlkWindows.h"
#import "StyleSet.h"

// This typedef works around header file annoyance. We're not going to refer to it.
typedef struct z_file_struct z_file;
#include "ios-autosave.h"

@implementation FizmoGlkDelegate

@synthesize maxwidth;
@synthesize fontfamily;
@synthesize fontscale;
@synthesize colorscheme;

- (void) dealloc {
	self.fontfamily = nil;
	[super dealloc];
}

- (NSString *) gameId {
	return nil;
}

- (NSString *) gamePath {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:@"Game" ofType:@"z5"];
	return path;
}

- (GlkWinBufferView *) viewForBufferWindow:(GlkWindowState *)win frame:(CGRect)box {
	return [[[FizmoGlkWinBufferView alloc] initWithWindow:win frame:box] autorelease];
}

- (GlkWinGridView *) viewForGridWindow:(GlkWindowState *)win frame:(CGRect)box {
	return nil;
}

/* Utility method: turn a font menu label into an actual set of fonts.
 */
- (FontVariants) fontVariantsForSize:(CGFloat)size label:(NSString *)label {
	if ([label isEqualToString:@"Helvetica"]) {
		return [StyleSet fontVariantsForSize:size name:@"Helvetica Neue", @"Helvetica", nil];
	}
	else if ([label isEqualToString:@"Euphemia"]) {
		return [StyleSet fontVariantsForSize:size name:@"EuphemiaUCAS", @"Verdana", nil];
	}
	else if (!label) {
		return [StyleSet fontVariantsForSize:size name:@"Georgia", nil];
	}
	else {
		return [StyleSet fontVariantsForSize:size name:label, @"Georgia", nil];
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (UIColor *) genForegroundColor {
	switch (self.colorscheme) {
		case 1: /* quiet */
			return [UIColor colorWithRed:0.25 green:0.2 blue:0.0 alpha:1];
		case 2: /* dark */
			return [UIColor colorWithRed:0.75 green:0.75 blue:0.7 alpha:1];
		case 0: /* bright */
		default:
			return [UIColor blackColor];
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (UIColor *) genBackgroundColor {
	switch (self.colorscheme) {
		case 1: /* quiet */
			return [UIColor colorWithRed:0.9 green:0.85 blue:0.7 alpha:1];
		case 2: /* dark */
			return [UIColor blackColor];
		case 0: /* bright */
		default:
			return [UIColor colorWithRed:1 green:1 blue:0.95 alpha:1];
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (void) prepareStyles:(StyleSet *)styles forWindowType:(glui32)wintype rock:(glui32)rock {
	BOOL isiphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
	
	NSString *fontfam = self.fontfamily;
	
	if (wintype == wintype_TextGrid) {
		styles.margins = UIEdgeInsetsMake(6, 6, 6, 6);
		
		CGFloat statusfontsize;
		if (isiphone) {
			statusfontsize = 9+self.fontscale;
		}
		else {
			statusfontsize = 11+self.fontscale;
		}
		
		FontVariants variants = [StyleSet fontVariantsForSize:statusfontsize name:@"Courier", nil];
		styles.fonts[style_Normal] = variants.normal;
		styles.fonts[style_Emphasized] = variants.italic;
		styles.fonts[style_Preformatted] = variants.normal;
		styles.fonts[style_Header] = variants.bold;
		styles.fonts[style_Subheader] = variants.bold;
		styles.fonts[style_Alert] = variants.italic;
		styles.fonts[style_Note] = variants.italic;
		
		switch (self.colorscheme) {
			case 1: /* quiet */
				styles.backgroundcolor = [UIColor colorWithRed:0.75 green:0.7 blue:0.5 alpha:1];
				styles.colors[style_Normal] = [UIColor colorWithRed:0.15 green:0.1 blue:0.0 alpha:1];
				break;
			case 2: /* dark */
				styles.backgroundcolor =  [UIColor colorWithRed:0.55 green:0.55 blue:0.5 alpha:1];
				styles.colors[style_Normal] = [UIColor blackColor];
				break;
			case 0: /* bright */
			default:
				styles.backgroundcolor = [UIColor colorWithRed:0.85 green:0.8 blue:0.6 alpha:1];
				styles.colors[style_Normal] = [UIColor colorWithRed:0.25 green:0.2 blue:0.0 alpha:1];
				break;
		}
	}
	else {
		styles.margins = UIEdgeInsetsMake(4, 6, 4, 6);

		CGFloat statusfontsize = 11+self.fontscale;

		FontVariants variants = [self fontVariantsForSize:statusfontsize label:fontfam];
		
		styles.fonts[style_Normal] = variants.normal;
		styles.fonts[style_Emphasized] = variants.italic;
		styles.fonts[style_Preformatted] = [UIFont fontWithName:@"Courier" size:14];
		styles.fonts[style_Header] = variants.bold;
		styles.fonts[style_Subheader] = variants.bold;
		styles.fonts[style_Input] = variants.bold;
		styles.fonts[style_Alert] = variants.italic;
		styles.fonts[style_Note] = variants.italic;
		
		styles.backgroundcolor = self.genBackgroundColor;
		styles.colors[style_Normal] = self.genForegroundColor;
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (CGSize) interWindowSpacing {
	return CGSizeMake(2, 2);
}

- (CGRect) adjustFrame:(CGRect)rect {
	if (maxwidth > 64 && rect.size.width > maxwidth) {
		rect.origin.x = (rect.origin.x+0.5*rect.size.width) - 0.5*maxwidth;
		rect.size.width = maxwidth;
	}
	return rect;
}

- (void) vmHasExited {
	iosglk_clear_autosave();
}

@end

