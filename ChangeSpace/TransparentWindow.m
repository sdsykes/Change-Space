//
//  TransparentWindow.m
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "TransparentWindow.h"

@implementation TransparentWindow

- (id)init {
  NSRect screen = [[NSScreen mainScreen] frame];
  self = [super initWithContentRect:screen 
                          styleMask:NSBorderlessWindowMask 
                            backing:NSBackingStoreBuffered 
                              defer:NO];
  if (self != nil) {
    [self setLevel: NSStatusWindowLevel];
    [self setBackgroundColor: [NSColor clearColor]];
    [self setAlphaValue:1.0];
    [self setOpaque:NO];
    [self setHasShadow:NO];
    [self setIgnoresMouseEvents: YES];
  }
  return self;
  
}

- (void)resetFrame
{
  NSRect screen = [[NSScreen mainScreen] frame];
  [self setFrame:screen display:NO];
}

@end
