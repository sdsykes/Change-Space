//
//  NotificationView.h
//  Change Space
//
//  Created by Stephen Sykes on 23/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface NotificationView : NSView
{
  NSMutableDictionary*	mTextAttributes;	//!< Attributes for desktop name text 
	
	NSString*	mText;
}

@property (nonatomic, retain) NSMutableDictionary*	mTextAttributes;
@property (nonatomic, retain) NSString*	mText;

- (void) fade;

@end
