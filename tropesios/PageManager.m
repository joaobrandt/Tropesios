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
#import "SearchEntry.h"

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
        
        int topicId = -1;
        
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

- (void)loadHistory
{
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:@"history.out"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
    
        [self.backHistory addObjectsFromArray:[NSArray arrayWithContentsOfFile:filePath]];
        
        if (self.backHistory.count > 0) {
            NSString *lastVisited = [self.backHistory lastObject];
            [self.backHistory removeLastObject];
            [self goToPageWithId:lastVisited];
        }
        else {
            // TODO
            [self goToPageWithId:@"Main/AbortedDeclarationOfLove"];

        }
    }
    
    else {
        // TODO
        [self goToPageWithId:@"Main/AbortedDeclarationOfLove"];
    }
}

- (void)saveHistory
{
    NSMutableArray *history = [NSMutableArray arrayWithArray:self.backHistory];
    
    if (self.currentPage != nil) {
        [history addObject:self.currentPage.pageId];
    }
    
    NSString *directoryPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *filePath = [directoryPath stringByAppendingPathComponent:@"history.out"];
    [history writeToFile:filePath atomically:YES];
}

- (void)search:(NSString*)query;
{
    // **************************************
    // Loading remote content;
    // **************************************
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.google.com/cse?cx=partner-pub-6610802604051523%%3Aamzitfn8e7v&cof=FORID%%3A10&q=%@", query]];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error != nil) {
            // TODO Handle
            return;
        }
        
        TFHpple *hpple = [TFHpple hppleWithHTMLData:data encoding:@"ISO-8859-1"];
        
        NSArray *elements = [hpple searchWithXPathQuery:@"//a[@class='l']"];
        NSMutableArray *entries = [[NSMutableArray alloc] initWithCapacity:elements.count];
        
        for (TFHppleElement *element in elements) {
            
            SearchEntry *entry = [SearchEntry new];
            
            entry.pageId = [element.attributes objectForKey:@"href"];
            if ([entry.pageId hasPrefix:TV_TROPES_URL_PREFIX]) {
                entry.pageId = [entry.pageId substringFromIndex:[TV_TROPES_URL_PREFIX length]];
            }
            
            entry.text = @"";
            for (TFHppleElement *child in element.children) {
                entry.text = [entry.text stringByAppendingString: (child.text != nil ? child.text : child.content) ];
            }
            
            if ([entry.text hasSuffix:TV_TROPES_TITLE_SUFFIX]) {
                entry.text = [entry.text substringToIndex:entry.text.length - TV_TROPES_TITLE_SUFFIX.length];
                [entries addObject:entry];
            }
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.searchDelegate resultsFound:entries];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [task resume];
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
