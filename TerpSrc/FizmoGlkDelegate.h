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
	int fontscale;
}

@property (nonatomic) CGFloat maxwidth;
@property (nonatomic, retain) NSString *fontfamily;
@property (nonatomic) int fontscale;

@end
