-- Smokeleaf Industries - Cannabis Cultivation Mod for Luanti
-- Ported from Minecraft NeoForge mod
-- Version: 1.0.4

local S = minetest.get_translator("smokyleaf_industry")

-- Mod namespace
smokyleaf_industry = {}

-- Constants
local PLANT_GROWTH_STAGES = 8
local GROWTH_CHANCE = 3 -- 1 in X per ABM cycle
local HEMP_GROWTH_SPEED_MULTIPLIER = 1.2
local TOBACCO_GROWTH_SPEED_MULTIPLIER = 1.0

-- Optional Elepower PAPI integration. It is safe to run this mod without Elepower.
local ELEPOWER_AVAILABLE = minetest.get_modpath("elepower_papi") ~= nil
	and type(rawget(_G, "ele")) == "table"
	and type(ele.register_machine) == "function"

local function ele_node_property(meta, pos, key, fallback)
	if ELEPOWER_AVAILABLE and ele.helpers and ele.helpers.get_node_property then
		local ok, value = pcall(ele.helpers.get_node_property, meta, pos, key)
		if ok and type(value) == "number" then return value end
	end
	local value = meta:get_int(key)
	if value ~= 0 then return value end
	return fallback or 0
end

local function ele_use_energy(pos, amount)
	if not ELEPOWER_AVAILABLE then return true end
	local meta = minetest.get_meta(pos)
	local storage = meta:get_int("storage")
	if storage < amount then return false end
	meta:set_int("storage", storage - amount)
	return true
end

local function ele_power_label(pos, usage_label)
	if not ELEPOWER_AVAILABLE then
		return "Power: not required (Elepower not installed)"
	end
	local meta = minetest.get_meta(pos)
	local storage = meta:get_int("storage")
	local capacity = ele_node_property(meta, pos, "capacity", 1600)
	return string.format("POWER: %d / %d EU   |   %s", storage, capacity, usage_label or "Powered")
end

-- ============================================================================
-- WEED STRAIN DEFINITIONS
-- ============================================================================

local weed_strains = {
	-- Indica strains (faster, stronger effects)
	{
		name = "purple_kush",
		title = S("Purple Kush"),
		color = 0x6B0080,
		growth_time = 80,
		potency = 0.9,
		effects = {"relaxation", "sleep"},
		yield_multiplier = 1.1
	},
	{
		name = "northern_lights",
		title = S("Northern Lights"),
		color = 0x87CEEB,
		growth_time = 75,
		potency = 0.85,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.05
	},
	{
		name = "grandmaster_flash",
		title = S("Grandmaster Flash"),
		color = 0x32CD32,
		growth_time = 70,
		potency = 0.8,
		effects = {"happiness", "focus"},
		yield_multiplier = 1.2
	},
	{
		name = "strawberry_cough",
		title = S("Strawberry Cough"),
		color = 0xFF6347,
		growth_time = 85,
		potency = 0.75,
		effects = {"creativity", "energy"},
		yield_multiplier = 1.15
	},
	{
		name = "critical_mass",
		title = S("Critical Mass"),
		color = 0x228B22,
		growth_time = 65,
		potency = 0.95,
		effects = {"relaxation", "pain_relief"},
		yield_multiplier = 1.25
	},
	
	-- Sativa strains (slower, uplifting)
	{
		name = "sour_diesel",
		title = S("Sour Diesel"),
		color = 0xFFD700,
		growth_time = 100,
		potency = 0.8,
		effects = {"energy", "focus"},
		yield_multiplier = 0.95
	},
	{
		name = "jack_herer",
		title = S("Jack Herer"),
		color = 0x90EE90,
		growth_time = 95,
		potency = 0.85,
		effects = {"creativity", "happiness"},
		yield_multiplier = 1.0
	},
	{
		name = "green_crack",
		title = S("Green Crack"),
		color = 0x32CD32,
		growth_time = 92,
		potency = 0.75,
		effects = {"energy", "focus"},
		yield_multiplier = 1.05
	},
	{
		name = "pineapple_express",
		title = S("Pineapple Express"),
		color = 0xFFB347,
		growth_time = 105,
		potency = 0.8,
		effects = {"energy", "creativity"},
		yield_multiplier = 1.1
	},
	{
		name = "durban_poison",
		title = S("Durban Poison"),
		color = 0x98FB98,
		growth_time = 98,
		potency = 0.7,
		effects = {"energy", "focus"},
		yield_multiplier = 1.15
	},
	
	-- Hybrid strains (balanced)
	{
		name = "og_kush",
		title = S("OG Kush"),
		color = 0x556B2F,
		growth_time = 85,
		potency = 0.9,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.2
	},
	{
		name = "blue_dream",
		title = S("Blue Dream"),
		color = 0x4169E1,
		growth_time = 90,
		potency = 0.8,
		effects = {"relaxation", "creativity"},
		yield_multiplier = 1.1
	},
	{
		name = "girl_scout_cookies",
		title = S("Girl Scout Cookies"),
		color = 0x8B4513,
		growth_time = 88,
		potency = 0.88,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.15
	},
	{
		name = "gorilla_glue",
		title = S("Gorilla Glue"),
		color = 0x696969,
		growth_time = 82,
		potency = 0.95,
		effects = {"relaxation", "sleep"},
		yield_multiplier = 1.2
	},
	{
		name = "white_widow",
		title = S("White Widow"),
		color = 0xF0F8FF,
		growth_time = 87,
		potency = 0.85,
		effects = {"relaxation", "focus"},
		yield_multiplier = 1.12
	},
	
	-- Specialty strains
	{
		name = "chemdawg",
		title = S("Chemdawg"),
		color = 0xDAA520,
		growth_time = 86,
		potency = 0.9,
		effects = {"energy", "focus"},
		yield_multiplier = 1.08
	},
	{
		name = "ak_47",
		title = S("AK-47"),
		color = 0x2F4F4F,
		growth_time = 79,
		potency = 0.82,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.18
	},
	{
		name = "amnesia_haze",
		title = S("Amnesia Haze"),
		color = 0xF5DEB3,
		growth_time = 108,
		potency = 0.78,
		effects = {"energy", "creativity"},
		yield_multiplier = 0.98
	},
	{
		name = "super_lemon_haze",
		title = S("Super Lemon Haze"),
		color = 0xFFFF00,
		growth_time = 102,
		potency = 0.76,
		effects = {"energy", "happiness"},
		yield_multiplier = 1.0
	},
	{
		name = "trainwreck",
		title = S("Trainwreck"),
		color = 0xCD853F,
		growth_time = 81,
		potency = 0.88,
		effects = {"energy", "focus"},
		yield_multiplier = 1.13
	},
	
	-- Additional strains
	{
		name = "skywalker_og",
		title = S("Skywalker OG"),
		color = 0x191970,
		growth_time = 84,
		potency = 0.92,
		effects = {"relaxation", "sleep"},
		yield_multiplier = 1.19
	},
	{
		name = "bruce_banner",
		title = S("Bruce Banner"),
		color = 0x006400,
		growth_time = 83,
		potency = 0.91,
		effects = {"relaxation", "energy"},
		yield_multiplier = 1.21
	},
	{
		name = "wedding_cake",
		title = S("Wedding Cake"),
		color = 0xE6E6FA,
		growth_time = 89,
		potency = 0.93,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.17
	},
	{
		name = "midnight_express",
		title = S("Midnight Express"),
		color = 0x2C2C2C,
		growth_time = 76,
		potency = 0.87,
		effects = {"relaxation", "sleep"},
		yield_multiplier = 1.16
	},
	{
		name = "cherry_pie",
		title = S("Cherry Pie"),
		color = 0xC71585,
		growth_time = 91,
		potency = 0.84,
		effects = {"relaxation", "happiness"},
		yield_multiplier = 1.09
	},
}

