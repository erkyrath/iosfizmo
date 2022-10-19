/* FizmoGlkDelegate.h: Fizmo-specific delegate for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <Foundation/Foundation.h>
#import "IosGlkLibDelegate.h"
#import "StyleSet.h"

#define FONTSCALE_MAX (9)
#define LEADING_MAX (5)

@interface FizmoGlkDelegate : NSObject <IosGlkLibDelegate> {
	int maxwidth; // 0 for full-width, 1 for 3/4-ish, 2 for 1/2-ish.
	NSString *fontfamily; // as the user knows it -- not necessarily the true family name
	int fontscale; // a number from 1 to FONTSCALE_MAX
	int colorscheme; // 0:Bright, 1:Quiet, 2:Dark
	int leading; // 0 to LEADING_MAX
}

@property (nonatomic) int maxwidth;
/* The following properties are read from multiple threads, so we declare them atomic. */
@property (strong) NSString *fontfamily;
@property int fontscale;
@property int colorscheme;
@property int leading;

@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *gameTitle;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) NSString *gamePath;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) UIColor *genBackgroundColor;
@property (NS_NONATOMIC_IOSONLY, readonly, copy) UIColor *genForegroundColor;
- (FontVariants) fontVariantsForSize:(CGFloat)size label:(NSString *)label;

@end
