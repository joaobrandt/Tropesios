//
//  PageManager.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "PageManager.h"

#import "Page.h"
#import "History.h"
#import "Content.h"
#import "SubPage.h"
#import "Topic.h"

#import "TFHpple.h"
#import "TFHppleElement.h"
#import "NSManagedObject+Extensions.h"
#import "NSDate+Extensions.h"

@interface PageManager ()

@property (readonly, retain, nonatomic) NSURLSession *urlSession;

@property (nonatomic) NSMutableArray *backHistory;
@property (nonatomic) NSMutableArray *forwardHistory;
@property (nonatomic) BOOL navigationInHistory;

- (void)pageLoaded:(Page*)page;

@end

@implementation PageManager

@synthesize urlSession = _urlSession;

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.backHistory = [NSMutableArray new];
        self.forwardHistory = [NSMutableArray new];
    }
    return self;
}

- (BOOL)canGoBack
{
    return self.backHistory.count > 0;
}

- (BOOL)canGoForward
{
    return self.forwardHistory.count > 0;
}

- (void)goToBackPage
{
    if ([self canGoBack]) {
        NSString *pageId = [self.backHistory lastObject];
        
        [self.backHistory removeLastObject];
        [self.forwardHistory addObject:self.currentPage.pageId];
        
        self.navigationInHistory = YES;
        [self goToPageWithId:pageId];
        self.navigationInHistory = NO;
    }
}

- (void)goToForwardPage
{
    if ([self canGoForward]) {
        NSString *pageId = [self.forwardHistory lastObject];
        
        [self.backHistory addObject:self.currentPage.pageId];
        [self.forwardHistory removeLastObject];
        
        self.navigationInHistory = YES;
        [self goToPageWithId:pageId];
        self.navigationInHistory = NO;
    }
}

- (void)goToPageWithId:(NSString *)pageId
{
    // **************************************
    // Check page existence
    // **************************************
    Page *page = [Page in:self.managedObjectContext getOneWithPredicate:@"pageId = %@", pageId];
    
    if (page == nil) {
        page = [Page newIn:self.managedObjectContext];
        page.pageId = pageId;
    }
    
    [self goToPage:page];
}

- (void)goToPage:(Page *)page
{
    // **************************************
    // Check current page is already loaed
    // **************************************
    if ([page.objectID isEqual:self.currentPage.objectID]) {
        return;
    }
    
    // **************************************
    // Check content is stored
    // **************************************
    if (page.content != nil) {
        [self pageLoaded:page];
        return;
    }
    
    // **************************************
    // Loading remote content;
    // **************************************
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tvtropes.org/pmwiki/pmwiki.php/%@", page.pageId]];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            // TODO Handle
            return;
        }
        
        // **************************************
        // Converting downloaded page
        // **************************************
        TFHpple *hpple = [TFHpple hppleWithHTMLData:data encoding:@"ISO-8859-1"];
        
        TFHppleElement *titleElement = [hpple peekAtSearchWithXPathQuery:@"//div[@class='pagetitle']/span"];
        TFHppleElement *contentsElement = [hpple peekAtSearchWithXPathQuery:@"//div[@id='wikitext']"];
        NSArray *folders = [hpple searchWithXPathQuery:@"//div[@class='folderlabel']"];
        
        // **************************************
        // Cleaning old content
        // **************************************
        [Topic in:self.managedObjectContext deleteAllWithPredicate:@"page == %@", page];
        [SubPage in:self.managedObjectContext deleteAllWithPredicate:@"page == %@", page];
        
        // **************************************
        // Storing entities
        // **************************************
        page.title = titleElement.text;
        
        Content *content = [Content newIn:self.managedObjectContext];
        content.html = contentsElement.raw;
        content.page = page;
        
        int topicId = 0;
        
        Topic *topic = [Topic newIn:self.managedObjectContext];
        topic.topicId = [NSNumber numberWithInt:topicId];
        topic.title = @"Contents";
        topic.page = page;
        
        topicId++;
        
        for (TFHppleElement *element in folders) {
        
            if ([[element.attributes valueForKey:@"onclick"] isEqualToString:@"toggleAllFolders();"]) {
                continue;
            }
            
            topic = [Topic newIn:self.managedObjectContext];
            topic.topicId = [NSNumber numberWithInt:topicId];
            topic.title = [element.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
            topic.page = page;
            
            topicId++;
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self pageLoaded:page];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [task resume];
}

- (void)pageLoaded:(Page*)page
{
    // **************************************
    // Registring history;
    // **************************************
    NSDate *today = [NSDate date];
    
    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;
    
    NSDate *lastMidnight = [NSCalendar.currentCalendar dateFromComponents:[NSCalendar.currentCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today]];
    NSDate *nextMidnight = [NSCalendar.currentCalendar dateByAddingComponents:oneDay toDate:lastMidnight options:NSWrapCalendarComponents];
    
    History *history = [History in:self.managedObjectContext getOneWithPredicate:@"page == %@ AND date >= %@ AND date <= %@", page, lastMidnight, nextMidnight];
    
    if (history == nil) {
        history = [History newIn:self.managedObjectContext];
        history.page = page;
    }
    
    history.date = today;
    
    // TODO Handle the error;
    [self.managedObjectContext save:nil];
    
    // **************************************
    // Configurate navigation
    // **************************************
    if (!self.navigationInHistory) {
        [self.forwardHistory removeAllObjects];
        
        if (self.currentPage != nil) {
            [self.backHistory addObject:self.currentPage.pageId];
        }
    }
    
    self.currentPage = page;
}

- (NSURLSession*)urlSession
{
    if (_urlSession == nil) {
        NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}

@end
