//
//  TvTropes.h
//  tropesios
//
//  Created by João Paulo Gonçalves on 07/01/14.
//  Copyright (c) 2014 João Paulo Gonçalves. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TvTropesDelegate <NSObject>

- (void)pageLoaded:(NSString *)content;

@end

@interface TvTropes : NSObject

@property (nonatomic) id<TvTropesDelegate> delegate;

- (void)loadPageNamed:(NSString*)name;

@end
