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

@interface PageManager ()

@property (readonly, nonatomic, retain) NSURLSession *urlSession;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation PageManager

@synthesize urlSession = _urlSession;
@synthesize managedObjectContext = _managedObjectContext;

- (void)loadPage:(Page *)page
{
    // TODO
    [self loadPageWithId:page.pageId];
}

- (void)loadPageWithId:(NSString *)pageId
{
    Page* page = nil;
    
    // **************************************
    // Check page existence
    // **************************************
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Page class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %@", pageId];
    
    NSArray* entities = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (entities.count > 0) {
        page = [entities objectAtIndex:0];
    } else {
        page = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Page class]) inManagedObjectContext:self.managedObjectContext];
        page.pageId = pageId;
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
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://tvtropes.org/pmwiki/pmwiki.php/%@", pageId]];
    
    NSURLSessionDataTask *task = [self.urlSession dataTaskWithURL:url completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        // **************************************
        // Converting downloaded page
        // **************************************
        TFHpple *hpple = [TFHpple hppleWithHTMLData:data encoding:@"ISO-8859-1"];
        
        TFHppleElement *titleElement = [hpple peekAtSearchWithXPathQuery:@"//div[@class='pagetitle']/span"];
        TFHppleElement *contentsElement = [hpple peekAtSearchWithXPathQuery:@"//div[@id='wikitext']"];
        NSArray *folders = [hpple searchWithXPathQuery:@"//div[@class='folderlabel']"];
        
        // **************************************
        // Storing entities
        // **************************************
        page.title = titleElement.text;
        
        Content *content = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Content class]) inManagedObjectContext:self.managedObjectContext];
        content.html = contentsElement.raw;
        content.page = page;
        
        Topic *topic = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Topic class]) inManagedObjectContext:self.managedObjectContext];
        topic.topicId = @"0";
        topic.title = @"Contents";
        topic.content = content;
        
        for (TFHppleElement *element in folders) {
            topic = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Topic class]) inManagedObjectContext:self.managedObjectContext];
            topic.topicId = @"0";
            topic.title = element.text;
            topic.content = content;
        }
        
        // **************************************
        // Notifing delegate
        // **************************************
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self pageLoaded:page];
    }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    [task resume];
}

- (void)pageLoaded:(Page*)page
{
    // **************************************
    // Defining time period to today
    // **************************************
    NSDate *today = [NSDate date];

    NSDateComponents *oneDay = [NSDateComponents new];
    oneDay.day = 1;

    NSDate *lastMidnight = [NSCalendar.currentCalendar dateFromComponents:[NSCalendar.currentCalendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:today]];
    NSDate *nextMidnight = [NSCalendar.currentCalendar dateByAddingComponents:oneDay toDate:lastMidnight options:NSWrapCalendarComponents];
    
    // **************************************
    // Check history duplicate
    // **************************************
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([History class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"page == %@ AND date >= %@ AND date <= %@", page, lastMidnight, nextMidnight];
    
    NSArray* entities = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];

    History *history;
    if (entities.count > 0) {
        history = [entities objectAtIndex:0];
    } else {
        history = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([History class]) inManagedObjectContext:self.managedObjectContext];
        history.page = page;
    }
    history.date = [NSDate date];
    
    // TODO Handle the error;
    [self.managedObjectContext save:nil];
    
    // **************************************
    // Notifying the delegate
    // **************************************
    [self.delegate pageLoaded:page];
}

- (NSURLSession*)urlSession
{
    if (_urlSession == nil) {
        NSURLSessionConfiguration *urlSessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        _urlSession = [NSURLSession sessionWithConfiguration:urlSessionConfiguration delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    }
    return _urlSession;
}

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = AppDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

@end