-- Store strain data for lookup
smokyleaf_industry.strains = {}
for _, strain in ipairs(weed_strains) do
	smokyleaf_industry.strains[strain.name] = strain
end

-- ============================================================================
-- Shared planting logic for all seed types.
-- Prefer the standard "soil" group so farmland and third-party soil nodes work
-- without depending on one specific game or node namespace.
local PLANTABLE_SOIL_NODES = {
	["default:dirt"] = true,
	["default:dirt_with_grass"] = true,
	["default:dirt_with_dry_grass"] = true,
	["default:farmland"] = true,
	["farming:soil"] = true,
	["farming:soil_wet"] = true,
	["mcl_core:dirt"] = true,
	["mcl_core:dirt_with_grass"] = true,
	["mcl_core:coarse_dirt"] = true,
	["mcl_core:podzol"] = true,
	["mcl_core:mycelium"] = true,
	["mcl_farming:soil"] = true,
	["mcl_farming:soil_wet"] = true,
	-- The grow pot is a dedicated planting surface, like the original Forge mod.
	["smokyleaf_industry:grow_pot"] = true,
}

local function is_plantable_surface(pos)
	local node = minetest.get_node(pos)
	return minetest.get_item_group(node.name, "soil") > 0
		or PLANTABLE_SOIL_NODES[node.name] == true
end

local function plant_seed(itemstack, user, pointed_thing, plant_node_name)
	if not pointed_thing or pointed_thing.type ~= "node" or not pointed_thing.under then
		return itemstack
	end

	local under_pos = pointed_thing.under
	local under_node = minetest.get_node(under_pos)
	local plant_pos

	-- Normal Luanti interaction: under is the soil block and above is the
	-- adjacent block where the plant belongs.
	if is_plantable_surface(under_pos) then
		plant_pos = pointed_thing.above or {
			x = under_pos.x,
			y = under_pos.y + 1,
			z = under_pos.z,
		}
	-- Also support callers that point directly at the air block above soil.
	elseif under_node.name == "air" and is_plantable_surface({
		x = under_pos.x,
		y = under_pos.y - 1,
		z = under_pos.z,
	}) then
		plant_pos = under_pos
	else
		if user then
			minetest.chat_send_player(user:get_player_name(),
				minetest.colorize("#FF0000", "Plant only on farmland, dirt, or a Grow Pot!"))
		end
		return itemstack
	end

	local target_node = minetest.get_node(plant_pos)
	if target_node.name ~= "air"
		and minetest.get_item_group(target_node.name, "buildable_to") == 0 then
		return itemstack
	end

	if user and minetest.is_protected then
		local player_name = user:get_player_name()
		if minetest.is_protected(plant_pos, player_name) then
			if minetest.record_protection_violation then
				minetest.record_protection_violation(plant_pos, player_name)
			end
			return itemstack
		end
	end

	minetest.set_node(plant_pos, {name = plant_node_name})
	minetest.sound_play("default_dig_snappy", {
		pos = plant_pos,
		max_hear_distance = 8,
		gain = 0.5,
	})
	itemstack:take_item()
	return itemstack
end

-- ITEM REGISTRATION
-- ============================================================================

-- Register weed buds for each strain
for _, strain in ipairs(weed_strains) do
	local seed_strain_name = strain.name
	minetest.register_craftitem("smokyleaf_industry:buds_" .. strain.name, {
		description = strain.title .. S(" Buds"),
		inventory_image = "smokyleaf_industry_buds.png",
		stack_max = 64,
		groups = {weed_bud = 1, flammable = 2},
	})

	-- Dried buds
	minetest.register_craftitem("smokyleaf_industry:dried_buds_" .. strain.name, {
		description = S("Dried ") .. strain.title .. S(" Buds"),
		inventory_image = "smokyleaf_industry_dried_buds.png",
		stack_max = 64,
		groups = {weed_bud = 1, flammable = 3},
	})

	-- Seeds
	minetest.register_craftitem("smokyleaf_industry:seeds_" .. strain.name, {
		description = strain.title .. S(" Seeds"),
		inventory_image = "smokyleaf_industry_seeds.png",
		stack_max = 64,
		groups = {seed = 1, flammable = 2},
		on_place = function(itemstack, user, pointed_thing)
			return plant_seed(itemstack, user, pointed_thing,
				"smokyleaf_industry:weed_" .. seed_strain_name .. "_1")
		end,
	})
end

-- Hemp items
minetest.register_craftitem("smokyleaf_industry:hemp_seeds", {
	description = S("Hemp Seeds"),
	inventory_image = "smokyleaf_industry_hemp_seeds.png",
	stack_max = 64,
	groups = {seed = 1, flammable = 2},
	on_place = function(itemstack, user, pointed_thing)
		return plant_seed(itemstack, user, pointed_thing, "smokyleaf_industry:hemp_1")
	end,
})

minetest.register_craftitem("smokyleaf_industry:hemp_fiber", {
	description = S("Hemp Fiber"),
	inventory_image = "smokyleaf_industry_hemp_fiber.png",
	stack_max = 64,
	groups = {flammable = 2},
})

minetest.register_craftitem("smokyleaf_industry:hemp_rope", {
	description = S("Hemp Rope"),
	inventory_image = "smokyleaf_industry_hemp_rope.png",
	stack_max = 64,
	groups = {flammable = 2},
})

-- Tobacco items
minetest.register_craftitem("smokyleaf_industry:tobacco_seeds", {
	description = S("Tobacco Seeds"),
	inventory_image = "smokyleaf_industry_tobacco_seeds.png",
	stack_max = 64,
	groups = {seed = 1, flammable = 2},
	on_place = function(itemstack, user, pointed_thing)
		return plant_seed(itemstack, user, pointed_thing, "smokyleaf_industry:tobacco_1")
	end,
})

minetest.register_craftitem("smokyleaf_industry:tobacco_leaves", {
	description = S("Tobacco Leaves"),
	inventory_image = "smokyleaf_industry_tobacco_leaves.png",
	stack_max = 64,
	groups = {flammable = 2},
})

-- The original mod dries tobacco leaves before their downstream use.
minetest.register_craftitem("smokyleaf_industry:dried_tobacco_leaves", {
	description = S("Dried Tobacco Leaves"),
	inventory_image = "smokyleaf_industry_dried_tobacco_leaves.png",
	stack_max = 64,
	groups = {flammable = 2, dried_material = 1},
})

