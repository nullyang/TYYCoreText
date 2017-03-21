//
//  TYYCoreTextLabelManager.h
//  Pods
//
//  Created by Null on 17/3/16.
//
//


#import <Foundation/Foundation.h>
#import "TYYSubCoreTextSection.h"

@protocol TYYCoreTextLabelManagerAdditionalConfigure <NSObject>

/**
 如果有其他需要匹配的情况，请继承TYYCoreTextLabelManager，并遵循以下协议
 */
@optional
- (NSArray <TYYLinkModel *>*)addtionalRegexWithRangeString:(NSString *__autoreleasing *)rangeString;

@end

@interface TYYCoreTextLabelManager : NSObject<TYYCoreTextLabelManagerAdditionalConfigure>
/**
 使用表情进行切割（之所以使用emoji表情来切割，主要是考虑到将原始text转为含有emiji表情的属性字符串后，
 会导致属性字符串的长度和每个链接的range发生改变，而将text分割后，每个Section内的链接的位置相对于Section
 本身来说，是不变的）
 @param text 待分割的文字
 @return 分割后的所有子section
 @param customLinks 额外链接
 @param keywords 关键字列表
 @param enableRegexTypeList 可匹配的链接类型（1：@sombody，2：#topic#，3：www）
 */
- (NSArray <TYYSubCoreTextSection *>*)subCoreTextSectionListSeprateWithEmoji:(NSString *)text customLinks:(NSArray <NSString *>*)customLinks keywords:(NSArray <NSString *>*)keywords enableRegexTypeList:(NSArray <NSNumber *>*)enableRegexTypeList;


@end
