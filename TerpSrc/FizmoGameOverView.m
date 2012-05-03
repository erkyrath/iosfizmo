/* FizmoGameOverView.m: Fizmo "Game Over" pop-up dialog
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGameOverView.h"
#import "GlkAppWrapper.h"
#import "GlkFrameView.h"
#include "ios-restart.h"

@implementation FizmoGameOverView

- (NSString *) nibForContent {
	if (iosglk_can_restart_cleanly())
		return @"GameOverView";
	else
		return @"FatalGameOverView";
}

- (IBAction) handleRestartButton:(id)sender {
	[self.superviewAsFrameView removePopMenuAnimated:YES];
	
	[[GlkAppWrapper singleton] acceptEventRestart];
}

- (IBAction) handleRestoreButton:(id)sender {
	[self.superviewAsFrameView removePopMenuAnimated:YES];
	NSLog(@"### restore button");
	
	//###[[GlkAppWrapper singleton] acceptEventRestart];
}

- (IBAction) handleQuitButton:(id)sender {
	iosglk_shut_down_process();
}

@end
