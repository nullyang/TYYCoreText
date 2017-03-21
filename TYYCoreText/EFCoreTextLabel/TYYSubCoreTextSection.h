//
//  TYYSubCoreTextResult.h
//  Pods
//
//  Created by Null on 17/3/16.
//
//

#import <UIKit/UIKit.h>
@class TYYLinkModel;

/**
 默认是将按表情将整段文字分割为n个TYYSubCoreTextResult类型的对象（包含emoji表情）
 */
@interface TYYSubCoreTextSection : NSObject
/**
 本段字符串
 */
@property (nonatomic ,strong)NSString *string;

/**
 本段在整段文字的范围
 */
@property (nonatomic ,assign)NSRange range;

/**
 是否是emoji部分
 */
@property (nonatomic ,assign)BOOL isEmoji;

/**
 本段文字的所有链接
 */
@property (nonatomic ,strong)NSArray <TYYLinkModel *>*links;
@end

typedef NS_ENUM(NSInteger,TYYLinkType){
    TYYLinkTypeNotAvailble = 0, /**< 无效*/
    TYYLinkTypeTrendLink   = 1, /**< @someBody */
    TYYLinkTypeTopicLink   = 2, /**< #话题# */
    TYYLinkTypeWebLink     = 3, /**< http */
    TYYLinkTypeCustomLink  = 4, /**< 自定义链接 */
    TYYLinkTypeKeyword     = 5  /**< 关键字(高亮文字)*/
};

@interface TYYLinkModel : NSObject
/**
 链接内容
 */
@property (nonatomic ,strong)NSString *linkText;

/**
 链接地址
 */
@property (nonatomic ,strong)NSString *linkUrl;

/**
 链接点击影响区域
 */
@property (nonatomic ,strong) NSArray <UITextSelectionRect *>*rects;

/**
 链接在section中的范围
 */
@property (nonatomic ,assign)NSRange range;

/**
 链接类型
 */
@property (nonatomic ,assign)TYYLinkType linkType;
@end
