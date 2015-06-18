//
//  ECInfiniteHorizontalPageView.m
//  EvCal
//
//  Created by Tom on 6/18/15.
//  Copyright (c) 2015 spitzgoby LLC. All rights reserved.
//

#import "ECInfiniteHorizontalPageView.h"

@implementation ECInfiniteHorizontalPageView

- (void)setContentSize:(CGSize)contentSize
{
    CGSize threePageContentSize = CGSizeMake(contentSize.width * 3, contentSize.height);
    [super setContentSize:threePageContentSize];
}

- (void)setPagingEnabled:(BOOL)pagingEnabled
{
    DDLogWarn(@"The infinite horizontal pager should always be in paging mode");
    [super setPagingEnabled:YES];
}

@end
