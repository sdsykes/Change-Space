//
//  AppDelegate.m
//  ChangeSpace
//
//  Created by Stephen Sykes on 20/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

- (NSUInteger) currentSpace;

@end


@implementation AppDelegate

@synthesize window, transWindow;
@synthesize c_bridge, statusItemView, blank_image, menu_images, pollingTimer, ddh;

#pragma mark defaults

- (id) defaultsValues
{
  NSUserDefaultsController *defaults = [NSUserDefaultsController sharedUserDefaultsController];
  return [defaults values];
}

- (BOOL)isFirstLaunch
{
  id values = [self defaultsValues];
  NSNumber *before = [values valueForKey:@"hasLaunchedBefore"];
  BOOL firstLaunch = ![before boolValue];
  [values setValue:[NSNumber numberWithBool:YES] forKey:@"hasLaunchedBefore"];
  return firstLaunch;
}

- (BOOL) circulateVertical
{
  NSNumber *cv = [[self defaultsValues] valueForKey:@"circulateVertical"];
  return [cv boolValue];
}

- (BOOL) sameRowWrap
{
  NSNumber *srw = [[self defaultsValues] valueForKey:@"sameRowWrap"];
  return [srw boolValue];
}

#pragma mark -
#pragma mark preferences

- (void) updateLayout
{
  width = [[[gridColumns selectedItem] title] intValue];
  height = [[[gridRows selectedItem] title] intValue];
  total_spaces = width * height;
  [desktopCount setStringValue:[NSString stringWithFormat:@"%d", total_spaces]];
}

- (IBAction) updateGrid:(id) sender
{
  [self updateLayout];
}

- (void)activatePreferences:(id)sender
{
  [gridRows selectItemAtIndex:[[[self defaultsValues] valueForKey:@"gridRows"] intValue]];
  [gridColumns selectItemAtIndex:[[[self defaultsValues] valueForKey:@"gridColumns"] intValue]];

  [NSApp activateIgnoringOtherApps:YES];
  [preferences makeKeyAndOrderFront:self];
}

- (NSString *)codeKeyForDirection:(CSDirection)direction
{
  switch(direction) {
    case CSLeft:
      return @"leftKeyCode";
    case CSRight:
      return @"rightKeyCode";
    case CSUp:
      return @"upKeyCode";
    case CSDown:
      return @"downKeyCode";
  }
}

- (NSString *)flagsKeyForDirection:(CSDirection)direction
{
  switch(direction) {
    case CSLeft:
      return @"leftKeyFlags";
    case CSRight:
      return @"rightKeyFlags";
    case CSUp:
      return @"upKeyFlags";
    case CSDown:
      return @"downKeyFlags";
  }
}

- (KeyCombo)keyComboForDirection:(CSDirection)direction
{
  KeyCombo combo;
  combo.code = [[[self defaultsValues] valueForKey:[self codeKeyForDirection:direction]] longValue];
  combo.flags = [[[self defaultsValues] valueForKey:[self flagsKeyForDirection:direction]] unsignedLongValue];
  return combo;
}

- (void) setKeyCombo:(KeyCombo)combo direction:(CSDirection)direction
{
  id values = [self defaultsValues];
  [values setValue:[NSNumber numberWithLong:combo.code] forKey:[self codeKeyForDirection:direction]];
  [values setValue:[NSNumber numberWithUnsignedLong:combo.flags] forKey:[self flagsKeyForDirection:direction]];  
}

#pragma mark -
#pragma mark poll

- (void) pollWork:(id)sender
{
  NSUInteger spaceNumber = [self currentSpace];    

  [statusItemView setTitle:[NSString stringWithFormat:@"%d", spaceNumber]];
}

- (void) setupTimer
{
  if (!pollingTimer) {
    self.pollingTimer = [[NSTimer scheduledTimerWithTimeInterval:POLLING_INTERVAL 
                                                    target:self
                                                  selector:@selector(pollWork:)
                                                  userInfo:nil 
                                                   repeats:YES] autorelease];
  }
}

