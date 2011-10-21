//
//  ChangeSpaceAppDelegate.h
//  Change Space
//
//  Created by Stephen Sykes on 19/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Sparkle/Sparkle.h>
#import <ScriptingBridge/ScriptingBridge.h>
#import "SRRecorderControl.h"
#import "SpacesCBridge.h"

#define MAX_DESKTOPS 16

typedef enum {
  CSLeft,
  CSRight,
  CSUp,
  CSDown
} CSDirection;

@interface ChangeSpaceAppDelegate : NSObject <NSApplicationDelegate>

{
  IBOutlet NSWindow *window;
  IBOutlet NSPanel *preferences;
  IBOutlet SUUpdater *suupdater;
  IBOutlet NSPopUpButton *gridColumns;
  IBOutlet NSPopUpButton *gridRows;
  IBOutlet NSTextField *desktopCount;
  IBOutlet NSButton *circulateVertical;
  IBOutlet SRRecorderControl *leftKeys;
  IBOutlet SRRecorderControl *rightKeys;
  IBOutlet SRRecorderControl *upKeys;
  IBOutlet SRRecorderControl *downKeys;
  
  NSString *cache_path;
  NSString *res_path;

  SpacesCBridge *c_bridge;
  
  NSUInteger width, height, total_spaces;
  
  NSStatusItem *status_item;
  
  NSImage *blank_image;
  NSMutableArray *menu_images;
}

@property (nonatomic, retain) NSString *cache_path;
@property (nonatomic, retain) NSString *res_path;
@property (nonatomic, retain) SpacesCBridge *c_bridge;  
@property (nonatomic, retain) NSStatusItem *status_item;
@property (nonatomic, retain) NSImage *blank_image;
@property (nonatomic, retain) NSMutableArray *menu_images;

@end
