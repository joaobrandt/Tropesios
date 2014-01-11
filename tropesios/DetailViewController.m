//
//  DetailViewController.m
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

#import "DetailViewController.h"
#import "TFHpple.h"

@interface DetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
@property (nonatomic) BOOL spoilersVisible;

@end

@implementation DetailViewController

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
    
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURL *url = [NSURL URLWithString:@"http://tvtropes.org/pmwiki/pmwiki.php/Main/AbortedDeclarationOfLove"];
    NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        TFHpple *hpple = [TFHpple hppleWithHTMLData:data encoding:@"ISO-8859-1"];

        TFHppleElement *title = [hpple peekAtSearchWithXPathQuery:@"//div[@class='pagetitle']/span"];
        TFHppleElement *text = [hpple peekAtSearchWithXPathQuery:@"//div[@id='wikitext']"];
        
        NSString *cssFile = [[NSBundle mainBundle] pathForResource:@"Style" ofType:@"css"];
        cssFile = [NSURL fileURLWithPath:cssFile];
        //NSString *cssData = [NSString stringWithContentsOfFile:cssFile encoding:NSUTF8StringEncoding error:NULL];
        
        NSString *path = [[NSBundle mainBundle] bundlePath];
        NSURL *baseURL = [NSURL fileURLWithPath:path];
        
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
        
        [self.webView loadHTMLString:[NSString stringWithFormat:html, title.text, text.raw] baseURL:baseURL];
    
    }];
    [task resume];
}

- (IBAction)toggleSpoiler:(id)sender
{
    NSString *command = self.spoilersVisible ? @"hideAllSpoilers();" : @"showAllSpoilers();";
    
    [self.webView stringByEvaluatingJavaScriptFromString:command];
    self.spoilersVisible = !self.spoilersVisible;
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
