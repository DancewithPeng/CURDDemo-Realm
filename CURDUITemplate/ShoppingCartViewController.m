//
//  ShoppingCartViewController.m
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/22.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import "ShoppingCartViewController.h"
#import "SearchResultViewController.h"
#import "UIAlertController+Remind.h"
#import "CommentListViewController.h"

#import <Realm/Realm.h>
#import "ShoppingCartItem.h"


@interface ShoppingCartViewController () <GoodsCellDelegate, UISearchResultsUpdating, SearchResultViewControllerDelegate>

/// UI Elements
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBBI;
@property (nonatomic, strong) UISearchController *searchController;
@property (nonatomic, strong) UIAlertController *alertController;
@property (nonatomic, weak) SearchResultViewController *resultViewController;


/** 数据源 */
@property (nonatomic, strong) RLMResults<ShoppingCartItem *> *dataSource;

@property (nonatomic, strong) RLMNotificationToken *cartItemsToken;

@end

@implementation ShoppingCartViewController


#pragma mark - Life Cycle Methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (@available(iOS 11.0, *)) {
        self.navigationItem.searchController = self.searchController;
        self.navigationItem.hidesSearchBarWhenScrolling = NO;
    } else {
        [self.searchController.searchBar sizeToFit];
        self.tableView.tableHeaderView = self.searchController.searchBar;
    }
    
    self.definesPresentationContext = YES;
    
    [self firtLoadData];
    
    __weak typeof (self) weakSelf = self;
    self.cartItemsToken =
    [self.dataSource addNotificationBlock:^(RLMResults<ShoppingCartItem *> * _Nullable results, RLMCollectionChange * _Nullable change, NSError * _Nullable error) {
        
        NSArray *updateIndexPaths = [change modificationsInSection:0];
        
        if (change == nil) {
            [weakSelf.tableView reloadData];
            return;
        }
        
        [weakSelf.tableView beginUpdates];
        
        if (updateIndexPaths !=nil && updateIndexPaths.count > 0) {
            [weakSelf.tableView reloadRowsAtIndexPaths:updateIndexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        [weakSelf.tableView endUpdates];
    }];
}

- (void)deleteForIndexPaths:(NSArray<NSIndexPath *> *)indexPaths {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationAutomatic];
    });
}

#pragma mark - Interfaces

// 第一次加载数据
- (void)firtLoadData {
    self.dataSource = [ShoppingCartItem allObjects];
}

// 添加商品
- (void)addGoodsWithData:(NSDictionary *)data {
    
    ShoppingCartItem *item = [[ShoppingCartItem alloc] init];
    item.number = [data[@"count"] integerValue];
    
    Goods *goods = [[Goods alloc] init];
    goods.title = data[@"name"];
    item.goods = goods;
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm addObject:item];
    }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 增加商品数量
- (void)goodsCellAddButtonDidTaped:(GoodsCell *)goodsCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:goodsCell];
    ShoppingCartItem *item = self.dataSource[indexPath.row];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        item.number += 1;
    }];
}

// 减少商品数量
- (void)goodsCellDeleteButtonDidTaped:(GoodsCell *)goodsCell {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:goodsCell];
    ShoppingCartItem *item = self.dataSource[indexPath.row];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        item.number -= 1;
    }];
}

// 删除商品
- (void)deleteGoods:(id)data {
    ShoppingCartItem *item = data;
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteObject:item];
    }];
}

// 搜索商品
- (void)searchGoods:(NSString *)goodsName {

    // 方式1
    NSString *whereFormat = [NSString stringWithFormat:@"goods.title LIKE[c] '*%@*'", goodsName];
    RLMResults *results = [ShoppingCartItem objectsWhere:whereFormat];
    [self updateSearchResults:results];
    
    // 方式2
    // SUBQUERY 要是数组
//    NSString *whereFormat = [NSString stringWithFormat:@"SUBQUERY(NONE, $goods, $goods.title LIKE[c] '*%@*') .@count > 0", goodsName];
//    RLMResults *results = [ShoppingCartItem objectsWhere:whereFormat];
//    [self updateSearchResults:results];
}

