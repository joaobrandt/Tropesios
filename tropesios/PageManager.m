//
//  PageManager.m
//  Tropesios
//
//  Created by João Paulo Gonçalves on 12/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import "SubPage.h"
#import "Topic.h"
#import "PageManager.h"

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
    // **************************************
    // LOCAL LOADING
    // **************************************
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:NSStringFromClass([Page class])];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"pageId = %@", pageId];
    
    NSArray* entities = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (entities.count > 0) {
        Page* page = [entities objectAtIndex:0];
        [self.delegate pageLoaded:page];
        return;
    }
    
    // **************************************
    // REMOTE LOADING
    // **************************************
    NSString *stringURL = [NSString stringWithFormat:@"http://tvtropes.org/pmwiki/pmwiki.php/%@", pageId];
    NSURL *url = [NSURL URLWithString:stringURL];
    
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
        Page *page = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Page class]) inManagedObjectContext:self.managedObjectContext];
        page.pageId = pageId;
        page.title = titleElement.text;
        page.contents = contentsElement.raw;
        page.fetchedIn = [NSDate date];
        
        Topic *topic = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Topic class]) inManagedObjectContext:self.managedObjectContext];
        topic.page = page;
        topic.topicId = @"0";
        topic.title = @"Contents";
        [page addTopicsObject:topic];
        
        for (TFHppleElement *element in folders) {
            topic = [NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([Topic class]) inManagedObjectContext:self.managedObjectContext];
            topic.page = page;
            topic.topicId = @"0";
            topic.title = element.text;
            [page addTopicsObject:topic];
        }
        
        [AppDelegate.managedObjectContext save:nil];
        
        // **************************************
        // Notifing delegate
        // **************************************
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        [self.delegate pageLoaded:page];
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

- (NSManagedObjectContext*)managedObjectContext
{
    if (_managedObjectContext == nil) {
        _managedObjectContext = AppDelegate.managedObjectContext;
    }
    return _managedObjectContext;
}

@end
