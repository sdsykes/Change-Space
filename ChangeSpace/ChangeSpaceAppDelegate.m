//
//  ChangeSpaceAppDelegate.m
//  Change Space
//
//  Created by Stephen Sykes on 19/10/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "ChangeSpaceAppDelegate.h"

@implementation ChangeSpaceAppDelegate

@synthesize cache_path, res_path, c_bridge, status_item, blank_image, menu_images;

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

- (void)setupPaths
{
  self.res_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/"];
  NSArray *arr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true);
  self.cache_path = [[arr objectAtIndex:0] stringByAppendingString:@"/"];
}

#pragma mark -
#pragma mark menu

- (NSMenuItem *) directionMenuItem:(NSString *)direction
{
  NSMenuItem *mi = [[[NSMenuItem alloc] init] autorelease];
  mi.title = [@"Go " stringByAppendingString:direction];
  mi.action = NSSelectorFromString([@"go" stringByAppendingString:direction]);
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
  mi.action = @selector(activate_preferences:);
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
  NSStatusBar *status_bar = [NSStatusBar systemStatusBar];
  self.status_item = [status_bar statusItemWithLength:NSVariableStatusItemLength];
  [status_item setMenu:menu];

  NSString *iconFile = [[NSBundle mainBundle] pathForResource:@"menu_icon" ofType:@"png"];
  self.blank_image = [[[NSImage alloc] initWithContentsOfFile:iconFile] autorelease];
  [status_item setImage:blank_image];
  
  iconFile = [[NSBundle mainBundle] pathForResource:@"menu_icon_alt" ofType:@"png"];
  NSImage *altImage = [[[NSImage alloc] initWithContentsOfFile:iconFile] autorelease];
  [status_item setAlternateImage:altImage];

  self.menu_images = [[NSMutableArray alloc] initWithCapacity:MAX_DESKTOPS];
  for (int i = 0; i < MAX_DESKTOPS; i++) {
    NSString *fname = [NSString stringWithFormat:@"menu_icon_%d", i+1]; 
    iconFile = [[NSBundle mainBundle] pathForResource:fname ofType:@"png"];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:iconFile];
    [menu_images replaceObjectAtIndex:i withObject:image];
  }
  [status_item setHighlightMode:YES];
}

#pragma mark -
#pragma mark delegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
  self.c_bridge = [[[SpacesCBridge alloc] init] autorelease];

  [self setupPaths];
  
  BOOL firstLaunch = [self isFirstLaunch];
  
  NSMenu *statusMenu = [self setupMenu];
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

- (void) moveTo:(NSUInteger) spaceNumber
{
  if (spaceNumber < 2) {
    SBApplication *sb = [SBApplication applicationWithBundleIdentifier:@"com.apple.SystemEvents"];
    [sb keystroke:[NSString stringWithFormat:@"%d", spaceNumber] using:[self fourCharCode:"Kctl"]];
  } else {
    NSUInteger spaceIndex = spaceNumber - 1;
    [c_bridge set_space_by_index:(unsigned int)spaceIndex];
  }

  [status_item setImage:[menu_images objectAtIndex:spaceNumber]];
  // reset menu image...
}

- (NSDictionary *) remapDesktops
{
  NSMutableDictionary *map = [[NSMutableDictionary alloc] initWithObjectsAndKeys:[NSNumber numberWithInt:1], @"space_1", nil];
  for (int i = 2; i <= total_spaces; i++) {
    [self moveTo:i];
    [NSThread sleepForTimeInterval:1.0f];
    NSUInteger currentSpaceId = [c_bridge get_space_id];
    [map setValue:[NSNumber numberWithInt:i] forKey:[self spaceKey:currentSpaceId]];
  }
  
  return map;
}

- (NSUInteger) current_space
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
  NSUInteger current = [self current_space];
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
      if (spaceNumber < 1) {
        spaceNumber += total_spaces;
      }
      break;
    case CSRight:
      spaceNumber += 1;
      if (spaceNumber > total_spaces) {
        spaceNumber -= total_spaces;
      }
  }

  if (spaceNumber != current) {
    [self moveTo:spaceNumber];
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

- (void) dealloc 
{
  [cache_path release];
  [res_path release];
  [c_bridge release];
  [status_item release];
  [blank_image release];
  [menu_images release];
  
  [super dealloc];
}

@end
