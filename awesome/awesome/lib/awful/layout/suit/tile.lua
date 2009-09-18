---------------------------------------------------------------------------
-- @author Donald Ephraim Curtis &lt;dcurtis@cs.uiowa.edu&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2009 Donald Ephraim Curtis
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local client = require("awful.client")
local tag = require("awful.tag")
local capi =
{
    screen = screen
}

--- Tiled layouts module for awful
module("awful.layout.suit.tile")

local function tile_group(cls, wa, orientation, fact, group)
    -- get our orientation right
    local height = "height"
    local width = "width"
    local x = "x"
    local y = "y"
    if orientation == "top" or orientation == "bottom" then
        height = "width"
        width = "height"
        x = "y"
        y = "x"
    end

    -- make this more generic (not just width)
    available = wa[width] - (group.coord - wa[x])

    -- find our total values
    local total_fact = 0
    local min_fact = 1
    local size = group.size
    for c = group.first,group.last do
        -- determine the width/height based on the size_hint
        local i = c - group.first +1
        local size_hints = cls[c].size_hints
        local size_hint = size_hints["min_"..width] or size_hints["base_"..width] or 0
        size_hint = size_hint + cls[c].border_width*2
        size = math.max(size_hint, size)

        -- calculate the height
        if not fact[i] then
            fact[i] = min_fact
        else
            min_fact = math.min(fact[i],min_fact)
        end
        total_fact = total_fact + fact[i]
    end
    size = math.min(size, available)

    local coord = wa[y]
    local geom = {}
    local used_size = 0
    local unused = wa[height]
    for c = group.first,group.last do
        local i = c - group.first +1
        geom[width] = size
        geom[height] = math.floor(unused * fact[i] / total_fact)
        geom[x] = group.coord
        geom[y] = coord
        geom = cls[c]:geometry(geom)
        coord = coord + geom[height]
        unused = unused - geom[height]
        total_fact = total_fact - fact[i]
        used_size = math.max(used_size, geom[width])
    end

    return used_size

end

local function tile(_, screen, orientation)
    orientation = orientation or "right"

    -- this handles are different orientations
    local height = "height"
    local width = "width"
    local x = "x"
    local y = "y"
    if orientation == "top" or orientation == "bottom" then
        height = "width"
        width = "height"
        x = "y"
        y = "x"
    end

    local t = tag.selected(screen)
    local cls = client.tiled(screen)
    local nmaster = math.min(tag.getnmaster(t), #cls)
    local nother = math.max(#cls - nmaster,0)

    local mwfact = tag.getmwfact(t)
    local wa = capi.screen[screen].workarea
    local ncol = tag.getncol(t)

    local data = tag.getproperty(t,"windowfact")

    if not data then
        data = {}
        tag.setproperty(t,"windowfact", data)
    end

    --
    local coord = wa[x]
    local place_master = true
    if orientation == "left" or orientation == "top" then
        -- if we are on the left or top we need to render the other windows first
        place_master = false
    end

    -- this was easier than writing functions because there is a lot of data we need
    for d = 1,2 do
        if place_master and nmaster > 0 then
            local size = wa[width]
            if nother > 0 then
                size = math.min(wa[width] * mwfact, wa[width] - (coord - wa[x]))
            end
            if not data[0] then
                data[0] = {}
            end
            coord = coord + tile_group(cls, wa, orientation, data[0], {first=1, last=nmaster, coord = coord, size = size})
        end

        if not place_master and nother > 0 then
            local last = nmaster

            -- we have to modify the work area size to consider left and top views
            local wasize = wa[width]
            if nmaster > 0 and (orientation == "left" or orientation == "top") then
                wasize = wa[width] - wa[width]*mwfact
            end
            for i = 1,ncol do
                -- Try to get equal width among remaining columns
                local size = math.min( (wasize - (coord - wa[x])) / (ncol - i + 1) )
                local first = last + 1
                last = last + math.floor((#cls - last)/(ncol - i + 1))
                -- tile the column and update our current x coordinate
                if not data[i] then
                    data[i] = {}
                end
                coord = coord + tile_group(cls, wa, orientation, data[i], { first = first, last = last, coord = coord, size = size })
            end
        end
        place_master = not place_master
    end

end

--- The main tile algo, on left.
-- @param screen The screen number to tile.
function left(screen)
    return tile(nil, screen, "left")
end

--- The main tile algo, on bottom.
-- @param screen The screen number to tile.
function bottom(screen)
    return tile(nil, screen, "bottom")
end

--- The main tile algo, on top.
-- @param screen The screen number to tile.
function top(screen)
    return tile(nil, screen, "top")
end

setmetatable(_M, { __call = tile })
