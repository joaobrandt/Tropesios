//
//  PagePreferencesViewController.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 03/02/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PagePreferencesViewController.h"

@interface PagePreferencesViewController ()

@end

@implementation PagePreferencesViewController

- (void)viewDidLoad
{
    self.showAllSpoilersSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_SHOW_SPOILERS];
    self.fontSizeSlider.value = [[NSUserDefaults standardUserDefaults] floatForKey:PREFERENCE_FONT_SIZE];
    self.fontSerifSwitch.on = [[NSUserDefaults standardUserDefaults] boolForKey:PREFERENCE_FONT_SERIF];
}

- (IBAction)updateShowAllSpoilers:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.showAllSpoilersSwitch.on forKey:PREFERENCE_SHOW_SPOILERS];
}

- (IBAction)updateFontSize:(UISlider *)sender
{
    [[NSUserDefaults standardUserDefaults] setFloat:self.fontSizeSlider.value forKey:PREFERENCE_FONT_SIZE];
}

- (IBAction)updateFontSerif:(UISwitch *)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.fontSerifSwitch.on forKey:PREFERENCE_FONT_SERIF];
}

@end
