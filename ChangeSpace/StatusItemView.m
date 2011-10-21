//
//  StatusItemView.m
//  ChangeSpace
//
//  Created by Stephen Sykes on 21/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//  Thanks Kris Johnson
//  See http://undefinedvalue.com/2009/07/07/adding-custom-view-nsstatusitem
//

#import "StatusItemView.h"
#import "StatusTitleView.h"

@implementation StatusItemView

@synthesize statusItem, menu, icon, altIcon, titleView;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      statusItem = nil;
      isMenuVisible = NO;
      NSString *iconFile = [[NSBundle mainBundle] pathForResource:@"menu_icon" ofType:@"png"];
      self.icon = [[[NSImage alloc] initWithContentsOfFile:iconFile] autorelease];
      iconFile = [[NSBundle mainBundle] pathForResource:@"menu_icon_alt" ofType:@"png"];
      self.altIcon = [[[NSImage alloc] initWithContentsOfFile:iconFile] autorelease];
      
      self.titleView = [[[StatusTitleView alloc] initWithFrame:CGRectMake(0, 0, StatusItemViewWidth, StatusItemViewHeight)] autorelease];
      [self addSubview:titleView];
      title = @"";
    }
    
    return self;
}

#pragma mark -
#pragma mark menu

- (void)mouseDown:(NSEvent *)event {
  [[self menu] setDelegate:self];
  [statusItem popUpStatusItemMenu:[self menu]];
  [self setNeedsDisplay:YES];
}

- (void)rightMouseDown:(NSEvent *)event {
  // Treat right-click just like left-click
  [self mouseDown:event];
}

- (void)menuWillOpen:(NSMenu *)aMenu {
  isMenuVisible = YES;
  [titleView setMenuVisible:YES];
  [self setNeedsDisplay:YES];
}

- (void)menuDidClose:(NSMenu *)aMenu {
  isMenuVisible = NO;
  [titleView setMenuVisible:NO];
  [aMenu setDelegate:nil];    
  [self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark title

- (void)setTitle:(NSString *)newTitle {
  if (![title isEqual:newTitle]) {
    [newTitle retain];
    [title release];
    title = newTitle;

    [titleView setTitle:newTitle];
    
    [self setNeedsDisplay:YES];
    // not needed when polling
    // [titleView fade];
  }
}

- (NSString *)title {
  return title;
}

#pragma mark -
#pragma mark icon

- (NSImage *)iconImage {
  if (isMenuVisible) {
    return altIcon;
  } else {
    return icon;
  }
}

#pragma mark -
#pragma mark draw

- (void)drawRect:(NSRect)rect
{
  // Draw status bar background, highlighted if menu is showing
  [statusItem drawStatusBarBackgroundInRect:[self bounds]
                              withHighlight:isMenuVisible];

  NSPoint origin = NSMakePoint(StatusItemViewPaddingWidth,
                               StatusItemViewPaddingHeight);
  
  [[self iconImage] drawAtPoint:origin fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
}

- (void)dealloc {
  [statusItem release];
  [title release];
  [menu release];
  [icon release];
  [altIcon release];
  [titleView release];
  [super dealloc];
}

@end
