//
//  TYYCoreTextAttributesModel.m
//  Pods
//
//  Created by Null on 17/3/16.
//
//

#import "TYYCoreTextAttributesModel.h"

static CGFloat EFDefaultLinkBackAlpha = 0.5;

@implementation TYYCoreTextAttributesModel

- (instancetype)init{
    if (self = [super init]) {
        _linkBackAlpha = EFDefaultLinkBackAlpha;
        _keywordBackAlpha = EFDefaultLinkBackAlpha;
    }
    return self;
}

#pragma mark - 普通文本部分属性

- (UIFont *)font{
    if (_font) {
        return _font;
    }
    return [UIFont systemFontOfSize:14.f];
}

- (UIColor *)textColor{
    if (_textColor) {
        return _textColor;
    }
    return [UIColor blackColor];
}

#pragma mark - emoji和图片部分

- (CGSize)imageSize{
    if (_imageSize.height > 0 && _imageSize.width > 0) {
        return _imageSize;
    }
    return CGSizeMake(self.font.lineHeight, self.font.lineHeight);
}

#pragma mark - 链接部分

- (UIFont *)linkTextFont{
    if (_linkTextFont) {
        return _linkTextFont;
    }
    return self.font;
}

- (UIColor *)linkTextColor{
    if (_linkTextColor) {
        return _linkTextColor;
    }
    return [UIColor blueColor];
}

- (UIColor *)linkBackgroundColor{
    if (_linkBackgroundColor) {
        return _linkBackgroundColor;
    }
    return [UIColor grayColor];
}

#pragma mark - 关键字部分属性

- (UIColor *)keywordColor{
    if (_keywordColor) {
        return _keywordColor;
    }
    return [UIColor redColor];
}

- (UIColor *)keywordBackgroundColor{
    if (_keywordBackgroundColor) {
        return _keywordBackgroundColor;
    }
    return [UIColor yellowColor];
}

@end
