--
-- Awesome-wm configuration
-- For awesome 3.5.x
-- Adopted from default config of awesome 3.4
--

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
-- Extra widgets
local vicious = require("vicious")

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
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = os.getenv("TERM_EMU") or "urxvt"
browser = os.getenv("BROWSER") or "chromium"
editor = os.getenv("EDITOR") or "vim"
lock_command = os.getenv("LOCK_COMMAND") or "xlock"
network_interface = os.getenv("NETW_INTERFACE") or "wlan0"
battery = os.getenv("BATTERY") or "BAT0"

backlight_up = "xbacklight -inc 10"
backlight_down = "xbacklight -dec 10"
kbd_backlight_up = "kbdlight up"
kbd_backlight_down = "kbdlight down"
suspend_command = "sudo pm-suspend"

-- Percentage at which to give warnings for low battery
battery_low_perc = 5


-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts =
{
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    --awful.layout.suit.tile.bottom,
    --awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    --awful.layout.suit.fair.horizontal,
    --awful.layout.suit.spiral,
    --awful.layout.suit.spiral.dwindle,
    --awful.layout.suit.max,
    --awful.layout.suit.max.fullscreen,
    --awful.layout.suit.magnifier
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
-- Define a tag table which hold all screen tags.
tags = {
    names = {"irc", "mail", "www", 4, 5, 6, 7, 8, 9},
    layouts = {layouts[4], layouts[4], layouts[2], layouts[4], layouts[4],
               layouts[4], layouts[4], layouts[4], layouts[4]}
}


for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layouts)
end
-- }}}

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Seperator for space between widgets
sep = wibox.widget.textbox(" ")

local gradient_col = { type = "linear",
                       from = { 0, 10 },
                       to   = { 0, 0 },
                       stops = { { 0, "#AECF96" }, { 1, "#FF5656" } } }

-- Memory usage widget
memwidget = awful.widget.progressbar()
memwidget:set_width(8)
memwidget:set_height(20)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color(gradient_col)
memtooltip = awful.tooltip({ objects = { memwidget }, })
vicious.register(memwidget,
        vicious.widgets.mem,
        function (widget, args)
            memtooltip:set_text(args[1].."% (".. args[2].."MB / "..args[3].."MB)")
            return args[1]
        end,
        9 -- seconds
        )

-- CPU graph
cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color(gradient_col)
cputooltip = awful.tooltip({ objects = { cpuwidget }, })
vicious.register(cpuwidget,
         vicious.widgets.cpu,
         function (widget, args)
             cputooltip:set_text("CPU: "..args[1].."%")
             return args[1]
         end)

-- Network graph
networkwidget = awful.widget.graph()
networkwidget:set_width(50)
networkwidget:set_background_color("#494B4F")
networkwidget:set_color(gradient_col)
networktooltip = awful.tooltip({ objects = { networkwidget }, })
vicious.register(networkwidget,
        vicious.widgets.net,
        function (widget, args)
            local dk = args["{"..network_interface.." down_kb}"]
            local uk = args["{"..network_interface.." up_kb}"]
            local dm = args["{"..network_interface.." down_mb}"]
            local um = args["{"..network_interface.." up_mb}"]
            if dk == nil or uk == nil or dm == nil or um == nil then
                networktooltip:set_text("Network: interface not found")
                return 100
            end
            networktooltip:set_text("Network: "..dk.."KB/s "..uk.."KB/s")
            return 100 * (dm + um)
        end)

-- Battery state
batterywidget = wibox.widget.textbox()
batterytooltip = awful.tooltip({ objects = { batterywidget }, })

if battery ~= nil and battery ~= "" then
    vicious.register(batterywidget,
            vicious.widgets.bat,
            function (widget, args)
                local state = args[1]
                local percentage = args[2]
                local time = args[3]

                local tt = ""
                if state == "+" then
                    tt = "Charging, time until fully charged: "
                elseif state == "-" then
                    tt = "Discharging, time remaining: "
                else
                    tt = "Fully charged, time: "
                end
                tt = tt .. time

                if percentage < battery_low_perc and state == "-" then
                    naughty.notify(
                        { title = "Battery low: " .. percentage .. "%",
                          text = time .. " hours remaining",
                          timeout = 10,
                          width = 300,
                          icon = "/home/koen/icon_battery.png",
                          bg = beautiful.bg_urgent,
                          fg = beautiful.fg_urgent,
                          border_color = beautiful.border_urgent})
                end


                batterytooltip:set_text(tt)
                return "[" .. state .. " " .. percentage .. "%]"
            end,
            10, -- seconds
            battery)