#pragma mark -
#pragma mark menu

- (NSMenuItem *) directionMenuItem:(NSString *)direction
{
  NSMenuItem *mi = [[[NSMenuItem alloc] init] autorelease];
  mi.title = [@"Go " stringByAppendingString:direction];
  mi.action = NSSelectorFromString([NSString stringWithFormat:@"go%@:", direction]);
  mi.target = self;
  return mi;
}
- (NSMenuItem *) updateMenuItem
{
  NSMenuItem *mi = [[[NSMenuItem alloc] init] autorelease];
  mi.title = @"Check for updates";
  mi.action = @selector(checkForUpdates:);
  mi.target = suupdater;
  return mi;
}

- (NSMenuItem *) preferencesMenuItem
{
  NSMenuItem *mi = [[[NSMenuItem alloc] init] autorelease];
  mi.title = @"Preferences";
  mi.action = @selector(activatePreferences:);
  mi.target = self;
  return mi;
}

- (NSMenuItem *) quitMenuItem
{
  NSMenuItem *mi = [[[NSMenuItem alloc] init] autorelease];
  mi.title = @"Quit";
  mi.action = @selector(quit:);
  mi.target = self;
  return mi;
}

- (NSMenu *)setupMenu
{
  NSMenu *menu = [[[NSMenu alloc] initWithTitle:@"Spaces"] autorelease];
  
  [menu addItem:[self directionMenuItem:@"Left"]];
  [menu addItem:[self directionMenuItem:@"Right"]];
  [menu addItem:[self directionMenuItem:@"Up"]];
  [menu addItem:[self directionMenuItem:@"Down"]];
  
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItem:[self updateMenuItem]];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItem:[self preferencesMenuItem]];
  [menu addItem:[NSMenuItem separatorItem]];
  [menu addItem:[self quitMenuItem]];
  
  return menu;
}

- (void) initStatusBar:(NSMenu *)menu
{
  NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
  NSStatusItem *statusItem = [statusBar statusItemWithLength:22];

  self.statusItemView = [[[StatusItemView alloc] init] autorelease];
  statusItemView.statusItem = statusItem;
  statusItemView.menu = menu;
  [statusItem setView:statusItemView];
}

- (void) quit:(id)sender
{
  [[NSApplication sharedApplication] terminate:self];
}

#pragma mark -
#pragma mark hotkeys

- (void)changeComboTo:(KeyCombo)combo dirction:(CSDirection)direction
{
  SEL action;
  
  switch(direction) {
    case CSLeft:
      action = @selector(goLeft:);
      break;
    case CSRight:
      action = @selector(goRight:);
      break;
    case CSUp:
      action = @selector(goUp:);
      break;
    case CSDown:
      action = @selector(goDown:);
      break;
  }
  
  [ddh unregisterHotKeysWithTarget:self action:action];
  [self setKeyCombo:combo direction:direction];
  [ddh registerHotKeyWithKeyCode:combo.code modifierFlags:combo.flags target:self action:action object:nil];  
}

- (void)registerHotkeyForDirection:(CSDirection)direction
{
  KeyCombo combo;
  combo = [self keyComboForDirection:direction];
  [self changeComboTo:combo dirction:direction];
}

- (void)registerHotkeys
{
  [self registerHotkeyForDirection:CSLeft];
  [self registerHotkeyForDirection:CSRight];
  [self registerHotkeyForDirection:CSUp];
  [self registerHotkeyForDirection:CSDown];
}

