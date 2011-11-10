//
//  TransparentWindow.m
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "TransparentWindow.h"

@implementation TransparentWindow

@synthesize frameSize;

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
    self.frameSize = NSMakeSize(300, 150);
  }
  return self;
  
}

- (void)calculateSize: (int)numRows numCols:(int)numCols spaceWidth:(int)spaceWidth spaceHeight:(int)spaceHeight spacePadding:(int)spacePadding
{
  int width = (numCols*(spaceWidth+spacePadding))+spacePadding;
  int height = (numRows*(spaceHeight+spacePadding))+spacePadding;
  self.frameSize = NSMakeSize(width, height);
}

- (void)resetFrame
{
  NSRect screen = [[NSScreen mainScreen] frame];
  int xPos = (screen.size.width/2)-(self.frameSize.width/2);
  int yPos = (screen.size.height/2)-(self.frameSize.height/2);
  CGRect newFrame = CGRectMake(xPos, yPos, self.frameSize.width, self.frameSize.height);
  [self setFrame:newFrame display:NO];
}

@end
