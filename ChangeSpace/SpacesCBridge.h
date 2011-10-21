//
//  SpacesCBridge.h
//  Change Space
//
//  Created by Stephen Sykes on 30/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpacesCBridge : NSObject

- (unsigned int) get_space_id;
- (void) set_space_by_index:(unsigned int) space;

@end
