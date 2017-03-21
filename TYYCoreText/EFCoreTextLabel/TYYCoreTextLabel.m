//
//  TYYCoreTextLabel.m
//  Pods
//
//  Created by Null on 17/3/16.
//
//

#define TYYCoreTextLabelCoverTag    998
#define TYYCoreTextKeywordCoverTag 1998
#define TYYCoreTextAttributeLinkType @"TYYCoreTextAttributeLinkType"
#define TYYCoreTextAttributeKeywordType @"TYYCoreTextAttributeKeywordType"

#import "TYYCoreTextLabel.h"
#import "TYYSubCoreTextSection.h"
#import "TYYCoreTextLabelManager.h"
#import <Masonry.h>

@interface TYYCoreTextLabel ()
@property (nonatomic ,strong)UITextView *contentTextView; //
@property (nonatomic ,strong)NSArray <TYYLinkModel *>*linkList; //所有的链接model
@property (nonatomic ,strong)NSArray <TYYSubCoreTextSection *>*subCoreTextSectionList; //所有subSection
@property (nonatomic ,copy)NSString *text; //文本
@property (nonatomic ,strong)NSArray *keywords;//关键字
@property (nonatomic ,strong)NSArray *customLinks; //自定义链接
@property (nonatomic ,strong)NSArray *enableLinkTypeList;//正则选项
@property (nonatomic ,strong)TYYLinkModel *currentTouchLink; //当前手指所在链接model
@property (nonatomic ,assign,getter=isKeywordConfiged)BOOL keywordConfig; //临时记录用

@property (nonatomic ,strong)TYYCoreTextLabelManager *coreTextLabelManager;

@end

@implementation TYYCoreTextLabel

- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentTextView];
        [self.contentTextView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

- (void)configureText:(NSString *)text customLinks:(NSArray<NSString *> *)customLinks keywords:(NSArray<NSString *> *)keywords enableLinkTypeList:(NSArray<NSNumber *> *)enableLinkTypeList attributeModel:(TYYCoreTextAttributesModel *)attributeModel{
    self.text = text;
    self.keywords = keywords;
    self.customLinks = customLinks;
    self.enableLinkTypeList = enableLinkTypeList;
    if (!attributeModel) {
        self.attributeModel = [[TYYCoreTextAttributesModel alloc]init];
    }else {
        self.attributeModel = attributeModel;
    }
}

- (void)setAttributeModel:(TYYCoreTextAttributesModel *)attributeModel{
    _attributeModel = attributeModel;
    if (!self.text.length) {
        return;
    };
    //清除之前的
    [self clearForeRecord];
    [self configAttributeString];
}

- (void)setNumbersOfLines:(NSInteger)numbersOfLines{
    _numbersOfLines = numbersOfLines;
    self.contentTextView.textContainer.maximumNumberOfLines = numbersOfLines;
}

- (void)clearForeRecord{
    self.subCoreTextSectionList = nil;
    self.linkList = nil;
    self.keywordConfig = NO;
    for (UIView *view in self.subviews) {
        if (view.tag == TYYCoreTextKeywordCoverTag) {
            [view removeFromSuperview];
        }
    }
}

- (void)configAttributeString{
    NSMutableAttributedString *attributeStr = [[NSMutableAttributedString alloc]init];
    //遍历sections
    [self.subCoreTextSectionList enumerateObjectsUsingBlock:^(TYYSubCoreTextSection * _Nonnull section, NSUInteger idx, BOOL * _Nonnull stop) {
        //表情/图片
        if (section.isEmoji) {
            NSTextAttachment *attachmeent = [[NSTextAttachment alloc]init];
            UIImage *emojiImage = [UIImage imageNamed:section.string];
            if (!emojiImage && [self.delegate respondsToSelector:@selector(coreTextLabel:availebleImageNameWithImageName:)]) {
                emojiImage = [UIImage imageNamed:[self.delegate coreTextLabel:self availebleImageNameWithImageName:section.string]];
            }
            if (emojiImage) {
                attachmeent.image = emojiImage;
                attachmeent.bounds = CGRectMake(0, -3, self.attributeModel.imageSize.width, self.attributeModel.imageSize.height);
                NSAttributedString *imageAttributeStr = [NSAttributedString attributedStringWithAttachment:attachmeent];
                [attributeStr appendAttributedString:imageAttributeStr];
            }else{
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:section.string];
                [self settingNomalAttrbute:string];
                [attributeStr appendAttributedString:string];
            }
        }else {
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:section.string];
            //先设置为普通文本属性
            [self settingNomalAttrbute:string];
            //设置链接属性
            if (section.links.count) {
                for (TYYLinkModel *link in section.links) {
                    if (link.linkType != TYYLinkTypeKeyword && link.linkType != TYYLinkTypeNotAvailble) {
                        //将link数组存储到属性中，后续可以通过属性取出，同时也能获取新的range
                        [string addAttribute:TYYCoreTextAttributeLinkType value:link range:link.range];
                        //设置链接属性
                        [self settingLinkAttribute:string range:link.range];
                    }else if (link.linkType == TYYLinkTypeKeyword){
                        //将关键字存在属性中
                        [string addAttribute:TYYCoreTextAttributeKeywordType value:[section.string substringWithRange:link.range] range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:self.attributeModel.keywordColor range:link.range];
                    }else {
                        [string addAttribute:NSForegroundColorAttributeName value:self.attributeModel.textColor range:link.range];
                    }
                }
            }
            [attributeStr appendAttributedString:string];
        }
    }];
    self.contentTextView.attributedText = attributeStr;
}

