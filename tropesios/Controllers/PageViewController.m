//
//  PageViewController.m
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageViewController.h"
#import "SearchViewController.h"

#import "Page.h"
#import "Content.h"
#import "Topic.h"
#import "SearchEntry.h"

@interface PageViewController () <UIPopoverControllerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *pagePreferencesPopoverController;
@property (strong, nonatomic) UIPopoverController *searchPopoverController;

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation PageViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
    NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"EmptyPage" ofType:@"html"];
    
    NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];
    [self.webView loadHTMLString:html baseURL:baseURL];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    self.pageManager.delegate = self;
    [self.pageManager addObserver:self forKeyPath:@"currentPage" options:0 context:nil];
    [self.pageManager loadHistory];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"showPagePreferences"]) {
        return self.pagePreferencesPopoverController == nil;
    }
    
    if ([identifier isEqualToString:@"showSearch"]) {
        return self.searchPopoverController == nil;
    }
    
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPagePreferences"]) {
        self.pagePreferencesPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        self.pagePreferencesPopoverController.delegate = self;
    }
    
    if ([segue.identifier isEqualToString:@"showSearch"]) {
        self.searchPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        self.searchPopoverController.delegate = self;
        
        SearchViewController *contentViewController = (SearchViewController *) self.searchPopoverController.contentViewController;
        contentViewController.searchTextField = self.searchTextField;
        contentViewController.pageManager = self.pageManager;
        contentViewController.popover = self.searchPopoverController;
    }
}

#pragma mark - Actions

- (IBAction)goBack:(id)sender
{
    [self.pageManager goToBackPage];
}

- (IBAction)goForward:(id)sender
{
    [self.pageManager goToForwardPage];
}

- (void)closeMasterPopover
{
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (NSString *)createPagePreferencesCommand:(NSUserDefaults *)userDefaults
{
    return [NSString stringWithFormat:@"showSpoilers(%d);fontSize(%f);fontSerif(%d);",
                         [userDefaults boolForKey:PREFERENCE_SHOW_SPOILERS],
                         [userDefaults floatForKey:PREFERENCE_FONT_SIZE],
                         [userDefaults boolForKey:PREFERENCE_FONT_SERIF]];
}

- (void)scrollToTopic:(Topic *)topic
{
    if ([topic.page isEqual:self.pageManager.currentPage]) {
        [self closeMasterPopover];
        
        NSString *command = [NSString stringWithFormat:@"scrollToTopic(%@);", topic.topicId];
        [self.webView stringByEvaluatingJavaScriptFromString:command];
    }
}

#pragma mark - NSUserDefaultsDidChangeNotification

- (void)userDefaultsDidChanged:(NSNotification *)notification
{
    NSUserDefaults *userDefaults = notification.object;
    [self.webView stringByEvaluatingJavaScriptFromString:[self createPagePreferencesCommand:userDefaults]];
}

#pragma mark - Page Manager Observer

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([object isEqual:self.pageManager] && [keyPath isEqualToString:@"currentPage"]) {
        
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        NSString *htmlFile = [[NSBundle mainBundle] pathForResource:@"DefaultPage" ofType:@"html"];

        NSString *html = [NSString stringWithContentsOfFile:htmlFile encoding:NSUTF8StringEncoding error:nil];

        html = [NSString stringWithFormat:html, self.pageManager.currentPage.title, self.pageManager.currentPage.content.html, [self createPagePreferencesCommand:[NSUserDefaults standardUserDefaults]]];
        
        [self.webView loadHTMLString:html baseURL:baseURL];
        
        self.backButton.enabled = [self.pageManager canGoBack];
        self.forwardButton.enabled = [self.pageManager canGoForward];
        
        [self closeMasterPopover];
    }
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self performSegueWithIdentifier:@"showSearch" sender:nil];
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther) {
        return YES;
    }
    
    if ([request.URL.scheme isEqualToString:TV_TROPES_SCHEME]) {
        [self.pageManager goToPageWithId:request.URL.resourceSpecifier];
    }
    else {
        [[UIApplication sharedApplication] openURL:request.URL];
    }
    
    return NO;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (self.pagePreferencesPopoverController == popoverController) {
        self.pagePreferencesPopoverController = nil;
    }
    
    if (self.searchPopoverController == popoverController) {
        self.searchPopoverController = nil;
        
        [self.searchTextField resignFirstResponder];
    }
}

#pragma mark - UISplitViewControllerDelegate

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.image = [UIImage imageNamed:@"Master"];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.toolbar.items.count + 1];
    [array addObject:barButtonItem];
    [array addObjectsFromArray:self.toolbar.items];
    
    [self.toolbar setItems:array];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:self.toolbar.items];
    [array removeObject:barButtonItem];
    
    [self.toolbar setItems:array];
    self.masterPopoverController = nil;
}

#pragma mark - PageManagerDelegate
- (void)connectionUnavailable
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Not connected" message:@"Tropesios requires an internet connection to reach this information." delegate:self cancelButtonTitle: @"OK" otherButtonTitles: nil];
    [alertView show];
}

@end
