local USE_RADIUS = 2
local WAIT_TIME = 1
local CHAIN_RADIUS = WAIT_TIME * 30

local name = "chain_transfer:link"
local texture = "chain_transfer_link.png"
local texture_off = "chain_transfer_link_off.png"

local function swap_node(pos, name)
        local node = minetest.get_node(pos)
        if node.name == name then
                return
        end
        node.name = name
        minetest.swap_node(pos, node)
end

minetest.register_node(name, {
    description = "Transfer Link",
    drawtype = "signlike",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    alpha = 200,
    tiles = {texture},
    inventory_image = texture,
    wield_image = texture,
    selection_box = {
        type = "wallmounted",
        --wall_top = = <default>
        --wall_bottom = = <default>
        --wall_side = = <default>
    },
    groups = {cracky=3},
})

minetest.register_node(name .. "_off", {
    description = "Transfer Link Off",
    drawtype = "signlike",
    paramtype = "light",
    paramtype2 = "wallmounted",
    sunlight_propagates = true,
    walkable = false,
    alpha = 200,
    tiles = {texture_off},
    inventory_image = texture,
    wield_image = texture,
    selection_box = {
        type = "wallmounted",
        --wall_top = = <default>
        --wall_bottom = = <default>
        --wall_side = = <default>
    },
    groups = {cracky=3, not_in_creative_inventory=1},
    drop = name,
    on_timer = function(pos, elapsed)
        swap_node(pos, name)
    end,
})

minetest.register_abm({
    nodenames = {name},
    interval = WAIT_TIME,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)

        -- First find objects
        local objects = minetest.get_objects_inside_radius(pos, USE_RADIUS)
        if #objects == 0 then
            return
        end

        -- Then find other linkers
        local link = minetest.find_node_near(pos, CHAIN_RADIUS, node.name)
        if not link or link == pos then
            return
        end

        -- Adjust final position (optional)
        local link_shift = {
            x = link.x,
            y = link.y - 0.5,
            z = link.z,
        }

        -- Teleport objects
        local _, object
        for _, object in ipairs(objects) do
            object:setpos(link_shift)
        end

        -- Temporarily turn off teleporter so player won't get into loop
        swap_node(pos, name .. "_off")
        local timer = minetest.env:get_node_timer(pos)
        timer:start(WAIT_TIME * 5)
    end,
})

minetest.register_craft({
	output = "chain_transfer:link",
	recipe = {
		{"bucket:bucket_lava", "", "bucket:bucket_water"},
		{"default:cobble", "", "default:wood"},
	}
})
