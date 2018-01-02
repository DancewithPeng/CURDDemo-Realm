//
//  Goods.h
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/27.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import <Realm/Realm.h>
#import "CommentItem.h"

RLM_ARRAY_TYPE(CommentItem)

@interface Goods : RLMObject

@property NSString *goodsID;
@property NSString *title;
@property NSString *picture;

@property RLMArray<CommentItem *><CommentItem> *comments;

@end
