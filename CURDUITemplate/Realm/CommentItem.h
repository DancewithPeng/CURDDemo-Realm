//
//  CommentItem.h
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/27.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import <Realm/Realm.h>

@interface CommentItem : RLMObject

@property NSString *goodsID;
@property NSString *text;
@property NSDate *date;

// 链接属性
@property (readonly) RLMLinkingObjects *goods;

@end
