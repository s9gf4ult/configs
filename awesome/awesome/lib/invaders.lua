----------------------------------------------------------------------------
-- @author Gregor "farhaven" Best
-- @copyright 2008 Gregor "farhaven" Best
-- @release v3.2.1
----------------------------------------------------------------------------

--{{{ Awesome Invaders by Gregor "farhaven" Best
-- The ultra-cool retro graphics are done by Andrei "Garoth" Thorp.
--
-- Use Left and Right to control motion, Space to fire, q quits the game,
-- s creates a screenshot in ~/.cache/awesome (needs ImageMagick).
--
-- Maybe there are some huge memory leaks here and there, if you notice one,
-- message me.
--
-- Anyway, have fun :)
--
-- Start this by adding
-- require("invaders")
-- to the top of your rc.lua and adding
-- invaders.run()
-- to the bottom of rc.lua or as a keybinding
--}}}

local wibox = wibox
local widget = widget
local awful = require("awful")
local beautiful = require("beautiful")
local image = image
local capi = { screen = screen, mouse = mouse, keygrabber = keygrabber }

local tonumber = tonumber
local table = table
local math = math
local os = os
local io = io

--- Space Invaders look-alike
module("invaders")

local gamedata = { }
gamedata.field = { }
gamedata.field.x = 100
gamedata.field.y = 100
gamedata.field.h = 400
gamedata.field.w = 600
gamedata.running = false
gamedata.highscore = { }
gamedata.enemies = { }
gamedata.enemies.h = 10
gamedata.enemies.w = 20
gamedata.enemies.rows = 5
gamedata.enemies.count = gamedata.enemies.rows * 6
gamedata.enemies[1] = image("/usr/share/awesome/icons/invaders/enemy_1.png")
gamedata.enemies[2] = image("/usr/share/awesome/icons/invaders/enemy_2.png")
gamedata.enemies[3] = image("/usr/share/awesome/icons/invaders/enemy_3.png")

local player = { }
local game = { }
local shots = { }
local enemies = { }

function player.new ()
    p = wibox({ position = "floating",
                bg = gamedata.solidbg or "#12345600" })
    p:geometry({ width = 24,
                 height = 16,
                 x = gamedata.field.x + (gamedata.field.w / 2),
                 y = gamedata.field.y + gamedata.field.h - (16 + 5) })
    p.screen = gamedata.screen

    w = widget({ type = "imagebox" })
    w.image = image("/usr/share/awesome/icons/invaders/player.png")
    p.widgets = w

    return p
end

function player.move(x)
    if not gamedata.running then return false end
    local g = gamedata.player:geometry()

    if x < 0 and g.x > gamedata.field.x then
        g.x = g.x + x
    elseif x > 0 and g.x < gamedata.field.x + gamedata.field.w - 30 then
        g.x = g.x + x
    end

    gamedata.player:geometry(g)
end

function player.fire()
    if not gamedata.running then return false end
    if gamedata.ammo == 1 then
        gamedata.ammo = 0
        local gb = gamedata.player:geometry()
        shots.fire(gb.x + 9, gb.y - 10, "#00FF00")
    end
end

function shots.fire (x, y, color)
    local s = wibox({ position = "floating",
                      bg = color })
    s:geometry({ width = 4,
                 height = 10,
                 x = x,
                 y = y })
    s.screen = gamedata.screen

    if not gamedata.shot or gamedata.shot.screen == nil then
            gamedata.shot = s
    end
end

function shots.fire_enemy (x, y, color)
    if gamedata.enemies.shots.fired < gamedata.enemies.shots.max then
        gamedata.enemies.shots.fired = gamedata.enemies.shots.fired + 1
        local s = wibox({ position = "floating",
                          bg = color })
        s:geometry({ width = 4,
                     height = 10,
                     x = x,
                     y = y })
        s.screen = gamedata.screen
        for i = 1, gamedata.enemies.shots.max do
            if not gamedata.enemies.shots[i] or gamedata.enemies.shots[i].screen == nil then
                gamedata.enemies.shots[i] = s
                break
            end
        end
    end
end

function shots.handle()
    if not gamedata.running then return false end
    if gamedata.ammo == 1 then return false end

    local s = gamedata.shot
    if s and s.screen then
        gamedata.ammo = 0
        local g = s:geometry()
        if g.y < gamedata.field.y + 15 then
            s.screen = nil
            gamedata.ammo = 1
        else
            g.y = g.y - 6
            s:geometry(g)
        end
    end
end