#pragma mark - 文本属性设置
// 设置普通文本
- (void)settingNomalAttrbute:(NSMutableAttributedString *)attributeStr{
    [attributeStr addAttribute:NSFontAttributeName value:self.attributeModel.font range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:self.attributeModel.textColor range:NSMakeRange(0, attributeStr.length)];
    NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc]init];
    paragra.lineBreakMode = NSLineBreakByCharWrapping;
    paragra.lineSpacing = self.attributeModel.lineSpacing;
    [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragra range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSKernAttributeName value:@(self.attributeModel.wordSpacing) range:NSMakeRange(0, attributeStr.length)];
}

//链接属性
- (void)settingLinkAttribute:(NSMutableAttributedString *)attriteStr range:(NSRange)linkRange{
    [attriteStr addAttribute:NSForegroundColorAttributeName value:self.attributeModel.linkTextColor range:linkRange];
    [attriteStr addAttribute:NSFontAttributeName value:self.attributeModel.linkTextFont range:linkRange];
}

// 高亮关键字设置
- (void)highlightKeywords{
    if (!self.keywords.count) {
        return;
    }
    NSAttributedString *attributeStr = self.contentTextView.attributedText;
    [attributeStr enumerateAttribute:TYYCoreTextAttributeKeywordType inRange:NSMakeRange(0, attributeStr.length) options:0 usingBlock:^(NSString *str, NSRange range, BOOL * _Nonnull stop) {
        if (![self.keywords containsObject:str] || !range.length) {
            return ;
        }
        //计算选中区域
        self.contentTextView.selectedRange = range;//设置selectedRange，会直接影响selectedTextRange
        NSArray *coverRects = [self.contentTextView selectionRectsForRange:self.contentTextView.selectedTextRange];
        for (UITextSelectionRect *rect in coverRects) {
            if (!rect.rect.size.width || !rect.rect.size.height) {
                continue;
            };
            UIView *keywordView = [[UIView alloc]init];
            keywordView.backgroundColor = self.attributeModel.keywordBackgroundColor;
            keywordView.alpha = self.attributeModel.keywordBackAlpha;
            keywordView.layer.cornerRadius = 3.f;
            keywordView.clipsToBounds = YES;
            keywordView.tag = TYYCoreTextKeywordCoverTag;
            keywordView.frame = rect.rect;
            [self insertSubview:keywordView atIndex:0];
        }
    }];
}

#pragma mark - 点击检测
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    CGPoint touchPoint = [[touches anyObject] locationInView:self.contentTextView];
    self.currentTouchLink = [self linkModelAtPoint:touchPoint];
    [self addSelectedAnimation];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if (self.currentTouchLink) {
        if ([self.delegate respondsToSelector:@selector(coreTextLabel:linkType:linkUrl:)]) {
            [self.delegate coreTextLabel:self linkType:self.currentTouchLink.linkType linkUrl:self.currentTouchLink.linkUrl?:self.currentTouchLink.linkText];
        }
    }
    [self addDismissAnimation];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *moveTouch = [touches anyObject];
    CGPoint movePoint = [moveTouch locationInView:moveTouch.view];
    //当前触摸点是否还在之前的连接上
    BOOL isContained = NO;
    for (UITextSelectionRect *rect in self.currentTouchLink.rects) {
        if (CGRectContainsPoint(rect.rect, movePoint)) {
            isContained = YES;
        }
    }
    if (!isContained) {
        [self addDismissAnimation];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self addDismissAnimation];
}

