//
//  Goods.m
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/27.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import "Goods.h"

@implementation Goods

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.goodsID = [[NSUUID UUID] UUIDString];
    }
    return self;
}

@end
