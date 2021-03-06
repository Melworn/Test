-- Standard awesome library
local gears 	= require("gears")
local awful 	= require("awful")
awful.rules 	= require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox 	= require("wibox")
-- Theme handling library
local beautiful	= require("beautiful")
-- Notification library
local naughty 	= require("naughty")
local drop 		= require("scratchdrop")
local lain 		= require("lain")
local menubar 	= require("menubar")


-- Load Debian menu entries
require("debian.menu")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions

home			     = os.getenv("HOME")
confdir			   = "/usr/share/awesome"
--scriptdir		 = confdir .. "/scripts/"
themes			   = confdir .. "/themes"
active_theme	 = themes .. "/multicolor"
language		   = string.gsub(os.getenv("LANG"), ".utf8", "")

beautiful.init(active_theme .. "/theme.lua")

terminal 	      = "x-terminal-emulator"
editor 		      = os.getenv("EDITOR") or "vim"
editor_cmd      = terminal .. " -e " .. editor
browser		      = "firefox"
mail 		        = terminal .. " -e mutt "
--wifi		      = terminal .. " -e sudo wifi-menu "
musicpir	      = terminal .. " -g 130x34-320+16 -e ncmpcpp "
filemanager     = "nautilus"

-- Default modkey.
modkey = "Mod4"
altkey = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
tags = {
names = { "web", "term", "docs", "media", "files", "other" },
layout = { layouts[1], layouts[3], layouts[4], layouts[1], layouts[7], layouts[1] }
}
for s = 1, screen.count() do
-- Each screen has its own tag table.
tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ FreeDesktop Menu
mymainmenu1 =  require("menugen").build_menu()

awesomeconffile = "/etc/xdg/awesome/rc.lua"
myawesomemenu = {
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesomeconffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "Debian", debian.menu.Debian_menu.Debian },
                                    { "open terminal", terminal },
                                    { "All", mymainmenu1 },
                            theme = { height = 16, width = 180 }
                                  }
                        })
-- }}}