- (TYYLinkModel *)linkModelAtPoint:(CGPoint)touchPoint{
    TYYLinkModel *linkModel = nil;
    for (TYYLinkModel *link in self.linkList) {
        for (UITextSelectionRect *rect in link.rects) {
            if (CGRectContainsPoint(rect.rect, touchPoint)) {
                linkModel = link;
                break;
            }
        }
    }
    return linkModel;
}

- (void)addSelectedAnimation{
    [self.currentTouchLink.rects enumerateObjectsUsingBlock:^(UITextSelectionRect * _Nonnull rect, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *coverView = [[UIView alloc]init];
        coverView.backgroundColor = self.attributeModel.linkBackgroundColor;
        coverView.alpha = self.attributeModel.linkBackAlpha;
        coverView.frame = rect.rect;
        coverView.tag = TYYCoreTextLabelCoverTag;
        coverView.layer.cornerRadius = 3.f;
        coverView.clipsToBounds = YES;
        [self insertSubview:coverView atIndex:0];
    }];
}

- (void)addDismissAnimation{
    self.currentTouchLink = nil;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *coverView in self.subviews) {
            if (coverView.tag == TYYCoreTextLabelCoverTag) {
                [coverView removeFromSuperview];
            }
        }
    });
}

#pragma mark - 计算尺寸

- (void)layoutSubviews{
    [super layoutSubviews];
//    self.contentTextView.frame = self.bounds;
    if (self.isKeywordConfiged) {
        return;
    }
    //设置高亮关键字
    [self highlightKeywords];
    self.keywordConfig = YES;
}

- (CGSize)sizeThatFits:(CGSize)size{
    if (!self.contentTextView.attributedText.length) {
        return CGSizeZero;
    }
    CGSize viewSize = [self.contentTextView sizeThatFits:CGSizeMake(size.width, size.height)];
    return viewSize;
}

- (UITextView *)contentTextView{
    if (_contentTextView) {
        return _contentTextView;
    }
    _contentTextView = [[UITextView alloc]init];
    _contentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _contentTextView.editable = NO;
    _contentTextView.userInteractionEnabled = NO;
    _contentTextView.scrollEnabled = NO;
    _contentTextView.backgroundColor = [UIColor clearColor];
    return _contentTextView;
}

- (NSArray<TYYLinkModel *> *)linkList{
    if (_linkList) {
        return _linkList;
    }
    NSMutableArray *list = @[].mutableCopy;
    [self.contentTextView.attributedText enumerateAttribute:TYYCoreTextAttributeLinkType inRange:NSMakeRange(0, self.contentTextView.attributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
        TYYLinkModel *link = nil;
        if (value && [value isKindOfClass:[TYYLinkModel class]]) {
            link = (TYYLinkModel *)value;
            //更新range
            link.range = range;
        }
        if (link) {
            self.contentTextView.selectedRange = link.range;
            NSArray *selectedRects = [self.contentTextView selectionRectsForRange:self.contentTextView.selectedTextRange];
            NSMutableArray *rects  = [NSMutableArray array];
            for (UITextSelectionRect *rect  in selectedRects) {
                if (!rect.rect.size.width||!rect.rect.size.height) {
                    continue;
                };
                [rects addObject:rect];
            }
            link.rects = rects;
            [list addObject:link];
        }
    }];
    _linkList = list.copy;
    return _linkList;
}

- (NSArray<TYYSubCoreTextSection *> *)subCoreTextSectionList{
    if (_subCoreTextSectionList) {
        return _subCoreTextSectionList;
    }
    _subCoreTextSectionList = [self.coreTextLabelManager subCoreTextSectionListSeprateWithEmoji:self.text customLinks:self.customLinks keywords:self.keywords enableRegexTypeList:self.enableLinkTypeList];
    return _subCoreTextSectionList;
}

- (TYYCoreTextLabelManager *)coreTextLabelManager{
    if (_coreTextLabelManager) {
        return _coreTextLabelManager;
    }
    if ([self.delegate respondsToSelector:@selector(coreTextLabelManagerInCoreTextLabel:)]) {
        _coreTextLabelManager = [self.delegate coreTextLabelManagerInCoreTextLabel:self];
    }else {
        _coreTextLabelManager = [[TYYCoreTextLabelManager alloc]init];
    }
    return _coreTextLabelManager;
}

@end
