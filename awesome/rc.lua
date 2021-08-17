-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

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
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_themes_dir() .. "default/theme.lua")
my_border_width = 7
my_border_color_select = "#CB1B20"
my_border_color_norm = "#595959"


-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
terminal_class = "Alacritty"
editor = os.getenv("EDITOR") or "vim"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    -- awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    -- awful.layout.suit.tile.top,
    -- awful.layout.suit.fair,
    -- awful.layout.suit.fair.horizontal,
    -- awful.layout.suit.spiral,
    -- awful.layout.suit.spiral.dwindle,
    -- awful.layout.suit.max,
    -- awful.layout.suit.max.fullscreen,
    -- awful.layout.suit.magnifier,
    -- awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function(c) c:kill() end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }, s, awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            wibox.widget.systray(),
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

function client_center(c)
   local x = c.x + (c.width / 2)
   local y = c.y + (c.height / 2)
   return { x = x, y = y }
end

-- All visible clients sorted from left to right and from top to bottom
function my_visible_clients()
   local allClients = { }
   for s in screen do
      for _, c in ipairs(s.clients) do
         if c:isvisible() then
            table.insert(allClients, {client = c, center = client_center(c)})
         end
      end
   end
   table.sort(allClients,
   function(a, b)
      if a.center.x == b.center.x then
         return a.center.y < b.center.y
      else
         return a.center.x < b.center.x
      end
   end)
   local res = { }
   for _, c in ipairs(allClients) do
      table.insert(res, c.client)
   end
   return res
end

function my_center_mouse_at(cl)
   local c = cl or client.focus
   if c then
      mouse.coords(client_center(c), true)
   end
end


function toset(a)
   res = {}
   for _, a in ipairs(a) do
      res[a] = true
   end
   return res
end

-- Returns true if two lists intersect
function intersects(a, b)
   local bset = toset(b)
   for _, x in ipairs(a) do
      if bset[x] then
         return true
      end
   end
   return false
end

-- Returns difference between two lists
function difference(b, a)
   local aset = toset(a)
   local res = {}
   for _, x in ipairs(b) do
      if not aset[x] then
         table.insert(res, x)
      end
   end
   return res
end

function isSubset(a, b)
   local rest = difference(a, b)
   if not next(rest) then
      -- rest is empty
      return true
   else
      -- non-empty rest means a is not subset of b
      return false
   end
end

function tagsNames(tlist)
   local res = {}
   for _, tag in ipairs(tlist) do
      table.insert(res, tag.name)
   end
   return table.concat(res, ",")
end

function smart_hide (s, c)
   local otherTags = difference(c:tags(), s.selected_tags)
   -- c:tags is subset of s.selected_tags
   naughty.notify({text = "otherTags = " .. tagsNames(otherTags) })
   if not next(otherTags) then
      naughty.notify({text = "minimize"})
      c.minimized = true
   else
      naughty.notify({text = "set other tags"})
      c:tags(otherTags)
   end
   awful.layout.arrange(s)
end

function smart_toggle (s, cpred)
   local vis_clients = s.clients
   local hid_clients = s.hidden_clients

   local fclient = client.focus
   if fclient and cpred(fclient) then
      naughty.notify({text = "fired focus"})
      -- If desired client is active then smart hide it
      smart_hide(s, fclient)
      return fclient
   end

   -- Iterate over all visible clients and try to smart hide one
   for _, c in ipairs(vis_clients) do -- For all visible clients
      if cpred(c) then
         smart_hide(s, c)
         return c
      end
   end

   -- Iterate over all hidden clients and placed on active tags. This means
   -- those clients may be only minimized
   for _, c in ipairs(hid_clients) do -- For all hidden clients
      if cpred(c) and isSubset(c:tags(), s.selected_tags) then
         c.minimized = false
         awful.layout.arrange(s)
         client.focus = c
         my_center_mouse_at(c)
         return c
      end
   end

   -- Iterate over all tags above currently active and assign first client to
   -- current tag to show it
   local thistag = s.selected_tag
   local gottag = false
   for _, t in ipairs(s.tags) do
      if not gottag and (t == thistag) then
         gottag = true
      elseif gottag then
         for _, c in ipairs(t:clients()) do
            if cpred(c) and c.minimized == false then
               toggle_client_tag(s, c)
               return c
            end
         end
      end
   end

   return nil
end

function toggle_client_tag(s, c)
   local t = s.selected_tag
   c:toggle_tag(t)
   awful.layout.arrange(s)
   if c:isvisible() then
      client.focus = c
      my_center_mouse_at(c)
   end
end

