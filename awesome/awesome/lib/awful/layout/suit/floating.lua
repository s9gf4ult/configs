---------------------------------------------------------------------------
-- @author Gregor Best
-- @copyright 2008 Gregor Best
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local setmetatable = setmetatable

--- Dummy function for floating layout
module("awful.layout.suit.floating")

local function floating(_, screen)
    return nil
end

setmetatable(_M, { __call = floating })
