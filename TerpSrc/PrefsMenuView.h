/* PrefsMenuView.h: A popmenu subclass that can display the preferences menu
 for IosGlk, the iOS implementation of the Glk API.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "PopMenuView.h"

@interface PrefsMenuView : PopMenuView

@property (nonatomic, retain) IBOutlet UIView *container;

@end


@interface PrefsContainerView : UIView

@end
