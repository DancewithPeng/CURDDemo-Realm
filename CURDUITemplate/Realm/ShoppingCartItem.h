//
//  ShoppingCartItem.h
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/27.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import <Realm/Realm.h>
#import "Goods.h"

@interface ShoppingCartItem : RLMObject

@property Goods *goods;
@property NSInteger number;

@end