#pragma mark -
#pragma mark delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.c_bridge = [[[SpacesCBridge alloc] init] autorelease];
  
  [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"defaults" ofType:@"plist"]]];
  
  BOOL firstLaunch = [self isFirstLaunch];
  
  NSMenu *statusMenu = [self setupMenu];
  [self initStatusBar:statusMenu];
  
  self.ddh = [[[DDHotKeyCenter alloc] init] autorelease];
  
  [self registerHotkeys];
  [self updateLayout];

  self.transWindow = [[[TransparentWindow alloc] init] autorelease];
  [transWindow setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces];
  
  if (firstLaunch) [self activatePreferences:self];
  else [self setupTimer];
}

#pragma mark -
#pragma mark preferences delegate

- (void)windowWillClose:(NSNotification *)notification
{
  [self setupTimer];
}

- (void)setupKeyRecorders
{
  KeyCombo combo;
  combo = [self keyComboForDirection:CSLeft];
  [leftKeys setKeyCombo:combo];
  [leftKeys setCanCaptureGlobalHotKeys:YES];

  combo = [self keyComboForDirection:CSRight];
  [rightKeys setKeyCombo:combo];
  [rightKeys setCanCaptureGlobalHotKeys:YES];

  combo = [self keyComboForDirection:CSUp];
  [upKeys setKeyCombo:combo];
  [upKeys setCanCaptureGlobalHotKeys:YES];

  combo = [self keyComboForDirection:CSDown];
  [downKeys setKeyCombo:combo];
  [downKeys setCanCaptureGlobalHotKeys:YES];
}

- (NSString *)versionString
{
  return [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
}

- (void)windowDidBecomeKey:(NSNotification *)notification
{
  [self setupKeyRecorders];
  
  versionString.stringValue = [NSString stringWithFormat:@"Change Space v%@", [self versionString]];
}

#pragma mark -
#pragma mark key recorder delegate

- (void)shortcutRecorder:(SRRecorderControl *)aRecorder keyComboDidChange:(KeyCombo)newKeyCombo
{
  if (aRecorder == leftKeys) {
    [self changeComboTo:newKeyCombo dirction:CSLeft];
  }
  if (aRecorder == rightKeys) {
    [self changeComboTo:newKeyCombo dirction:CSRight];
  }
  if (aRecorder == upKeys) {
    [self changeComboTo:newKeyCombo dirction:CSUp];
  }
  if (aRecorder == downKeys) {
    [self changeComboTo:newKeyCombo dirction:CSDown];
  }
}

#pragma mark -
#pragma mark notification view

- (void) notify:(CSDirection)direction
{
  NSString *dirStr = @"";
  
  switch(direction) {
    case CSLeft:
      dirStr = @"←";
      break;
    case CSRight:
      dirStr = @"→";
      break;
    case CSUp:
      dirStr = @"↑";
      break;
    case CSDown:
      dirStr = @"↓";
      break;
  }
  
  NSRect screen = [[NSScreen mainScreen] frame];
  NotificationView *notificationView = [[[NotificationView alloc] initWithFrame:CGRectMake(screen.size.width / 2, screen.size.height / 2, 50, 50)] autorelease];
  notificationView.mText = dirStr;
  [transWindow setContentView:notificationView];

  [transWindow display];  // make ready for display when the window is ordered front

  [notificationView fade];
  
  [transWindow orderFront:self];
}

#pragma mark -
#pragma mark front window

- (void) activateFrontWindow
{
  ProcessSerialNumber fp;
  GetProcessForPID([c_bridge get_front_window_pid], &fp);
  SetFrontProcessWithOptions(&fp, kSetFrontProcessFrontWindowOnly);
}

#pragma mark -
#pragma mark movement

- (NSUInteger) fourCharCode:(char *)s
{
  return (s[0] << 24) + (s[1] << 16) + (s[2] << 8) + s[3];
}

- (NSString *) spaceKey:(NSUInteger)spaceNumber
{
  NSString *str = [NSString stringWithFormat:@"space_%d", spaceNumber];
  return str;
}

- (void) moveTo:(NSUInteger)spaceNumber
{
  if (spaceNumber == 1) {
    id sb = [SBApplication applicationWithBundleIdentifier:@"com.apple.SystemEvents"];
    // the cast to id is a hack to avoid the type warning, and the call to performSelector is a hack to
    // avoid the semantic warning when calling keystroke:using: directly
    [sb performSelector:@selector(keystroke:using:) withObject:@"1" withObject:(id)[self fourCharCode:"Kctl"]];
  } else {
    NSUInteger spaceIndex = spaceNumber - 1;
    [c_bridge set_space_by_index:(unsigned int)spaceIndex];
  }

  [statusItemView setTitle:[NSString stringWithFormat:@"%d", spaceNumber]];
}

- (NSDictionary *) remapDesktops
{
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"space_1", nil];

  NSUInteger savedSpaceId = [c_bridge get_space_id];  

  for (int i = 2; i <= total_spaces; i++) {
    [self moveTo:i];
    [NSThread sleepForTimeInterval:DESKTOP_MOVE_DELAY];
    NSUInteger currentSpaceId = [c_bridge get_space_id];
    [map setValue:[NSNumber numberWithInt:i] forKey:[self spaceKey:currentSpaceId]];
  }

  [self moveTo:[[map valueForKey:[self spaceKey:savedSpaceId]] intValue]];

  [self setupTimer];  // makes sure timer is running even if prefs was not closed

  return map;
}

