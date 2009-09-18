---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local tag = require("awful.tag")
local util = require("awful.util")
local suit = require("awful.layout.suit")
local capi =
{
    hooks = hooks,
    screen = screen
}
local hooks = require("awful.hooks")

--- Layout module for awful
module("awful.layout")

--- Get the current layout.
-- @param screen The screen number.
-- @return The layout function.
function get(screen)
    local t = tag.selected(screen)
    return tag.getproperty(t, "layout") or suit.floating
end

--- Change the layout of the current tag.
-- @param layouts A table of layouts.
-- @param i Relative index.
function inc(layouts, i)
    local t = tag.selected()
    if t then
        local curlayout = get()
        local curindex
        local rev_layouts = {}
        for k, v in ipairs(layouts) do
            if v == curlayout then
                curindex = k
                break
            end
        end
        if curindex then
            local newindex = util.cycle(#layouts, curindex + i)
            set(layouts[newindex])
        end
    end
end

--- Set the layout function of the current tag.
-- @param layout Layout name.
function set(layout, t)
    t = t or tag.selected()
    tag.setproperty(t, "layout", layout)
    capi.hooks.arrange()(t.screen)
end

-- Register an arrange hook.
local function on_arrange (screen)
    get(screen)(screen)
end

local layouts_name =
{
    [suit.tile]            = "tile",
    [suit.tile.left]       = "tileleft",
    [suit.tile.bottom]     = "tilebottom",
    [suit.tile.top]        = "tiletop",
    [suit.fair]            = "fairv",
    [suit.fair.horizontal] = "fairh",
    [suit.max]             = "max",
    [suit.max.fullscreen]  = "fullscreen",
    [suit.magnifier]       = "magnifier",
    [suit.floating]        = "floating",
	[suit.acordion] 	   = "acordion"
}

--- Get the current layout name.
-- @param layout the layout name.
-- @return The layout name.
function getname(layout)
    return layouts_name[layout]
end

hooks.arrange.register(on_arrange)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
