/* SettingsViewController.h: Interpreter settings tab view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "SettingsViewController.h"
#import "FizmoGlkViewController.h"
#import "DisplayWebViewController.h"
#import "ShareFilesViewController.h"
#import "GlkFrameView.h"
#import "IosGlkAppDelegate.h"

@implementation SettingsViewController

@synthesize tableview;
@synthesize autocorrectcell;
@synthesize keepopencell;
@synthesize sharefilescell;
@synthesize licensecell;
@synthesize autocorrectswitch;
@synthesize keepopenswitch;


- (void) viewDidLoad
{
	[super viewDidLoad];

	if ([tableview respondsToSelector:@selector(backgroundView)]) {
		/* This is only available in iOS 3.2 and up */
		tableview.backgroundView = [[UIView alloc] initWithFrame:tableview.backgroundView.frame];
        tableview.backgroundView.backgroundColor = [UIColor colorNamed:@"CustomTableBackground"];
	}

	/* Create the cells... */
	self.licensecell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"];
	licensecell.backgroundColor = [UIColor colorNamed:@"CustomCellBackground"];
	licensecell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.license", @"TerpLocalize", nil);
	licensecell.textLabel.textColor = [UIColor colorNamed:@"CustomCellText"];
	licensecell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	self.sharefilescell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"];
	sharefilescell.backgroundColor = licensecell.backgroundColor;
	sharefilescell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.sharefiles", @"TerpLocalize", nil);
	sharefilescell.textLabel.textColor = licensecell.textLabel.textColor;
	sharefilescell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

	self.autocorrectcell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"];
	autocorrectcell.backgroundColor = licensecell.backgroundColor;
	autocorrectcell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.autocorrect", @"TerpLocalize", nil);
	autocorrectcell.textLabel.textColor = licensecell.textLabel.textColor;
	autocorrectcell.selectionStyle = UITableViewCellSelectionStyleNone;
	autocorrectcell.accessoryView = autocorrectswitch;

	self.keepopencell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Settings"];
	keepopencell.backgroundColor = licensecell.backgroundColor;
	keepopencell.textLabel.text = NSLocalizedStringFromTable(@"settings.cell.keepopen", @"TerpLocalize", nil);
	keepopencell.textLabel.textColor = licensecell.textLabel.textColor;
	keepopencell.selectionStyle = UITableViewCellSelectionStyleNone;
	keepopencell.accessoryView = keepopenswitch;

	if (true) {
		FizmoGlkViewController *mainviewc = [FizmoGlkViewController singleton];
		UISwipeGestureRecognizer *recognizer;
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeLeft:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionLeft;
		[tableview addGestureRecognizer:recognizer];
		recognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:mainviewc action:@selector(handleSwipeRight:)];
		recognizer.direction = UISwipeGestureRecognizerDirectionRight;
		[tableview addGestureRecognizer:recognizer];
	}
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	autocorrectswitch.on = ![defaults boolForKey:@"NoAutocorrect"];
	keepopenswitch.on = ![defaults boolForKey:@"NoKeepOpen"];
}

- (IBAction) handleAutoCorrect:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:!autocorrectswitch.on forKey:@"NoAutocorrect"];

	IosGlkViewController *glkviewc = [IosGlkViewController singleton];
	if (glkviewc.frameview)
		[glkviewc.frameview updateInputTraits];
}

- (IBAction) handleKeepOpen:(id)sender
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:!keepopenswitch.on forKey:@"NoKeepOpen"];
}

- (void) handleLicenses
{
	NSString *title = NSLocalizedStringFromTable(@"settings.title.license", @"TerpLocalize", nil);

    UIStoryboard* sb = [UIStoryboard storyboardWithName:@"MainStoryboard"
                                                 bundle:nil];

    DisplayWebViewController* viewc = (DisplayWebViewController *)[sb instantiateViewControllerWithIdentifier:@"WebDoc"];

    viewc.filename = @"license";
    viewc.doctitle = title;

	[self.navigationController pushViewController:viewc animated:YES];
}

- (void) handleShareFiles
{
	[self handleShareFilesHighlightUsage:0 name:nil];
}

- (void) handleShareFilesHighlightUsage:(int)usage name:(NSString *)filename
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"ShareFiles" bundle:nil];

    UINavigationController *navc = [sb instantiateViewControllerWithIdentifier:@"ShareFilesNav"];
    ShareFilesViewController *viewc = (ShareFilesViewController *)navc.viewControllers[0];

	BOOL animated = YES;
	if (filename) {
		// It so happens that if filename exists, this is an arriving file (and the caller is displayGlkFileUsage). Don't animate in that case.
		animated = NO;
		viewc.highlightusage = usage;
		viewc.highlightname = filename;
	}
	[self.navigationController pushViewController:viewc animated:animated];
}

/* UITableViewDataSource methods */

#define SECTION_PREFS (0)
#define SECTION_FILES (1)
#define SECTION_LICENSE (2)
#define NUM_SECTIONS (3)

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
	if (section == SECTION_PREFS)
		return NSLocalizedStringFromTable(@"settings.footer.settings", @"TerpLocalize", nil);
	return nil;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	switch (section) {
		case SECTION_PREFS:
			return 2;
		case SECTION_FILES:
			return 1;
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
					return keepopencell;
				case 1:
					return autocorrectcell;
				default:
                    abort();
			}

		case SECTION_FILES:
			switch (indexpath.row) {
				case 0:
					return sharefilescell;
				default:
                    abort();
			}

		case SECTION_LICENSE:
			switch (indexpath.row) {
				case 0:
					return licensecell;
				default:
                    abort();
			}

		default:
            abort();
	}
}

/* UITableViewDelegate methods */

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexpath
{
	[tableview deselectRowAtIndexPath:indexpath animated:NO];
	if (indexpath.section == SECTION_LICENSE && indexpath.row == 0)
		[self handleLicenses];
	if (indexpath.section == SECTION_FILES && indexpath.row == 0)
		[self handleShareFiles];
}


@end
