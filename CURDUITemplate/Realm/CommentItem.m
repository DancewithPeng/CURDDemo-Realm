//
//  CommentItem.m
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/27.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import "CommentItem.h"
#import "Goods.h"

@implementation CommentItem

+ (NSDictionary<NSString *,RLMPropertyDescriptor *> *)linkingObjectsProperties {
    return @{
             @"goods": [RLMPropertyDescriptor descriptorWithClass:[Goods class] propertyName:@"comments"]
             };
}

@end
