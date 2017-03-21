//
//  TYYCoreTextLabelManager.m
//  Pods
//
//  Created by Null on 17/3/16.
//
//

#import "TYYCoreTextLabelManager.h"
#import "TYYSubCoreTextSection.h"

@interface TYYCoreTextLabelManager ()

@property (nonatomic ,strong)NSString *text;
@property (nonatomic ,strong)NSArray <NSString *>*keywords;
@property (nonatomic ,strong)NSArray <NSString *>*customLinks;
@property (nonatomic ,strong)NSArray <NSString *>*enableRegexTypeList;

@end
@implementation TYYCoreTextLabelManager

- (NSArray <TYYSubCoreTextSection *>*)subCoreTextSectionListSeprateWithEmoji:(NSString *)text customLinks:(NSArray<NSString *> *)customLinks keywords:(NSArray<NSString *> *)keywords enableRegexTypeList:(NSArray<NSString *> *)enableRegexTypeList{
    self.text = text;
    self.customLinks = customLinks;
    self.keywords = keywords;
    self.enableRegexTypeList = enableRegexTypeList;
    if (!self.text.length) {
        return @[];
    }
    //获取所有的表情section
    NSArray *emojiSections = [self getAllEmojiSectionsWithText:text];
    if (!emojiSections.count) {
        TYYSubCoreTextSection *section = [self getNormalTextSectionsWithRange:NSMakeRange(0, text.length)];
        return @[section];
    }
    //返回所有的section数组
    return [self sectionsSepWithEmojiSections:emojiSections];
}

#pragma 获取所有emojiSection
- (NSArray <TYYSubCoreTextSection *>*)getAllEmojiSectionsWithText:(NSString *)text{
    NSMutableArray *emojiSections = [self regexEmoji:text];
    //表情section排序
    [emojiSections sortUsingComparator:^NSComparisonResult(TYYSubCoreTextSection *_Nonnull section1, TYYSubCoreTextSection  *_Nonnull section2) {
        return section1.range.location > section2.range.location;
    }];
    return emojiSections.copy;
}

#pragma mark - 根据emojiSection分割文本
- (NSArray <TYYSubCoreTextSection *>*)sectionsSepWithEmojiSections:(NSArray <TYYSubCoreTextSection *>*)emojiSections{
    NSMutableArray <TYYSubCoreTextSection*>*sections = @[].mutableCopy;
    //先将emojisection加入
    [sections addObjectsFromArray:emojiSections];
    
    [emojiSections enumerateObjectsUsingBlock:^(TYYSubCoreTextSection  *_Nonnull emojiSecion, NSUInteger idx, BOOL * _Nonnull stop) {
        //如果只有一个emoji
        if (emojiSections.count == 1) {
            NSArray *normalSections = [self.text componentsSeparatedByString:emojiSecion.string];
            if (normalSections.count) {
                if ([normalSections.firstObject length]) {
                    TYYSubCoreTextSection *firstSection = [self getNormalTextSectionsWithRange:[self.text rangeOfString:normalSections.firstObject]];
                    [sections insertObject:firstSection atIndex:0];
                }
                if ([normalSections.lastObject length]) {
                    TYYSubCoreTextSection *lastSection = [self getNormalTextSectionsWithRange:[self.text rangeOfString:normalSections.lastObject]];
                    [sections addObject:lastSection];
                }
            }
            *stop = YES;
        }
        //第一个
        else if (idx == 0) {
            //插入最前面文本
            TYYSubCoreTextSection *firstNormalSection = nil;
            //不是从0开始,剪切之前的文本
            if (emojiSecion.range.location != 0) {
                firstNormalSection = [self getNormalTextSectionsWithRange:NSMakeRange(0, emojiSecion.range.location)];
            }
            if (firstNormalSection) {
                [sections insertObject:firstNormalSection atIndex:0];
            }
        }else {
            //插入中间普通文本
            TYYSubCoreTextSection *midNormalSection = [self getMiddleNormalSectionWithEmojiSection:emojiSecion preEmojiSection:emojiSections[idx-1]];
            if (midNormalSection) {
                [sections insertObject:midNormalSection atIndex:[sections indexOfObject:emojiSecion]];
            }
            
            //最后一个链接处理
            if (idx == emojiSections.count -1) {
                TYYSubCoreTextSection *lastNormalSection = [self getLastNormalSectionWithLastEmojiSection:emojiSecion];
                if (lastNormalSection) {
                    [sections addObject:lastNormalSection];
                }
            }
        }
    }];
    return sections;
}

