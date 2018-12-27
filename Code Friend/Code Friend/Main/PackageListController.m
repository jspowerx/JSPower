//
//  QVPackageListController.m
//  Code Friend
//
//  Created by everettjf on 2018/11/7.
//  Copyright © 2018 everettjf. All rights reserved.
//

#import "PackageListController.h"

@interface PackageListController ()<NSTableViewDelegate,NSTableViewDataSource>
@end

@implementation PackageListController

- (void)reload
{
    [self.packageTableView reloadData];
}

- (void)setup
{
    self.packageTableView.delegate = self;
    self.packageTableView.dataSource = self;
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return self.packages.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    QVSharedPackageModelInConfig *package = self.packages[row];
    
    NSView *view = [tableView makeViewWithIdentifier:@"Cell0" owner:self];
    for(NSView *subview in [view subviews]){
        if([subview.identifier isEqualToString:@"name"]) {
            NSTextField *label = (NSTextField*)subview;
            label.stringValue = [NSString stringWithFormat:@"Name: %@",package.name];
        }else if([subview.identifier isEqualToString:@"author"]) {
            NSTextField *label = (NSTextField*)subview;
            label.stringValue = [NSString stringWithFormat:@"Author: %@",package.author];
        }else if([subview.identifier isEqualToString:@"description"]) {
            NSTextField *label = (NSTextField*)subview;
            label.stringValue = [NSString stringWithFormat:@"Description: %@",package.desc];
        }
    }
    return view;
}

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    NSTableView *tableView = notification.object;
    
    NSInteger row = tableView.selectedRow;
    NSLog(@"row = %@", @(row));
    if(row >= 0 && row < self.packages.count){
        self.selectedRow = row;
        self.selectedPackage = self.packages[row];
    }else{
        self.selectedRow = -1;
        self.selectedPackage = nil;
    }
    
    if(self.delegate){
        [self.delegate packageListControllerSelectedPackageChanged:self];
    }
}

@end
