/* TranscriptViewController.m: Transcript overview display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import "TranscriptViewController.h"
#import "DisplayTextViewController.h"
#import "IosGlkViewController.h"
#import "RelDateFormatter.h"
#import "GlkLibrary.h"
#import "GlkFileRef.h"
#import "GlkFileTypes.h"
#import "GlkUtilities.h"

@implementation TranscriptViewController

@synthesize tableView;
@synthesize filelist;
@synthesize dateformatter;

- (id) initWithNibName:(NSString *)nibName bundle:(NSBundle *)nibBundle {
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.filelist = [NSMutableArray arrayWithCapacity:16];
		self.dateformatter = [[[RelDateFormatter alloc] init] autorelease];
		[dateformatter setDateStyle:NSDateFormatterMediumStyle];
		[dateformatter setTimeStyle:NSDateFormatterShortStyle];
	}
	return self;
}

- (void) dealloc {
	self.filelist = nil;
	self.dateformatter = nil;
	self.tableView = nil;
	[super dealloc];
}

- (void) viewDidLoad {
	[super viewDidLoad];
	
	self.navigationItem.title = NSLocalizedStringFromTable(@"title.transcripts", @"TerpLocalize", nil);
	
	self.navigationItem.rightBarButtonItem = [self editButtonItem];
	
	/* We use an old-fashioned way of locating the Documents directory. (The NSManager method for this is iOS 4.0 and later.) */
	
	NSArray *dirlist = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	if (!dirlist) {
		dirlist = [NSArray array];
	}
	NSString *basedir = [dirlist objectAtIndex:0];
	NSString *dirname = [GlkFileRef subDirOfBase:basedir forUsage:fileusage_Transcript gameid:[GlkLibrary singleton].gameId];
	
	[filelist removeAllObjects];
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
			
			GlkFileThumb *thumb = [[[GlkFileThumb alloc] init] autorelease];
			thumb.filename = filename;
			thumb.pathname = pathname;
			thumb.modtime = [attrs fileModificationDate];
			thumb.label = label;
			
			[filelist addObject:thumb];
		}
	}
	
	[filelist sortUsingSelector:@selector(compareModTime:)];
	
	if (filelist.count == 0)
		[self addBlankThumb];
}

- (void) addBlankThumb {
	GlkFileThumb *thumb = [[[GlkFileThumb alloc] init] autorelease];
	thumb.isfake = YES;
	thumb.modtime = [NSDate date];
	thumb.label = NSLocalizedStringFromTable(@"label.no-transcripts", @"TerpLocalize", nil);
	[filelist insertObject:thumb atIndex:0];
}

- (void) setEditing:(BOOL)editing animated:(BOOL)animated {
	[super setEditing:editing animated:animated];
	[tableView setEditing:editing animated:animated];
}

// Table view data source methods (see UITableViewDataSource)

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return filelist.count;
}

- (BOOL) tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	GlkFileThumb *thumb = nil;
	
	int row = indexPath.row;
	if (row >= 0 && row < filelist.count)
		thumb = [filelist objectAtIndex:row];
	
	return (thumb && !thumb.isfake);
}

- (UITableViewCell *) tableView:(UITableView *)tableview cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"File";
	
	// This is boilerplate and I haven't touched it.
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
	}
	
	GlkFileThumb *thumb = nil;
	
	int row = indexPath.row;
	if (row >= 0 && row < filelist.count)
		thumb = [filelist objectAtIndex:row];
	
	/* Make the cell look right... */
	
	if (!thumb) {
		// shouldn't happen
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = @"(null)";
		cell.textLabel.textColor = [UIColor blackColor];
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
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.textLabel.text = thumb.label;
		cell.textLabel.textColor = [UIColor blackColor];
		cell.detailTextLabel.text = [dateformatter stringFromDate:thumb.modtime];
	}
	
	return cell;
}

- (void) tableView:(UITableView *)tableview commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		GlkFileThumb *thumb = nil;
		int row = indexPath.row;
		if (row >= 0 && row < filelist.count)
			thumb = [filelist objectAtIndex:row];
		if (thumb && !thumb.isfake) {
			GlkFileThumb *thumb = [filelist objectAtIndex:row];
			NSLog(@"selector: deleting file \"%@\" (%@)", thumb.label, thumb.pathname);
			BOOL res = [[NSFileManager defaultManager] removeItemAtPath:thumb.pathname error:nil];
			if (res) {
				[filelist removeObjectAtIndex:row];
				[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				if (filelist.count == 0) {
					[self addBlankThumb];
					[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
				}
			}
		}
	}
}

// Table view delegate (see UITableViewDelegate)

- (void) tableView:(UITableView *)tableview didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	GlkFileThumb *thumb = nil;
	int row = indexPath.row;
	if (row >= 0 && row < filelist.count)
		thumb = [filelist objectAtIndex:row];
	if (!thumb)
		return;
	if (thumb.isfake)
		return;
	
	NSLog(@"selector: selected \"%@\"", thumb.label);
	
	/* The user has selected a file. */
	DisplayTextViewController *viewc = [[[DisplayTextViewController alloc] initWithNibName:@"DisplayTextVC" thumb:thumb bundle:nil] autorelease];
	[self.navigationController pushViewController:viewc animated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)orientation {
	return [[IosGlkViewController singleton] shouldAutorotateToInterfaceOrientation:orientation];
}

@end