#pragma mark - 获取两个emojiSection中间的文本
- (TYYSubCoreTextSection *)getMiddleNormalSectionWithEmojiSection:(TYYSubCoreTextSection *)emojiSection preEmojiSection:(TYYSubCoreTextSection *)preEmojiSection{
    NSInteger currentLocation = emojiSection.range.location;
    NSInteger preLocation = preEmojiSection.range.location;
    NSInteger preLength = preEmojiSection.range.length;
    //获取文本
    NSInteger length = currentLocation - preLocation - preLength;
    NSInteger location = preLocation + preEmojiSection.range.length;
    
    if (length) {
        return [self getNormalTextSectionsWithRange:NSMakeRange(location, length)];
    }
    return nil;
}

#pragma mark - 最后一个文本
- (TYYSubCoreTextSection *)getLastNormalSectionWithLastEmojiSection:(TYYSubCoreTextSection *)lastEmojiSection {
    NSInteger location = lastEmojiSection.range.location + lastEmojiSection.range.length;
    if (lastEmojiSection.range.location +lastEmojiSection.range.length < self.text.length) {
        return [self getNormalTextSectionsWithRange:NSMakeRange(location, self.text.length - location)];
    }
    return nil;
}

#pragma mark - 除了表情外的其他文本
- (TYYSubCoreTextSection *)getNormalTextSectionsWithRange:(NSRange)range{
    NSString *rangeString = [self.text substringWithRange:range];
    TYYSubCoreTextSection *rangeSection = [[TYYSubCoreTextSection alloc]init];
    rangeSection.range = range;
    rangeSection.isEmoji = NO;
    
    NSMutableArray <TYYLinkModel *>*linkModelList = @[].mutableCopy;
    //必须先执行协议中的正则(有可能协议中会将原字符串修改)
    if ([self respondsToSelector:@selector(addtionalRegexWithRangeString:)]) {
        NSArray *additiLinks = [self addtionalRegexWithRangeString:&rangeString];
        [linkModelList addObjectsFromArray:additiLinks];
    }
    //必须在这里设置string，因为在协议方法里可能会修改
    rangeSection.string = rangeString;
    for (NSNumber *regexTypeValue in self.enableRegexTypeList) {
        NSInteger regexType = [regexTypeValue integerValue];
        switch (regexType) {
            case TYYLinkTypeTrendLink:{
                //匹配@someBody
                NSArray *trends = [self regexTrend:rangeString];
                [linkModelList addObjectsFromArray:trends];
            }
                break;
            case TYYLinkTypeTopicLink:{
                //匹配#话题#
                NSArray *topics = [self regexTopic:rangeString];
                [linkModelList addObjectsFromArray:topics];
            }
                break;
            case TYYLinkTypeWebLink:{
                //匹配网址
                NSArray *webs = [self regexWebs:rangeString];
                [linkModelList addObjectsFromArray:webs];
            }
                break;
            default:
                break;
        }
    }
    
    //匹配关键字
    NSArray *keywords = [self regexKeyword:rangeString];
    [linkModelList addObjectsFromArray:keywords];
    
    //匹配自定义链接
    NSArray *tagStrs = [self regexCustomLinks:rangeString];
    [linkModelList addObjectsFromArray:tagStrs];
    
    rangeSection.links = linkModelList;
    return rangeSection;
}

