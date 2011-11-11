//
//  NotificationView.m
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "NotificationView.h"

@implementation NotificationView

@synthesize mTextAttributes;
@synthesize numRows, numCols, spaceWidth, spaceHeight, spacePadding, currentSpace, previousSpace;

NSString *dirStr = @"⬅";

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
                          [NSFont boldSystemFontOfSize: 58], NSFontAttributeName,
                          textShadow, NSShadowAttributeName,  
                              nil];
            
    }
    
    return self;
}

- (CGPoint)positionForSpaceNumber:(int)spaceNumber
{
  CGPoint point;
  point.x = (spaceNumber - 1) % numCols;
  point.y = (spaceNumber - 1) / numCols;

  return point;
}

- (CGFloat)angleForDirection
{
  CGFloat angle = 0;
  CGPoint p1 = [self positionForSpaceNumber:previousSpace];
  CGPoint p2 = [self positionForSpaceNumber:currentSpace];

  CGFloat dx = p1.x - p2.x;
  CGFloat dy = p2.y - p1.y;

  angle = atan2(dy, dx) * 180 / M_PI;
  
  return angle;
}

- (CGFloat)fontSizeForDirection
{
  CGFloat size = 0;
  CGFloat angle = [self angleForDirection];
  
  if (abs(angle) == 0 || abs(angle) == 180) {
    size = ARROW_SIZE_HOR;
  } else if (abs(angle) == 90) {
    size = ARROW_SIZE_VER;
  } else {
    size = ARROW_SIZE_DIAG;
  }
  return size;
}


- (void)drawRect:(NSRect)dirtyRect
{
  [[NSGraphicsContext currentContext] saveGraphicsState];
  NSRect bounds = [self bounds];
  NSBezierPath* clipShape = [NSBezierPath bezierPath];
  [clipShape appendBezierPathWithRoundedRect:bounds xRadius:8 yRadius:8];
  [clipShape setWindingRule:NSEvenOddWindingRule];
  
  // all of the clipped out spaces that will be mostly transparent
  NSBezierPath* spacesPath = [NSBezierPath bezierPath];
  
  // the path that should be highlighted white
  NSBezierPath* highlightPath = nil;
  
  int prevXPos = 0, prevYPos = 0;
  int k = 0;
  for (k=0; k < numRows; k++) {
    int i = 0;
    for (i=0; i < numCols; i++) {
      int spaceNumber = i + (k * numCols) + 1;
      
      NSBezierPath* oneGrid = [NSBezierPath bezierPath];
      int xPos = (spacePadding * (i + 1)) + (spaceWidth * i);
      int yPos = (spacePadding * (self.numRows - k))+(spaceHeight * (self.numRows - k - 1));
      [oneGrid appendBezierPathWithRoundedRect:NSMakeRect(xPos, yPos, spaceWidth, spaceHeight) xRadius:2 yRadius:2];
      
      [spacesPath appendBezierPath:oneGrid];
      
      if (spaceNumber == self.currentSpace) {
        highlightPath = [NSBezierPath bezierPathWithRoundedRect:NSMakeRect(xPos + 2, yPos + 2, spaceWidth - 4, spaceHeight - 4) xRadius:4 yRadius:4];
      }
      
      if (spaceNumber == self.previousSpace) {
        prevXPos = xPos;
        prevYPos = yPos;
      }
    }
  }
  [clipShape appendBezierPath: spacesPath];
  [clipShape addClip];
  
  
  NSGradient* aGradient = [[[NSGradient alloc]
                            initWithColorsAndLocations:[NSColor colorWithCalibratedRed:143/255.0 green:153/255.0 blue:155/255.0 alpha:1.0f], (CGFloat)0.0,
                            [NSColor colorWithCalibratedRed:143/255.0 green:153/255.0 blue:155/255.0 alpha:1.0f], (CGFloat)2.0,
                            [NSColor colorWithCalibratedRed:30/255.0 green:40/255.0 blue:39/255.0 alpha:1.0f], (CGFloat)0.55,
                            [NSColor colorWithCalibratedRed:19/255.0 green:31/255.0 blue:29/255.0 alpha:1.0f], (CGFloat)0.58,
                            [NSColor colorWithCalibratedRed:21/255.0 green:35/255.0 blue:46/255.0 alpha:1.0f], (CGFloat)1.0,
                            nil] autorelease];
  
  
  [aGradient drawInBezierPath:clipShape angle:-90.0];
  
  [clipShape setLineWidth:2];
  [clipShape stroke];
  [[NSGraphicsContext currentContext] restoreGraphicsState];
  
  [[[NSColor blackColor] colorWithAlphaComponent:0.35] setFill];
  [spacesPath fill];
  [[[NSColor blackColor] colorWithAlphaComponent:0.5] setStroke];
  [spacesPath stroke];
  
  if (highlightPath != nil) {
    [[[NSColor whiteColor] colorWithAlphaComponent:0.9] setFill];
    [highlightPath fill];
  }

  // draw the arrow
  [[NSGraphicsContext currentContext] saveGraphicsState];  
  [mTextAttributes setValue:[NSFont boldSystemFontOfSize: [self fontSizeForDirection]] forKey:NSFontAttributeName];
  textSize = [dirStr sizeWithAttributes: mTextAttributes];

  NSPoint	textPosition;
	textPosition.x = prevXPos + spaceWidth / 2 - textSize.width / 2;
  textPosition.y = prevYPos + spaceHeight / 2 - textSize.height / 2;

  NSAffineTransform* transform = [NSAffineTransform transform];
  NSSize originShift = NSMakeSize(prevXPos + spaceWidth / 2,
                                  prevYPos + spaceHeight / 2);
  [transform translateXBy: originShift.width yBy: originShift.height];
  [transform rotateByDegrees:[self angleForDirection]];
  [transform translateXBy: -originShift.width yBy: -originShift.height];
  [transform concat];
  
  [dirStr drawAtPoint:textPosition withAttributes: mTextAttributes];
  [[NSGraphicsContext currentContext] restoreGraphicsState];
}

- (void)fade
{
  [self setAlphaValue:1.0];
  
  [[NSAnimationContext currentContext] setDuration:0.4];
  [[self animator] setAlphaValue:0.0];  
}


@end
