//
//  StatusTitleView.m
//  ChangeSpace
//
//  Created by Stephen Sykes on 21/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "StatusTitleView.h"
#import "StatusItemView.h"

@implementation StatusTitleView

@synthesize title;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      isMenuVisible = NO;
    }
    
    return self;
}

- (void) setMenuVisible:(BOOL)visible
{
  isMenuVisible = visible;
}

#pragma mark -
#pragma mark title

- (NSColor *)titleForegroundColor {
  if (isMenuVisible) {
    return [NSColor whiteColor];
  }
  else {
    return [NSColor blackColor];
  }    
}

- (NSDictionary *)titleAttributes {
  // Use default menu bar font size
  NSFont *font = [NSFont menuBarFontOfSize:11];
  
  NSColor *foregroundColor = [self titleForegroundColor];
  
  NSMutableParagraphStyle * paragraphStyle = [[[NSParagraphStyle defaultParagraphStyle] mutableCopy] autorelease];
  [paragraphStyle setAlignment:NSCenterTextAlignment];
  
  return [NSDictionary dictionaryWithObjectsAndKeys:
          font,            NSFontAttributeName,
          foregroundColor, NSForegroundColorAttributeName,
          paragraphStyle, NSParagraphStyleAttributeName,
          nil];
}

#pragma mark -
#pragma mark draw

- (void)drawRect:(NSRect)rect
{
  NSRect titleRect = CGRectMake(rect.origin.x, rect.origin.y - StatusItemViewPaddingHeight, rect.size.width, rect.size.height);
  [title drawInRect:titleRect withAttributes:[self titleAttributes]];
}

- (void) fade
{
  [self setAlphaValue:1.0];
  
  [[NSAnimationContext currentContext] setDuration:4.0];
  [[self animator] setAlphaValue:0.0];  
}

@end