#pragma mark - 匹配emoji
- (NSMutableArray <TYYSubCoreTextSection *>*)regexEmoji:(NSString *)text{
    NSMutableArray<TYYSubCoreTextSection *> *emojiSections = [NSMutableArray array];
    //正则匹配表情
    NSError *error = nil;
    NSString *emojiRegex = @"\\[[\u4E00-\u9FA5]*\\]";
    NSRegularExpression *emojiExpression = [NSRegularExpression regularExpressionWithPattern:emojiRegex options:NSRegularExpressionCaseInsensitive error:&error];
    [emojiExpression enumerateMatchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length) {
            TYYSubCoreTextSection *section = [[TYYSubCoreTextSection alloc]init];
            section.isEmoji = YES;
            section.range = result.range;
            section.string = [text substringWithRange:result.range];
            [emojiSections addObject:section];
        }
    }];
    return emojiSections;
}

#pragma mark - 匹配网址
- (NSArray <TYYLinkModel *>*)regexWebs:(NSString *)rangeString{
    NSMutableArray *weblinks = [NSMutableArray array];
    //正则匹配超链接
    NSString *linkRegex = @"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|(www.[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)";
    NSRegularExpression *linkExpression = [NSRegularExpression regularExpressionWithPattern:linkRegex options:NSRegularExpressionCaseInsensitive error:nil];
    //遍历结果
    [linkExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range  = result.range;
            link.linkText = [rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeWebLink;
            [weblinks addObject:link];
        }
    }];
    return weblinks;
}

#pragma mark - 匹配 @someBody
- (NSArray <TYYLinkModel *>*)regexTrend:(NSString *)rangeString{
    NSMutableArray *trendlinks = [NSMutableArray array];
    //正则匹配 @
    NSString *trendRegex = @"@[a-zA-Z0-9\\u4e00-\\u9fa5\\-]+ ?";
    NSRegularExpression *trendExpression = [NSRegularExpression regularExpressionWithPattern:trendRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [trendExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range = result.range;
            link.linkText = [rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeTrendLink;
            [trendlinks addObject:link];
        }
    }];
    return trendlinks;
}

#pragma mark - 匹配 #话题#
- (NSArray <TYYLinkModel *>*)regexTopic:(NSString *)rangeString{
    NSMutableArray *topiclinks = [NSMutableArray array];
    //正则匹配## 话题
    NSString *topicRegex = @"#[a-zA-Z0-9\\u4e00-\\u9fa5]+#";
    NSRegularExpression *topicExpression = [NSRegularExpression regularExpressionWithPattern:topicRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [topicExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range = result.range;
            link.linkText = [rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeTopicLink;
            [topiclinks addObject:link];
        }
    }];
    return topiclinks;
}

#pragma mark - 匹配关键字 keyword
- (NSArray <TYYLinkModel *>*)regexKeyword:(NSString *)rangeString{
    NSMutableArray *keywords = [NSMutableArray array];
    //正则匹配关键字keyword
    if (!self.keywords.count){
        return nil ;
    }
    
    for (NSString *keywordReges in self.keywords) {
        NSRegularExpression *keywordExpression = [NSRegularExpression regularExpressionWithPattern:keywordReges options:NSRegularExpressionCaseInsensitive error:nil];
        [keywordExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if (result.range.length) {
                TYYLinkModel *link = [[TYYLinkModel alloc]init];
                link.range = result.range;
                link.linkText = [rangeString substringWithRange:result.range];
                link.linkType = TYYLinkTypeKeyword;
                [keywords addObject:link];
            }
        }];
    }
    return keywords;
}

#pragma mark - 匹配自定义链接
- (NSArray <TYYLinkModel *>*)regexCustomLinks:(NSString *)rangeString{
    NSMutableArray *customLinks = [NSMutableArray array];
    //正则匹配指定链接字符串
    if (!self.customLinks.count) {
        return nil;
    };
    
    [self.customLinks enumerateObjectsUsingBlock:^(NSString  *_Nonnull linkText, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSRegularExpression *customLinkExpression = [NSRegularExpression regularExpressionWithPattern:linkText options:NSRegularExpressionCaseInsensitive error:nil];
        [customLinkExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
            
            if (result.range.length) {
                TYYLinkModel *link = [[TYYLinkModel alloc]init];
                link.range = result.range;
                link.linkText = [rangeString substringWithRange:result.range];
                link.linkType = TYYLinkTypeCustomLink; //自定义链接
                [customLinks addObject:link];
            }
        }];
    }];
    return customLinks;
}

@end
