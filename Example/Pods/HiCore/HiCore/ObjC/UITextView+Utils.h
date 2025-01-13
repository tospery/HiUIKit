//
//  UITextView+Utils.h
//  HiUtils
//
//  Created by 杨建祥 on 2024/5/16.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITextView (Utils)
@property (nonatomic, readonly) UITextView *placeholderTextView NS_SWIFT_NAME(placeholderTextView);

@property (nonatomic, strong, nullable) IBInspectable NSString *placeholder;
@property (nonatomic, strong, nullable) NSAttributedString *attributedPlaceholder;
@property (nonatomic, strong, nullable) IBInspectable UIColor *placeholderColor;

+ (UIColor *)defaultPlaceholderColor;

@end

NS_ASSUME_NONNULL_END
