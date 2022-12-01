//
//  FizmoGlkTabBarControllerDelegate.h
//  iosfizmo
//
//  Created by Administrator on 2022-11-30.
//

#import "IosGlkTabBarControllerDelegate.h"

@class NotesViewController, SettingsViewController;

NS_ASSUME_NONNULL_BEGIN

@interface FizmoGlkTabBarControllerDelegate : IosGlkTabBarControllerDelegate

@property (nonatomic, assign) NotesViewController *notesvc;
@property (nonatomic, assign) SettingsViewController *settingsvc;

@end

NS_ASSUME_NONNULL_END