// 配置Cell
- (void)setupCell:(GoodsCell *)cell withData:(id)data {
    
    ShoppingCartItem *item = data;
//    cell.imageView.image = ...
    cell.titleLabel.text = item.goods.title;
    cell.numberLabel.text = [NSString stringWithFormat:@"%ld", item.number];
    cell.commentNumberLabel.text = [NSString stringWithFormat:@"有%ld条评价", item.goods.comments.count];
}

// 点击商品
- (void)didSelectedGoods:(id)goods {
    
    ShoppingCartItem *item = goods;
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    CommentListViewController *commentListVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"CommentListViewController"];
    commentListVC.cartItem = item;
    [self.navigationController pushViewController:commentListVC animated:YES];
}


#pragma mark - Event Handlers

- (IBAction)handlerAddBBIClicked:(id)sender {
    [self presentViewController:self.alertController animated:YES completion:nil];
}


#pragma mark - UISearchControllerDelegate

// 更新搜索文本
- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    [self searchGoods:searchController.searchBar.text];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodsCell" forIndexPath:indexPath];
    cell.delegate = self;
    [self setupCell:cell withData:self.dataSource[indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteGoods:self.dataSource[indexPath.row]];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self didSelectedGoods:self.dataSource[indexPath.row]];
}

#pragma mark - Helper Methods

- (NSString *)validateGoodsNameForText:(NSString *)text {
    NSString *trimText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimText != nil && trimText.length > 0) {
        return trimText;
    }
    
    [UIAlertController remindMessage:@"请输入正确的商品名称" inViewController:self];
    
    return nil;
}

- (NSInteger)validateGoodsCountForText:(NSString *)text {
    
    NSInteger num = [text integerValue];
    if (num >= 1) {
        return num;
    }
    
    [UIAlertController remindMessage:@"请输入正确的商品数量" inViewController:self];
    
    return -1;
}

- (void)updateSearchResults:(RLMResults<ShoppingCartItem *> *)results {
    self.resultViewController.dataSource = results;
}


#pragma mark - Getter

- (UISearchController *)searchController {
    if (_searchController == nil) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        SearchResultViewController *searchResultVC = [mainStoryboard instantiateViewControllerWithIdentifier:@"SearchResultViewController"];
        searchResultVC.shoppingCartViewController = self;
        searchResultVC.delegate = self;

        _searchController = [[UISearchController alloc] initWithSearchResultsController:searchResultVC];
        _searchController.searchResultsUpdater = self;
        
        self.resultViewController = searchResultVC;
    }
    return _searchController;
}

- (UIAlertController *)alertController {
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入商品名称和数量" preferredStyle:UIAlertControllerStyleAlert];
        
        [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入商品名称";
            textField.tag = 1001;
        }];
        
        [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入商品数量";
            textField.tag = 1002;
            textField.keyboardType = UIKeyboardTypeNumberPad;
        }];
        
        __weak UIAlertController *weakAlert = _alertController;
        [_alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            UITextField *nameTF = weakAlert.textFields[0];
            UITextField *countTF = weakAlert.textFields[1];
            
            nameTF.text = nil;
            countTF.text = nil;
        }]];
        
        __weak typeof (self) weakSelf = self;
        [_alertController addAction:[UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *nameTF = weakAlert.textFields[0];
            UITextField *countTF = weakAlert.textFields[1];
            
            NSString *name = [weakSelf validateGoodsNameForText:nameTF.text];
            NSInteger count = [weakSelf validateGoodsCountForText:countTF.text];
            
            nameTF.text = nil;
            countTF.text = nil;
            
            if (name != nil && count >= 0) {
                [weakSelf addGoodsWithData:@{@"name": name,
                                             @"count": @(count)
                                             }];
            }
        }]];
    }        
    
    return _alertController;
}

@end