-- {{{ Wibox
markup 	= lain.util.markup

-- Textclock
clockicon = wibox.widget.imagebox(beautiful.widget_clock)
mytextclock = awful.widget.textclock(" %a %d %b %H:%M")
mytextclock = awful.widget.textclock(markup("#7788af", "%a %d %b ") .. markup("#343639", ">") .. markup("#de5e1e", " %H:%M "))


-- calendar
lain.widgets.calendar:attach(mytextclock, { font_size = 10 })

-- {{ widgets

-- Weather
weathericon = wibox.widget.imagebox(beautiful.widget_weather)
yawn = lain.widgets.yawn(123456, {
settings = function()
widget:set_markup(markup("#eca4c4", forecast:lower() .. " - " .. units .. "°C "))
end
})

-- / fs
fsicon = wibox.widget.imagebox(beautiful.widget_fs)
fswidget = lain.widgets.fs({
settings = function()
widget:set_markup(markup("#80d9d8", fs_now.used .. "% "))
end
})


-- CPU
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpuwidget = lain.widgets.cpu({
settings = function()
widget:set_markup(markup("#e33a6e", cpu_now.usage .. "% "))
end
})
-- Coretemp
tempicon = wibox.widget.imagebox(beautiful.widget_temp)
tempwidget = lain.widgets.temp({
settings = function()
widget:set_markup(markup("#f1af5f", coretemp_now .. "°C "))
end
})

--  Battery 
baticon = wibox.widget.imagebox(beautiful.widget_batt)
batwidget = lain.widgets.bat({
settings = function()
if bat_now.perc == "N/A" then
bat_now.perc = "AC" 
else
bat_now.perc = bat_now.perc .. "% "
end
widget:set_text(bat_now.perc)
end
})


-- ALSA volume
volicon = wibox.widget.imagebox(beautiful.widget_vol)
volumewidget = lain.widgets.alsa({
settings = function()
if volume_now.status == "off" then
volume_now.level = volume_now.level .. "M"
end
widget:set_markup(markup("#7493d2", volume_now.level .. "% "))
end
})
-- }}

-- Net
netdownicon = wibox.widget.imagebox(beautiful.widget_netdown)
--netdownicon.align = "middle"
netdowninfo = wibox.widget.textbox()
netupicon = wibox.widget.imagebox(beautiful.widget_netup)
--netupicon.align = "middle"
netupinfo = lain.widgets.net({
settings = function()
if iface ~= "network off" and
string.match(yawn.widget._layout.text, "N/A")
then
yawn.fetch_weather()
end
widget:set_markup(markup("#e54c62", net_now.sent .. " "))
netdowninfo:set_markup(markup("#87af5f", net_now.received .. " "))
end
})
-- MEM
memicon = wibox.widget.imagebox(beautiful.widget_mem)
memwidget = lain.widgets.mem({
settings = function()
widget:set_markup(markup("#e0da37", mem_now.used .. "M "))
end
})
-- MPD
mpdicon = wibox.widget.imagebox()
mpdwidget = lain.widgets.mpd({
settings = function()
mpd_notification_preset = {
text = string.format("%s [%s] - %s\n%s", mpd_now.artist,
mpd_now.album, mpd_now.date, mpd_now.title)
}
if mpd_now.state == "play" then
artist = mpd_now.artist .. " > "
title = mpd_now.title .. " "
mpdicon:set_image(beautiful.widget_note_on)
elseif mpd_now.state == "pause" then
artist = "mpd "
title = "paused "
else
artist = ""
title = ""
mpdicon:set_image(nil)
end
widget:set_markup(markup("#e54c62", artist) .. markup("#b2b2b2", title))
end
})
-- Spacer
spacer = wibox.widget.textbox(" ")


-- Keyboard map indicator and changer
kbdcfg = {}
kbdcfg.cmd = "setxkbmap"
kbdcfg.layout = { { "us", "", "US" }, 
                  { "ru", "", "RU" },
                  { "ge", "", "KA" }
                } 
kbdcfg.current = 1  -- us is our default layout
kbdcfg.widget = wibox.widget.textbox()
kbdcfg.widget:set_text(" " .. kbdcfg.layout[kbdcfg.current][3] .. " ")
kbdcfg.switch = function ()
  kbdcfg.current = kbdcfg.current % #(kbdcfg.layout) + 1
  local t = kbdcfg.layout[kbdcfg.current]
  kbdcfg.widget:set_text(" " .. t[3] .. " ")
  os.execute( kbdcfg.cmd .. " " .. t[1] .. " " .. t[2] )
end

 -- Mouse bindings
kbdcfg.widget:buttons(
 awful.util.table.join(awful.button({ }, 1, function () kbdcfg.switch() end))
)


-- }}}



-- Create a wibox for each screen and add it
mywibox = {}
mybottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({
                                                      theme = { width = 250 }
                                                  })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
          left_layout:add(mytaglist[s])
          left_layout:add(mypromptbox[s])
          left_layout:add(mpdicon)
          left_layout:add(mpdwidget)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
     --right_layout:add(mailicon)
     --right_layout:add(mailwidget)
    right_layout:add(netdownicon)
    right_layout:add(netdowninfo)
    right_layout:add(netupicon)
    right_layout:add(netupinfo)
    right_layout:add(volicon)
    right_layout:add(volumewidget)
    right_layout:add(memicon)
    right_layout:add(memwidget)
    right_layout:add(cpuicon)
    right_layout:add(cpuwidget)
    right_layout:add(fsicon)
    right_layout:add(fswidget)
    right_layout:add(weathericon)
    right_layout:add(yawn.widget)
    right_layout:add(tempicon)
    right_layout:add(tempwidget)
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(clockicon)
    right_layout:add(mytextclock)
    right_layout:add(kbdcfg.widget)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    --layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)

     -- Create the bottom wibox
