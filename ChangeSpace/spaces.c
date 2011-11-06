//
//  spaces.c
//  Change Space
//
//  Created by Stephen Sykes on 30/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//
//  Derived from https://gist.github.com/1129406

#include <unistd.h>
#include <CoreServices/CoreServices.h>
#include <ApplicationServices/ApplicationServices.h>

#include "spaces.h"

int get_space_id(void)
{
  int space;
  CFArrayRef windows = CGWindowListCopyWindowInfo( kCGWindowListOptionOnScreenOnly, kCGNullWindowID );
  CFIndex i, n;
  
  for (i = 0, n = CFArrayGetCount(windows); i < n; i++) {
    CFDictionaryRef windict = CFArrayGetValueAtIndex(windows, i);
    CFNumberRef spacenum = CFDictionaryGetValue(windict, kCGWindowWorkspace);
    if (spacenum) {
      CFNumberGetValue(spacenum,  kCFNumberIntType, &space);
      return space;
    }
  }
  return -1;
}

int total_spaces(void)
{
  int rows, cols;
  CoreDockGetWorkspacesCount(&rows, &cols);
  
  return cols;  
}

void set_space_by_index(int space)
{
  
  CFNotificationCenterRef nc = CFNotificationCenterGetDistributedCenter();
  CFStringRef numstr = CFStringCreateWithFormat(NULL, nil, CFSTR("%d"), space);
  CFNotificationCenterPostNotification(nc, CFSTR("com.apple.switchSpaces"), numstr, NULL, TRUE);
}

int get_front_window_pid(void)
{
  int pid;
  CFArrayRef windows = CGWindowListCopyWindowInfo(kCGWindowListOptionOnScreenOnly, kCGNullWindowID);
  CFIndex i, n;
  
  for (i = 0, n = CFArrayGetCount(windows); i < n; i++) {
    CFDictionaryRef windict = CFArrayGetValueAtIndex(windows, i);
    CFNumberRef layernum = CFDictionaryGetValue(windict, kCGWindowLayer);
    CFNumberRef pidnum = CFDictionaryGetValue(windict, kCGWindowOwnerPID);
    if (layernum && pidnum) {
      int layer;
      CFNumberGetValue(layernum,  kCFNumberIntType, &layer);
      if (layer == 0) {
        CFNumberGetValue(pidnum,  kCFNumberIntType, &pid);
        return pid;
      }
    }
  }
  return -1;
}

int is_full_screen(void)
{
  CFArrayRef windows = CGWindowListCopyWindowInfo( kCGWindowListOptionOnScreenOnly, kCGNullWindowID );
  CFIndex i, n;
  
  for (i = 0, n = CFArrayGetCount(windows); i < n; i++) {
    CFDictionaryRef windict = CFArrayGetValueAtIndex(windows, i);
    CFNumberRef layernum = CFDictionaryGetValue(windict, kCGWindowLayer);
    if (layernum) {
      int layer;
      CFNumberGetValue(layernum,  kCFNumberIntType, &layer);
      if (layer == -1) return 1;
    }
  }
  return 0;
}
