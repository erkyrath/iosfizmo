/* FizmoGameOverView.m: Fizmo "Game Over" pop-up dialog
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "FizmoGameOverView.h"
#import "FizmoGlkViewController.h"
#import "GlkAppWrapper.h"
#import "GlkLibrary.h"
#import "GlkFileRef.h"
#import "GlkFrameView.h"
#import "GlkFileTypes.h"
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
	
	NSString *basedir = [GlkFileRef documentsDirectory];
	NSString *dirname = [GlkFileRef subDirOfBase:basedir forUsage:fileusage_SavedGame gameid:[GlkLibrary singleton].gameId];
	
	FizmoGlkViewController *viewc = [FizmoGlkViewController singleton];
	
	viewc.restorefileprompt = [[GlkFileRefPrompt alloc] initWithUsage:fileusage_SavedGame fmode:filemode_Read dirname:dirname];
	[viewc displayModalRequest:viewc.restorefileprompt];
	
	// The callback from the FileSelectVC will trigger acceptEventRestart.
}

- (IBAction) handleQuitButton:(id)sender {
	iosglk_shut_down_process();
}

@end
