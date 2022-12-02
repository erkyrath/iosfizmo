/* UnderlinedTextView.m: A UITextView subclass with underlined text
 for IosFizmo, an IosGlk port of the Fizmo Z-machine interpreter.
 Designed by Andrew Plotkin <erkyrath@eblong.com>
 http://eblong.com/zarf/glk/
 */

#import <CoreGraphics/CGContext.h>
#import "UnderlinedTextView.h"

@interface UnderlinedTextView ()
{
    CGFloat lineHeight;
    CGFloat lastY;
}

@end


@implementation UnderlinedTextView

- (void)awakeFromNib {
    [super awakeFromNib];
    lineHeight = 0;
    lastY = 0;
}

- (void)drawRect:(CGRect)rect {

    if (lineHeight == 0)
        [self getLineHeight];

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorNamed:@"CustomNoteLines"].CGColor);
    CGFloat topInset = self.textContainerInset.top;

    UITextPosition *start = [self closestPositionToPoint:rect.origin];
    CGFloat y = topInset - 3;

    if (!_animating) {
        // Get the bottom of the topmost visible line, if any
        if (start && self.layoutManager.numberOfGlyphs)
        {
            NSUInteger index = [self offsetFromPosition:start toPosition:start];
            
            NSRange lineRange = NSMakeRange(0, 1);
            
            CGRect fragmentRect = [self.layoutManager lineFragmentRectForGlyphAtIndex:index effectiveRange:&lineRange withoutAdditionalLayout:YES];
            
            y += CGRectGetMaxY(fragmentRect);
            lastY = y;
        }

        while (y <= CGRectGetMaxY(rect)) {
            CGMutablePathRef line = CGPathCreateMutable();
            CGContextMoveToPoint(ctx, 0.0, y);
            CGContextAddLineToPoint(ctx, rect.size.width, y);
            CGContextAddPath(ctx, line);
            CGPathRelease(line);
            y += lineHeight;
        }
        CGContextStrokePath(ctx);
    }

    [super drawRect:rect];
}

- (void)getLineHeight {
    NSUInteger numberOfGlyphs = self.layoutManager.numberOfGlyphs;
    NSLayoutManager *layoutManager = self.layoutManager;

    if (!numberOfGlyphs) { // If the text view has no text, we create a dummy text view
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithString:@"Å\n"];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:self.textContainer.size];
        layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [textStorage addAttribute:NSFontAttributeName
                            value:self.font
                            range:NSMakeRange(0, textStorage.length)];
        [layoutManager glyphRangeForTextContainer:textContainer];
    }

    CGRect fragmentRect = [layoutManager lineFragmentRectForGlyphAtIndex:0 effectiveRange:nil withoutAdditionalLayout:YES];
    lineHeight = fragmentRect.size.height;

    if (lineHeight == 0)
        lineHeight = 25.84;
}

// Hack to hide the fact that the lines get out of sync with
// the text during the contentInset change animation when
// the keyboard is closed. We stop drawing lines in drawRect
// during the animation and instead add a temporary CAShapeLayer
// with identical lines, which for some reason makes it look right.

- (CAShapeLayer *)createAnimationLayer {
    CAShapeLayer *pathLayer = [CAShapeLayer layer];
    CGRect frame = self.bounds;

    frame.origin.y = lastY - 5; // No idea why we have to subtract 5 here
    pathLayer.frame = frame;
    pathLayer.strokeColor = [UIColor colorNamed:@"CustomNoteLines"].CGColor;
    pathLayer.lineWidth = 1.0;
    UIBezierPath *path = [UIBezierPath bezierPath];

    for (CGFloat y = lastY; y <= CGRectGetMaxY(self.bounds); y += lineHeight) {
        [path moveToPoint:CGPointMake(0.0,y)];
        [path addLineToPoint:CGPointMake(self.bounds.size.width, y)];
    }
    pathLayer.path = path.CGPath;
    return pathLayer;
}

@end