-- {{{ Key bindings
globalkeys = gears.table.join(
    awful.key({ modkey,           }, "s",      hotkeys_popup.show_help,
       {description="show help", group="awesome"}),

    awful.key({ modkey,           }, "n", function ()
          awful.client.focus.byidx( 1)
          my_center_mouse_at()
    end, {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "p", function ()
          awful.client.focus.byidx(-1)
          my_center_mouse_at()
    end, {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey, "Control"   }, "n", function ()
          awful.client.swap.byidx(  1)
          my_center_mouse_at()
    end, {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Control"   }, "p", function ()
          awful.client.swap.byidx( -1)
          my_center_mouse_at()
    end, {description = "swap with previous client by index", group = "client"}),

    awful.key({ modkey,           }, "Right", function ()
          awful.client.focus.global_bydirection("right")
          my_center_mouse_at()
    end, {description = "focus right client", group = "client"}),
    awful.key({ modkey,           }, "Left", function ()
          awful.client.focus.global_bydirection("left")
          my_center_mouse_at()
    end, {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "Up", function ()
          awful.client.focus.global_bydirection("up")
          my_center_mouse_at()
    end, {description = "focus upper client", group = "screen"}),
    awful.key({ modkey,           }, "Down", function ()
          awful.client.focus.global_bydirection("down")
          my_center_mouse_at()
    end, {description = "focus lower client", group = "screen"}),

    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
       {description = "jump to urgent client", group = "client"}),

    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey, "Shift" }, "t", function ()
          awful.spawn(terminal)
    end, {description = "spawn a terminal", group = "launcher"}),

    awful.key({ modkey }, "t", function ()
          local this_screen = awful.screen.focused()
          smart_toggle(this_screen,
             function (c)
                return c.class == terminal_class
             end
          )
    end, {description = "Toggle terminal", group = "client"}),

    -- Toggle telegram
    awful.key({ modkey }, "b", function ()
          for s in screen do
             c = smart_toggle(s, function (c)
                                 return c.class == "TelegramDesktop"
             end)
             if c then
                break
             end
          end
    end ,{description = "Toggle telegram", group = "client"}),

    -- Toggle Firefox
    awful.key({ modkey }, "w", function ()
          for s in screen do
             if s.index == 2 then
                smart_toggle(s, function (c)
                                return c.class == "Firefox"
                end)
                break
             end
          end
    end, {description = "Toggle Firefox", group = "client"}),

    -- Toggle emacs
    awful.key({ modkey }, "d", function ()
          local this_screen = awful.screen.focused()
          smart_toggle(this_screen,
             function (c)
                return c.class == "Emacs"
             end
          )
    end, {description = "Toggle Emacs", group = "client"}),

    awful.key({ modkey,           }, "x", function ()
          awful.spawn("keepassxc")
    end, {description = "open keepassxc", group = "launcher"}),

    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift", "Control" }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "j",     function () awful.tag.incmwfact( 0.05)          end,
       {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "y",     function () awful.tag.incmwfact(-0.05)          end,
       {description = "decrease master width factor", group = "layout"}),

    awful.key({ modkey, "Control"   }, "j",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control"   }, "y",     function () awful.tag.incnmaster(-1, nil, true) end,
       {description = "decrease the number of master clients", group = "layout"}),

    awful.key({ modkey, "Mod1" }, "j",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Mod1" }, "y",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),

    awful.key({ modkey,           }, "space",
       function ()
          awful.layout.inc( 1)
          my_center_mouse_at()
       end,
       {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space",
       function ()
          awful.layout.inc(-1)
          my_center_mouse_at()
       end,
       {description = "select previous", group = "layout"}),

    -- Unminimize all client in current screen
    awful.key({ modkey, "Shift" }, "z",
       function ()
          local s = awful.screen.focused()
          local ts = {} -- Selected tags table
          for _, t in ipairs(s.selected_tags) do
             ts[t.name] = t
          end
          for _, c in ipairs(s.all_clients) do
             for _, t in ipairs(c:tags()) do
                if ts[t.name] then
                   c.minimized = false
                   break
                end
             end
          end
       end,
       {description = "restore all minimized", group = "client"}),

    -- Tile all visible clients on current screen
    awful.key({ modkey, "Shift" }, "m",
       function ()
          local s = awful.screen.focused()
          local ts = {} -- Selected tags table
          for _, t in ipairs(s.selected_tags) do
             ts[t.name] = t
          end
          for _, c in ipairs(s.all_clients) do
             for _, t in ipairs(c:tags()) do
                if ts[t.name] then
                   c.maximized = false
                   c.floating = false
                   break
                end
             end
          end
       end,
       {description = "tile all clients", group = "client"}),


    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    -- awful.key({ modkey }, "x",
    --           function ()
    --               awful.prompt.run {
    --                 prompt       = "Run Lua code: ",
    --                 textbox      = awful.screen.focused().mypromptbox.widget,
    --                 exe_callback = awful.util.eval,
    --                 history_path = awful.util.get_cache_dir() .. "/history_eval"
    --               }
    --           end,
    --           {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "o", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)



function my_screen_is_big(s)
   if s.geometry.width > 3800 then
      return true
   else
      return false
   end
end


-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 0, 9 do
   if i == 0 then
      i = 10 -- cause 0 is the last one and we count from 1 in lua
   end
   globalkeys = gears.table.join(globalkeys,
        -- Focus at client at pos
        awful.key({ modkey, }, "#" .. i + 9,
                  function ()
                     local vc = my_visible_clients()
                     local c = vc[i] or vc[#vc]
                     if c then
                        client.focus = c
                        my_center_mouse_at(c)
                     end
                  end,
                  {description = "focus at client #" .. i, group = "client"}),

        -- View tag only.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                           my_center_mouse_at()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),

        -- View tag on all screens
        awful.key({ modkey, "Mod1" }, "#" .. i + 9,
           function ()
              for s in screen do
                 if my_screen_is_big(s) then
                    local tag = s.tags[i]
                    if tag then
                       tag:view_only()
                    end
                 end
              end
           end,
           {description = "all screens view tag #"..i, group = "tag"}),

        -- Toggle tag display.
        awful.key({ modkey, "Mod1", "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                         if tag.selected then
                            for _, c in ipairs(tag:clients()) do
                               if c.minimized == false then
                                  client.focus = c
                                  my_center_mouse_at(c)
                                  break
                               end
                            end
                         end
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),

        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),

        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
           function ()
              local c = client.focus
              if c then
                 local s = c.screen
                 local tag = s.tags[i]
                 if tag then
                    client.focus:toggle_tag(tag)
                    awful.layout.arrange(s)
                 end
              end
           end,
           {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

my_monitor_keys = { "l", ",", "k" }
for s in screen do
   local key = my_monitor_keys[s.index]
   if key then
      globalkeys = gears.table.join(globalkeys,
          awful.key({ modkey }, key,
             function()
                awful.screen.focus(s)
                if s.clients[1] then
                   my_center_mouse_at()
                end
             end
          )
      )
   end
end

-- Set keys
root.keys(globalkeys)
-- }}}

clientkeys = gears.table.join(
    awful.key({ modkey,           }, "F12",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey,           }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey,           }, "f",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey,           }, "Return", function (c) c:swap(awful.client.getmaster()) end,
       {description = "move to master", group = "client"}),


    awful.key({ modkey, "Shift" }, "Right",  function (c) c:move_to_screen(c.screen.index+1) end,
       {description = "move to next screen", group = "client"}),
    awful.key({ modkey, "Shift" }, "Left",  function (c) c:move_to_screen(c.screen.index-1) end,
       {description = "move to prev screen", group = "client"}),

    awful.key({ modkey,           }, "z",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),

    awful.key({ modkey }, "i", my_center_mouse_at
       , {description = "centor cursor at", group = "client"})

)

clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = my_border_width,
                     border_color = my_border_color_norm,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wpa_gui",
          "veromix",
          "xtightvncviewer",
          "mpv" },

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
    }, properties = { floating = true }},

    { rule_any = {
         class = {
            "Gnucash"
         }
    }, properties = { floating = false }}


    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("property::floating", function(c)
    if c.floating and not c.requests_no_titlebar then
       -- buttons for the titlebar
       local buttons = gears.table.join(
          awful.button({ }, 1, function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.move(c)
          end),
          awful.button({ }, 3, function()
                c:emit_signal("request::activate", "titlebar", {raise = true})
                awful.mouse.client.resize(c)
          end)
       )

       awful.titlebar(c) : setup {
          { -- Left
             awful.titlebar.widget.iconwidget(c),
             buttons = buttons,
             layout  = wibox.layout.fixed.horizontal
          },
          { -- Middle
             { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
             },
             buttons = buttons,
             layout  = wibox.layout.flex.horizontal
          },
          { -- Right
             awful.titlebar.widget.floatingbutton (c),
             awful.titlebar.widget.maximizedbutton(c),
             awful.titlebar.widget.stickybutton   (c),
             awful.titlebar.widget.ontopbutton    (c),
             awful.titlebar.widget.closebutton    (c),
             layout = wibox.layout.fixed.horizontal()
          },
          layout = wibox.layout.align.horizontal }
    else
       awful.titlebar.hide(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("request::geometry", function(c, _, _)
    if c.fullscreen then
       c.border_width = 0
    else
       c.border_width = my_border_width
    end
end)


client.connect_signal("focus" ,
                      function(c)
                         c.border_color = my_border_color_select
                         local c_screen = c.screen
                         local m_screen = awful.screen.focused({ mouse = true })
                         if c_screen.index ~= m_screen.index and string.lower(c.class) == "emacs" then
                            my_center_mouse_at(c)
                         end
end)
client.connect_signal("unfocus", function(c) c.border_color = my_border_color_norm end)
-- }}}
