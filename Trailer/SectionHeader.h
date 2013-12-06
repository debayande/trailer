//
//  SectionHeader.h
//  Trailer
//
//  Created by Paul Tsochantaris on 06/12/2013.
//  Copyright (c) 2013 HouseTrip. All rights reserved.
//


#import <Cocoa/Cocoa.h>


@class SectionHeader;


@protocol SectionHeaderDelegate <NSObject>

- (void)sectionHeaderRemoveSelected:(NSMenuItem *)item;

@end


@interface SectionHeader : NSView

@property (nonatomic,weak) id<SectionHeaderDelegate> delegate;

- (id)initWithRemoveAllDelegate:(id<SectionHeaderDelegate>)delegate;

@end