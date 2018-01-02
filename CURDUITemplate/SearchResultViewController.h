//
//  SearchResultViewController.h
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/23.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ShoppingCartViewController.h"
#import <Realm/Realm.h>
#import "ShoppingCartItem.h"

@protocol SearchResultViewControllerDelegate <NSObject>

- (void)didSelectedGoods:(id)goods;

@end

@interface SearchResultViewController : UITableViewController

@property (nonatomic, strong) RLMResults<ShoppingCartItem *> *dataSource;
@property (nonatomic, weak) ShoppingCartViewController *shoppingCartViewController;
@property (nonatomic, weak) id<SearchResultViewControllerDelegate> delegate;

@end
