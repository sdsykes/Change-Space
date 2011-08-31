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

- (void) set_space_by_index:(int) space {
  set_space_by_index(space);
}

@end
