//
//  TransparentWindow.h
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface TransparentWindow : NSWindow {
  NSSize frameSize;
}

@property (assign) NSSize frameSize;

- (void)calculateSize: (int)numRows numCols:(int)numCols spaceWidth:(int)spaceWidth spaceHeight:(int)spaceHeight spacePadding:(int)spacePadding;
- (void)resetFrame;

@end
