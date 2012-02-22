/* FizmoGlkDelegate.h: Fizmo-specific delegate for the IosGlk library
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <Foundation/Foundation.h>
#import "IosGlkLibDelegate.h"

#define FONTSCALE_MAX (7)

@interface FizmoGlkDelegate : NSObject <IosGlkLibDelegate> {
	CGFloat maxwidth;
	NSString *fontfamily; // as the user knows it -- not necessarily the true family name
	int fontscale; // a number from 1 to FONTSCALE_MAX
	int colorscheme; // 0:Bright, 1:Quiet, 2:Dark
}

@property (nonatomic) CGFloat maxwidth;
@property (nonatomic, retain) NSString *fontfamily;
@property (nonatomic) int fontscale;
@property (nonatomic) int colorscheme;

- (UIColor *) genBackgroundColor;
- (UIColor *) genForegroundColor;

@end