- (NSUInteger) currentSpace
{
  NSUInteger currentSpaceId = [c_bridge get_space_id];
  id values = [self defaultsValues];
  
  NSDictionary *spaceMap = [values valueForKey:@"spaceMap"];
  
  NSNumber *spaceNumber = [spaceMap valueForKey:[self spaceKey:currentSpaceId]];
  
  if (!spaceNumber) {
    spaceMap = [self remapDesktops];
  }
  
  spaceNumber = [spaceMap valueForKey:[self spaceKey:currentSpaceId]];
  
  [values setValue:spaceMap forKey:@"spaceMap"];
  
  return [spaceNumber intValue];
}

- (void) go:(CSDirection)direction
{
  NSUInteger current = [self currentSpace];
  NSUInteger spaceNumber = current;
  
  if (!spaceNumber) return;
  
  switch(direction) {
    case CSUp:
      spaceNumber -= width;
      if (spaceNumber < 1) {
        if ([self circulateVertical]) {
          spaceNumber += total_spaces;
        } else {
          spaceNumber = current;
        }
      }
      break;
    case CSDown:
      spaceNumber += width;
      if (spaceNumber > total_spaces) {
        if ([self circulateVertical]) {
          spaceNumber -= total_spaces;
        } else {
          spaceNumber = current;
        }
      }
      break;
    case CSLeft:
      spaceNumber -= 1;
      if ([self sameRowWrap]) {
        if (spaceNumber % width == 0) spaceNumber += width;
      } else if (spaceNumber < 1) {
        spaceNumber += total_spaces;
      }
      break;
    case CSRight:
      spaceNumber += 1;
      if ([self sameRowWrap]) {
        if (spaceNumber % width == 1) spaceNumber -= width;
      } else if (spaceNumber > total_spaces) {
        spaceNumber -= total_spaces;
      }
  }
  
  if (spaceNumber != current) {
    [self notify:direction];

    [self moveTo:spaceNumber];
    // this delay means it works you to press the arrows fast
    [NSThread sleepForTimeInterval:DESKTOP_MOVE_DELAY];

    [self activateFrontWindow];
  }
}

- (void) goLeft:(id)sender
{
  [self go:CSLeft];
}
- (void) goRight:(id)sender
{
  [self go:CSRight];
}
- (void) goUp:(id)sender
{
  [self go:CSUp];
}
- (void) goDown:(id)sender
{
  [self go:CSDown];
}

#pragma mark -

- (void)dealloc
{
  [c_bridge release];
  [statusItemView release];
  [blank_image release];
  [menu_images release];
  [super dealloc];
}

@end
