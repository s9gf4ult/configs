---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local client = require("awful.client")
local capi =
{
    screen = screen
}

--- Fair layouts module for awful
module("awful.layout.suit.fair")

local function fair(screen, orientation)
    local wa = capi.screen[screen].workarea
    local cls = client.tiled(screen)

    if #cls > 0 then
        local cells = math.ceil(math.sqrt(#cls))
        local strips = math.ceil(#cls / cells)

        local cell = 0
        local strip = 0
        for k, c in ipairs(cls) do
            local g = {}
            if ( orientation == "east" and #cls > 2 )
            or ( orientation == "south" and #cls <= 2 ) then
                if #cls < (strips * cells) and strip == strips - 1 then
                    g.width = wa.width / (cells - ((strips * cells) - #cls))
                else
                    g.width = wa.width / cells
                end
                g.height = wa.height / strips

                g.x = wa.x + cell * g.width
                g.y = wa.y + strip * g.height

            else
                if #cls < (strips * cells) and strip == strips - 1 then
                    g.height = wa.height / (cells - ((strips * cells) - #cls))
                else
                    g.height = wa.height / cells
                end
                g.width = wa.width / strips

                g.x = wa.x + strip * g.width
                g.y = wa.y + cell * g.height
            end

            c:geometry(g)

            cell = cell + 1
            if cell == cells then
                cell = 0
                strip = strip + 1
            end
        end
    end
end
--- Horizontal fair layout.
-- @param screen The screen to arrange.
function horizontal(screen)
    return fair(screen, "east")
end

-- Vertical fair layout.
-- @param screen The screen to arrange.
local function fairv(_, screen)
    return fair(screen, "south")
end

setmetatable(_M, { __call = fairv })
