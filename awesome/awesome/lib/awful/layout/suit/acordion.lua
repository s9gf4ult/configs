---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local ipairs = ipairs
local math = math
local tag = require("awful.tag")
local capi =
{
    client = client,
    screen = screen
}
local client = require("awful.client")

--- acordion layout module for awful
module("awful.layout.suit.acordion")

function arrange(p)
    -- Fullscreen?
    local area = p.workarea
    local cls = p.clients
    local focus = capi.client.focus
    local mwfact = tag.getmwfact(tag.selected(p.screen))

    -- Check that the focused window is on the right screen
    if focus and focus.screen ~= p.screen then focus = nil end

    if not focus and #cls > 0 then
        focus = cls[1]
    end

    -- Abort if no clients are present
    if not focus then return end

    -- If focused window is not tiled, take the first one which is tiled.
    if client.floating.get(focus) then
        focus = cls[1]
    end

	local relation=mwfact
	local lasty=area.y
	if #cls == 1 then
		focus:geometry(area)
		focus:raise()
	end
    if #cls > 1 then
		local geometry = {}
		local focus_height=area.height*relation
		local unfocus_height=area.height*(1-relation)/(#cls-1)
		for  k,c in ipairs(cls) do
			if c == focus then
				geometry.width=area.width
				geometry.height=focus_height
				geometry.x=area.x
				geometry.y=lasty
				lasty=lasty+geometry.height
				c:geometry(geometry)
				c:raise()
			else
				geometry.width=area.width
				geometry.height=unfocus_height
				geometry.x=area.x
				geometry.y=lasty
				lasty=lasty+geometry.height
				c:geometry(geometry)
			end
		end
	end

end
name = "acordion"
