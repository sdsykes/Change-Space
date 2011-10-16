#
#  AppDelegate.rb
#  Change Space
#
#  Created by Stephen Sykes on 29/8/11.
#  Copyright 2011 Stephen Sykes. All rights reserved.
#

# Permission to use, copy, modify, and/or distribute this software for any purpose with or without fee is 
# hereby granted, provided that the above copyright notice and this permission notice appear in 
# all copies.

# The software is  provided "as is", without warranty of any kind, including all implied warranties of
# merchantability and fitness. In no event shall the author(s) or copyright holder(s) be liable for any
# claim, damages, or other liability, whether in an action of contract, tort, or otherwise, arising from,
# out of, or in connection with the software or the use or other dealings in the software.

framework 'Foundation'
framework 'ScriptingBridge'

class AppDelegate
  attr_accessor :window, :preferences, :suupdater
  attr_accessor :gridColumns, :gridRows, :circulateVertical, :desktopCount
  
  def applicationDidFinishLaunching(a_notification)
    $res_path = NSBundle.mainBundle.resourcePath.fileSystemRepresentation + '/'
    arr = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, true)
    $cache_path = arr[0] + '/'
    
    $c_bridge = SpacesCBridge.new

    default_file = $res_path + "defaults.plist"
    default_settings = NSDictionary.dictionaryWithContentsOfFile(default_file)
    NSUserDefaults.standardUserDefaults.registerDefaults(default_settings)

    defaults = NSUserDefaultsController.sharedUserDefaultsController
    before = defaults.values.valueForKey("hasLaunchedBefore")
    first_time = !before
    defaults.values.setValue(true, forKey: "hasLaunchedBefore")
    
    initStatusBar(setupMenu)
    
    kVK_LeftArrow = 0x7B
    kVK_RightArrow = 0x7C
    kVK_DownArrow = 0x7D
    kVK_UpArrow = 0x7E

    ddh = DDHotKeyCenter.new
    flags =  NSControlKeyMask | NSShiftKeyMask
    ddh.registerHotKeyWithKeyCode(kVK_LeftArrow, modifierFlags: flags, target: self, action: "goLeftKey:", object: nil)
    ddh.registerHotKeyWithKeyCode(kVK_RightArrow, modifierFlags: flags, target: self, action: "goRightKey:", object: nil)
    ddh.registerHotKeyWithKeyCode(kVK_UpArrow, modifierFlags: flags, target: self, action: "goUpKey:", object: nil)
    ddh.registerHotKeyWithKeyCode(kVK_DownArrow, modifierFlags: flags, target: self, action: "goDownKey:", object: nil)
    
    if first_time
      activate_preferences(self)
    end
  end
  
  def update_layout
    @width, @height = gridColumns.selectedItem.title.to_i, gridRows.selectedItem.title.to_i
    @total_spaces = @width * @height
    desktopCount.setStringValue @total_spaces.to_s
  end
  
  def update_grid(sender)
    update_layout
  end
  
  def setupMenu
    menu = NSMenu.new
    menu.initWithTitle 'Spaces'

    menu.addItem(menu_item("Left"))
    menu.addItem(menu_item("Right"))
    menu.addItem(menu_item("Up"))
    menu.addItem(menu_item("Down"))
    menu.addItem(NSMenuItem.separatorItem)
    menu.addItem(update_menu_item)
    menu.addItem(NSMenuItem.separatorItem)
    menu.addItem(preferences_menu_item)
    menu.addItem(NSMenuItem.separatorItem)
    menu.addItem(quit_menu_item)
    menu
  end

  def menu_item(direction)
    mi = NSMenuItem.new
    mi.title = "Go #{direction}"
    mi.action = "go#{direction}:"
    mi.target = self
    # key bindings here did not work well
    # mi.setKeyEquivalentModifierMask(NSShiftKeyMask | NSCommandKeyMask);
    # arrow = Pointer.new("S")
    # directions = {"Left" => NSLeftArrowFunctionKey,
    #  "Right" => NSRightArrowFunctionKey,
    #  "Up" => NSUpArrowFunctionKey,
    #  "Down" => NSDownArrowFunctionKey}
    # arrow[0] = directions[direction]
    # s = NSString.send(:"stringWithCharacters:length:", arrow, 1)
    # mi.setKeyEquivalent(s)
    mi
  end
  
  def update_menu_item
    mi = NSMenuItem.new
    mi.title = "Check for updates"
    mi.action = "checkForUpdates:"
    mi.target = suupdater
    mi
  end

  def activate_preferences(sender)
    defaults = NSUserDefaultsController.sharedUserDefaultsController
    gridRows.selectItemAtIndex(defaults.values.valueForKey("gridRows"))
    gridColumns.selectItemAtIndex(defaults.values.valueForKey("gridColumns"))
    
    update_layout
    
    NSApp.activateIgnoringOtherApps(true);
    preferences.makeKeyAndOrderFront(self)
  end
  
  def preferences_menu_item
    mi = NSMenuItem.new
    mi.title = "Preferences"
    mi.action = "activate_preferences:"
    mi.target = self
    mi
  end
  
  def quit_menu_item
    mi = NSMenuItem.new
    mi.title = 'Quit'
    mi.action = 'quit:'
    mi.target = self
    mi
  end
  
  def initStatusBar(menu)
    status_bar = NSStatusBar.systemStatusBar
    @status_item = status_bar.statusItemWithLength(NSVariableStatusItemLength)
    @status_item.setMenu menu 

    @blank_img = NSImage.new.initWithContentsOfFile($res_path + 'menu_icon.png')
    @status_item.setImage(@blank_img)
    #    img = NSImage.new.initWithContentsOfFile($res_path + 'menu_icon_alt.png')
    #    @status_item.setAlternateImage(img)
    @menu_images = []
    1.upto(9) do |n|
      @menu_images[n] = NSImage.new.initWithContentsOfFile($res_path + "menu_icon_#{n}.png")
    end
    @status_item.setHighlightMode(true)
  end
  
  def goLeft(sender)
    go("left")
  end
  
  def goLeftKey(sender, obj)
    go("left")
  end
  
  def goRight(sender)
    go("right")
  end

  def goRightKey(sender, obj)
    go("right")
  end
  
  def goUp(sender)
    go("up")
  end
  
  def goUpKey(sender, obj)
    go("up")
  end

  def goDown(sender)
    go("down")
  end

  def goDownKey(sender, obj)
    go("down")
  end

  def go(direction)
    update_layout
    
    current = current_space
    space_number = current
    # puts "Current space is #{space_number}"
    
    return unless space_number
    
    case direction
    when "up"
      space_number -= @width
      space_number = current if space_number < 1
    when "down"
      space_number += @width
      space_number = current if space_number > (@total_spaces)
    when "left"
      space_number -= 1
      space_number += (@total_spaces) if space_number < 1
    when "right"
      space_number += 1
      space_number -= (@total_spaces) if space_number > (@total_spaces)
    end

    if space_number != current
      # puts "Moving to #{space_number}"
      move_to(space_number)
    end
  end
  
  def current_space
    current_space = $c_bridge.get_space_id
    # puts "Current space id is #{current_space}"
    space_map_file = "#{$cache_path}/space_map"
    if File.exist? space_map_file
      space_map = Marshal.load(File.read(space_map_file))
      else
      space_map = {}
    end
    
    space_number = space_map[current_space]
    
    if !space_number
      space_map = remap_desktops
      File.open(space_map_file, "w") {|f| f.write(Marshal.dump(space_map))}
      space_number = space_map[current_space]
    end
    
    space_number
  end
  
  def remap_desktops
    map = {1=>1}
    2.upto(@total_spaces) do |n|
      move_to(n)
      sleep 1
      space_id = $c_bridge.get_space_id
      map[space_id] = n
      puts "Mapping id #{space_id} to space #{n}"
    end
    map
  end

  def four_char_code(s)
    (s[0].ord << 24) + (s[1].ord << 16) + (s[2].ord << 8) + s[3].ord
  end
  
  def move_to(space_number)
    if space_number < 2
      system = SBApplication.applicationWithBundleIdentifier("com.apple.SystemEvents")
      system.send(:"keystroke:using:", space_number.to_s, four_char_code('Kctl'))
    else
      space_index = space_number - 1
      $c_bridge.set_space_by_index(space_index)
    end
    
    @status_item.setImage(@menu_images[space_number])
    self.send(:"performSelector:withObject:afterDelay:", :reset_menu_image, nil, 2.5);
  end
  
  def reset_menu_image
    @status_item.setImage(@blank_img)
  end
  
  def quit(sender)
    app = NSApplication.sharedApplication
    app.terminate(self)
  end
end
