//
//  ViewController.m
//  TYYCoreText
//
//  Created by Null on 17/3/20.
//  Copyright © 2017年 zcs_yang. All rights reserved.
//

#import "ViewController.h"
#import "TYYCoreTextLabel.h"
#import <Masonry.h>

@interface ViewController ()<TYYCoreTextLabelDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor grayColor];
    UIScrollView *mainScrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.view addSubview:mainScrollView];
    
    [mainScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.left.equalTo(self.view);
        make.top.equalTo(self.view.mas_top).offset(20);
    }];
    
    UIView *container = [[UIView alloc]init];
    [mainScrollView addSubview:container];
    
    [container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(mainScrollView);
        make.width.equalTo(mainScrollView.mas_width);
    }];
    
    TYYCoreTextAttributesModel *model = [[TYYCoreTextAttributesModel alloc]init];
    model.font = [UIFont systemFontOfSize:20.f];
    model.imageSize = CGSizeMake(25, 25);
    model.lineSpacing = 3;
    model.wordSpacing = 2;
    
    TYYCoreTextLabel *lastLabel;
    NSArray *datas = [self datas];
    for (int i = 0;i<datas.count;i++) {
        NSDictionary *data = datas[i];
        NSString *text = data[@"text"];
        NSString *title = data[@"title"];
        NSArray *customLinks = data[@"customLinks"];
        NSArray *keyWord = data[@"keywords"];
        NSArray *enableLinkTypeList = data[@"enableLinkTypeList"];
        TYYCoreTextLabel *label = [[TYYCoreTextLabel alloc]init];
        label.backgroundColor = [UIColor whiteColor];
        label.delegate = self;
        UILabel *titleLbael = [[UILabel alloc]init];
        titleLbael.backgroundColor = [UIColor redColor];
        titleLbael.textAlignment = NSTextAlignmentCenter;
        titleLbael.text = title;
        [container addSubview:titleLbael];
        [container addSubview:label];
        [label configureText:text customLinks:customLinks keywords:keyWord enableLinkTypeList:enableLinkTypeList attributeModel:model];
        if (lastLabel) {
            [titleLbael mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.width.equalTo(lastLabel);
                make.top.equalTo(lastLabel.mas_bottom);
                make.height.equalTo(@40);
            }];
        }else {
            [titleLbael mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(container.mas_top);
                make.width.left.equalTo(container);
                make.height.equalTo(@40);
            }];
        }
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(titleLbael.mas_bottom);
            make.left.width.equalTo(titleLbael);
        }];
        lastLabel = label;
    }
    if (lastLabel) {
        [container mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(lastLabel.mas_bottom).offset(20);
        }];
    }
    
}

- (void)coreTextLabel:(TYYCoreTextLabel *)coreTextLabel linkType:(TYYLinkType)linkType linkUrl:(NSString *)linkUrl{
    NSLog(@"linkUrl = %@",linkUrl);
}


- (id<TYYCoreTextLabelManagerAdditionalConfigure>)coreTextLabelManagerInCoreTextLabel:(TYYCoreTextLabel *)coreTextLabel{
    return [[NSClassFromString(@"TYYTestManager") alloc]init];
}

//如果图片是来自bundle文件
- (NSString *)coreTextLabel:(TYYCoreTextLabel *)coreTextLabel availebleImageNameWithImageName:(NSString *)imageName{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"sb_emoji" ofType:@"json"];
    NSData *jsonData = [NSData dataWithContentsOfFile:path options:NSDataReadingMappedIfSafe error:nil];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&err];
    NSArray *emojiArray = [dic[@"re"] copy];
    for (NSDictionary *dic in emojiArray) {
        NSString *name = [[NSString alloc] initWithFormat:@"[%@]", dic[@"emojimeaning"]];
        if ([name isEqualToString:imageName]) {
            return [@"SBEmoji.bundle" stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", dic[@"emojiname"]]];
        }
    }
    return @"";
}

