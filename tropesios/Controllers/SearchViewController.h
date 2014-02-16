//
//  SearchViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 10/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageManager.h"

@interface SearchViewController : UITableViewController

@property (strong, nonatomic) PageManager *pageManager;
@property (strong, nonatomic) UIPopoverController *popover;
@property (weak, nonatomic) UITextField *searchTextField;

@end
