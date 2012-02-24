//
//  DisplayTextViewController.m
//  IosFizmo
//
//  Created by Andrew Plotkin on 2/23/12.
//  Copyright (c) 2012 Zarfhome. All rights reserved.
//

#import "DisplayTextViewController.h"
#import "RelDateFormatter.h"
#import "GlkFileTypes.h"

@implementation DisplayTextViewController

@synthesize textview;
@synthesize titlelabel;
@synthesize datelabel;
@synthesize thumb;

- (id) initWithNibName:(NSString *)nibName thumb:(GlkFileThumb *)thumbref bundle:(NSBundle *)nibBundle
{
	self = [super initWithNibName:nibName bundle:nibBundle];
	if (self) {
		self.thumb = thumbref;
	}
	return self;
}

- (void) dealloc {
	self.thumb = nil;
	self.textview = nil;
	self.titlelabel = nil;
	self.datelabel = nil;
	[super dealloc];
}

- (void) viewDidLoad
{
	[super viewDidLoad];

	self.navigationItem.title = @"Transcript"; //### localize

	UIBarButtonItem *sendbutton = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(buttonSend:)] autorelease];
	sendbutton.enabled = [MFMailComposeViewController canSendMail];
	self.navigationItem.rightBarButtonItem = sendbutton;

	titlelabel.text = thumb.label;
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		/* No room for this on the iphone layout */
		datelabel.hidden = YES;
	}
	else {
		RelDateFormatter *dateformatter = [[[RelDateFormatter alloc] init] autorelease];
		datelabel.text = [dateformatter stringFromDate:thumb.modtime];
	}

	NSString *str = [NSString stringWithContentsOfFile:thumb.pathname encoding:NSUTF8StringEncoding error:nil];
	if (str)
		textview.text = str;
}

- (void) buttonSend:(id)sender
{
	MFMailComposeViewController *compose = [[MFMailComposeViewController alloc] init];
	compose.mailComposeDelegate = self;
	
	[compose setSubject:[@"Transcript: " stringByAppendingString:thumb.label]];
    [compose setMessageBody:textview.text isHTML:NO];

	[self presentModalViewController:compose animated:YES];
    [compose release]; // Can safely release the controller now.
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