- (NSArray *)datas{
    return @[
  @{@"text":@"刚看到#拉勾#上公司挂出的职位时，我还是有些担忧的。这个职位的要求是，3 年工作经验，独立开发，作为创业公司唯一的 iOS @工程师 一个人负责整个 app 的全部功能迭代，未来可能还要带一个小组。www.baidu.com 基本至少是一个中级@工程师  的要求，而#拉勾#上挂出的薪水范围是 10~20k。虽然公司的业务是电商类，技术没什么特别的难点，我还是担心给得不够，怕真正有 3 年经验的@工程师 看见这个薪资连简历都不会投",
    @"customLinks":@[],
    @"keywords":@[@"职位",@"简历"],
    @"enableLinkTypeList":@[],
    @"title":@"仅显示关键字"
    },
  @{@"text":@"[为什么]从没见过如此厚颜无耻的基金经理，真希望[闭嘴],谁能一把刀捅死他[鼓掌]，股票都已经让我[不屑]，你却在[咪咪]，[疑问],@王大牛 #论王宝强老婆出轨# www.baidu.com ",
    @"customLinks":@[],
    @"keywords":@[],
    @"enableLinkTypeList":@[],
    @"title":@"仅显示表情和图片"
    },
  @{@"text":@"刚看到#拉勾#上公司挂出的职位时，我还是有些担忧的。这个职位的要求是，3 年工作经验，独立开发，作为创业公司唯一的 iOS @工程师 一个人负责整个 app 的全部功能迭代，未来可能还要带一个小组。www.baidu.com 基本至少是一个中级@工程师 的要求，而#拉勾#上挂出的薪水范围是 10~20k。虽然公司的业务是电商类，技术没什么特别的难点，我还是担心给得不够，怕真正有 3 年经验的@工程师 看见这个薪资连简历都不会投",
    @"customLinks":@[@"职位",@"工作经验",@"要求"],
    @"keywords":@[],
    @"enableLinkTypeList":@[@(TYYLinkTypeTrendLink),@(TYYLinkTypeTopicLink),@(TYYLinkTypeWebLink)],
    @"title":@"仅显示链接"
    },
  @{@"text":@"没有数据的场景不可能实现人工智能。大数据就是人工智能的引爆点，<a href=\"http://fund.eastmoney.com/ztjj/?spm=001.3.swh#!sort%3ASYL_Z%3Ars%3AWRANK/undefined/syl/SYL_1N/curr/321cc099a2d5f9ce-云计算/fs/SYL_6Y/fst/DESC\">云计算</a>、大数据、人工智能趋向“三位一体”在欧美国家 走势最牛的股票就是大数据$银信科技(300231)$就是三方面的龙头 盘子小 股价低 这才是优势献花次新银行前一波是小银行，下一波是$江苏银行(600919)$ 江苏银行与德邦证券发起设立国内首支消费金融ABS创新投资基金$易方达基金[012221]$",
    @"customLinks":@[],
    @"keywords":@[],
    @"enableLinkTypeList":@[],
    @"title":@"仅显示自定义特殊链接规则"
    },
  @{@"text":@"没有数据的场景不可能实现人工智能。大数据就是人工智能的引爆点，<a href=\"http://fund.eastmoney.com/ztjj/?spm=001.3.swh#!sort%3ASYL_Z%3Ars%3AWRANK/undefined/syl/SYL_1N/curr/321cc099a2d5f9ce-云计算/fs/SYL_6Y/fst/DESC\">云计算</a>、大数据、人工智能趋向“三位一体”在欧美国家 走势最牛的股票就是大数据$银信科技(300231)$就是三方面的龙头 盘子小 股价低 这才是优势献花次新银行前一波是小银行，下一波是$江苏银行(600919)$ [赚大了]江苏银行与德邦证券发起设立国内首支消费金融ABS创新投资基金$易方达基金[012221]$,详情可见http://fund.eastmoney.com",
    @"customLinks":@[@"人工智能"],
    @"keywords":@[@"基金",@"股票"],
    @"enableLinkTypeList":@[@(TYYLinkTypeTrendLink),@(TYYLinkTypeTopicLink),@(TYYLinkTypeWebLink)],
    @"title":@"所有都显示"
    }];
}


@end
