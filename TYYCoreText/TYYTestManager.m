//
//  TYYTestManager.m
//  TYYCoreText
//
//  Created by Null on 17/3/21.
//  Copyright © 2017年 zcs_yang. All rights reserved.
//

#import "TYYTestManager.h"

@implementation TYYTestManager

- (NSArray<TYYLinkModel *> *)addtionalRegexWithRangeString:(NSString *__autoreleasing *)rangeString{
    //a标签
    NSArray *htmlLinks = [self regexHtml:rangeString];
    //股票
    NSArray *stockLinks = [self regexStock:*rangeString];
    //基金
    NSArray *fundLinks = [self regexFund:*rangeString];
    NSMutableArray *list = [NSMutableArray array];
    [list addObjectsFromArray:htmlLinks];
    [list addObjectsFromArray:stockLinks];
    [list addObjectsFromArray:fundLinks];
    return list.copy;
}

- (NSArray <TYYLinkModel *>*)regexHtml:(NSString **)rangeString{
    NSMutableArray *htmllinks = [NSMutableArray array];
    //正则匹配## 话题
    NSString *htmlRegex = @"<a .*>(\\d+|\\D+)</a>";
    NSRegularExpression *htmlExpression = [NSRegularExpression regularExpressionWithPattern:htmlRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [htmlExpression enumerateMatchesInString:*rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, (*rangeString).length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range = result.range;
            link.linkText = [*rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeCustomLink;
            [htmllinks addObject:link];
        }
    }];
    return htmllinks;
}

- (NSArray <TYYLinkModel *>*)regexStock:(NSString *)rangeString{
    NSMutableArray *stocklinks = [NSMutableArray array];
    //正则匹配## 话题
    NSString *stockRegex = @"\\$\\s*\\w+\\s*\\([_a-zA-Z0-9\\.]+\\)\\$";
    NSRegularExpression *stockExpression = [NSRegularExpression regularExpressionWithPattern:stockRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [stockExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range = result.range;
            link.linkText = [rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeCustomLink;
            [stocklinks addObject:link];
        }
    }];
    return stocklinks;
}

- (NSArray <TYYLinkModel *>*)regexFund:(NSString *)rangeString{
    NSMutableArray *fundlinks = [NSMutableArray array];
    //正则匹配## 话题
    NSString *fundRegex = @"\\$\\S*?[_a-zA-Z0-9\\.\\(\\)\\u4e00-\\u9fa5]+?\\s*?\\[[_a-zA-Z0-9\\.]+?\\]\\$";
    NSRegularExpression *fundExpression = [NSRegularExpression regularExpressionWithPattern:fundRegex options:NSRegularExpressionCaseInsensitive error:nil];
    [fundExpression enumerateMatchesInString:rangeString options:NSMatchingReportCompletion range:NSMakeRange(0, rangeString.length) usingBlock:^(NSTextCheckingResult * _Nullable result, NSMatchingFlags flags, BOOL * _Nonnull stop) {
        
        if (result.range.length) {
            TYYLinkModel *link = [[TYYLinkModel alloc]init];
            link.range = result.range;
            link.linkText = [rangeString substringWithRange:result.range];
            link.linkType = TYYLinkTypeCustomLink;
            [fundlinks addObject:link];
        }
    }];
    return fundlinks;
}

@end
