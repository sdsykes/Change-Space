//
//  main.m
//  Change Space
//
//  Created by Stephen Sykes on 29/8/11.
//  Copyright (c) 2011 Switchstep. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import <MacRuby/MacRuby.h>

int main(int argc, char *argv[])
{
  return macruby_main("rb_main.rb", argc, argv);
}
