/* ShareFilesViewController.m: Files list overview display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "ShareFilesViewController.h"
#import "IosGlkViewController.h"
#import "RelDateFormatter.h"
#import "DisplayTextViewController.h"
#import "GlkLibrary.h"
#import "GlkFileRef.h"
#import "GlkFileTypes.h"
#import "GlkUtilities.h"

static int usages[] = { fileusage_SavedGame, fileusage_Transcript, fileusage_Data, fileusage_InputRecord, -1 };

@implementation ShareFilesViewController

@synthesize tableView;
@synthesize sendbutton;
@synthesize highlightusage;
@synthesize highlightname;
@synthesize sharedocic;
@synthesize sharetemppath;
@synthesize filelists;
@synthesize dateformatter;


- (void) viewDidLoad {
    [super viewDidLoad];

		self.filelists = [NSMutableArray arrayWithCapacity:8];
		self.dateformatter = [[RelDateFormatter alloc] init];
		dateformatter.dateStyle = NSDateFormatterMediumStyle;
		dateformatter.timeStyle = NSDateFormatterShortStyle;

	self.navigationItem.title = NSLocalizedStringFromTable(@"title.sharefiles", @"TerpLocalize", nil);

	// Setting two right-bar-buttons like this is an iOS5+ API.

	self.sendbutton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonSend:)];
	self.sendbutton.enabled = NO;

	UIBarButtonItem *editbutton = self.editButtonItem;

	self.navigationItem.rightBarButtonItems = @[editbutton, sendbutton];

	/* We use an old-fashioned way of locating the Documents directory. (The NSManager method for this is iOS 4.0 and later.) */

	NSArray *dirlist = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (!dirlist) {
		dirlist = @[];
	}
	NSString *basedir = dirlist[0];

	[filelists removeAllObjects];
	for (int ux = 0; usages[ux] >= 0; ux++) {
		glui32 usage = usages[ux];
		NSString *dirname = [GlkFileRef subDirOfBase:basedir forUsage:usage gameid:[GlkLibrary singleton].gameId];
		NSMutableArray *files = nil;
		NSArray *ls = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:dirname error:nil];
		if (ls) {
			for (NSString *filename in ls) {
				NSString *pathname = [dirname stringByAppendingPathComponent:filename];
				NSDictionary *attrs = [[NSFileManager defaultManager] attributesOfItemAtPath:pathname error:nil];
				if (!attrs)
					continue;
				if (![NSFileTypeRegular isEqualToString:[attrs fileType]])
					continue;

				/* We accept both dumbass-encoded strings (which were typed by the user) and "normal" strings (which were created by fileref_by_name). */
				NSString *label = StringFromDumbEncoding(filename);
				if (!label)
					label = filename;

				GlkFileThumb *thumb = [[GlkFileThumb alloc] init];
				thumb.filename = filename;
				thumb.pathname = pathname;
				thumb.usage = usage;
				thumb.modtime = [attrs fileModificationDate];
				thumb.label = label;

				if (!files) {
					files = [NSMutableArray arrayWithCapacity:16];
					[filelists addObject:files];
				}
				[files addObject:thumb];
			}
		}
	}

	for (NSMutableArray *files in filelists) {
		[files sortUsingSelector:@selector(compareModTime:)];
	}

	if (filelists.count == 0)
		[self addBlankThumb];

	if (highlightname) {
		// Try to highlight the file that was passed in to us.
		BOOL found = NO;
		int selectsection = 0;
		int selectrow = 0;
		for (selectsection=0; selectsection<filelists.count; selectsection++) {
			NSMutableArray *files = filelists[selectsection];
			for (selectrow=0; selectrow<files.count; selectrow++) {
				GlkFileThumb *thumb = files[selectrow];
				if (thumb.usage != highlightusage) {
					// skip this whole section
					found = NO;
					break;
				}
				if ([highlightname isEqualToString:thumb.filename]) {
					found = YES;
					break;
				}
			}
			if (found)
				break;
		}

		if (found) {
			NSUInteger vals[2];
			vals[0] = selectsection;
			vals[1] = selectrow;
			NSIndexPath *indexpath = [NSIndexPath indexPathWithIndexes:vals length:2];
			[tableView selectRowAtIndexPath:indexpath animated:NO scrollPosition:UITableViewScrollPositionNone];
		}
	}
}

