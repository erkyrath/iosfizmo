/* MButton.h: A button with some utility features
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>


@interface MButton : UIButton {
	UIImage *selectimage;
	UIImageView *selectview;
}

@property (nonatomic, retain) UIImage *selectimage;
@property (nonatomic, retain) UIImageView *selectview;

- (void) setSelectImage:(UIImage *)img;

@end
