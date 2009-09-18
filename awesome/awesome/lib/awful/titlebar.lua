---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local math = math
local image = image
local pairs = pairs
local otable = otable
local capi =
{
    wibox = wibox,
    widget = widget,
    button = button,
    client = client,
}
local beautiful = require("beautiful")
local hooks = require("awful.hooks")
local util = require("awful.util")
local widget = require("awful.widget")
local mouse = require("awful.mouse")

--- Titlebar module for awful
module("awful.titlebar")

-- Privata data
local data = otable()

--- Create a standard titlebar.
-- @param c The client.
-- @param args Arguments.
-- modkey: the modkey used for the bindings.
-- fg: the foreground color.
-- bg: the background color.
-- fg_focus: the foreground color for focused window.
-- fg_focus: the background color for focused window.
-- width: the titlebar width
function add(c, args)
    if not c or (c.type ~= "normal" and c.type ~= "dialog") then return end
    if not args then args = {} end
    local theme = beautiful.get()
    -- Store colors
    data[c] = {}
    data[c].fg = args.fg or theme.titlebar_fg_normal or theme.fg_normal
    data[c].bg = args.bg or theme.titlebar_bg_normal or theme.bg_normal
    data[c].fg_focus = args.fg_focus or theme.titlebar_fg_focus or theme.fg_focus
    data[c].bg_focus = args.bg_focus or theme.titlebar_bg_focus or theme.bg_focus
    data[c].width = args.width

    local tb = capi.wibox(args)

    local title = capi.widget({ type = "textbox", align = "flex" })
    if c.name then
        title.text = " " .. util.escape(c.name) .. " "
    else
        title.text = nil
    end

    -- Redirect relevant events to the client the titlebar belongs to
    local bts =
    {
        capi.button({ }, 1, function (t) capi.client.focus = t.client t.client:raise() mouse.client.move(t.client) end),
        capi.button({ args.modkey }, 1, function (t) mouse.client.move(t.client) end),
        capi.button({ args.modkey }, 3, function (t) mouse.client.resize(t.client) end)
    }
    title:buttons(bts)
    function title.mouse_enter(s) hooks.user.call('mouse_enter', c) end

    local appicon = capi.widget({ type = "imagebox", align = "left" })
    appicon.image = c.icon

    -- Also redirect events for appicon (So the entire titlebar behaves consistently)
    appicon:buttons(bts)
    function appicon.mouse_enter(s) hooks.user.call('mouse_enter', c) end

    local closef
    if theme.titlebar_close_button_focus then
        closef = widget.button({ align = "right",
                                 image = image(theme.titlebar_close_button_focus) })
    end

    local close
    if theme.titlebar_close_button_normal then
        close = widget.button({ align = "right",
                                image = image(theme.titlebar_close_button_normal) })
    end

    if close or closef then
        -- Bind kill button, also allow moving and resizing on this widget
        local bts =
        {
            capi.button({ }, 1, nil, function (t) t.client:kill() end),
            capi.button({ args.modkey }, 1, function (t) mouse.client.move(t.client) end),
            capi.button({ args.modkey }, 3, function (t) mouse.client.resize(t.client) end)
        }
        if close then
            local rbts = close:buttons()
            for k, v in pairs(rbts) do
                bts[#bts + 1] = v
            end
            close:buttons(bts)
            function close.mouse_enter(s) hooks.user.call('mouse_enter', c) end
        end
        if closef then
            local rbts = closef:buttons()
            for k, v in pairs(rbts) do
                bts[#bts + 1] = v
            end
            closef:buttons(bts)
            -- Needed for sloppy focus beheaviour
            function closef.mouse_enter(s) hooks.user.call('mouse_enter', c) end
        end
    end

    tb.widgets = { appicon = appicon, title = title,
                   closef = closef, close = close }

    c.titlebar = tb

    update(c)
end

--- Update a titlebar. This should be called in some hooks.
-- @param c The client to update.
-- @param prop The property name which has changed.
function update(c, prop)
    if c.titlebar and data[c] then
        local widgets = c.titlebar.widgets
        if prop == "name" then
            if widgets.title then
                widgets.title.text = " " .. util.escape(c.name) .. " "
            end
        elseif prop == "icon" then
            if widgets.appicon then
                widgets.appicon.image = c.icon
            end
        end
        if capi.client.focus == c then
            c.titlebar.fg = data[c].fg_focus
            c.titlebar.bg = data[c].bg_focus
            if widgets.closef then widgets.closef.visible = true end
            if widgets.close then widgets.close.visible = false end
        else
            c.titlebar.fg = data[c].fg
            c.titlebar.bg = data[c].bg
            if widgets.closef then widgets.closef.visible = false end
            if widgets.close then widgets.close.visible = true end
        end
    end
end

--- Remove a titlebar from a client.
-- @param c The client.
function remove(c)
    c.titlebar = nil
    data[c] = nil
end

-- Register standards hooks
hooks.focus.register(update)
hooks.unfocus.register(update)
hooks.property.register(update)
hooks.unmanage.register(remove)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
