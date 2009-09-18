----------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
----------------------------------------------------------------------------

-- Grab environment
local os = os
local io = io
local http = require("socket.http")
local ltn12 = require("ltn12")
local otable = otable
local setmetatable = setmetatable
local util = require("awful.util")
local hooks = require("awful.hooks")
local capi =
{
    wibox = wibox,
    widget = widget,
    image = image
}

--- Root window image display library
module("telak")

local data = otable()

-- Update a telak wibox.
-- @param w The wibox to update.
local function update(w)
    local tmp = os.tmpname()
    http.request{url = data[w].image, sink = ltn12.sink.file(io.open(tmp, "w"))}
    local img = capi.image(tmp)
    if img then
        w:geometry({ width = img.width, height = img.height })
        w.widgets.image = img
    else
        w.visible = false
    end
    os.remove(tmp)
end

--- Create a new telak wibox. This will be automagically update to show a
-- local or remote image.
-- @param args A table with arguments: image is the local or remote image.
-- Timer can be specified to set the time in seconds between two update.
-- Default is 300 seconds.
-- @return The wibox. You need to attach it to a screen and to set its
-- coordinates as you want.
local function new(_, args)
    if not args or not args.image then return end

    -- Create wibox
    local w = capi.wibox({ position = "floating" })
    data[w] = { image = args.image }
    local wimg = capi.widget({ type = "imagebox" })
    w.widgets = wimg

    data[w].cb = function () update(w) end
    hooks.timer.register(args.timer or 3, data[w].cb)

    update(w)

    return w
end

--- Delete a telak wibox.
-- @param w The wibox.
function delete(w)
    if data[w] then
        hooks.timer.unregister(data[w].cb)
        data[w] = nil
    end
end

setmetatable(_M, { __call = new })

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
