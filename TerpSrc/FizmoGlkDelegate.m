/* FizmoGlkDelegate.m: Fizmo-specific delegate for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGlkDelegate.h"
#import "FizmoGlkViewController.h"
#import "SettingsViewController.h"
#import "IosGlkLibDelegate.h"
#import "FizmoGlkWindows.h"
#import "GlkWindowState.h"
#import "StyleSet.h"
#import "GlkUtilities.h"

// This typedef works around header file annoyance. We're not going to refer to it.
typedef struct z_file_struct z_file;
#include "ios-autosave.h"

@implementation FizmoGlkDelegate

@synthesize maxwidth;
@synthesize fontfamily;
@synthesize fontscale;
@synthesize colorscheme;
@synthesize leading;


- (NSString *) gameId {
	return nil;
}

#define IFFID(c1, c2, c3, c4)  \
  ( (((glui32)c1) << 24)    \
  | (((glui32)c2) << 16)    \
  | (((glui32)c3) << 8)     \
  | (((glui32)c4)) )

/* Check whether the given file is a Glulx save file matching our game.

	This replicates the Quetzal-parsing code in glulxe. It's a stable algorithm and I don't want to go chopping additional entry points into the interpreter.

	Recall that for Z-code, the IFhd chunk contains: release (2 bytes), serial (6 bytes), checksum (2 bytes), PC (3 bytes).
	http://inform-fiction.org/zmachine/standards/quetzal/index.html#five
 */
- (GlkSaveFormat) checkGlkSaveFileFormat:(NSString *)path {
	NSFileHandle *fhan = [NSFileHandle fileHandleForReadingAtPath:path];
	if (!fhan)
		return saveformat_Unreadable;

	// Let's do this using a block.
	BOOL (^Read4)(glui32 *) = ^(glui32 *val) {
		NSData *dat = [fhan readDataOfLength:4];
		if (!dat || dat.length < 4) {
			*val = 0;
			return NO;
		}
		const unsigned char *bytes = dat.bytes;
		*val = ((bytes[0] << 24) | (bytes[1] << 16) | (bytes[2] << 8) | (bytes[3]));
		return YES;
	};

	BOOL res;
	glui32 val;

	res = Read4(&val);
	if (!res || val != IFFID('F', 'O', 'R', 'M')) {
		[fhan closeFile];
		return saveformat_UnknownFormat;
	}

	glui32 filelen;
	res = Read4(&filelen);
	if (!res) {
		[fhan closeFile];
		return saveformat_UnknownFormat;
	}
	glui32 filestart = fhan.offsetInFile;

	res = Read4(&val);
	if (!res || val != IFFID('I', 'F', 'Z', 'S')) {
		[fhan closeFile];
		return saveformat_UnknownFormat;
	}

	GlkSaveFormat result = saveformat_UnknownFormat;

	while (fhan.offsetInFile < filestart+filelen) {
		/* Read a chunk and deal with it. */
		glui32 chunktype=0, chunkstart=0, chunklen=0;

		res = Read4(&chunktype);
		if (!res) {
			result = saveformat_UnknownFormat;
			break;
		}
		res = Read4(&chunklen);
		if (!res) {
			result = saveformat_UnknownFormat;
			break;
		}
		chunkstart = fhan.offsetInFile;

		if (chunktype == IFFID('I', 'F', 'h', 'd')) {
			/* Read the value, compare to the game file. If it matches, we're good. */
			NSData *dat = [fhan readDataOfLength:chunklen];
			if (!dat || dat.length < chunklen) {
				result = saveformat_UnknownFormat;
				break;
			}
			result = saveformat_UnknownFormat;
			NSFileHandle *gamehan = [NSFileHandle fileHandleForReadingAtPath:self.gamePath];
			if (gamehan) {
				int len = 0x20; // the Z-machine header
				NSData *gamedat = [gamehan readDataOfLength:len];
				if (gamedat && len == 0x20) {
					int ix;
					const unsigned char *bytes = dat.bytes;
					const unsigned char *gamebytes = gamedat.bytes;
					result = saveformat_Ok;
					for (ix=0; ix<2; ix++) {
						if (bytes[0+ix] != gamebytes[0x02+ix]) {
							result = saveformat_WrongGame;
							break;
						}
					}
					for (ix=0; ix<6; ix++) {
						if (bytes[2+ix] != gamebytes[0x12+ix]) {
							result = saveformat_WrongGame;
							break;
						}
					}
					for (ix=0; ix<2; ix++) {
						if (bytes[8+ix] != gamebytes[0x1C+ix]) {
							result = saveformat_WrongGame;
							break;
						}
					}
				}
			}
			/* Whatever happened, we're done now. */
			[gamehan closeFile];
			break;
		}
		else {
			/* Unknown chunk type. Skip it. */
			NSData *dat = [fhan readDataOfLength:chunklen];
			if (!dat || dat.length < chunklen) {
				result = saveformat_UnknownFormat;
				break;
			}
		}

		if (chunkstart+chunklen != fhan.offsetInFile) {
			/* Funny chunk length. */
			result = saveformat_UnknownFormat;
			break;
		}

		if ((chunklen & 1) != 0) {
			/* Skip the mandatory byte after an odd-length chunk. */
			NSData *dat = [fhan readDataOfLength:1];
			if (!dat || dat.length < 1) {
				result = saveformat_UnknownFormat;
				break;
			}
		}
	}

	[fhan closeFile];

	return result;
}

