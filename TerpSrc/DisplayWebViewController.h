/* DisplayWebViewController.h: HTML Display view controller
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface DisplayWebViewController : UIViewController <WKNavigationDelegate>

@property (nonatomic, strong) IBOutlet WKWebView *webview;
@property (nonatomic, strong) NSString *filename;
@property (nonatomic, strong) NSString *doctitle;

- (instancetype) initWithNibName:(NSString *)nibName filename:(NSString *)filename title:(NSString *)title bundle:(NSBundle *)nibBundle;

@end
