//
//  NotificationView.h
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AppDelegate.h"

#define ARROW_FUDGE_X 7
#define ARROW_FUDGE_Y 14
#define ARROW_SIZE_HOR 43
#define ARROW_SIZE_VER 35
#define ARROW_SIZE_DIAG 40

@interface NotificationView : NSView
{
  NSMutableDictionary*	mTextAttributes;	//!< Attributes for desktop name text 
  NSSize textSize;
  
  int numCols;
  int numRows;
  int spaceWidth;
  int spaceHeight;
  int spacePadding;
  int currentSpace;
  int previousSpace;
}

@property (nonatomic, retain) NSMutableDictionary*	mTextAttributes;

@property (assign) int numCols;
@property (assign) int numRows;
@property (assign) int spaceWidth;
@property (assign) int spaceHeight;
@property (assign) int spacePadding;
@property (assign) int currentSpace;
@property (assign) int previousSpace;

- (void) fade;

@end