function shots.handle_enemy ()
    if not gamedata.running then return false end
    if gamedata.enemies.shots.fired == 0 then return false end

    for i = 1, gamedata.enemies.shots.max do
        local s = gamedata.enemies.shots[i]
        if s and s.screen then
            local g = s:geometry()
            if g.y > gamedata.field.y + gamedata.field.h - 15 then
                s.screen = nil
                gamedata.enemies.shots.fired = gamedata.enemies.shots.fired - 1
            else
                g.y = g.y + 3
                s:geometry(g)
            end
            if game.collide(gamedata.player, s) then
                game.over()
            end
        end
    end
end

function enemies.new (t)
    e = wibox({ position = "floating",
                bg = gamedata.solidbg or "#12345600" })
    e:geometry({ height = gamedata.enemies.h,
                 width = gamedata.enemies.w,
                 x = gamedata.field.x,
                 y = gamedata.field.y })
    e.screen = gamedata.screen
    w = widget({ type = "imagebox" })
    w.image = gamedata.enemies[t]

    e.widgets = w
    return e
end

function enemies.setup()
    gamedata.enemies.data = { }
    gamedata.enemies.x = 10
    gamedata.enemies.y = 5
    gamedata.enemies.dir = 1
    if not gamedata.enemies.shots then gamedata.enemies.shots = { } end
    gamedata.enemies.shots.max = 10
    gamedata.enemies.shots.fired = 0

    gamedata.enemies.speed_count = 0

    for y = 1, gamedata.enemies.rows do
        gamedata.enemies.data[y] = { }
        for x = 1, math.ceil((gamedata.enemies.count / gamedata.enemies.rows) + 1) do
            gamedata.enemies.data[y][x] = enemies.new((y % 3) + 1)
        end
    end

    if gamedata.shot then
        gamedata.shot.screen = nil
    end

    for i = 1, gamedata.enemies.shots.max do
        if gamedata.enemies.shots[i] then
            gamedata.enemies.shots[i].screen = nil
        end
    end
end

function enemies.handle ()
    if not gamedata.running then return false end

    gamedata.enemies.number = 0

    for y = 1, #gamedata.enemies.data do
        for x = 1, #gamedata.enemies.data[y] do
            local e = gamedata.enemies.data[y][x]
            if e.screen then
                local g = e:geometry()
                gamedata.enemies.number = gamedata.enemies.number + 1
                if gamedata.enemies.speed_count == (gamedata.enemies.speed - 1) then
                    g.y = math.floor(gamedata.field.y + gamedata.enemies.y + ((y - 1) * gamedata.enemies.h * 2))
                    g.x = math.floor(gamedata.field.x + gamedata.enemies.x + ((x - 1) * gamedata.enemies.w * 2))
                    e:geometry(g)
                    if game.collide(gamedata.player, e) or g.y > gamedata.field.y + gamedata.field.h - 20 then
                        game.over()
                    end
                end
                if gamedata.ammo == 0 then
                        local s = gamedata.shot
                        if s and s.screen and game.collide(e, s) then
                        gamedata.enemies.number = gamedata.enemies.number - 1
                        gamedata.ammo = 1
                        e.screen = nil
                        s.screen = nil

                        if (y % 3) == 0 then
                            gamedata.score = gamedata.score + 15
                        elseif (y % 3) == 1 then
                            gamedata.score = gamedata.score + 10
                        else
                            gamedata.score = gamedata.score + 5
                        end
                        gamedata.field.status.text = gamedata.score.." | "..gamedata.round.."  "
                    end
                end
            end
        end

        local x = math.random(1, gamedata.enemies.count / gamedata.enemies.rows)
        if gamedata.enemies.speed_count == (gamedata.enemies.speed - 1)
            and math.random(0, 150) <= 1
            and gamedata.enemies.data[y][x].screen then
            shots.fire_enemy(math.floor(gamedata.field.x + gamedata.enemies.x + ((x - 1) * gamedata.enemies.w)),
                             gamedata.field.y + gamedata.enemies.y + gamedata.enemies.h,
                             "#FF0000")
        end
    end

    if gamedata.enemies.number == 0 then
        enemies.setup()
        gamedata.round = gamedata.round + 1
        gamedata.field.status.text = gamedata.score.." | "..gamedata.round.."  "
        if gamedata.enemies.speed > 1 then gamedata.enemies.speed = gamedata.enemies.speed - 1 end
        return false
    end

    gamedata.enemies.speed_count = gamedata.enemies.speed_count + 1
    if gamedata.enemies.speed_count < gamedata.enemies.speed then return false end
    gamedata.enemies.speed_count = 0
    gamedata.enemies.x = gamedata.enemies.x + math.floor((gamedata.enemies.w * gamedata.enemies.dir) / 4)
    if gamedata.enemies.x > gamedata.field.w - (2 * gamedata.enemies.w * (gamedata.enemies.count / gamedata.enemies.rows + 1)) + 5
        or gamedata.enemies.x <= 10 then
        gamedata.enemies.y = gamedata.enemies.y + gamedata.enemies.h
        gamedata.enemies.dir = gamedata.enemies.dir * (-1)
    end
