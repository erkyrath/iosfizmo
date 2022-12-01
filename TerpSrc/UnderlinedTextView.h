//
//  UnderlinedTextView.h
//  iosfizmo
//
//  Created by Administrator on 2022-10-24.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UnderlinedTextView : UITextView

@property (nonatomic) BOOL animating;

- (CAShapeLayer *)createAnimationLayer;

@end

NS_ASSUME_NONNULL_END
