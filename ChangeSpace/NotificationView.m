//
//  NotificationView.m
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

@synthesize mTextAttributes, direction;

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

- (CGFloat)angleForDirection
{
  CGFloat angle = 0;
  
  switch(direction) {
    case CSLeft:
      angle = 180;
      break;
    case CSRight:
      angle = 0;
      break;
    case CSUp:
      angle = 90;
      break;
    case CSDown:
      angle = -90;
      break;
    case CSUpLeft:
      angle = 135;
      break;
    case CSUpRight:
      angle = 45;
      break;
    case CSDownLeft:
      angle = -135;
      break;
    case CSDownRight:
      angle = -45;
      break;
  }
  return angle;
}

- (void)drawRect:(NSRect)dirtyRect
{
  NSString *dirStr = @"→";
  
  NSSize	textSize = [dirStr sizeWithAttributes: mTextAttributes];
  NSPoint	textPosition; 
	textPosition.x = 0.5 * (dirtyRect.size.width - textSize.width);
  textPosition.y = 0.5 * (dirtyRect.size.height - textSize.height);
  
  NSAffineTransform* transform = [NSAffineTransform transform];
  NSSize originShift = NSMakeSize(self.bounds.origin.x + self.bounds.size.width /
                                  2.0, self.bounds.origin.y + self.bounds.size.height / 2.0);
  [transform translateXBy: originShift.width yBy: originShift.height];
  [transform rotateByDegrees:[self angleForDirection]];
  [transform translateXBy: -originShift.width yBy: -originShift.height];
  [transform concat];

  [dirStr drawAtPoint:textPosition withAttributes: mTextAttributes];

}

- (void)fade
{
  [self setAlphaValue:1.0];
  
  [[NSAnimationContext currentContext] setDuration:1.0];
  [[self animator] setAlphaValue:0.0];  
}


@end
