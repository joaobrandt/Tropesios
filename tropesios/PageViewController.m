//
//  PageViewController.m
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageViewController.h"

#import "Page.h"
#import "PageManager.h"

@interface PageViewController () <PageManagerDelegate>

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (strong, nonatomic) PageManager *pageManager;
@property (nonatomic) BOOL spoilersVisible;

@end

@implementation PageViewController



#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.spoilersVisible = NO;
    self.pageManager = [PageManager new];
    self.pageManager.delegate = self;
    
    [self.pageManager loadPage:@"Main/AbortedDeclarationOfLove"];
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

#pragma mark PageManagerDelegate

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
    
    [self.webView loadHTMLString:[NSString stringWithFormat:html, page.title, page.contents] baseURL:baseURL];
    
}

#pragma mark UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if (navigationType == UIWebViewNavigationTypeOther)
        return YES;
    
    if ([request.URL.scheme isEqualToString:@"tvtropeswiki"])
        [self.pageManager loadPage:request.URL.resourceSpecifier];
        
    return NO;
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

@end