- (void) addBlankThumb {
	GlkFileThumb *thumb = [[GlkFileThumb alloc] init];
	thumb.isfake = YES;
	thumb.modtime = [NSDate date];
	thumb.label = NSLocalizedStringFromTable(@"label.no-share-files", @"TerpLocalize", nil);
	[filelists insertObject:[NSMutableArray arrayWithObject:thumb] atIndex:0];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[tableView setEditing:editing animated:animated];
	self.sendbutton.enabled = NO;
}

- (void) buttonView:(id)sender
{
	NSIndexPath *indexpath = tableView.indexPathForSelectedRow;
	if (!indexpath)
		return;

	GlkFileThumb *thumb = nil;

	int sect = indexpath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexpath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}
	if (!thumb)
		return;

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DisplayText" bundle:nil];

    UINavigationController *navc = [sb instantiateViewControllerWithIdentifier:@"ViewTextNav"];
    DisplayTextViewController *viewc = (DisplayTextViewController *)navc.viewControllers[0];
    viewc.thumb = thumb;

    [self presentViewController:navc animated:YES completion:nil];
}

- (void) buttonSend:(id)sender
{
	NSIndexPath *indexpath = tableView.indexPathForSelectedRow;
	if (!indexpath)
		return;

	GlkFileThumb *thumb = nil;

	int sect = indexpath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexpath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}
	if (!thumb)
		return;

	NSString *temppath = [thumb exportTempFile];
	if (!temppath)
		return;

	self.sharetemppath = temppath;
	NSURL *url = [NSURL fileURLWithPath:temppath];
	self.sharedocic = [UIDocumentInteractionController interactionControllerWithURL:url];
	//NSLog(@"### docic URL %@, UTI %@", url, sharedocic.UTI);
	sharedocic.delegate = self;

	// Removing the temporary file is a nuisance. We *either* remove it at DidDismissOpenInMenu time (if the file was not sent to another app) or didEndSendingToApplication time (if it was). To track this, we'll clear self.sharetemppath at willBeginSendingToApplication time.

	BOOL res = [sharedocic presentOpenInMenuFromBarButtonItem:sender animated:YES];
	if (!res) {
		// The menu never opened at all, so we delete the file now.
		if (self.sharetemppath) {
			[[NSFileManager defaultManager] removeItemAtPath:self.sharetemppath error:nil];
			self.sharetemppath = nil;
		}
		self.sharedocic = nil;

        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedStringFromTable(@"title.noshareapps", @"TerpLocalize", nil) message:NSLocalizedStringFromTable(@"label.noshareapps", @"TerpLocalize", nil) preferredStyle:UIAlertControllerStyleAlert];

        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedStringFromTable(@"button.drat", @"TerpLocalize", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {}]];

        UIPopoverPresentationController *popoverController = alert.popoverPresentationController;
        if (popoverController) {
            popoverController.sourceView = self.view;
            popoverController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 0, 0);
            popoverController.permittedArrowDirections = 0;
        }

        // Present alert sheet.
        [self presentViewController:alert animated:YES completion:nil];
	}
}

// Documentation Interaction delegate methods (see UIDocumentInteractionControllerDelegate)

