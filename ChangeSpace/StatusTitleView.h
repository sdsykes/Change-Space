//
//  StatusTitleView.h
//  ChangeSpace
//
//  Created by Stephen Sykes on 21/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface StatusTitleView : NSView
{
  BOOL isMenuVisible;
  NSString *title;
}

@property (retain, nonatomic) NSString *title;

- (void) setMenuVisible:(BOOL)visible;
- (void) fade;

@end
