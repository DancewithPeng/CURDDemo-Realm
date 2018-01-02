//
//  CommentListViewController.m
//  CURDUITemplate
//
//  Created by 张鹏 on 2017/11/22.
//  Copyright © 2017年 DancewithPeng. All rights reserved.
//

#import "CommentListViewController.h"
#import "CommentCell.h"
#import "UIAlertController+Remind.h"

@interface CommentListViewController ()

@property (weak, nonatomic) IBOutlet UIBarButtonItem *addBBI;
@property (nonatomic, strong) UIAlertController *alertController;

@end

@implementation CommentListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Interface

// 添加评论
- (void)addCommentWithData:(id)data {
    CommentItem *comment = [[CommentItem alloc] init];
    comment.text = data[@"comment"];
    comment.date = [NSDate date];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [self.cartItem.goods.comments addObject:comment];
    }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.cartItem.goods.comments.count-1 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 删除评论
- (void)deleteCommentWithData:(id)data {
    CommentItem *comment = data;
    NSInteger index = [self.cartItem.goods.comments indexOfObject:comment];
    
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [self.cartItem.goods.comments removeObjectAtIndex:index];
    }];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// 配置Cell
- (void)setupCell:(CommentCell *)cell withData:(id)data {
    CommentItem *comment = data;
    cell.titleLabel.text = comment.text;
    cell.dateLabel.text = comment.date.description;
}


#pragma mark - Event Handlers

- (IBAction)handlerAddBBIClicked:(id)sender {
    [self presentViewController:self.alertController animated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.cartItem.goods.comments.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    id data = self.cartItem.goods.comments[indexPath.row];
    [self setupCell:cell withData:data];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleteCommentWithData:self.cartItem.goods.comments[indexPath.row]];
    }
}

#pragma mark - Helper Methods

- (NSString *)validateCommentForText:(NSString *)text {
    
    NSString *trimText = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trimText != nil && trimText.length > 0) {
        return trimText;
    }
    
    [UIAlertController remindMessage:@"请输入评论" inViewController:self];
    
    return nil;
}


#pragma mark - Setter & Getter

- (UIAlertController *)alertController {
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入评论" preferredStyle:UIAlertControllerStyleAlert];
        
        [_alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入评论";
            textField.tag = 1001;
        }];
        
        __weak UIAlertController *weakAlert = _alertController;
        [_alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            UITextField *commentTF = weakAlert.textFields[0];
            
            commentTF.text = nil;
        }]];
        
        __weak typeof (self) weakSelf = self;
        [_alertController addAction:[UIAlertAction actionWithTitle:@"添加评论" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *commentTF = weakAlert.textFields[0];
            
            NSString *comment = [weakSelf validateCommentForText:commentTF.text];
            
            commentTF.text = nil;
            
            if (comment != nil) {
                [weakSelf addCommentWithData:@{@"comment": comment}];
            }
        }]];
    }
    
    return _alertController;
}

@end
