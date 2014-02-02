//
//  PageViewController.h
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageManager.h"

@interface PageViewController : UIViewController <UIWebViewDelegate, UISplitViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *forwardButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *spoilersButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *textChangeButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *actionsButton;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) PageManager *pageManager;

- (IBAction)toggleSpoilers:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goForward:(id)sender;

@end
