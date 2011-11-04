//
//  spaces.h
//  Change Space
//
//  Created by Stephen Sykes on 30/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#ifndef Change_Space_spaces_h
#define Change_Space_spaces_h

int get_space_id(void);
void set_space_by_index(int space);
int get_front_window_pid(void);
int is_full_screen(void);
int total_spaces(void);


void CoreDockGetWorkspacesCount(int *rows, int *cols);

#endif
