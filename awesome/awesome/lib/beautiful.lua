----------------------------------------------------------------------------
-- @author Damien Leone &lt;damien.leone@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Damien Leone, Julien Danjou
-- @release v3.2.1
----------------------------------------------------------------------------

-- Grab environment
local io = io
local print = print
local setmetatable = setmetatable
local util = require("awful.util")
local package = package
local capi =
{
    screen = screen,
    awesome = awesome,
    image = image
}

--- Theme library
module("beautiful")

-- Local data
local theme = {}

--- Get a value directly.
-- @param key The key.
-- @return The value.
function __index(self, key)
    return theme[key]
end

--- Init function, should be runned at the beginning of configuration file.
-- @param path The theme file path.
function init(path)
    if path then
       local f = io.open(path)

       if not f then
           return print("E: unable to load theme " .. path)
       end

       for key, value in f:read("*all"):gsub("^","\n"):gmatch("\n[\t ]*([a-z_]+)[\t ]*=[\t ]*([^\n\t]+)") do
            if key == "wallpaper_cmd" then
                for s = 1, capi.screen.count() do
                    util.spawn(value, s)
                end
            elseif key == "font" then
                capi.awesome.font = value
            elseif key == "fg_normal" then
                capi.awesome.fg = value
            elseif key == "bg_normal" then
                capi.awesome.bg = value
            end
            -- Store.
            theme[key] = value
        end
        f:close()
    end
end

--- Get the current theme.
-- @return The current theme table.
function get()
    return _M
end

setmetatable(_M, _M)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
