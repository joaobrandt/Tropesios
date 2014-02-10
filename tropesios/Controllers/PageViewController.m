//
//  PageViewController.m
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageViewController.h"

#import "Page.h"
#import "Content.h"
#import "Topic.h"
#import "SearchEntry.h"

@interface PageViewController () <UIPopoverControllerDelegate, PageSearchDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) UIPopoverController *pagePreferencesPopoverController;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

- (void)search;

@end

@implementation PageViewController

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userDefaultsDidChanged:) name:NSUserDefaultsDidChangeNotification object:nil];
    
    [self.pageManager addObserver:self forKeyPath:@"currentPage" options:0 context:nil];
    [self.pageManager loadHistory];
    self.pageManager.searchDelegate = self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    return ![identifier isEqualToString:@"showPagePreferences"] || self.pagePreferencesPopoverController == nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPagePreferences"]) {
        self.pagePreferencesPopoverController = ((UIStoryboardPopoverSegue *)segue).popoverController;
        self.pagePreferencesPopoverController.delegate = self;
    }
}

- (void)resultsFound:(NSArray *)results
{
    for (SearchEntry *entry in results) {
        NSLog(@"%@ -> %@", entry.pageId, entry.text);
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

- (IBAction)searchTextChanged:(id)sender
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(search) object:nil];
    [self performSelector:@selector(search) withObject:nil afterDelay:0.5];
}

- (void)search
{
    [self.pageManager search:self.searchText.text];
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
        NSString *cssFile = [[NSBundle mainBundle] pathForResource:@"Style" ofType:@"css"];
        cssFile = [NSURL fileURLWithPath:cssFile];
        
        NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]];
        
        NSString *html = @"<!DOCTYPE html>"
        "<html>"
        "  <head>"
        "    <link rel='stylesheet' type='text/css' href='Style.css'/>"
        "    <script type='text/javascript' src='Zepto.min.js'></script>"
        "    <script type='text/javascript' src='Script.js'></script>"
        "  </head>"
        "  <body>"
        "    <h1>%@</h1>"
        "    %@"
        "  </body>"
        "  <script type='text/javascript'>Zepto(function($){%@})</script>"
        "</html>";
        
        html = [NSString stringWithFormat:html, self.pageManager.currentPage.title, self.pageManager.currentPage.content.html, [self createPagePreferencesCommand:[NSUserDefaults standardUserDefaults]]];
        
        [self.webView loadHTMLString:html baseURL:baseURL];
        
        self.backButton.enabled = [self.pageManager canGoBack];
        self.forwardButton.enabled = [self.pageManager canGoForward];
        
        [self closeMasterPopover];
    }
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;
    
    if ([request.URL.scheme isEqualToString:@"tvtropeswiki"])
        [self.pageManager goToPageWithId:request.URL.resourceSpecifier];
        
    return NO;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (self.pagePreferencesPopoverController == popoverController) {
        self.pagePreferencesPopoverController = nil;
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



@end
