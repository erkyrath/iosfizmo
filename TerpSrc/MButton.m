/* MButton.m: A button with some utility features
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "MButton.h"


@implementation MButton

- (id) initWithCoder:(NSCoder *)decoder {
	self = [super initWithCoder:decoder];
	
	if (self) {
		self.titleLabel.textAlignment = UITextAlignmentCenter;
		
		UIImage *img;
		img = [self backgroundImageForState:UIControlStateNormal];
		img = [img stretchableImageWithLeftCapWidth:img.size.width/2 topCapHeight:img.size.height/2];
		[self setBackgroundImage:img forState:UIControlStateNormal];
		img = [self backgroundImageForState:UIControlStateHighlighted];
		img = [img stretchableImageWithLeftCapWidth:img.size.width/2 topCapHeight:img.size.height/2];
		[self setBackgroundImage:img forState:UIControlStateHighlighted];
	}
	
	return self;
}

@end
