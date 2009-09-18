---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local util = require("awful.util")
local pairs = pairs
local ipairs = ipairs
local otable = otable
local capi =
{
    hooks = hooks,
    screen = screen,
    mouse = mouse
}
local hooks = require("awful.hooks")

--- Tag module for awful
module("awful.tag")

-- Private data
local data = {}
data.history = {}
data.history.past = {}
data.history.current = {}
data.tags = otable()

-- History functions
history = {}

-- Compare 2 tables of tags.
-- @param a The first table.
-- @param b The second table of tags.
-- @return True if the tables are identical, false otherwise.
local function compare_select(a, b)
    if not a or not b then
        return false
    end
    -- Quick size comparison
    if #a ~= #b then
        return false
    end
    for ka, va in pairs(a) do
        if b[ka] ~= va.selected then
            return false
        end
    end
    for kb, vb in pairs(b) do
        if a[kb].selected ~= vb then
            return false
        end
    end
    return true
end

--- Update the tag history.
-- @param screen The screen number.
function history.update(screen)
    local curtags = capi.screen[screen]:tags()
    if not compare_select(curtags, data.history.current[screen]) then
        data.history.past[screen] = data.history.current[screen]
        data.history.current[screen] = {}
        for k, v in ipairs(curtags) do
            data.history.current[screen][k] = v.selected
        end
    end
end

-- Revert tag history.
-- @param screen The screen number.
function history.restore(screen)
    local s = screen or capi.mouse.screen
    local tags = capi.screen[s]:tags()
    for k, t in pairs(tags) do
        t.selected = data.history.past[s][k]
    end
end

--- Return a table with all visible tags
-- @param s Screen number.
-- @return A table with all selected tags.
function selectedlist(s)
    local screen = s or capi.mouse.screen
    local tags = capi.screen[screen]:tags()
    local vtags = {}
    for i, t in pairs(tags) do
        if t.selected then
            vtags[#vtags + 1] = t
        end
    end
    return vtags
end

--- Return only the first visible tag.
-- @param s Screen number.
function selected(s)
    return selectedlist(s)[1]
end

--- Set master width factor.
-- @param mwfact Master width factor.
function setmwfact(mwfact, t)
    local t = t or selected()
    if mwfact >= 0 and mwfact <= 1 then
        setproperty(t, "mwfact", mwfact)
        capi.hooks.arrange()(t.screen)
    end
end

--- Increase master width factor.
-- @param add Value to add to master width factor.
function incmwfact(add, t)
    setmwfact(getmwfact(t) + add)
end

--- Get master width factor.
-- @param t Optional tag.
function getmwfact(t)
    local t = t or selected()
    return getproperty(t, "mwfact") or 0.5
end

--- Set the number of master windows.
-- @param nmaster The number of master windows.
-- @param t Optional tag.
function setnmaster(nmaster, t)
    local t = t or selected()
    if nmaster >= 0 then
        setproperty(t, "nmaster", nmaster)
        capi.hooks.arrange()(t.screen)
    end
end

--- Get the number of master windows.
-- @param t Optional tag.
function getnmaster(t)
    local t = t or selected()
    return getproperty(t, "nmaster") or 1
end

--- Increase the number of master windows.
-- @param add Value to add to number of master windows.
function incnmaster(add, t)
    setnmaster(getnmaster(t) + add)
end


--- Set the tag icon
-- @param icon the icon to set, either path or image object
-- @param tag the tag
function seticon(icon, tag)
    local tag = tag or selected()
    setproperty(tag, "icon", icon)
    capi.hooks.tags()(tag.screen, tag, "modify")
end

--- Get the tag icon
-- @param t the tag
function geticon(tag)
    local tag = tag or selected()
    return getproperty(tag, "icon")
end

--- Set number of column windows.
-- @param ncol The number of column.
function setncol(ncol, t)
    local t = t or selected()
    if ncol >= 1 then
        setproperty(t, "ncol", ncol)
        capi.hooks.arrange()(t.screen)
    end
end

--- Get number of column windows.
-- @param t Optional tag.
function getncol(t)
    local t = t or selected()
    return getproperty(t, "ncol") or 1
end

--- Increase number of column windows.
-- @param add Value to add to number of column windows.
function incncol(add, t)
    setncol(getncol(t) + add)
end

--- View no tag.
-- @param Optional screen number.
function viewnone(screen)
    local tags = capi.screen[screen or capi.mouse.screen]:tags()
    for i, t in pairs(tags) do
        t.selected = false
    end
end

--- View a tag by its index.
-- @param i The relative index to see.
-- @param screen Optional screen number.
function viewidx(i, screen)
    local tags = capi.screen[screen or capi.mouse.screen]:tags()
    local sel = selected(screen)
    viewnone(screen)
    for k, t in ipairs(tags) do
        if t == sel then
            tags[util.cycle(#tags, k + i)].selected = true
        end
    end
end

--- View next tag. This is the same as tag.viewidx(1).
function viewnext()
    return viewidx(1)
end

--- View previous tag. This is the same a tag.viewidx(-1).
function viewprev()
    return viewidx(-1)
end

--- View only a tag.
-- @param t The tag object.
function viewonly(t)
    viewnone(t.screen)
    t.selected = true
end

--- View only a set of tags.
-- @param tags A table with tags to view only.
-- @param screen Optional screen number of the tags.
function viewmore(tags, screen)
    viewnone(screen)
    for i, t in pairs(tags) do
        t.selected = true
    end
end

local function hook_tags(screen, tag, action)
    if action == "remove" then
        data.tags[tag] = nil
    elseif action == "add" then
        data.tags[tag] = {}
    end
end

--- Get a tag property.
-- @param tag The tag.
-- @param prop The property name.
-- @return The property.
function getproperty(tag, prop)
    if data.tags[tag] then
        return data.tags[tag][prop]
    end
end

--- Set a tag property.
-- This properties are internal to awful. Some are used to draw taglist, or to
-- handle layout, etc.
-- @param tag The tag.
-- @param prop The property name.
-- @param value The value.
-- @return True if the value has been set, false otherwise.
function setproperty(tag, prop, value)
    if data.tags[tag] then
        data.tags[tag][prop] = value
        return true
    end
    return false
end

--- Tag a client with the set of current tags.
-- @param c The client to tag.
-- @param startup Optional: don't do anything if true.
function withcurrent(c, startup)
    if startup ~= true and c.sticky == false then
        if c.transient_for then
            c.screen = c.transient_for.screen
            c:tags(c.transient_for:tags())
        end
        if #c:tags() == 0 then
            c:tags(selectedlist(c.screen))
        end
    end
end

-- Register standards hooks
hooks.arrange.register(history.update)
hooks.tags.register(hook_tags)
hooks.manage.register(withcurrent)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
