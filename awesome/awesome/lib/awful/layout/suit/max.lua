---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local setmetatable = setmetatable
local pairs = pairs
local client = require("awful.client")
local capi =
{
    screen = screen
}

--- Maximized and fullscreen layouts module for awful
module("awful.layout.suit.max")

local function fmax(screen, fs)
    -- Fullscreen?
    local area
    if fs then
        area = capi.screen[screen].geometry
    else
        area = capi.screen[screen].workarea
    end

    for k, c in pairs(client.visible(screen)) do
        if not client.floating.get(c) then
            c:geometry(area)
        end
    end
end

--- Maximized layout.
-- @param screen The screen to arrange.
local function max(_, screen)
    return fmax(screen, false)
end

--- Fullscreen layout.
-- @param screen The screen to arrange.
function fullscreen(screen)
    return fmax(screen, true)
end

setmetatable(_M, { __call = max })
