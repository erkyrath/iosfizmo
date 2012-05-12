/* SettingsViewController.h: Interpreter settings tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "SettingsViewController.h"
#import "FizmoGlkViewController.h"
#import "DisplayWebViewController.h"
#import "GlkFrameView.h"
#import "IosGlkAppDelegate.h"

@implementation SettingsViewController

@synthesize tableview;
@synthesize autocorrectcell;
@synthesize morepromptcell;
@synthesize licensecell;
@synthesize autocorrectswitch;
@synthesize morepromptswitch;

- (void) dealloc {
	self.tableview = nil;
	self.autocorrectcell = nil;
	self.morepromptcell = nil;
	self.licensecell = nil;
	self.autocorrectswitch = nil;
	self.morepromptswitch = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	NSLog(@"SettingsVC: viewDidLoad");

	if ([tableview respondsToSelector:@selector(backgroundView)]) {
		/* This is only available in iOS 3.2 and up */
		tableview.backgroundView = [[[UIView alloc] initWithFrame:tableview.backgroundView.frame] autorelease];
		tableview.backgroundView.backgroundColor = [UIColor colorWithRed:0.85 green:0.8 blue:0.6 alpha:1];
	}
	
	/* Create the cells... */
	self.licensecell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"] autorelease];
	licensecell.backgroundColor = [UIColor colorWithRed:1.0 green:0.98 blue:0.92 alpha:1];
	licensecell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.license", @"TerpLocalize", nil);
	licensecell.textLabel.textColor = [UIColor colorWithRed:0.35 green:0.215 blue:0 alpha:1];
	licensecell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	self.autocorrectcell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"] autorelease];
	autocorrectcell.backgroundColor = licensecell.backgroundColor;
	autocorrectcell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.autocorrect", @"TerpLocalize", nil);
	autocorrectcell.textLabel.textColor = licensecell.textLabel.textColor;
	autocorrectcell.selectionStyle = UITableViewCellSelectionStyleNone;
	autocorrectcell.accessoryView = autocorrectswitch;
	
	self.morepromptcell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"] autorelease];
	morepromptcell.backgroundColor = licensecell.backgroundColor;
	morepromptcell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.moreprompt", @"TerpLocalize", nil);
	morepromptcell.textLabel.textColor = licensecell.textLabel.textColor;
	morepromptcell.selectionStyle = UITableViewCellSelectionStyleNone;
	morepromptcell.accessoryView = morepromptswitch;
		
	if ([IosGlkAppDelegate gesturesavailable]) {
		/* gestures are available in iOS 3.2 and up */
		
		FizmoGlkViewController *mainviewc = [FizmoGlkViewController singleton];
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeLeft:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[tableview addGestureRecognizer:recognizer];
		recognizer = [[[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeRight:)] autorelease];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[tableview addGestureRecognizer:recognizer];
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	autocorrectswitch.on = ![defaults boolForKey:@"NoAutocorrect"];
	morepromptswitch.on = ![defaults boolForKey:@"NoMorePrompt"];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation
{
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	return [glkviewc shouldAutorotateToInterfaceOrientation:orientation];
}

- (IBAction) handleAutoCorrect:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:!autocorrectswitch.on forKey:@"NoAutocorrect"];
	
	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	if (glkviewc.frameview)
		[glkviewc.frameview updateInputTraits];
}

- (IBAction) handleMorePrompt:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:!morepromptswitch.on forKey:@"NoMorePrompt"];
}

- (void) handleLicenses
{
	NSString *title = NSLocalizedStringFromTable(@"settings.title.license", @"TerpLocalize", nil);
	DisplayWebViewController *viewc = [[[DisplayWebViewController alloc] initWithNibName:@"WebDocVC" filename:@"license" title:title bundle:nil] autorelease];
	[self.navigationController pushViewController:viewc animated:YES];
}

/* UITableViewDataSource methods */

#define SECTION_PREFS (0)
#define SECTION_LICENSE (1)
#define NUM_SECTIONS (2)

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return NUM_SECTIONS;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section == SECTION_PREFS)
		return NSLocalizedStringFromTable(@"settings.section.settings", @"TerpLocalize", nil);
	return nil;
}

- (NSString *) tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case SECTION_PREFS:
			return 2;
		case SECTION_LICENSE:
			return 1;
		default:
			return 0;
	}
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexpath
{
	switch (indexpath.section) {
		case SECTION_PREFS:
			switch (indexpath.row) {
				case 0:
					return autocorrectcell;
				case 1:
					return morepromptcell;
				default:
					return nil;
			}
			
		case SECTION_LICENSE:
			switch (indexpath.row) {
				case 0:
					return licensecell;
				default:
					return nil;
			}
			
		default:
			return nil;
	}
}

/* UITableViewDelegate methods */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexpath
{
	[tableview deselectRowAtIndexPath:indexpath animated:NO];
	if (indexpath.section == SECTION_LICENSE && indexpath.row == 0)
		[self handleLicenses];
}


@end