-- Smoking items
minetest.register_craftitem("smokyleaf_industry:joint", {
	description = S("Joint"),
	inventory_image = "smokyleaf_industry_joint.png",
	stack_max = 64,
	groups = {flammable = 3, smoking_item = 1},
	on_use = function(itemstack, user, pointed_thing)
		minetest.sound_play("smokyleaf_industry_smoke", {
			pos = user:get_pos(),
			max_hear_distance = 16,
			gain = 0.5,
		})
		user:get_meta():set_int("smokeleaf_high_time", 300)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("smokyleaf_industry:blunt", {
	description = S("Blunt"),
	inventory_image = "smokyleaf_industry_blunt.png",
	stack_max = 64,
	groups = {flammable = 3, smoking_item = 1},
	on_use = function(itemstack, user, pointed_thing)
		minetest.sound_play("smokyleaf_industry_smoke", {
			pos = user:get_pos(),
			max_hear_distance = 16,
			gain = 0.5,
		})
		user:get_meta():set_int("smokeleaf_high_time", 400)
		itemstack:take_item()
		return itemstack
	end,
})

-- Crafting materials
minetest.register_craftitem("smokyleaf_industry:hemp_oil", {
	description = S("Hemp Oil"),
	inventory_image = "smokyleaf_industry_hemp_oil.png",
	stack_max = 64,
})

minetest.register_craftitem("smokyleaf_industry:hash", {
	description = S("Hash"),
	inventory_image = "smokyleaf_industry_hash.png",
	stack_max = 64,
	groups = {flammable = 3},
})

minetest.register_craftitem("smokyleaf_industry:glass_bong", {
	description = S("Glass Bong"),
	inventory_image = "smokyleaf_industry_glass_bong.png",
	stack_max = 1,
})

minetest.register_craftitem("smokyleaf_industry:grinder", {
	description = S("Grinder"),
	inventory_image = "smokyleaf_industry_grinder.png",
	stack_max = 1,
})

-- ============================================================================
-- NODE REGISTRATION - WEED PLANTS
-- ============================================================================

-- Register weed plants for each strain (8 growth stages)
for _, strain in ipairs(weed_strains) do
	for stage = 1, PLANT_GROWTH_STAGES do
		local nodename = "smokyleaf_industry:weed_" .. strain.name .. "_" .. stage
		local next_stage = stage < PLANT_GROWTH_STAGES and stage + 1 or stage

		minetest.register_node(nodename, {
			description = strain.title .. S(" (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
			drawtype = "plantlike",
			tiles = {"smokyleaf_industry_weed_" .. stage .. ".png"},
			inventory_image = "smokyleaf_industry_weed_" .. stage .. ".png",
			paramtype = "light",
			paramtype2 = "meshoptions",
			place_param2 = 0,
			sunlight_propagates = true,
			walkable = false,
			buildable_to = true,
			floodable = true,
			waving = 1,
			damage_per_second = 0,
			drop = {
				max_items = 1,
				items = {
					{items = {"smokyleaf_industry:seeds_" .. strain.name}, rarity = 2},
					{items = {}, rarity = 2},
				}
			},
			groups = {snappy = 3, flammable = 2, plant = 1, weed = 1, attached_node = 1},
			sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
		})
	end
end

-- ============================================================================
-- NODE REGISTRATION - HEMP PLANTS
-- ============================================================================

for stage = 1, PLANT_GROWTH_STAGES do
	minetest.register_node("smokyleaf_industry:hemp_" .. stage, {
		description = S("Hemp Plant (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
		drawtype = "plantlike",
		tiles = {"smokyleaf_industry_hemp_" .. stage .. ".png"},
		inventory_image = "smokyleaf_industry_hemp_stage.png",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 0,
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		floodable = true,
		waving = 1,
		damage_per_second = 0,
		drop = {
			max_items = 1,
			items = {
				{items = {"smokyleaf_industry:hemp_seeds"}, rarity = 2},
				{items = {}, rarity = 2},
			}
		},
		groups = {snappy = 3, flammable = 2, plant = 1, hemp = 1, attached_node = 1},
		sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
	})
end

-- ============================================================================
-- NODE REGISTRATION - TOBACCO PLANTS
-- ============================================================================

for stage = 1, PLANT_GROWTH_STAGES do
	minetest.register_node("smokyleaf_industry:tobacco_" .. stage, {
		description = S("Tobacco Plant (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
		drawtype = "plantlike",
		tiles = {"smokyleaf_industry_tobacco_" .. stage .. ".png"},
		inventory_image = "smokyleaf_industry_tobacco_stage.png",
		paramtype = "light",
		paramtype2 = "meshoptions",
		place_param2 = 0,
		sunlight_propagates = true,
		walkable = false,
		buildable_to = true,
		floodable = true,
		waving = 1,
		damage_per_second = 0,
		drop = {
			max_items = 1,
			items = {
				{items = {"smokyleaf_industry:tobacco_seeds"}, rarity = 2},
				{items = {}, rarity = 2},
			}
		},
		groups = {snappy = 3, flammable = 2, plant = 1, tobacco = 1, attached_node = 1},
		sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
	})
end

-- ============================================================================
-- BLOCK REGISTRATION - INFRASTRUCTURE
-- ============================================================================

-- Grow pot (plantable surface, matching the requested Luanti interaction).
minetest.register_node("smokyleaf_industry:grow_pot", {
	description = S("Grow Pot"),
	tiles = {
		"smokyleaf_industry_grow_pot_top.png",
		"smokyleaf_industry_grow_pot_bottom.png",
		"smokyleaf_industry_grow_pot_side.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 1, soil = 1},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- Shared GUI helpers. Explicit slot backplates keep empty inventory slots visible
-- in themes where the default empty-list background is transparent.
local function append_slot_backgrounds(parts, x, y, columns, rows)
	for row = 0, rows - 1 do
		for column = 0, columns - 1 do
			-- Inventory list cells are spaced 1.25 formspec units apart.
			local sx = x + column * 1.25
			local sy = y + row * 1.25
			parts[#parts + 1] = string.format("box[%.2f,%.2f;0.92,0.92;#080E15]", sx, sy)
			parts[#parts + 1] = string.format("box[%.2f,%.2f;0.84,0.84;#253444]", sx + 0.04, sy + 0.04)
		end
	end
end

local function player_can_modify_node(pos, player)
	if not player or type(player.is_player) ~= "function" or not player:is_player() then
		return false
	end
	local player_name = player:get_player_name()
	if minetest.is_protected and minetest.is_protected(pos, player_name) then
		if minetest.record_protection_violation then
			minetest.record_protection_violation(pos, player_name)
		end
		return false
	end
	return true
end

-- Grow lights have explicit ON/OFF states, like the original Forge block's CLICKED property.
-- The ON states are hidden from the creative inventory and always drop the OFF item.
local function grow_light_formspec_infotext(pos, active, label)
	minetest.get_meta(pos):set_string("infotext", label .. (active and " (On)" or " (Off)"))
end

local function register_grow_light(kind, label, texture_prefix, light_level)
	local off_name = "smokyleaf_industry:grow_light_" .. kind
	local on_name = off_name .. "_active"
	local legacy_on_name = off_name .. "_on"
	local side_texture = "smokyleaf_industry_" .. texture_prefix .. "_side.png"
	local off_texture = "smokyleaf_industry_" .. texture_prefix .. "_off.png"
	local on_texture = "smokyleaf_industry_" .. texture_prefix .. "_on.png"
	local usage = kind == "hps" and 16 or 8
	local capacity = 256

	local function active_node(pos)
		return minetest.get_node(pos).name == on_name
	end

	local function set_state(pos, active)
		local node = minetest.get_node(pos)
		local desired = active and on_name or off_name
		if node.name == desired then return end
		local changed = {name = desired, param2 = node.param2 or 0}
		if ELEPOWER_AVAILABLE and type(ele.helpers.swap_node) == "function" then
			ele.helpers.swap_node(pos, changed)
		else
			minetest.swap_node(pos, changed)
		end
	end

	local function set_infotext(pos)
		local meta = minetest.get_meta(pos)
		if not ELEPOWER_AVAILABLE then
			meta:set_string("infotext", label .. (active_node(pos) and " (On)" or " (Off)"))
			return
		end
		local enabled = meta:get_int("enabled") == 1
		local need = ele_node_property(meta, pos, "usage", usage)
		local powered = meta:get_int("storage") >= need
		local state
		if not enabled then state = "Off" elseif powered then state = "Active" else state = "Out of Power!" end
		meta:set_string("infotext", label .. " (" .. state .. ")\n" .. ele_power_label(pos, tostring(need) .. " EU/s"))
	end

	local function power_timer(pos)
		if not ELEPOWER_AVAILABLE then return false end
		local meta = minetest.get_meta(pos)
		local enabled = meta:get_int("enabled") == 1
		if not enabled then
			set_state(pos, false)
			set_infotext(pos)
			return false
		end
		local need = ele_node_property(meta, pos, "usage", usage)
		local storage = meta:get_int("storage")
		local powered = storage >= need
		if powered then meta:set_int("storage", storage - need) end
		set_state(pos, powered)
		set_infotext(pos)
		return true
	end

	local function toggle(pos, node, clicker, itemstack)
		if not player_can_modify_node(pos, clicker) then return itemstack end
		if ELEPOWER_AVAILABLE then
			local meta = minetest.get_meta(pos)
			local enabled = meta:get_int("enabled") ~= 1
			meta:set_int("enabled", enabled and 1 or 0)
			local timer = minetest.get_node_timer(pos)
			if not timer:is_started() then timer:start(1) end
			local need = ele_node_property(meta, pos, "usage", usage)
			set_state(pos, enabled and meta:get_int("storage") >= need)
			set_infotext(pos)
			if enabled and meta:get_int("storage") < need then
				minetest.chat_send_player(clicker:get_player_name(), S("This grow light needs Elepower energy. Connect an Elepower generator with power conduits."))
			end
		else
			set_state(pos, not active_node(pos))
			set_infotext(pos)
		end
		minetest.sound_play("default_place_node", {pos = pos, gain = 0.25, max_hear_distance = 8}, true)
		return itemstack
	end

	local function base_def()
		return {
			description = label .. S(" (Right-click to toggle)"),
			drawtype = "nodebox",
			node_box = {type = "fixed", fixed = {-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}},
			selection_box = {type = "fixed", fixed = {-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}},
			collision_box = {type = "fixed", fixed = {-0.5, 0.375, -0.5, 0.5, 0.5, 0.5}},
			paramtype = "light",
			paramtype2 = "facedir",
			sunlight_propagates = true,
			walkable = false,
			light_source = 0,
			tiles = {side_texture, off_texture, side_texture, side_texture, side_texture, side_texture},
			inventory_image = off_texture,
			wield_image = off_texture,
			groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
			drop = off_name,
			sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
			on_place = function(itemstack, placer, pointed_thing)
				if not pointed_thing or pointed_thing.type ~= "node" or not pointed_thing.under or not pointed_thing.above then return itemstack end
				local under_node = minetest.get_node(pointed_thing.under)
				local under_def = minetest.registered_nodes[under_node.name]
				local target_pos = (under_def and under_def.buildable_to) and pointed_thing.under or pointed_thing.above
				local support_pos = {x = target_pos.x, y = target_pos.y + 1, z = target_pos.z}
				local support_node = minetest.get_node(support_pos)
				local support_def = minetest.registered_nodes[support_node.name]
				if not support_def or support_node.name == "air" or support_def.walkable == false then
					if placer and type(placer.is_player) == "function" and placer:is_player() then
						minetest.chat_send_player(placer:get_player_name(), S("Grow lights must be mounted directly beneath a solid block."))
					end
					return itemstack
				end
				return minetest.item_place_node(itemstack, placer, pointed_thing)
			end,
			after_place_node = function(pos)
				local meta = minetest.get_meta(pos)
				meta:set_int("enabled", 0)
				set_infotext(pos)
				if ELEPOWER_AVAILABLE then minetest.get_node_timer(pos):start(1) end
			end,
			on_construct = function(pos)
				local meta = minetest.get_meta(pos)
				if meta:get_int("enabled") ~= 1 then meta:set_int("enabled", 0) end
				set_infotext(pos)
				if ELEPOWER_AVAILABLE then minetest.get_node_timer(pos):start(1) end
			end,
			on_rightclick = toggle,
			on_timer = power_timer,
		}
	end

	if ELEPOWER_AVAILABLE then
		local def = base_def()
		def.groups.ele_user = 1
		def.ele_capacity = capacity
		def.ele_inrush = 32
		def.ele_usage = usage
		def.ele_active_node = true
		def.ele_no_automatic_ports = true
		def.ele_active_nodedef = {
			description = label .. S(" (Powered On)"),
			tiles = {side_texture, on_texture, side_texture, side_texture, side_texture, side_texture},
			light_source = light_level,
		}
		ele.register_machine(off_name, def)
	else
		minetest.register_node(off_name, base_def())
		local on_def = base_def()
		on_def.description = label .. S(" (On)")
		on_def.tiles = {side_texture, side_texture, side_texture, side_texture, on_texture, side_texture}
		on_def.light_source = light_level
		on_def.groups.not_in_creative_inventory = 1
		minetest.register_node(on_name, on_def)
	end

	-- v1.0.4 used the custom `_on` name. Preserve existing worlds by
	-- transparently remapping saved nodes to the correctly registered variant.
	if legacy_on_name ~= on_name and minetest.register_alias then
		minetest.register_alias(legacy_on_name, on_name)
	end
end

register_grow_light("led", S("LED Grow Light"), "led_light", 12)
register_grow_light("hps", S("HPS Grow Light"), "hps_light", 14)

-- The original GrowLightBlockEntity checks a 3x3 area up to five blocks below the
-- light every 100 ticks. This native ABM reproduces that behavior by accelerating
-- two randomly selected crops per cycle with a lower per-attempt chance.
local function next_crop_stage(name)
	local strain, stage = name:match("^smokyleaf_industry:weed_(.+)_(%d+)$")
	if strain then
		stage = tonumber(stage)
		if stage and stage < PLANT_GROWTH_STAGES then
			return "smokyleaf_industry:weed_" .. strain .. "_" .. (stage + 1)
		end
		return nil
	end
	local crop_kind, crop_stage = name:match("^smokyleaf_industry:(hemp)_(%d+)$")
	if not crop_kind then crop_kind, crop_stage = name:match("^smokyleaf_industry:(tobacco)_(%d+)$") end
	if crop_kind then
		crop_stage = tonumber(crop_stage)
		if crop_stage and crop_stage < PLANT_GROWTH_STAGES then
			return "smokyleaf_industry:" .. crop_kind .. "_" .. (crop_stage + 1)
		end
	end
	return nil
end

local function grow_light_line_clear(light_pos, crop_pos)
	for y = light_pos.y - 1, crop_pos.y + 1, -1 do
		local mid = {x = crop_pos.x, y = y, z = crop_pos.z}
		if y > crop_pos.y then
			local node = minetest.get_node(mid)
			local def = minetest.registered_nodes[node.name]
			if def and def.walkable ~= false then return false end
		end
	end
	return true
end

minetest.register_abm({
	label = "Smokeleaf grow light acceleration",
	nodenames = {
		"smokyleaf_industry:grow_light_led_on",
		"smokyleaf_industry:grow_light_hps_on",
	},
	interval = 5,
	chance = 1,
	action = function(pos)
		local candidates = {}
		for dx = -1, 1 do
			for dz = -1, 1 do
				for depth = 1, 5 do
					local crop_pos = {x = pos.x + dx, y = pos.y - depth, z = pos.z + dz}
					local crop_node = minetest.get_node(crop_pos)
					if next_crop_stage(crop_node.name) and grow_light_line_clear(pos, crop_pos) then
						candidates[#candidates + 1] = {pos = crop_pos, node = crop_node}
					end
				end
			end
		end
		local attempts = math.min(2, #candidates)
		for _ = 1, attempts do
			local index = math.random(1, #candidates)
			local candidate = table.remove(candidates, index)
			-- Two attempts per cycle, matching the original light's growth tick loop.
			if math.random(1, 3) == 1 then
				local new_name = next_crop_stage(candidate.node.name)
				if new_name then
					minetest.set_node(candidate.pos, {name = new_name, param2 = candidate.node.param2 or 0})
				end
			end
		end
	end,
})

-- Drying Rack inventory. Unlike the machine screens in Forge, the original rack is
-- a twelve-position drying surface with items inserted and retrieved directly. This
-- Luanti port provides a clearly visible 4x3 rack GUI while retaining automatic drying.
local DRYING_RACK_SLOTS = 12
local DRYING_BUD_SECONDS = 60       -- original generic bud dryingTime: 1200 ticks
local DRYING_TOBACCO_SECONDS = 15   -- original tobacco-leaf recipe: 300 ticks

local function drying_rack_formspec()
	local parts = {
		"formspec_version[4]", "size[10.8,10.35]", "no_prepend[]",
		"bgcolor[#101720;both;#0B1017]",
		"box[0,0;10.8,10.35;#101720]",
		"box[0.25,0.25;10.3,0.75;#26384A]",
		"style_type[label;textcolor=#E6EEF7]",
		"listcolors[#0D1722;#26384A;#7089A0]",
		"label[0.55,0.48;SMOKELEAF INDUSTRIES  /  DRYING RACK]",
		"box[0.25,1.15;5.35,4.15;#1A2735]",
		"label[0.55,1.4;DRYING POSITIONS  (12)]",
	}
	append_slot_backgrounds(parts, 0.75, 1.65, 4, 3)
	parts[#parts + 1] = "list[context;rack;0.75,1.65;4,3;]"
	parts[#parts + 1] = "box[5.8,1.15;4.45,4.15;#1A2735]"
	parts[#parts + 1] = "label[6.1,1.45;DRYING STATUS]"
	parts[#parts + 1] = "label[6.1,1.95;Fresh buds: about 60 seconds]"
	parts[#parts + 1] = "label[6.1,2.35;Tobacco leaves: about 15 seconds]"
	parts[#parts + 1] = "label[6.1,2.9;Insert fresh buds or tobacco leaves]"
	parts[#parts + 1] = "label[6.1,3.25;into an empty rack slot.]"
	parts[#parts + 1] = "label[6.1,3.7;Take dried items from their slots.]"
	parts[#parts + 1] = "label[0.55,5.25;PLAYER INVENTORY]"
	append_slot_backgrounds(parts, 0.75, 5.55, 8, 4)
	parts[#parts + 1] = "list[current_player;main;0.75,5.55;8,4;]"
	parts[#parts + 1] = "listring[context;rack]"
	parts[#parts + 1] = "listring[current_player;main]"
	return table.concat(parts, "\n")
end

local DRYING_RACK_FORMSPEC = drying_rack_formspec()

local function drying_rack_is_valid(stack)
	if not stack or stack:is_empty() then return false end
	local name = stack:get_name()
	if name:match("^smokyleaf_industry:buds_.+$") then return true end
	return name == "smokyleaf_industry:tobacco_leaves"
end

local function initialize_drying_rack(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:get_size("rack") ~= DRYING_RACK_SLOTS then
		inv:set_size("rack", DRYING_RACK_SLOTS)
	end
	meta:set_string("formspec", DRYING_RACK_FORMSPEC)
	meta:set_string("infotext", S("Drying Rack"))
	local timer = minetest.get_node_timer(pos)
	if timer and not timer:is_started() then timer:start(1) end
end

local function drying_rack_occupied(inv)
	local count = 0
	for i = 1, inv:get_size("rack") do
		if not inv:get_stack("rack", i):is_empty() then count = count + 1 end
	end
	return count
end

local function drying_rack_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local seconds = math.max(1, math.floor((elapsed or 1) + 0.5))
	local has_fresh_items = false
	local changed = false

	for i = 1, inv:get_size("rack") do
		local stack = inv:get_stack("rack", i)
		local name = stack:get_name()
		local strain = name:match("^smokyleaf_industry:buds_(.+)$")
		local limit
		local output_name
		if strain then
			limit = DRYING_BUD_SECONDS
			output_name = "smokyleaf_industry:dried_buds_" .. strain
		elseif name == "smokyleaf_industry:tobacco_leaves" then
			limit = DRYING_TOBACCO_SECONDS
			output_name = "smokyleaf_industry:dried_tobacco_leaves"
		end

		if limit and output_name then
			has_fresh_items = true
			local key = "rack_dry_progress_" .. i
			local progress = meta:get_int(key) + seconds
			if progress >= limit then
				inv:set_stack("rack", i, ItemStack(output_name .. " " .. stack:get_count()))
				meta:set_int(key, 0)
				changed = true
			else
				meta:set_int(key, progress)
			end
		else
			if meta:get_int("rack_dry_progress_" .. i) ~= 0 then
				meta:set_int("rack_dry_progress_" .. i, 0)
			end
		end
	end

	local occupied = drying_rack_occupied(inv)
	meta:set_string("infotext", S("Drying Rack") .. " (" .. occupied .. "/" .. DRYING_RACK_SLOTS .. ")")
	return has_fresh_items
end

minetest.register_node("smokyleaf_industry:drying_rack", {
	description = S("Drying Rack"),
	tiles = {
		"smokyleaf_industry_drying_rack_top.png",
		"smokyleaf_industry_drying_rack_bottom.png",
		"smokyleaf_industry_drying_rack_side.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 1},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
	on_construct = initialize_drying_rack,
	on_timer = drying_rack_timer,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname ~= "rack" or not player_can_modify_node(pos, player) then return 0 end
		local inv = minetest.get_meta(pos):get_inventory()
		if not inv:get_stack("rack", index):is_empty() or not drying_rack_is_valid(stack) then return 0 end
		return math.min(1, stack:get_count())
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if not player_can_modify_node(pos, player) then return 0 end
		local inv = minetest.get_meta(pos):get_inventory()
		if to_list == "rack" then
			if from_list ~= "main" or not inv:get_stack("rack", to_index):is_empty() then return 0 end
			local source = inv:get_stack(from_list, from_index)
			if not drying_rack_is_valid(source) then return 0 end
			return math.min(1, count)
		end
		if from_list == "rack" and to_list == "main" then return count end
		return 0
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if listname ~= "rack" or not player_can_modify_node(pos, player) then return 0 end
		return stack:get_count()
	end,
	on_metadata_inventory_put = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_move = function(pos)
		minetest.get_node_timer(pos):start(1)
	end,
	on_metadata_inventory_take = function(pos, listname, index)
		minetest.get_meta(pos):set_int("rack_dry_progress_" .. index, 0)
		minetest.get_node_timer(pos):start(1)
	end,
	on_destruct = function(pos)
		local inv = minetest.get_meta(pos):get_inventory()
		for i = 1, inv:get_size("rack") do
			local stack = inv:get_stack("rack", i)
			if not stack:is_empty() then minetest.add_item(pos, stack) end
		end
	end,
})

-- Restore drying-rack inventories/formspecs on blocks saved by earlier releases.
minetest.register_lbm({
	label = "Initialize Smokeleaf Drying Rack GUI v1.0.4",
	name = "smokyleaf_industry:initialize_drying_rack_v104",
	nodenames = {"smokyleaf_industry:drying_rack"},
	run_at_every_load = false,
	action = function(pos) initialize_drying_rack(pos) end,
})

-- Processing Machine GUI. This keeps the existing recipes but uses real lists with
-- visible slots, inventory cycling, and a high-contrast custom layout.
local function processing_machine_formspec(pos)
	local power_line
	if ELEPOWER_AVAILABLE and pos then
		power_line = ele_power_label(pos, "64 EU per successful process")
	else
		power_line = "Power is optional unless Elepower is installed"
	end
	local parts = {
		"formspec_version[4]", "size[12,10.55]", "no_prepend[]",
		"bgcolor[#101720;both;#0B1017]",
		"box[0,0;12,10.55;#101720]",
		"style_type[label;textcolor=#E6EEF7]",
		"listcolors[#0D1722;#26384A;#7089A0]",
		"style[process;bgcolor=#B43A50;border=false;textcolor=#FFFFFF]",
		"box[0.25,0.25;11.5,0.75;#26384A]",
		"label[0.55,0.48;SMOKELEAF INDUSTRIES  /  PROCESSING MACHINE]",
		"box[0.25,1.2;4.15,4.05;#1A2735]",
		"label[0.55,1.45;INPUT MATERIALS  (3 x 3)]",
	}
	append_slot_backgrounds(parts, 0.65, 1.85, 3, 3)
	parts[#parts + 1] = "list[context;src;0.65,1.85;3,3;]"
	parts[#parts + 1] = "box[4.55,1.2;2.65,4.05;#1A2735]"
	parts[#parts + 1] = "label[4.85,1.45;PROCESS]"
	parts[#parts + 1] = "button[4.9,2.0;1.9,0.8;process;PROCESS]"
	parts[#parts + 1] = "label[4.8,3.0;Fresh buds -> dried]"
	parts[#parts + 1] = "label[4.8,3.35;9 matching buds -> hash]"
	parts[#parts + 1] = "label[4.8,3.7;3 hemp fiber -> rope]"
	parts[#parts + 1] = "label[4.8,4.05;Joint / blunt patterns]"
	parts[#parts + 1] = "box[7.35,1.2;4.4,4.05;#1A2735]"
	parts[#parts + 1] = "label[7.65,1.45;OUTPUT  (2 x 2)]"
	append_slot_backgrounds(parts, 8.0, 1.95, 2, 2)
	parts[#parts + 1] = "list[context;dst;8.0,1.95;2,2;]"
	parts[#parts + 1] = "label[7.65,4.75;" .. minetest.formspec_escape(power_line) .. "]"
	parts[#parts + 1] = "label[0.55,5.45;PLAYER INVENTORY]"
	append_slot_backgrounds(parts, 0.75, 5.75, 8, 4)
	parts[#parts + 1] = "list[current_player;main;0.75,5.75;8,4;]"
	parts[#parts + 1] = "listring[context;src]"
	parts[#parts + 1] = "listring[current_player;main]"
	parts[#parts + 1] = "listring[context;dst]"
	parts[#parts + 1] = "listring[current_player;main]"
	return table.concat(parts, "\n")
end

local function machine_count(inv, item_name)
	local total = 0
	for i = 1, inv:get_size("src") do
		local stack = inv:get_stack("src", i)
		if stack:get_name() == item_name then total = total + stack:get_count() end
	end
	return total
end

local function machine_has_items(inv, requirements)
	for item_name, needed in pairs(requirements) do
		if machine_count(inv, item_name) < needed then return false end
	end
	return true
end

local function machine_consume_items(inv, requirements)
	for item_name, needed in pairs(requirements) do
		local remaining = needed
		for i = 1, inv:get_size("src") do
			if remaining <= 0 then break end
			local stack = inv:get_stack("src", i)
			if stack:get_name() == item_name then
				local taken = math.min(stack:get_count(), remaining)
				stack:take_item(taken)
				inv:set_stack("src", i, stack)
				remaining = remaining - taken
			end
		end
	end
end

local function machine_try_recipe(inv, requirements, output_name, output_count, output_pos)
	if not machine_has_items(inv, requirements) then return false end
	local output = ItemStack(output_name .. " " .. output_count)
	if not inv:room_for_item("dst", output) then return false, "output_full" end
	machine_consume_items(inv, requirements)
	local leftover = inv:add_item("dst", output)
	if not leftover:is_empty() then minetest.add_item(output_pos, leftover) end
	return true
end

local function machine_try_pattern(inv, pattern, expected_count, output_name, output_pos)
	local occupied = 0
	for slot = 1, 9 do
		if not inv:get_stack("src", slot):is_empty() then occupied = occupied + 1 end
	end
	if occupied ~= expected_count then return false end

	for slot, kind in pairs(pattern) do
		local name = inv:get_stack("src", slot):get_name()
		if kind == "paper" and name ~= "default:paper" then return false end
		if kind == "tobacco" and name ~= "smokyleaf_industry:tobacco" then return false end
		if kind == "bud" and not name:match("^smokyleaf_industry:buds_.+$") then return false end
	end

	local output = ItemStack(output_name)
	if not inv:room_for_item("dst", output) then return false, "output_full" end
	for slot in pairs(pattern) do
		local stack = inv:get_stack("src", slot)
		stack:take_item(1)
		inv:set_stack("src", slot, stack)
	end
	local leftover = inv:add_item("dst", output)
	if not leftover:is_empty() then minetest.add_item(output_pos, leftover) end
	return true
end

local function processing_machine_process(pos, player)
	local inv = minetest.get_meta(pos):get_inventory()

	-- Original Forge joint layout: paper at slots 2 and 8, buds at 4 and 6,
	-- and tobacco at slot 5. These are the 3x3 source-grid indices.
	local ok, reason = machine_try_pattern(inv, {
		[2] = "paper", [4] = "bud", [5] = "tobacco", [6] = "bud", [8] = "paper",
	}, 5, "smokyleaf_industry:joint", pos)
	if ok then return true end
	if reason == "output_full" then return false, reason end

	-- Original Forge blunt layout: paper in the top and bottom rows, three buds in the middle.
	ok, reason = machine_try_pattern(inv, {
		[1] = "paper", [2] = "paper", [3] = "paper", [4] = "bud", [5] = "bud",
		[6] = "bud", [7] = "paper", [8] = "paper", [9] = "paper",
	}, 9, "smokyleaf_industry:blunt", pos)
	if ok then return true end
	if reason == "output_full" then return false, reason end

	-- Hash uses nine buds of one matching strain.
	local seen_buds = {}
	for i = 1, inv:get_size("src") do
		local name = inv:get_stack("src", i):get_name()
		if name:match("^smokyleaf_industry:buds_.+$") then seen_buds[name] = true end
	end
	for name in pairs(seen_buds) do
		local ok, reason = machine_try_recipe(inv, {[name] = 9}, "smokyleaf_industry:hash", 1, pos)
		if ok then return true end
		if reason == "output_full" then return false, reason end
	end

	-- Joint: dried buds + paper.
	for i = 1, inv:get_size("src") do
		local name = inv:get_stack("src", i):get_name()
		if name:match("^smokyleaf_industry:dried_buds_.+$") then
			local ok, reason = machine_try_recipe(inv, {[name] = 1, ["default:paper"] = 1}, "smokyleaf_industry:joint", 1, pos)
			if ok then return true end
			if reason == "output_full" then return false, reason end
		end
	end

	-- Blunt: dried buds + dried tobacco leaves (matching the Forge drying chain).
	for i = 1, inv:get_size("src") do
		local name = inv:get_stack("src", i):get_name()
		if name:match("^smokyleaf_industry:dried_buds_.+$") then
			local ok, reason = machine_try_recipe(inv, {[name] = 1, ["smokyleaf_industry:dried_tobacco_leaves"] = 1}, "smokyleaf_industry:blunt", 1, pos)
			if ok then return true end
			if reason == "output_full" then return false, reason end
		end
	end

	local ok, reason = machine_try_recipe(inv, { ["smokyleaf_industry:hemp_fiber"] = 3 }, "smokyleaf_industry:hemp_rope", 1, pos)
	if ok then return true end
	if reason == "output_full" then return false, reason end

	-- Dry one fresh bud into the same strain's dried-bud item.
	for i = 1, inv:get_size("src") do
		local name = inv:get_stack("src", i):get_name()
		local strain = name:match("^smokyleaf_industry:buds_(.+)$")
		if strain then
			local ok, dry_reason = machine_try_recipe(inv, {[name] = 1}, "smokyleaf_industry:dried_buds_" .. strain, 1, pos)
			if ok then return true end
			if dry_reason == "output_full" then return false, dry_reason end
		end
	end

	-- Mature hemp block item -> hemp fiber (when the game makes that block collectible).
	ok, reason = machine_try_recipe(inv, { ["smokyleaf_industry:hemp_8"] = 1 }, "smokyleaf_industry:hemp_fiber", 3, pos)
	if ok then return true end
	if reason == "output_full" then return false, reason end
	return false, "no_recipe"
end

local function processing_machine_access_denied(pos, player)
	return not player_can_modify_node(pos, player)
end

local function processing_machine_update_status(pos)
	local meta = minetest.get_meta(pos)
	if not ELEPOWER_AVAILABLE then
		meta:set_string("infotext", S("Processing Machine"))
		return
	end
	local usage = ele_node_property(meta, pos, "usage", 64)
	local demanding = meta:get_int("power_demand") == 1
	local state = "Idle"
	if demanding and meta:get_int("storage") < usage then
		state = "Out of Power!"
	elseif demanding then
		state = "Active"
	end
	meta:set_string("infotext", S("Processing Machine") .. " (" .. state .. ")\n" .. ele_power_label(pos, tostring(usage) .. " EU/process"))
end

local function initialize_processing_machine(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	if inv:get_size("src") ~= 9 then inv:set_size("src", 9) end
	if inv:get_size("dst") ~= 4 then inv:set_size("dst", 4) end
	meta:set_string("formspec", processing_machine_formspec(pos))
	processing_machine_update_status(pos)
	if ELEPOWER_AVAILABLE then
		local timer = minetest.get_node_timer(pos)
		if not timer:is_started() then timer:start(1) end
	end
end

local function processing_machine_timer(pos)
	local meta = minetest.get_meta(pos)
	local usage = ele_node_property(meta, pos, "usage", 64)
	if meta:get_int("power_demand") == 1 and meta:get_int("storage") >= usage then
		meta:set_int("power_demand", 0)
	end
	meta:set_string("formspec", processing_machine_formspec(pos))
	processing_machine_update_status(pos)
	return ELEPOWER_AVAILABLE and meta:get_int("power_demand") == 1
end

local processing_machine_def = {
	description = S("Processing Machine"),
	tiles = {
		"smokyleaf_industry_machine_top.png",
		"smokyleaf_industry_machine_bottom.png",
		"smokyleaf_industry_machine_side.png",
		"smokyleaf_industry_machine_side.png",
		"smokyleaf_industry_machine_front.png",
		"smokyleaf_industry_machine_back.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
	on_construct = initialize_processing_machine,
	can_dig = function(pos, player)
		if not player_can_modify_node(pos, player) then return false end
		local inv = minetest.get_meta(pos):get_inventory()
		return inv:is_empty("src") and inv:is_empty("dst")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname ~= "src" or processing_machine_access_denied(pos, player) then return 0 end
		return stack:get_count()
	end,
	allow_metadata_inventory_move = function(pos, from_list, from_index, to_list, to_index, count, player)
		if to_list ~= "src" or from_list == "dst" or processing_machine_access_denied(pos, player) then return 0 end
		return count
	end,
	allow_metadata_inventory_take = function(pos, listname, index, stack, player)
		if processing_machine_access_denied(pos, player) then return 0 end
		return stack:get_count()
	end,
	on_receive_fields = function(pos, formname, fields, sender)
		if not fields.process or processing_machine_access_denied(pos, sender) then return end
		local player_name = sender:get_player_name()
		local meta = minetest.get_meta(pos)
		local usage = ele_node_property(meta, pos, "usage", 64)
		if ELEPOWER_AVAILABLE then meta:set_int("power_demand", 1) end
		if ELEPOWER_AVAILABLE and meta:get_int("storage") < usage then
			processing_machine_update_status(pos)
			meta:set_string("formspec", processing_machine_formspec(pos))
			if ele.helpers and ele.helpers.start_timer then ele.helpers.start_timer(pos) end
			minetest.chat_send_player(player_name, minetest.colorize("#FFB347", S("Out of power. Connect this machine to an Elepower generator using power conduits, then try again.")))
			return
		end
		local ok, reason = processing_machine_process(pos, sender)
		if ok then
			if ELEPOWER_AVAILABLE then ele_use_energy(pos, usage) end
			minetest.chat_send_player(player_name, minetest.colorize("#65D98A", S("Processing complete.")))
		elseif reason == "output_full" then
			minetest.chat_send_player(player_name, minetest.colorize("#FFB347", S("The output inventory is full.")))
		else
			minetest.chat_send_player(player_name, minetest.colorize("#FFB347", S("No matching recipe. Check the input items.")))
		end
		if ELEPOWER_AVAILABLE then meta:set_int("power_demand", 0) end
		meta:set_string("formspec", processing_machine_formspec(pos))
		processing_machine_update_status(pos)
	end,
	on_timer = processing_machine_timer,
}

if ELEPOWER_AVAILABLE then
	processing_machine_def.groups.ele_user = 1
	processing_machine_def.ele_capacity = 1600
	processing_machine_def.ele_inrush = 64
	processing_machine_def.ele_usage = 64
	ele.register_machine("smokyleaf_industry:processing_machine", processing_machine_def)
else
	minetest.register_node("smokyleaf_industry:processing_machine", processing_machine_def)
end

-- v1.0.4 marker: forces already placed machines to receive the repaired formspec.
minetest.register_lbm({
	label = "Initialize Smokeleaf Processing Machine GUI v1.0.4",
	name = "smokyleaf_industry:initialize_processing_machine_gui_v104",
	nodenames = {"smokyleaf_industry:processing_machine"},
	run_at_every_load = false,
	action = function(pos) initialize_processing_machine(pos) end,
})

-- ============================================================================
-- CRAFTING RECIPES
-- ============================================================================

-- Hemp fiber from hemp (drying process)
for stage = 1, PLANT_GROWTH_STAGES do
	if stage == PLANT_GROWTH_STAGES then
		minetest.register_craft({
			output = "smokyleaf_industry:hemp_fiber 3",
			recipe = {
				{"smokyleaf_industry:hemp_" .. stage}
			}
		})
	end
end

-- Hemp rope from hemp fiber
minetest.register_craft({
	output = "smokyleaf_industry:hemp_rope 1",
	recipe = {
		{"smokyleaf_industry:hemp_fiber", "smokyleaf_industry:hemp_fiber", "smokyleaf_industry:hemp_fiber"},
	}
})

-- Joint crafting (weed buds + rolling paper)
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokyleaf_industry:joint",
		recipe = {
			{"smokyleaf_industry:dried_buds_" .. strain.name, "default:paper"},
		}
	})
end

-- Blunt crafting (weed buds + tobacco)
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokyleaf_industry:blunt",
		recipe = {
			{"smokyleaf_industry:dried_buds_" .. strain.name, "smokyleaf_industry:dried_tobacco_leaves"},
		}
	})
end

-- Hash from buds
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokyleaf_industry:hash 1",
		recipe = {
			{"smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name},
			{"smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name},
			{"smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name, "smokyleaf_industry:buds_" .. strain.name},
		}
	})
end

-- ============================================================================
-- ABM (Active Block Modifier) - PLANT GROWTH
-- ============================================================================

-- Weed plant growth. Capture this iteration's strain and stage for Lua 5.1/LuaJIT.
for _, strain in ipairs(weed_strains) do
	local strain_name = strain.name
	local strain_growth_time = strain.growth_time
	for stage = 1, PLANT_GROWTH_STAGES - 1 do
		local current_stage = stage
		minetest.register_abm({
			label = "Weed growth - " .. strain_name .. " stage " .. current_stage,
			nodenames = {"smokyleaf_industry:weed_" .. strain_name .. "_" .. current_stage},
			neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass", "smokyleaf_industry:grow_pot"},
			interval = strain_growth_time * 10,
			chance = GROWTH_CHANCE,
			action = function(pos, node, active_object_count, active_object_count_wider)
				local light = minetest.get_node_light(pos)
				if light and light >= 13 then
					minetest.set_node(pos, {name = "smokyleaf_industry:weed_" .. strain_name .. "_" .. (current_stage + 1)})
				end
			end,
		})
	end

	-- Harvest - mature stage gives buds
	minetest.register_abm({
		label = "Weed harvest - " .. strain_name,
		nodenames = {"smokyleaf_industry:weed_" .. strain_name .. "_" .. PLANT_GROWTH_STAGES},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass", "smokyleaf_industry:grow_pot"},
		interval = 300,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local meta = minetest.get_meta(pos)
			meta:set_int("buds", meta:get_int("buds") + 1)
		end,
	})
end

-- Hemp plant growth
for stage = 1, PLANT_GROWTH_STAGES - 1 do
	local current_stage = stage
	minetest.register_abm({
		label = "Hemp growth stage " .. current_stage,
		nodenames = {"smokyleaf_industry:hemp_" .. current_stage},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass", "smokyleaf_industry:grow_pot"},
		interval = math.floor(80 * 10 / HEMP_GROWTH_SPEED_MULTIPLIER),
		chance = GROWTH_CHANCE,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local light = minetest.get_node_light(pos)
			if light and light >= 13 then
				minetest.set_node(pos, {name = "smokyleaf_industry:hemp_" .. (current_stage + 1)})
			end
		end,
	})
end

-- Tobacco plant growth
for stage = 1, PLANT_GROWTH_STAGES - 1 do
	local current_stage = stage
	minetest.register_abm({
		label = "Tobacco growth stage " .. current_stage,
		nodenames = {"smokyleaf_industry:tobacco_" .. current_stage},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass", "smokyleaf_industry:grow_pot"},
		interval = math.floor(85 * 10 / TOBACCO_GROWTH_SPEED_MULTIPLIER),
		chance = GROWTH_CHANCE,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local light = minetest.get_node_light(pos)
			if light and light >= 13 then
				minetest.set_node(pos, {name = "smokyleaf_industry:tobacco_" .. (current_stage + 1)})
			end
		end,
	})
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get strain info
function smokyleaf_industry.get_strain_info(strain_name)
	return smokyleaf_industry.strains[strain_name]
end

-- Get all strains
function smokyleaf_industry.get_all_strains()
	return weed_strains
end

-- Check if plant is mature
function smokyleaf_industry.is_plant_mature(nodename)
	local stage = tonumber(nodename:match("_(%d+)$"))
	if not stage then return false end
	return stage == PLANT_GROWTH_STAGES
end

-- Get next growth stage
function smokyleaf_industry.get_next_growth_stage(nodename)
	local stage = tonumber(nodename:match("_(%d+)$"))
	if not stage then return nil end
	if stage < PLANT_GROWTH_STAGES then
		return stage + 1
	end
	return stage
end

-- ============================================================================
-- INITIALIZATION MESSAGE
-- ============================================================================

minetest.log("action", "[Smokeleaf Industries] Mod loaded successfully!")
minetest.log("action", "[Smokeleaf Industries] " .. #weed_strains .. " weed strains registered")
minetest.log("action", "[Smokeleaf Industries] Hemp and Tobacco growth systems initialized")

-- Register on_player_hpchange for smoking effects (simplified)
local function apply_smoking_effects(player, strain_name)
	if not strain_name then return end
	
	local strain = smokyleaf_industry.strains[strain_name]
	if not strain then return end
	
	-- Simple effect: increase satiation and slight damage reduction
	local meta = player:get_meta()
	meta:set_int("smokeleaf_potency", math.floor(strain.potency * 100))
	meta:set_int("smokeleaf_effects_time", 300) -- 5 minutes
	
	-- Could add potion effects here if modifying player physics
	minetest.chat_send_player(player:get_player_name(), 
		minetest.colorize("#32CD32", "You feel the effects of " .. strain.title .. "..."))
end

smokyleaf_industry.apply_smoking_effects = apply_smoking_effects
