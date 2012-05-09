/* DisplayWebViewController.h: HTML Display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>

@interface DisplayWebViewController : UIViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIWebView *webview;
@property (nonatomic, retain) NSString *filename;
@property (nonatomic, retain) NSString *doctitle;

- (id) initWithNibName:(NSString *)nibName filename:(NSString *)filename title:(NSString *)title bundle:(NSBundle *)nibBundle;

@end
