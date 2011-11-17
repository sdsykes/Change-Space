//
//  SpacesCBridge.m
//  Change Space
//
//  Created by Stephen Sykes on 30/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import "SpacesCBridge.h"

#import "spaces.h"

@implementation SpacesCBridge

- (int) get_space_id {
  return get_space_id();
}

- (void) set_space_by_index:(int)space {
  set_space_by_index(space);
}

- (int) get_front_window_pid {
  return get_front_window_pid();
}

- (int) is_full_screen {
  return is_full_screen();
}

- (int) total_spaces {
  return total_spaces();
}

- (NSUInteger) fourCharCode:(char *)s
{
  return (s[0] << 24) + (s[1] << 16) + (s[2] << 8) + s[3];
}

- (void) setSpaceOne {
  id sb = [SBApplication applicationWithBundleIdentifier:@"com.apple.SystemEvents"];
  // the cast to id is a hack to avoid the type warning, and the call to performSelector is a hack to
  // avoid the semantic warning when calling keystroke:using: directly
  [sb performSelector:@selector(keystroke:using:) withObject:@"1" withObject:(id)[self fourCharCode:"Kctl"]];
}

- (void) setSpaceWithoutTransition:(unsigned int)spaceIndex
{
  if (spaceIndex == 0) [self setSpaceOne];
  else [self set_space_by_index:spaceIndex];
}

- (void) setSpaceWithTransition:(unsigned int)spaceIndex type:(CGSTransitionType)type direction:(CGSTransitionOption)direction {
  CGSConnection cid;
  int transitionHandle;
  CGSTransitionSpec transitionSpec;

  cid = _CGSDefaultConnection();
  
  memset(&transitionSpec, 0, sizeof(CGSTransitionSpec));
  transitionSpec.type = type;
  transitionSpec.option = direction;


  // Do the usual transition
  [self setSpaceWithoutTransition:spaceIndex];
  usleep(PRE_FREEZE_WAIT);
  CGSNewTransition(cid, &transitionSpec, &transitionHandle);

  // wait for it to happen
  usleep(LION_TRANSITION_DELAY); 
  // then do our own transition
  CGSInvokeTransition(cid, transitionHandle, 0.2);
}

@end