/* Open the Share Files view in the Settings tab. Make sure the given file is highlighted. */
- (void) displayGlkFileUsage:(int)usage name:(NSString *)name {
	FizmoGlkViewController *terpvc = [FizmoGlkViewController singleton];
	UITabBarController *tabbc = terpvc.tabBarController;
	if (!tabbc)
		return;

	if (tabbc.selectedViewController != terpvc.settingsvc.navigationController) {
		// Switch to the settings view.
		tabbc.selectedViewController = terpvc.settingsvc.navigationController;
	}
	// Pop out to the root of the settings view.
	[terpvc.settingsvc.navigationController popToRootViewControllerAnimated:NO];
	// Push in to the share view.
	[terpvc.settingsvc handleShareFilesHighlightUsage:usage name:name];
}

- (NSString *) gameTitle {
	return nil;
}

- (NSString *) gamePath {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *path = [bundle pathForResource:@"Game" ofType:@"z5"];
	return path;
}

- (GlkWinBufferView *) viewForBufferWindow:(GlkWindowState *)win frame:(CGRect)box margin:(UIEdgeInsets)margin {
	return [[FizmoGlkWinBufferView alloc] initWithWindow:win frame:box margin:margin];
}

- (GlkWinGridView *) viewForGridWindow:(GlkWindowState *)win frame:(CGRect)box margin:(UIEdgeInsets)margin {
	return nil;
}

- (BOOL) shouldTapSetKeyboard:(BOOL)toopen {
	if (toopen)
		return YES;
	else
		return NO;
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
            return [UIColor colorNamed:@"CustomTerpTextQuiet"];
		case 2: /* dark */
            NSLog(@"dark is deprecated");
		case 0: /* bright */
		default:
			return [UIColor colorNamed:@"CustomTerpTextBright"];
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (UIColor *) genBackgroundColor {
	switch (self.colorscheme) {
		case 1: /* quiet */
			return [UIColor colorNamed:@"CustomTerpBGQuiet"];
		case 0: /* bright */
		default:
            return [UIColor colorNamed:@"CustomTerpBGBright"];
	}
}

/* This is invoked from both the VM and UI threads.
 */
- (void) prepareStyles:(StyleSet *)styles forWindowType:(glui32)wintype rock:(glui32)rock {
	BOOL isiphone = (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone);

	NSString *fontfam = self.fontfamily;

	if (wintype == wintype_TextGrid) {
		styles.margins = UIEdgeInsetsMake(6, 6, 6, 6);
		styles.leading = self.leading;

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
                styles.backgroundcolor = [UIColor colorNamed:@"CustomTerpGridBGQuiet"];
                styles.colors[style_Normal] = [UIColor colorNamed:@"CustomTerpTextQuiet"];
				break;
			case 2: /* dark */
                NSLog(@"dark is deprecated");
				break;
			case 0: /* bright */
			default:
                styles.backgroundcolor = [UIColor colorNamed:@"CustomTerpGridBGBright"];
                styles.colors[style_Normal] = [UIColor colorNamed:@"CustomTerpTextBright"];
				break;
		}
	}
	else {
		styles.margins = UIEdgeInsetsMake(4, 6, 4, 6);
		styles.leading = self.leading;

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
	/* Decode the maxwidth value into a pixel width. 0 means full-width. */
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return rect;

	CGFloat limit = 0;
	switch (maxwidth) {
		case 0:
			limit = 0;
			break;
		case 1: // "3/4 column"
			limit = 0.8125 * rect.size.width;
			break;
		case 2: // "1/2 column"
			limit = 0.6667 * rect.size.width;
			break;
	}

	// I hate odd widths
	limit = ((int)floorf(limit)) & (~1);

	if (limit > 64 && rect.size.width > limit) {
		rect.origin.x = (rect.origin.x+0.5*rect.size.width) - 0.5*limit;
		rect.size.width = limit;
	}
	return rect;
}

- (UIEdgeInsets) viewMarginForWindow:(GlkWindowState *)win rect:(CGRect)rect framebounds:(CGRect)framebounds {
	if (UIDevice.currentDevice.userInterfaceIdiom == UIUserInterfaceIdiomPhone)
		return UIEdgeInsetsZero;

	if ([win isKindOfClass:[GlkWindowBufferState class]]) {
		CGFloat left = rect.origin.x - framebounds.origin.x;
		CGFloat right = (framebounds.origin.x+framebounds.size.width) - (rect.origin.x+rect.size.width);
		if (left >= 32 && right >= 32) {
			return UIEdgeInsetsMake(0, left, 0, right);
		}
	}

	return UIEdgeInsetsZero;
}

/* This is called when the library leaves glk_main(), either by returning or by a glk_exit() exception.
 */
- (void) vmHasExited {
	iosglk_clear_autosave();
}

@end

