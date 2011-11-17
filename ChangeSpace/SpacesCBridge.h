//
//  SpacesCBridge.h
//  Change Space
//
//  Created by Stephen Sykes on 30/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ScriptingBridge/ScriptingBridge.h>

#define PRE_FREEZE_WAIT 1000
#define LION_TRANSITION_DELAY 300000

typedef int CGSConnection;
/*
extern OSStatus CGSGetWorkspace(const CGSConnection cid, int *workspace);
extern OSStatus CGSSetWorkspace(const CGSConnection cid, int workspace);
*/
extern CGSConnection _CGSDefaultConnection(void);


typedef enum {
  CGSNone = 0,                    // No transition effect.
  CGSFade,                        // Cross-fade.
  CGSZoom,                        // Zoom/fade towards us.
  CGSReveal,                      // Reveal new desktop under old.
  CGSSlide,                       // Slide old out and new in.
  CGSWarpFade,                    // Warp old and fade out revealing new.
  CGSSwap,                        // Swap desktops over graphically.
  CGSCube,                        // The well-known cube effect.
  CGSWarpSwitch,                  // Warp old, switch and un-warp.
	CGSFlip                         // Flip over
} CGSTransitionType;

typedef enum {
  CGSDown,                        // Old desktop moves down.
  CGSLeft,                        // Old desktop moves left.
  CGSRight,                       // Old desktop moves right.
  CGSInRight,                     //
  CGSDown2,                       //
  CGSBottomLeft,                  // Old desktop moves to bl, new comes from tr.
  CGSBottomRight,                 // Old desktop to br, New from tl.
  CGSDownTopRight,                // 
  CGSUp                           // Old desktop moves up.
} CGSTransitionOption;

typedef int CGSWindow;

typedef struct {
  uint32_t unknown1;
  CGSTransitionType type;
  CGSTransitionOption option;
  CGSWindow wid; /* Can be 0 for full-screen */
  float *backColour; /* Null for black otherwise pointer to 3 float array with RGB value */
} CGSTransitionSpec;

extern OSStatus CGSNewTransition(const CGSConnection cid, const CGSTransitionSpec* spec, int *pTransitionHandle);
extern OSStatus CGSInvokeTransition(const CGSConnection cid, int transitionHandle, float duration);
extern OSStatus CGSReleaseTransition(const CGSConnection cid, int transitionHandle);


@interface SpacesCBridge : NSObject

- (int) get_space_id;
- (void) set_space_by_index:(int)space;
- (int) get_front_window_pid;
- (int) is_full_screen;
- (int) total_spaces;
- (void) setSpaceWithTransition:(unsigned int)spaceIndex type:(CGSTransitionType)type direction:(CGSTransitionOption)direction;
- (void) setSpaceWithoutTransition:(unsigned int)spaceIndex;

@end
