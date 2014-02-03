//
//  PagePreferencesViewController.h
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

@interface PagePreferencesViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UISwitch *showAllSpoilersSwitch;
@property (weak, nonatomic) IBOutlet UISlider *fontSizeSlider;
@property (weak, nonatomic) IBOutlet UISwitch *fontSerifSwitch;

@end