- (void) documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)docic
{
	if (self.sharetemppath) {
		[[NSFileManager defaultManager] removeItemAtPath:self.sharetemppath error:nil];
		self.sharetemppath = nil;
	}
	self.sharedocic = nil;
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller
		willBeginSendingToApplication:(NSString *)application
{
	// We won't want to delete the temp file at DidDismissOpenInMenu. Clear the path now to make sure of this.
	self.sharetemppath = nil;
}

- (void) documentInteractionController:(UIDocumentInteractionController *)controller
		   didEndSendingToApplication:(NSString *)application
{
	// Delete the temp file. It's no longer kept in self.sharetemppath, so we delete it via the controller's stored URL.
	[[NSFileManager defaultManager] removeItemAtURL:controller.URL error:nil];
}

// Table view data source methods (see UITableViewDataSource)

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
	return filelists.count;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (section < 0 || section >= filelists.count)
		return 0;

	NSMutableArray *files = filelists[section];
	return files.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
	if (section < 0 || section >= filelists.count)
		return @"???";

	NSMutableArray *files = filelists[section];
	// The array should be nonempty.
	if (!files.count)
		return @"???";

	GlkFileThumb *thumb = files[0];
	return [GlkFileThumb labelForFileUsage:thumb.usage localize:@"placeholders"];
}

- (UITableViewCell *) tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"File";

	// This is boilerplate and I haven't touched it.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
	}

	GlkFileThumb *thumb = nil;

	int sect = indexPath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexPath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}

	/* Make the cell look right... */

	if (!thumb) {
		// shouldn't happen
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = NSLocalizedString(@"(null)", nil);
		cell.textLabel.textColor = [UIColor colorNamed:@"CustomText"];
		cell.detailTextLabel.text = @"?";
	}
	else if (thumb.isfake) {
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
		cell.textLabel.text = thumb.label;
		cell.textLabel.textColor = [UIColor lightGrayColor];
		cell.detailTextLabel.text = @"";
	}
	else {
		cell.accessoryType = ((thumb.usage == fileusage_Transcript) ? UITableViewCellAccessoryDetailDisclosureButton : UITableViewCellAccessoryNone);
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = thumb.label;
		cell.textLabel.textColor = [UIColor colorNamed:@"CustomText"];
		cell.detailTextLabel.text = [dateformatter stringFromDate:thumb.modtime];
	}

	return cell;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	GlkFileThumb *thumb = nil;

	int sect = indexPath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexPath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}

	return (thumb && !thumb.isfake);
}

- (void) tableView:(UITableView *)tableview commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		GlkFileThumb *thumb = nil;
		NSMutableArray *files = nil;

		int sect = indexPath.section;
		if (sect >= 0 && sect < filelists.count) {
			files = filelists[sect];
			int row = indexPath.row;
			if (row >= 0 && row < files.count)
				thumb = files[row];
		}

		if (files && thumb && !thumb.isfake) {
			//NSLog(@"selector: deleting file \"%@\" (%@)", thumb.label, thumb.pathname);
			BOOL res = [[NSFileManager defaultManager] removeItemAtPath:thumb.pathname error:nil];
			if (res) {
				[files removeObjectAtIndex:indexPath.row];
				[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
				/*if (filelist.count == 0) {
					[self addBlankThumb];
					[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				}*/
				self.sendbutton.enabled = NO;
			}
		}
	}
}

// Table view delegate (see UITableViewDelegate)

- (void) tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GlkFileThumb *thumb = nil;

	int sect = indexPath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexPath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}

	if (!thumb || thumb.isfake) {
		self.sendbutton.enabled = NO;
		return;
	}

	/* The user has selected a file. */
	self.sendbutton.enabled = YES;
}

- (void) tableView:(UITableView *)tableview accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath
{
	GlkFileThumb *thumb = nil;

	int sect = indexPath.section;
	if (sect >= 0 && sect < filelists.count) {
		NSMutableArray *files = filelists[sect];
		int row = indexPath.row;
		if (row >= 0 && row < files.count)
			thumb = files[row];
	}

	if (!thumb)
		return;
	if (thumb.usage != fileusage_Transcript)
		return;

    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DisplayText" bundle:nil];

    UINavigationController *navc = [sb instantiateViewControllerWithIdentifier:@"ViewTextNav"];
    DisplayTextViewController *viewc = (DisplayTextViewController *)navc.viewControllers[0];
    viewc.thumb = thumb;

	[self.navigationController pushViewController:viewc animated:YES];
}

@end
