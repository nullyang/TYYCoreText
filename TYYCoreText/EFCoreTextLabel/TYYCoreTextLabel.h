//
//  TYYCoreTextLabel.h
//  Pods
//
//  Created by Null on 17/3/16.
//
//

/**
 TYYCoreTextLabel是一个仿coreText的控件，目前可以显示表情图片，关键字高亮，@王五 #王宝强离婚# www.baidu.com 这几种类型，
 如果要匹配更多类型，可以通过配置customLinks或者创建一个TYYCoreTextLabelManager子类，并实现-addtionalRegexWithRangeSt
 ring:协议方法，并通过label的-coreTextSubSectionToolOfCoreTextLabel:协议来返回这个TYYCoreTextLabelManager子类实例来
 进行扩展
 */

#import <UIKit/UIKit.h>
#import "TYYCoreTextAttributesModel.h"
#import "TYYCoreTextLabelManager.h"

@class TYYCoreTextLabel;

@protocol TYYCoreTextLabelDelegate <NSObject>

@optional

/**
 点击链接
 */
- (void)coreTextLabel:(TYYCoreTextLabel *)coreTextLabel linkType:(TYYLinkType)linkType linkUrl:(NSString *)linkUrl;

/**
 如果默认的几种链接不能满足需要，可创建一个TYYCoreTextLabelManager子类，并实现-addtionalRegexWithRangeString:协议
 方法，并通过label的-coreTextSubSectionToolOfCoreTextLabel:协议来返回这个TYYCoreTextLabelManager子类实例来进行
 扩展
 */
- (id<TYYCoreTextLabelManagerAdditionalConfigure>)coreTextLabelManagerInCoreTextLabel:(TYYCoreTextLabel *)coreTextLabel;

/**
    如果图片源是bundle文件或者其他，通过这个方法可以返回图片名
 */
- (NSString *)coreTextLabel:(TYYCoreTextLabel *)coreTextLabel availebleImageNameWithImageName:(NSString *)imageName;

@end

@interface TYYCoreTextLabel : UIView

@property (nonatomic ,strong)TYYCoreTextAttributesModel *attributeModel;

@property (nonatomic ,assign)NSInteger numbersOfLines;

@property (nonatomic ,weak)id<TYYCoreTextLabelDelegate> delegate;

/**
 内容添加链接 , 如不需要额外的指定链接 , customLinks传nil ,默认显示常规链接 @ #话题#  web $fundname[fundcode]$
 你可以通过attribute的showDefaultLinks属性设置是否显示最常规的链接
 @param text       原始text
 @param customLinks 自定义的链接
 @param enableLinkTypeList 可匹配的链接类型（1：@sombody，2：#topic#，3：www）
 @param attributeModel 属性model
 */
- (void)configureText:(NSString *)text customLinks:(NSArray <NSString *>*)customLinks keywords:(NSArray <NSString *>*)keywords enableLinkTypeList:(NSArray <NSNumber *>*)enableLinkTypeList attributeModel:(TYYCoreTextAttributesModel *)attributeModel;

@end
