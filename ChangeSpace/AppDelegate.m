//
//  AppDelegate.m
//  ChangeSpace
//
//  Created by Stephen Sykes on 20/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "AppDelegate.h"
#import "NotificationView.h"

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
  totalSpaces = width * height;
  [desktopCount setStringValue:[NSString stringWithFormat:@"%d", totalSpaces]];
}

- (IBAction) updateGrid:(id) sender
{
  [self updateLayout];
}

- (void)activatePreferences:(id)sender
{
  [gridRows selectItemAtIndex:[[[self defaultsValues] valueForKey:@"gridRows"] intValue]];
  [gridColumns selectItemAtIndex:[[[self defaultsValues] valueForKey:@"gridColumns"] intValue]];

  savedTotalSpaces = totalSpaces;
  
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
    default: return @"";
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
    default: return @"";
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
#pragma mark notifications

- (void)workspaceObserver:(id)aNotification
{
  NSUInteger spaceNumber = [self currentSpace];    
  NSString *displayString;

  if (spaceNumber > 0) displayString = [NSString stringWithFormat:@"%d", spaceNumber];
  else displayString = @"?";
  
  [statusItemView setTitle:displayString];
}

- (void) setupNotification
{
  if (!observing) {
    observing = YES;

    NSNotificationCenter *notCenter;
    notCenter = [[NSWorkspace sharedWorkspace] notificationCenter];
    [notCenter addObserver:self
                selector:@selector(workspaceObserver:)
                    name:NSWorkspaceActiveSpaceDidChangeNotification object:nil];

    [self workspaceObserver:nil];  // shows current desktop when app is first opened
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
    default: break;
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
  else [self setupNotification];
  
}

#pragma mark -
#pragma mark preferences delegate

- (void)reportBadDesktopCount:(int)reportedSpaces
{
  NSAlert *warning = [[NSAlert alloc] init];
  warning.messageText = @"Incorrect desktop count";
  NSString *desktopsText;
  if (reportedSpaces == 1) {
    desktopsText = @"is only 1 desktop";
  } else {
    desktopsText = [NSString stringWithFormat:@"are only %d desktops", reportedSpaces];
  }
  NSString *infoText = [NSString stringWithFormat:@"The system is reporting that there %@. Please add %d more othewise Change Space will not function correctly.", desktopsText, totalSpaces - reportedSpaces];
  warning.informativeText = infoText;
  [warning runModal];
  [warning release];  
}

- (void)windowWillClose:(NSNotification *)notification
{
  if (totalSpaces > savedTotalSpaces) remapNeeded = YES;
  
  int reportedSpaces = [c_bridge total_spaces];
  if (totalSpaces > reportedSpaces) {
    [self reportBadDesktopCount:reportedSpaces];
  }
  
  [self setupNotification];
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

- (void) notify:(CSDirection)direction fromSpace:(NSUInteger)fromSpace toSpace:(NSUInteger)toSpace
{
  NSRect screen = [[NSScreen mainScreen] frame];
  NotificationView *notificationView = [[[NotificationView alloc] initWithFrame:CGRectMake(screen.size.width / 2, screen.size.height / 2, 50, 50)] autorelease];
  notificationView.direction = direction;
  
  [transWindow resetFrame];  // the screen size may have changed if using ext monitors etc
  
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

- (NSString *) spaceKey:(NSUInteger)spaceNumber
{
  NSString *str = [NSString stringWithFormat:@"space_%d", spaceNumber];
  return str;
}

- (CGSTransitionOption) transitionDirectionForCSDirection:(CSDirection)direction
{
  CGSTransitionOption transDir;
  
  switch (direction) {
    case CSLeft:
      transDir = CGSRight;
      break;
    case CSUp:
      transDir = CGSDown;
      break;
    case CSRight:
      transDir = CGSLeft;
      break;
    case CSDown:
      transDir = CGSUp;
      break;
    case CSUpLeft:
      transDir = CGSBottomRight;
      break;
    case CSUpRight:
      transDir = CGSLeft;
      break;
    case CSDownLeft:
      transDir = CGSRight;
      break;
    case CSDownRight:
      transDir = CGSBottomLeft;
      break;
      
    default:
      transDir = CGSRight;
      break;
  }
  return transDir;
}

- (void) moveTo:(NSUInteger)spaceNumber direction:(CSDirection)direction defaultMotion:(BOOL)defaultMotion
{
  unsigned int spaceIndex = (unsigned int)spaceNumber - 1;
  if (defaultMotion) {
    [c_bridge setSpaceWithoutTransition:spaceIndex];
  } else {
    [c_bridge setSpaceWithTransition:spaceIndex type:CGSSlide direction:[self transitionDirectionForCSDirection:direction]];
  }

  [statusItemView setTitle:[NSString stringWithFormat:@"%d", spaceNumber]];
}

- (NSDictionary *) remapDesktops
{
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"space_1", nil];

  NSUInteger savedSpaceId = [c_bridge get_space_id];  

  for (int i = 2; i <= totalSpaces; i++) {
    [c_bridge set_space_by_index:(unsigned int)(i - 1)];
    [NSThread sleepForTimeInterval:DESKTOP_MOVE_DELAY];
    NSUInteger currentSpaceId = [c_bridge get_space_id];
    [map setValue:[NSNumber numberWithInt:i] forKey:[self spaceKey:currentSpaceId]];
  }

  NSNumber *savedSpaceNumber = (NSNumber *)[map valueForKey:[self spaceKey:savedSpaceId]];
  if (!savedSpaceNumber) {
    [map setValue:[NSNumber numberWithInt:0] forKey:[self spaceKey:savedSpaceId]];
  } else {
    [c_bridge set_space_by_index:[savedSpaceNumber unsignedIntValue] - 1];
  }
  
  [self setupNotification];  // makes sure we are subscribed even if prefs was not closed

  return map;
}

// returns 0 for an unknown space, or full screen app space
- (NSUInteger) currentSpace
{
  NSUInteger currentSpaceId = [c_bridge get_space_id];
  id values = [self defaultsValues];
  
  NSDictionary *spaceMap = [values valueForKey:@"spaceMap"];
  
  NSNumber *spaceNumber = [spaceMap valueForKey:[self spaceKey:currentSpaceId]];
  
  NSUInteger spaceNumberInt = [spaceNumber unsignedIntValue];
  
  if (!spaceNumber || (spaceNumberInt == 0 && remapNeeded) || spaceNumberInt > totalSpaces) {
    if ([c_bridge is_full_screen]) return 0;
    
    spaceMap = [self remapDesktops];
    [values setValue:spaceMap forKey:@"spaceMap"];
    remapNeeded = NO;
  }
  
  spaceNumber = [spaceMap valueForKey:[self spaceKey:currentSpaceId]];
  
  return [spaceNumber intValue];
}

- (void) go:(CSDirection)keyDirection
{
  NSUInteger current = [self currentSpace];
  NSUInteger spaceNumber = current;
  CSDirection direction = keyDirection;
  
  if (!spaceNumber) return;
  
  switch(keyDirection) {
    case CSUp:
      spaceNumber -= width;
      if (spaceNumber < 1) {
        if ([self circulateVertical]) {
          spaceNumber += totalSpaces;
        } else {
          spaceNumber = current;
        }
      }
      break;
    case CSDown:
      spaceNumber += width;
      if (spaceNumber > totalSpaces) {
        if ([self circulateVertical]) {
          spaceNumber -= totalSpaces;
        } else {
          spaceNumber = current;
        }
      }
      break;
    case CSLeft:
      spaceNumber -= 1;
      if (spaceNumber % width == 0) {
        if ([self sameRowWrap]) {
          spaceNumber += width;
          direction = CSRight;
        } else if (spaceNumber < 1) {
          spaceNumber += totalSpaces;
          direction = CSDownRight;
        } else {
          direction = CSUpRight;
        }
      }
      break;
    case CSRight:
      spaceNumber += 1;
      if (spaceNumber % width == 1) {
        if ([self sameRowWrap]) {
          spaceNumber -= width;
          direction = CSLeft;
        } else if (spaceNumber > totalSpaces) {
          spaceNumber -= totalSpaces;
          direction = CSUpLeft;
        } else {
          direction = CSDownLeft;
        }
      }
    default: break;
  }
  
  if (spaceNumber != current && spaceNumber <= [c_bridge total_spaces]) {
    [self notify:direction fromSpace:current toSpace:spaceNumber];
    
    BOOL isDefault;
    if ((current - 1 == spaceNumber && direction == CSLeft) ||
        (current + 1 == spaceNumber && direction == CSRight)) isDefault = YES;
    else isDefault = NO;

    [self moveTo:spaceNumber direction:direction defaultMotion:isDefault];
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
