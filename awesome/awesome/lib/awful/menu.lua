---------------------------------------------------------------------------
-- @author Damien Leone &lt;damien.leone@gmail.com&gt;
-- @author Julien Danjou &lt;julien@danjou.info&gt;
-- @copyright 2008 Damien Leone, Julien Danjou
-- @release v3.2.1
---------------------------------------------------------------------------

-- Grab environment we need
local pairs = pairs
local table = table
local type = type
local wibox = wibox
local image = image
local widget = widget
local button = button
local capi = { screen = screen, mouse = mouse, client = client }
local util = require("awful.util")
local tags = require("awful.tag")
local awbeautiful = require("beautiful")
local tonumber = tonumber

--- Menu module for awful
module("awful.menu")

local function load_theme(custom)
    local theme = {}
    local beautiful

    beautiful = awbeautiful.get()

    theme.fg_focus = custom.fg_focus or beautiful.menu_fg_focus or beautiful.fg_focus
    theme.bg_focus = custom.bg_focus or beautiful.menu_bg_focus or beautiful.bg_focus
    theme.fg_normal = custom.fg_normal or beautiful.menu_fg_normal or beautiful.fg_normal
    theme.bg_normal = custom.bg_normal or beautiful.menu_bg_normal or beautiful.bg_normal

    theme.submenu_icon = custom.submenu_icon or beautiful.menu_submenu_icon

    theme.menu_height = custom.height or beautiful.menu_height or 16
    theme.menu_width = custom.width or beautiful.menu_width or 100

    theme.border = custom.border_color or beautiful.menu_border_color or beautiful.border_normal
    theme.border_width = custom.border_width or beautiful.menu_border_width or beautiful.border_width

    return theme
end

--- Hide a menu popup.
-- @param menu The menu to hide.
function hide(menu)
    -- Remove items from screen
    for i = 1, #menu.items do
        -- Call mouse_leave to clear menu entry
        for k, w in pairs(menu.items[i].wibox.widgets) do
            w.mouse_leave()
        end
        menu.items[i].wibox.screen = nil
    end
    if menu.active_child then
        menu.active_child:hide()
        active_child = nil
    end
end

-- Get the elder parent so for example when you kill
-- it, it will destroy the whole family.
local function get_parents(data)
    if data.parent then
        return get_parents(data.parent)
    end
    return data
end

local function exec(data, num)
    cmd = data.items[num].cmd
    if type(cmd) == "table" then
        if not data.child[num] then
            data.child[num] = new({ items = cmd }, data, num)
        end
        if data.active_child then
            data.active_child:hide()
        end
        data.active_child = data.child[num]
        data.active_child:show()
    elseif type(cmd) == "string" then
        get_parents(data):hide()
        util.spawn(cmd)
    elseif type(cmd) == "function" then
        get_parents(data):hide()
        cmd()
    end
end

local function item_enter(data, num)
    data.items[num].wibox.fg = data.theme.fg_focus
    data.items[num].wibox.bg = data.theme.bg_focus

    if data.auto_expand == true then
        if data.active_child then
            data.active_child:hide()
        end

        if type(data.items[num].cmd) == "table" then
            exec(data, num)
        end
    end
end

local function item_leave(data, num)
    data.items[num].wibox.fg = data.theme.fg_normal
    data.items[num].wibox.bg = data.theme.bg_normal
end

local function add_item(data, num, item_info)
    local item = wibox({
        position = "floating",
        fg = data.theme.fg_normal,
        bg = data.theme.bg_normal,
        border_color = data.theme.border,
        border_width = data.theme.border_width
    })

    -- Create bindings
    local bindings = {
        button({}, 1, function () exec(data, num) end),
        button({}, 3, function () hide(data) end)
    }

    -- Create the item label widget
    local label = widget({ type = "textbox", align = "left" })
    label.text = item_info[1]
    label:margin({ left = data.h + 2 })
    -- Set icon if needed
    if item_info[3] then
        local icon = type(item_info[3]) == "string" and image(item_info[3]) or item_info[3]
        if icon.width > tonumber(data.h) or icon.height > tonumber(data.h) then
            local width, height
            if ((data.h/icon.height) * icon.width) > tonumber(data.h) then
                width, height = data.h, (tonumber(data.h) / icon.width) * icon.height
            else
                width, height = (tonumber(data.h) / icon.height) * icon.width, data.h
            end
            icon = icon:crop_and_scale(0, 0, icon.width, icon.height, width, height)
        end
        label.bg_image = icon
    end

    item:buttons(bindings)

    function label.mouse_enter() item_enter(data, num) end
    function label.mouse_leave() item_leave(data, num) end

    function item.mouse_enter() item_enter(data, num) end
    function item.mouse_leave() item_leave(data, num) end

    -- Create the submenu icon widget
    local submenu
    if type(item_info[2]) == "table" then
        submenu = widget({ type = "imagebox", align = "right" })
        submenu.image = data.theme.submenu_icon and image(data.theme.submenu_icon)
        submenu:buttons(bindings)

        function submenu.mouse_enter() item_enter(data, num) end
        function submenu.mouse_leave() item_leave(data, num) end
    end

    -- Add widgets to the wibox
    item.widgets = { label, submenu }

    item.ontop = true

    return { wibox = item, cmd = item_info[2] }
