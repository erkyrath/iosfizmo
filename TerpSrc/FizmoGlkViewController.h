/* FizmoGlkViewController.h: Fizmo-specific subclass of the IosGlk view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import "IosGlkViewController.h"

@class NotesViewController;

@interface FizmoGlkViewController : IosGlkViewController

@property (nonatomic, retain) IBOutlet NotesViewController *notesvc;

- (IBAction) showPreferences;

@end
