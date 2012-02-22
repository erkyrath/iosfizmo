/* FizmoGlkDelegate.m: Fizmo-specific delegate for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkDelegate.h"
#import "IosGlkLibDelegate.h"
#import "StyleSet.h"

@implementation FizmoGlkDelegate

@synthesize maxwidth;
@synthesize fontfamily;
@synthesize fontscale;

- (void) dealloc {
	self.fontfamily = nil;
	[super dealloc];
}

- (void) prepareStyles:(StyleSet *)styles forWindowType:(glui32)wintype rock:(glui32)rock {
	BOOL isiphone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
	
	if (wintype == wintype_TextGrid) {
		styles.margins = UIEdgeInsetsMake(4, 6, 4, 6);
		
		CGFloat statusfontsize;
		if (isiphone) {
			statusfontsize = 9+fontscale;
		}
		else {
			statusfontsize = 11+fontscale;
		}
		
		FontVariants variants = [StyleSet fontVariantsForSize:statusfontsize name:@"Courier", nil];
		styles.fonts[style_Normal] = variants.normal;
		styles.fonts[style_Emphasized] = variants.italic;
		styles.fonts[style_Preformatted] = variants.normal;
		styles.fonts[style_Header] = variants.bold;
		styles.fonts[style_Subheader] = variants.bold;
		styles.fonts[style_Alert] = variants.italic;
		styles.fonts[style_Note] = variants.italic;
		
		styles.backgroundcolor = [UIColor colorWithRed:0.8 green:0.7 blue:0.5 alpha:1];
	}
	else {
		styles.margins = UIEdgeInsetsMake(4, 6, 4, 6);

		CGFloat statusfontsize = 11+fontscale;

		FontVariants variants;
		if ([fontfamily isEqualToString:@"Helvetica"]) {
			variants = [StyleSet fontVariantsForSize:statusfontsize name:@"Helvetica Neue", @"Helvetica", nil];
		}
		if ([fontfamily isEqualToString:@"Euphemia"]) {
			variants = [StyleSet fontVariantsForSize:statusfontsize name:@"EuphemiaUCAS", @"Verdana", nil];
		}
		else if (!fontfamily) {
			variants = [StyleSet fontVariantsForSize:statusfontsize name:@"Georgia", nil];
		}
		else {
			variants = [StyleSet fontVariantsForSize:statusfontsize name:fontfamily, @"Georgia", nil];
		}
		
		styles.fonts[style_Normal] = variants.normal;
		styles.fonts[style_Emphasized] = variants.italic;
		styles.fonts[style_Preformatted] = [UIFont fontWithName:@"Courier" size:14];
		styles.fonts[style_Header] = variants.bold;
		styles.fonts[style_Subheader] = variants.bold;
		styles.fonts[style_Alert] = variants.italic;
		styles.fonts[style_Note] = variants.italic;
		
	}
}

- (CGSize) interWindowSpacing {
	return CGSizeMake(4, 4);
}

- (CGRect) adjustFrame:(CGRect)rect {
	if (maxwidth > 64 && rect.size.width > maxwidth) {
		rect.origin.x = (rect.origin.x+0.5*rect.size.width) - 0.5*maxwidth;
		rect.size.width = maxwidth;
	}
	return rect;
}

@end