end

-- Volume
volumecfg = {}
volumecfg.cardid  = 0
volumecfg.channel = "Master"
volumecfg.widget = wibox.widget.textbox()

volumecfg_t = awful.tooltip({ objects = { volumecfg.widget },})
volumecfg_t:set_text("Volume")

volumecfg.mixercommand = function (command)
    local fd = io.popen("amixer -c " .. volumecfg.cardid .. command)
    local status = fd:read("*all")
    fd:close()

    local volume = string.match(status, "(%d?%d?%d)%%")
    if not volume then
        volume = "EE"
    else
        volume = string.format("% 3d", volume)
        status = string.match(status, "%[(o[^%]]*)%]")
        if string.find(status, "on", 1, true) then
            volume = volume .. "%"
        else
            volume = volume .. "M"
        end
    end
    volumecfg.widget:set_text(volume)
end
volumecfg.update = function ()
    volumecfg.mixercommand(" sget " .. volumecfg.channel)
end
volumecfg.up = function ()
    volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%+")
end
volumecfg.down = function ()
    volumecfg.mixercommand(" sset " .. volumecfg.channel .. " 1%-")
end
volumecfg.toggle = function ()
    volumecfg.mixercommand(" sset " .. volumecfg.channel .. " toggle")
end
volumecfg.widget:buttons({
    button({ }, 4, function () volumecfg.up() end),
    button({ }, 5, function () volumecfg.down() end),
    button({ }, 1, function () volumecfg.toggle() end)
})
volumecfg.update()

-- Create a textclock widget
mytextclock = awful.widget.textclock()

-- Create a wibox for each screen and add it
mywibox = {}
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
                                                  instance = awful.menu.clients({ width=250 })
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

    -- Widgets on the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])

    -- Widgets on right (left to right)
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(sep)
    if s == 1 then
        right_layout:add(wibox.widget.systray())
        right_layout:add(sep)
    end
    right_layout:add(volumecfg.widget)
    right_layout:add(sep)
    right_layout:add(batterywidget)
    right_layout:add(sep)
    right_layout:add(cpuwidget)
    right_layout:add(sep)
    right_layout:add(memwidget)
    right_layout:add(sep)
    right_layout:add(networkwidget)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])

    -- Bring it all together with tasklist in middle
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
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
    awful.key({ modkey,           }, "space", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "c",      function () awful.util.spawn(browser)  end),
    awful.key({ modkey,           }, "v", function () awful.util.spawn(lock_command) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "z",     function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "z",     function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

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
    awful.key({ modkey }, "p", function() menubar.show() end),

    -- Sound control
    awful.key({ }, "XF86AudioRaiseVolume", function () volumecfg.up()     end),
    awful.key({ }, "XF86AudioLowerVolume", function () volumecfg.down()   end),
    awful.key({ }, "XF86AudioMute",        function () volumecfg.toggle() end),

    -- Backlight control
    awful.key({ }, "XF86MonBrightnessUp",   function () awful.util.spawn(backlight_up)       end),
    awful.key({ }, "XF86MonBrightnessDown", function () awful.util.spawn(backlight_down)     end),
    awful.key({ }, "XF86KbdBrightnessUp",   function () awful.util.spawn(kbd_backlight_up)   end),
    awful.key({ }, "XF86KbdBrightnessDown", function () awful.util.spawn(kbd_backlight_down) end),

    awful.key({ }, "XF86AudioPlay", function () awful.util.spawn(suspend_command) end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey,           }, "q",      function (c) c:kill()                         end),
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

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
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
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },

    { rule = { class = "Chromium" },
        properties = { floating = false } },
    --  properties = { tag = tags[1][3] } },
    { rule = { class = "Pidgin" },
      properties = { tag = tags[1][2] } },

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
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
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
                ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
