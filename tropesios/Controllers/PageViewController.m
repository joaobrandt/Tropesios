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
#import "PageManager.h"

@interface PageViewController () <PageManagerDelegate>

@property (nonatomic) BOOL spoilersVisible;
@property (strong, nonatomic) PageManager *pageManager;
@property (strong, nonatomic) UIPopoverController *masterPopoverController;

@end

@implementation PageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.spoilersVisible = NO;
    self.pageManager = [PageManager new];
    self.pageManager.delegate = self;
    [self.pageManager loadPageWithId:@"Main/AbortedDeclarationOfLove"];
}

- (void)loadPage:(Page *)page
{
    [self.pageManager loadPage:page];
    
    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }
}

- (IBAction)toggleSpoilers:(id)sender
{
    NSString *command = self.spoilersVisible ? @"hideAllSpoilers();" : @"showAllSpoilers();";
    [self.webView stringByEvaluatingJavaScriptFromString:command];
    self.spoilersVisible = !self.spoilersVisible;
    self.spoilersButton.tintColor = self.spoilersVisible ? [UIColor redColor] : [UIColor blackColor];
}

- (IBAction)goBack:(id)sender
{
    // TODO
}

- (IBAction)goForward:(id)sender
{
    // TODO
}

#pragma mark - PageManagerDelegate

- (void)pageLoaded:(Page*)page
{
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
    "</html>";
    
    [self.webView loadHTMLString:[NSString stringWithFormat:html, page.title, page.content.html] baseURL:baseURL];
    
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;
    
    if ([request.URL.scheme isEqualToString:@"tvtropeswiki"])
        [self.pageManager loadPageWithId:request.URL.resourceSpecifier];
        
    return NO;
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