end

function keyhandler(mod, key, event)
    if event ~= "press" then return true end
    if gamedata.highscore.getkeys then
        if key:len() == 1 and gamedata.name:len() < 20 then
            gamedata.name = gamedata.name .. key
        elseif key == "BackSpace" then
            gamedata.name = gamedata.name:sub(1, gamedata.name:len() - 1)
        elseif key == "Return" then
            gamedata.highscore.window.screen = nil
            game.highscore_add(gamedata.score, gamedata.name)
            game.highscore_show()
            gamedata.highscore.getkeys = false
        end
        gamedata.namebox.text = " Name: " .. gamedata.name .. "|"
    else
        if key == "Left" then
            player.move(-10)
        elseif key == "Right" then
            player.move(10)
        elseif key == "q" then
            game.quit()
            return false
        elseif key == " " then
            player.fire()
        elseif key == "s" then
            awful.util.spawn("import -window root "..gamedata.cachedir.."/invaders-"..os.time()..".png")
        elseif key == "p" then
            gamedata.running = not gamedata.running
        end
    end
    return true
end

function game.collide(o1, o2)
    g1 = o1:geometry()
    g2 = o2:geometry()

    --check if o2 is inside o1
    if g2.x >= g1.x and g2.x <= g1.x + g1.width
        and g2.y >= g1.y and g2.y <= g1.y + g1.height then
        return true
    end

    return false
end

function game.over ()
    gamedata.running = false
    game.highscore(gamedata.score)
end

function game.quit()
    gamedata.running = false

    if gamedata.highscore.window then
        gamedata.highscore.window.screen = nil
        gamedata.highscore.window.widgets = nil
    end

    if gamedata.field.background then
       gamedata.field.background.screen = nil
    end

    gamedata.player.screen = nil
    gamedata.player.widgets = nil
    gamedata.player = nil

    gamedata.field.north.screen = nil
    gamedata.field.north = nil

    gamedata.field.south.screen = nil
    gamedata.field.south = nil

    gamedata.field.west.screen = nil
    gamedata.field.west = nil

    gamedata.field.east.screen = nil
    gamedata.field.east = nil

    for y = 1, #gamedata.enemies.data do
        for x = 1, #gamedata.enemies.data[y] do
            gamedata.enemies.data[y][x].screen = nil
            gamedata.enemies.data[y][x].widgets = nil
        end
    end

    if gamedata.shot then gamedata.shot.screen = nil end

    for i = 1, gamedata.enemies.shots.max do
        if gamedata.enemies.shots[i] then gamedata.enemies.shots[i].screen = nil end
    end
end

function game.highscore_show ()
    gamedata.highscore.window:geometry({ height = 140,
                                         width = 200,
                                         x = gamedata.field.x + math.floor(gamedata.field.w / 2) - 100,
                                         y = gamedata.field.y + math.floor(gamedata.field.h / 2) - 55 })
    gamedata.highscore.window.screen = gamedata.screen

    gamedata.highscore.table = widget({ type = "textbox" })
    gamedata.highscore.window.widgets =  gamedata.highscore.table

    gamedata.highscore.table.text = " Highscores:\n"

    for i = 1, 5 do
        gamedata.highscore.table.text = gamedata.highscore.table.text .. "\n\t" .. gamedata.highscore[i]
    end

    gamedata.highscore.table.text = gamedata.highscore.table.text .. "\n\n Press Q to quit"

    local fh = io.open(gamedata.cachedir.."/highscore_invaders", "w")

    if not fh then
        return false
    end

    for i = 1, 5 do
        fh:write(gamedata.highscore[i].."\n")
    end

    fh:close()
end

function game.highscore_add (score, name)
    local t = gamedata.highscore

    for i = 5, 1, -1 do
        if tonumber(t[i]:match("(%d+) ")) <= score then
            if t[i+1] then t[i+1] = t[i] end
            t[i] = score .. " " .. name
        end
    end

    gamedata.highscore = t
end

function game.highscore (score)
    if gamedata.highscore.window and gamedata.highscore.window.screen then return false end
    local fh = io.open(gamedata.cachedir.."/highscore_invaders", "r")

    if fh then
        for i = 1, 5 do
        gamedata.highscore[i] = fh:read("*line")
        end
        fh:close()
    else
        for i = 1, 5 do
            gamedata.highscore[i] = ((6-i)*20).." foo"
        end
    end

    local newentry = false
    for i = 1, 5 do
        local s = tonumber(gamedata.highscore[i]:match("(%d+) .*"))
        if s <= score then newentry = true end
    end

    gamedata.highscore.window = wibox({ position = "floating",
                                        bg = gamedata.btheme.bg_focus or "#333333",
                                        fg = gamedata.btheme.fg_focus or "#FFFFFF" })
    gamedata.highscore.window:geometry({ height = 20,
                                         width = 300,
                                         x = gamedata.field.x + math.floor(gamedata.field.w / 2) - 150,
                                         y = gamedata.field.y + math.floor(gamedata.field.h / 2) })
    gamedata.highscore.window.screen = gamedata.screen

    gamedata.namebox = widget({ type = "textbox" })
    gamedata.namebox.text = " Name: |"
    gamedata.highscore.window.widgets = gamedata.namebox

    if newentry then
        gamedata.name = ""
        gamedata.highscore.getkeys = true
    else
        game.highscore_show()
    end
