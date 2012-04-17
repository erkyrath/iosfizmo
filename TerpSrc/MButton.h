/* MButton.h: A button with some utility features
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
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
