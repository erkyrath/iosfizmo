/* MButton.m: A button with some utility features
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "MButton.h"


@implementation MButton

@synthesize selectimage;
@synthesize selectview;

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
		
		// selectimage is nil by default, but the caller can set it.
	}
	
	return self;
}

- (void) dealloc {
	self.selectimage = nil;
	self.selectview = nil;
	[super dealloc];
}

- (void) setSelectImage:(UIImage *)img {
	if (img == selectimage)
		return;

	if (self.selectview) {
		[self.selectview removeFromSuperview];
		self.selectview = nil;
	}

	if (!img) {
		self.selectimage = nil;
		return;
	}

	self.selectimage = img;

	CGRect selfbounds = self.bounds;	
	CGRect rect;
	CGFloat margin = (selfbounds.size.width > 80) ? 6 : 4;
	rect.size = img.size;
	rect.origin.y = floorf(0.5 * (selfbounds.size.height - rect.size.height));
	rect.origin.x = selfbounds.size.width - rect.size.width - margin;
	
	self.selectview = [[[UIImageView alloc] initWithImage:img] autorelease];
	selectview.frame = rect;
	selectview.hidden = !self.selected;
	[self addSubview:selectview];
}

- (void) setSelected:(BOOL)val {
	[super setSelected:val];
	
	if (selectimage) {
		selectview.hidden = !val;
	}
}

@end
