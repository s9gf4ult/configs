---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local capi =
{
    mouse = mouse,
    screen = screen,
    client = client
}
local util = require("awful.util")
local client = require("awful.client")

--- Screen module for awful
module("awful.screen")

--- Give the focus to a screen, and move pointer.
-- @param i Relative screen number.
function focus(i)
    local s = util.cycle(capi.screen.count(), capi.mouse.screen + i)
    local c = client.focus.history.get(s, 0)
    if c then capi.client.focus = c end
    -- Move the mouse on the screen
    capi.mouse.screen = s
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
