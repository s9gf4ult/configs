---------------------------------------------------------------------------
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local os = os
local io = io
local assert = assert
local loadstring = loadstring
local loadfile = loadfile
local debug = debug
local print = print
local type = type
local capi =
{
    awesome = awesome,
    mouse = mouse
}

--- Utility module for awful
module("awful.util")

function deprecate(see)
    io.stderr:write("W: awful: function is deprecated")
    if see then
        io.stderr:write(", see " .. see)
    end
    io.stderr:write("\n")
    io.stderr:write(debug.traceback())
end

--- Strip alpha part of color.
-- @param color The color.
-- @return The color without alpha channel.
function color_strip_alpha(color)
    if color:len() == 9 then
        color = color:sub(1, 7)
    end
    return color
end

--- Make i cycle.
-- @param t A length.
-- @param i An absolute index to fit into #t.
-- @return The object at new index.
function cycle(t, i)
    while i > t do i = i - t end
    while i < 1 do i = i + t end
    return i
end

--- Create a directory
-- @param dir The directory.
-- @return mkdir return code
function mkdir(dir)
    return os.execute("mkdir -p " .. dir)
end

--- Spawn a program.
-- @param cmd The command.
-- @param screen The screen where to spawn window.
-- @return The awesome.spawn return value.
function spawn(cmd, screen)
    if cmd and cmd ~= "" then
        return capi.awesome.spawn(cmd .. "&", screen or capi.mouse.screen)
    end
end

-- Read a program output and returns its output as a string.
-- @param cmd The command to run.
-- @return A string with the program output.
function pread(cmd)
    if cmd and cmd ~= "" then
        local f, err = io.popen(cmd, 'r')
        if f then
            local s = f:read("*all")
            f:close()
            return s
        else
            print(err)
        end
    end
end

--- Eval Lua code.
-- @return The return value of Lua code.
function eval(s)
    return assert(loadstring("return " .. s))()
end

local xml_entity_names = { ["'"] = "&apos;", ["\""] = "&quot;", ["<"] = "&lt;", [">"] = "&gt;", ["&"] = "&amp;" };
--- Escape a string from XML char.
-- Useful to set raw text in textbox.
-- @param text Text to escape.
-- @return Escape text.
function escape(text)
    return text and text:gsub("['&<>\"]", xml_entity_names) or nil
end

local xml_entity_chars = { lt = "<", gt = ">", nbsp = " ", quot = "\"", apos = "'", ndash = "-", mdash = "-", amp = "&" };
--- Unescape a string from entities.
-- @param text Text to unescape.
-- @return Unescaped text.
function unescape(text)
    return text and text:gsub("&(%a+);", xml_entity_chars) or nil
end

--- Check if a file is a Lua valid file.
-- This is done by loading the content and compiling it with loadfile().
-- @param path The file path.
-- @return A function if everything is alright, a string with the error
-- otherwise.
function checkfile(path)
    local f, e = loadfile(path)
    -- Return function if function, otherwise return error.
    if f then return f end
    return e
end

--- Try to restart awesome.
-- It checks if the configuration file is valid, and then restart if it's ok.
-- If it's not ok, the error will be returned.
-- @return Never return if awesome restart, or return a string error.
function restart()
    local c = checkfile(capi.awesome.conffile)

    if type(c) ~= "function" then
        return c
    end

    capi.awesome.restart()
end

--- Get the user's config or cache dir.
-- It first checks XDG_CONFIG_HOME / XDG_CACHE_HOME, but then goes with the
-- default paths.
-- @param d The directory to get (either "config" or "cache").
-- @return A string containing the requested path.
function getdir(d)
    if d == "config" then
        local dir = os.getenv("XDG_CONFIG_HOME")
        if dir then
            return dir .. "/awesome"
        end
        return os.getenv("HOME") .. "/.config/awesome"
    elseif d == "cache" then
        local dir = os.getenv("XDG_CACHE_HOME")
        if dir then
            return dir .. "/awesome"
        end
        return os.getenv("HOME").."/.cache/awesome"
    end
end

--- Check if file exists and is readable.
-- @param filename The file path
-- @return True if file exists and readable.
function file_readable(filename)
    local file = io.open(filename)
    if file then
        io.close(file)
        return true
    end
    return false
end

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:encoding=utf-8:textwidth=80
