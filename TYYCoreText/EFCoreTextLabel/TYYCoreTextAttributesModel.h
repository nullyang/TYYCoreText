//
//  TYYCoreTextAttributesModel.h
//  Pods
//
//  Created by Null on 17/3/16.
//
//

#import <UIKit/UIKit.h>

@interface TYYCoreTextAttributesModel : NSObject

#pragma mark - 普通文本部分属性
/**
 普通内容字体大小（默认14）
 */
@property (nonatomic ,strong)UIFont *font;

/**
 普通内容字体颜色（默认黑色）
 */
@property (nonatomic ,strong)UIColor *textColor;

/**
 内容行间距
 */
@property (nonatomic ,assign)CGFloat lineSpacing;

/**
 字间距
 */
@property (nonatomic ,assign)CGFloat wordSpacing;

#pragma mark - emoji和图片部分
/**
 图片和表情的尺寸(如果没有设置，默认是文字的高度)
 */
@property (nonatomic ,assign)CGSize imageSize;

#pragma mark - 链接部分
/**
 链接点中背景透明度(默认0.5)
 */
@property (nonatomic ,assign)CGFloat linkBackAlpha;

/**
 链接字体颜色（默认蓝色）
 */
@property (nonatomic ,strong)UIColor *linkTextColor;

/**
 链接字体大小（默认14）
 */
@property (nonatomic ,strong)UIFont *linkTextFont;

/**
 链接选中背景色（默认灰色）
 */
@property (nonatomic ,strong)UIColor *linkBackgroundColor;

#pragma mark - 关键字部分属性

/**
 关键字颜色（默认红色）
 */
@property (nonatomic ,strong)UIColor *keywordColor;

/**
 关键字透明度（默认0.5）
 */
@property (nonatomic ,assign)CGFloat keywordBackAlpha;

/**
 关键字背景色（默认黄色）
 */
@property (nonatomic ,strong)UIColor *keywordBackgroundColor;
@end