end

--- Run Awesome Invaders
-- @param args A table with parameters.
-- x the X coordinate of the playing field.
-- y the Y coordinate of the playing field.
-- if either of these is left out, the game is placed in the center of the focused screen.
-- solidbg the background color of the playing field. If none is given, the playing field is transparent.
function run(args)
    gamedata.screen = capi.screen[capi.mouse.screen]
    gamedata.field.x = gamedata.screen.geometry.x + math.floor((gamedata.screen.geometry.width - gamedata.field.w) / 2)
    gamedata.field.y = gamedata.screen.geometry.y + math.floor((gamedata.screen.geometry.height - gamedata.field.h) / 2)
    gamedata.screen = capi.mouse.screen

    if args then
       if args['x'] then gamedata.field.x = args['x'] end
       if args['y'] then gamedata.field.y = args['y'] end
       if args['solidbg'] then gamedata.solidbg = args['solidbg'] end
    end

    gamedata.score = 0
    gamedata.name = ""
    gamedata.ammo = 1
    gamedata.round = 1
    gamedata.btheme = beautiful.get()

    gamedata.cachedir = awful.util.getdir("cache")

    if gamedata.solidbg then
       gamedata.field.background = wibox({ position = "floating",
                                           bg = gamedata.solidbg })
       gamedata.field.background:geometry({ x = gamedata.field.x,
                                            y = gamedata.field.y,
                                            height = gamedata.field.h,
                                            width = gamedata.field.w })
       gamedata.field.background.screen = gamedata.screen
    end

    gamedata.field.north = wibox({ position = "floating",
                                   bg = gamedata.btheme.bg_focus or "#333333",
                                   fg = gamedata.btheme.fg_focus or "#FFFFFF" })
    gamedata.field.north:geometry({ width = gamedata.field.w + 10,
                                    height = 15,
                                    x = gamedata.field.x - 5,
                                    y = gamedata.field.y - 15 })
    gamedata.field.north.screen = gamedata.screen

    gamedata.field.status = widget({ type = "textbox",
                                     align = "right" })
    gamedata.field.status.text = gamedata.score.." | "..gamedata.round .. "  "

    gamedata.field.caption = widget({ type = "textbox",
                                      align = "left" })
    gamedata.field.caption.text = "  Awesome Invaders"

    gamedata.field.north.widgets = { gamedata.field.caption, gamedata.field.status }

    gamedata.field.south = wibox({ position = "floating",
                                   bg = gamedata.btheme.bg_focus or "#333333",
                                   fg = gamedata.btheme.fg_focus or "#FFFFFF" })
    gamedata.field.south:geometry({ width = gamedata.field.w,
                                    height = 5,
                                    x = gamedata.field.x,
                                    y = gamedata.field.y + gamedata.field.h - 5 })
    gamedata.field.south.screen = gamedata.screen

    gamedata.field.west = wibox({ position = "floating",
                                  bg = gamedata.btheme.bg_focus or "#333333",
                                  fg = gamedata.btheme.fg_focus or "#FFFFFF" })
    gamedata.field.west:geometry({ width = 5,
                                   height = gamedata.field.h,
                                   x = gamedata.field.x - 5,
                                   y = gamedata.field.y })
    gamedata.field.west.screen = gamedata.screen

    gamedata.field.east = wibox({ position = "floating",
                                  bg = gamedata.btheme.bg_focus or "#333333",
                                  fg = gamedata.btheme.fg_focus or "#FFFFFF" })
    gamedata.field.east:geometry({ width = 5,
                                   height = gamedata.field.h,
                                   x = gamedata.field.x + gamedata.field.w,
                                   y = gamedata.field.y })
    gamedata.field.east.screen = gamedata.screen

    gamedata.enemies.speed = 5
    enemies.setup()

    gamedata.player = player.new()
    capi.keygrabber.run(keyhandler)
    gamedata.running = true
end

awful.hooks.timer.register(0.02, shots.handle)
awful.hooks.timer.register(0.03, shots.handle_enemy)
awful.hooks.timer.register(0.01, enemies.handle)
