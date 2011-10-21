//
//  StatusItemView.h
//  ChangeSpace
//
//  Created by Stephen Sykes on 21/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//  Thanks Kris Johnson
//  See http://undefinedvalue.com/2009/07/07/adding-custom-view-nsstatusitem
//

#import <Cocoa/Cocoa.h>

#define StatusItemViewPaddingWidth  3
#define StatusItemViewPaddingHeight 3
#define StatusItemViewWidth  22
#define StatusItemViewHeight 22

@class StatusTitleView;

@interface StatusItemView : NSView <NSMenuDelegate>
{
  NSStatusItem *statusItem;
  NSString *title;
  BOOL isMenuVisible;
  NSMenu *menu;
  NSImage *icon;
  NSImage *altIcon;
  StatusTitleView *titleView;
}

@property (retain, nonatomic) NSStatusItem *statusItem;
@property (retain, nonatomic) NSString *title;
@property (retain, nonatomic) NSMenu *menu;
@property (retain, nonatomic) NSImage *icon;
@property (retain, nonatomic) NSImage *altIcon;
@property (retain, nonatomic) StatusTitleView *titleView;

@end
