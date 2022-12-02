/* FizmoGlkTabBarControllerDelegate.h: IosFizmo-specific subclass of IosGlkTabBarControllerDelegate.
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "IosGlkTabBarControllerDelegate.h"

@class NotesViewController, SettingsViewController;

NS_ASSUME_NONNULL_BEGIN

@interface FizmoGlkTabBarControllerDelegate : IosGlkTabBarControllerDelegate

@property (nonatomic, assign) NotesViewController *notesvc;
@property (nonatomic, assign) SettingsViewController *settingsvc;

@end

NS_ASSUME_NONNULL_END