end

--- Build a popup menu with running clients and shows it.
-- @param menu Menu table, see new() function for more informations
-- @return The menu.
function clients(menu)
    local cls = capi.client.get()
    local cls_t = {}
    for k, c in pairs(cls) do
        cls_t[#cls_t + 1] = { util.escape(c.name) or "",
                              function ()
                                  if not c:isvisible() then
                                      tags.viewmore(c:tags(), c.screen)
                                  end
                                  capi.client.focus = c
                              end,
                              c.icon }
    end

    if not menu then
        menu = {}
    end

    menu.items = cls_t

    m = new(menu)
    m:show()
    return m
end

local function set_coords(menu, screen_idx)
    local s_geometry = capi.screen[screen_idx].workarea
    local screen_w = s_geometry.x + s_geometry.width
    local screen_h = s_geometry.y + s_geometry.height

    local i_h = menu.h - menu.theme.border_width
    local m_h = (i_h * #menu.items) + menu.theme.border_width

    if menu.parent then
        menu.w = menu.parent.w
        menu.h = menu.parent.h

        local p_w = i_h * (menu.num - 1)
        local m_w = menu.w - menu.theme.border_width

        menu.y = menu.parent.y + p_w + m_h > screen_h and screen_h - m_h or menu.parent.y + p_w
        menu.x = menu.parent.x + m_w*2 > screen_w and menu.parent.x - m_w or menu.parent.x + m_w
    else
        local m_coords = capi.mouse.coords()
        local m_w = menu.w

        menu.y = m_coords.y < s_geometry.y and s_geometry.y or m_coords.y
        menu.x = m_coords.x < s_geometry.x and s_geometry.x or m_coords.x

        menu.y = menu.y + m_h > screen_h and screen_h - m_h or menu.y
        menu.x = menu.x + m_w > screen_w and screen_w - m_w or menu.x
    end
end

--- Show a menu.
-- @param menu The menu to show.
function show(menu)
    local screen_index = capi.mouse.screen
    set_coords(menu, screen_index)
    for num, item in pairs(menu.items) do
        local wibox = item.wibox
        wibox:geometry({
            width = menu.w,
            height = menu.h,
            x = menu.x,
            y = menu.y + (num - 1) * (menu.h - menu.theme.border_width)
        })
        wibox.screen = screen_index
    end
end

--- Toggle menu visibility.
-- @param menu The menu to show if it's hidden, or to hide if it's shown.
function toggle(menu)
    if menu.items[1] and menu.items[1].wibox.screen then
        hide(menu)
    else
        show(menu)
    end
end

--- Open a menu popup.
-- @param menu Table containing the menu informations. Key items: Table containing the displayed items, each element is a tab containing: item name, tiggered action, submenu table or function, item icon (optional). Keys [fg|bg]_[focus|normal], border, border_width, submenu_icon, height and width override the default display for your menu, each of them are optional. Key auto_expand controls the submenu auto expand behaviour by setting it to true (default) or false.
-- @param parent Specify the parent menu if we want to open a submenu, this value should never be set by the user.
-- @param num Specify the parent's clicked item number if we want to open a submenu, this value should never be set by the user.
function new(menu, parent, num)
    -- Create a table to store our menu informations
    local data = {}

    data.items = {}
    data.num = num or 1
    data.theme = parent and parent.theme or load_theme(menu)
    data.parent = parent
    data.child = {}
    if parent then
        data.auto_expand = parent.auto_expand
    elseif menu.auto_expand ~= nil then
        data.auto_expand = menu.auto_expand
    else
        data.auto_expand = true
    end
    data.h = parent and parent.h or data.theme.menu_height
    data.w = parent and parent.w or data.theme.menu_width

    -- Create items
    for k, v in pairs(menu.items) do
        table.insert(data.items, add_item(data, k, v))
    end

    -- Set methods
    data.hide = hide
    data.show = show
    data.toggle = toggle

    return data
end