mybottomwibox[s] = awful.wibox({ position = "bottom", screen = s, border_width = 0, height = 20 })
--mybottomwibox[s].visible = false
-- Widgets that are aligned to the bottom left
bottom_left_layout = wibox.layout.fixed.horizontal()
-- Widgets that are aligned to the bottom right
bottom_right_layout = wibox.layout.fixed.horizontal()
bottom_right_layout:add(mylayoutbox[s])
-- Now bring it all together (with the tasklist in the middle)
bottom_layout = wibox.layout.align.horizontal()
bottom_layout:set_left(bottom_left_layout)
bottom_layout:set_middle(mytasklist[s])
bottom_layout:set_right(bottom_right_layout)
mybottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ altkey            }, "p", function() os.execute("screenshot")               end),

    -- Tag browsing
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    -- Non-empty tag browsing
    awful.key({ altkey            }, "Left",   function () lain.util.tag_view_nonempty(-1)   end),
    awful.key({ altkey            }, "Right",  function () lain.util.tag_view_nonempty(1)    end),

    -- Default client focus
    awful.key({ altkey            }, "k",      function () awful.client.focus.byidx( 1)
          if client.focus  
            then client.focus:raise()    
          end              
    end),

    awful.key({ altkey            }, "j",      function () awful.client.focus.byidx(-1)
          if client.focus 
            then client.focus:raise() 
          end
    end),

    -- By direction client focus
    awful.key({ modkey,           }, "j", function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    awful.key({ modkey,           }, "w", function () mymainmenu:show({ keygrabber = true }) end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j",         function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k",         function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j",         function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k",         function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
    awful.key({ modkey,           }, "o", function () awful.util.spawn(filemanager) end),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Alt + Right Shift switches the current keyboard layout
    --awful.key({ altkey,  "Shift"  }, "r", function () kbdcfg.switch()  end),



    -- Widgets popups
    awful.key({ altkey, },        "c", 
      function () 
        lain.widgets.calendar:show(7) 
      end),
    
    awful.key({ altkey, },        "h", 
      function () 
        fswidget.show(7) 
      end),
    
    awful.key({ altkey, },        "w", 
      function () 
        yawn.show(7) 
      end),
   
    -- ALSA volume control
    awful.key({ altkey },         "Up",
      function ()
        awful.util.spawn("amixer -q set Master 1%+")
        volumewidget.update()
      end),
    
    awful.key({ altkey  },        "Down",
      function ()
        awful.util.spawn("amixer -q set Master 1%-")
        volumewidget.update()
      end),

    awful.key({ altkey },           "m",
      function ()
        awful.util.spawn("amixer -q set Master playback toggle")
        volumewidget.update()
      end),

    awful.key({ altkey, "Control" }, "m",
      function ()
        awful.util.spawn("amixer -q set Master playback 100%")
        volumewidget.update()
      end),
    
    -- MPD control
    awful.key({ altkey, "Control" }, "Up",
      function ()
        awful.util.spawn_with_shell("mpc toggle || ncmpc toggle || pms toggle")
        mpdwidget.update()
      end),
    
    awful.key({ altkey, "Control" }, "Down",
      function ()
        awful.util.spawn_with_shell("mpc stop || ncmpc stop || pms stop")
        mpdwidget.update()
      end),

    awful.key({ altkey, "Control" }, "Left",
      function ()
        awful.util.spawn_with_shell("mpc prev || ncmpc prev || pms prev")
        mpdwidget.update()
      end),
    
    awful.key({ altkey, "Control" }, "Right",
      function ()
        awful.util.spawn_with_shell("mpc next || ncmpc next || pms next")
        mpdwidget.update()
      end),



    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run({ prompt = "Run Lua code: " },
                  mypromptbox[mouse.screen].widget,
                  awful.util.eval, nil,
                  awful.util.getdir("cache") .. "/history_eval")
              end),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        local tag = awful.tag.gettags(screen)[i]
                        if tag then
                           awful.tag.viewonly(tag)
                        end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      local tag = awful.tag.gettags(screen)[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.movetotag(tag)
                          end
                     end
                  end),
        -- Toggle tag.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = awful.tag.gettags(client.focus.screen)[i]
                          if tag then
                              awful.client.toggletag(tag)
                          end
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     size_hints_honor = false } },
    { rule = { class = "x-terminal-emulator" },
      properties = { opacity = 0.99 } },
    { rule = { class = "firefox" },
      properties = { tag = tags[1][1] } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- buttons for the titlebar
        local buttons = awful.util.table.join(
                awful.button({ }, 1, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.move(c)
                end),
                awful.button({ }, 3, function()
                    client.focus = c
                    c:raise()
                    awful.mouse.client.resize(c)
                end)
                )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))
        left_layout:buttons(buttons)

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))
        

        -- The title goes in the middle
        local middle_layout = wibox.layout.flex.horizontal()
        local title = awful.titlebar.widget.titlewidget(c)
        title:set_align("center")
        middle_layout:add(title)
        middle_layout:buttons(buttons)

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(middle_layout)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
