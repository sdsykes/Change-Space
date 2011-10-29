//
//  NotificationView.m
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

@synthesize mText, mTextAttributes;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      NSShadow* textShadow = [[[NSShadow alloc] init] autorelease];
      [textShadow setShadowColor: [NSColor blackColor]];
      [textShadow setShadowOffset: NSMakeSize(0, -1)];
      [textShadow setShadowBlurRadius: 3];
      
      // desktop name attributes 
      self.mTextAttributes = [NSMutableDictionary dictionaryWithObjectsAndKeys: 
                          [NSColor whiteColor], NSForegroundColorAttributeName,
                          [NSFont boldSystemFontOfSize: 148], NSFontAttributeName,
                          textShadow, NSShadowAttributeName,  
                              nil];
      
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSSize	textSize = [mText sizeWithAttributes: mTextAttributes];
  NSPoint	textPosition; 
	textPosition.x = 0.5 * (dirtyRect.size.width - textSize.width);
  textPosition.y = 0.5 * (dirtyRect.size.height - textSize.height);
  [mText drawAtPoint:textPosition withAttributes: mTextAttributes];
}

- (void)fade
{
  [self setAlphaValue:1.0];
  
  [[NSAnimationContext currentContext] setDuration:1.0];
  [[self animator] setAlphaValue:0.0];  
}


@end
