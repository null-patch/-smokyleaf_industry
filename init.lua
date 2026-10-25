-- Smokeleaf Industries - Cannabis Cultivation Mod for Luanti
-- Ported from Minecraft NeoForge mod
-- Version: 1.0.0

local S = minetest.get_translator("smokeleaf_industries")

-- Mod namespace
smokeleaf_industries = {}

-- Constants
local PLANT_GROWTH_STAGES = 8
local GROWTH_CHANCE = 3 -- 1 in X per ABM cycle
local HEMP_GROWTH_SPEED_MULTIPLIER = 1.2
local TOBACCO_GROWTH_SPEED_MULTIPLIER = 1.0

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
smokeleaf_industries.strains = {}
for _, strain in ipairs(weed_strains) do
	smokeleaf_industries.strains[strain.name] = strain
end

-- ============================================================================
-- ITEM REGISTRATION
-- ============================================================================

-- Register weed buds for each strain
for _, strain in ipairs(weed_strains) do
	minetest.register_craftitem("smokeleaf_industries:buds_" .. strain.name, {
		description = strain.title .. S(" Buds"),
		inventory_image = "smokeleaf_industries_buds.png",
		stack_max = 64,
		groups = {weed_bud = 1, flammable = 2},
	})

	-- Dried buds
	minetest.register_craftitem("smokeleaf_industries:dried_buds_" .. strain.name, {
		description = S("Dried ") .. strain.title .. S(" Buds"),
		inventory_image = "smokeleaf_industries_dried_buds.png",
		stack_max = 64,
		groups = {weed_bud = 1, flammable = 3},
	})

	-- Seeds
	minetest.register_craftitem("smokeleaf_industries:seeds_" .. strain.name, {
		description = strain.title .. S(" Seeds"),
		inventory_image = "smokeleaf_industries_seeds.png",
		stack_max = 64,
		groups = {seed = 1, flammable = 2},
	})
end

-- Hemp items
minetest.register_craftitem("smokeleaf_industries:hemp_seeds", {
	description = S("Hemp Seeds"),
	inventory_image = "smokeleaf_industries_hemp_seeds.png",
	stack_max = 64,
	groups = {seed = 1, flammable = 2},
})

minetest.register_craftitem("smokeleaf_industries:hemp_fiber", {
	description = S("Hemp Fiber"),
	inventory_image = "smokeleaf_industries_hemp_fiber.png",
	stack_max = 64,
	groups = {flammable = 2},
})

minetest.register_craftitem("smokeleaf_industries:hemp_rope", {
	description = S("Hemp Rope"),
	inventory_image = "smokeleaf_industries_hemp_rope.png",
	stack_max = 64,
	groups = {flammable = 2},
})

-- Tobacco items
minetest.register_craftitem("smokeleaf_industries:tobacco_seeds", {
	description = S("Tobacco Seeds"),
	inventory_image = "smokeleaf_industries_tobacco_seeds.png",
	stack_max = 64,
	groups = {seed = 1, flammable = 2},
})

minetest.register_craftitem("smokeleaf_industries:tobacco_leaves", {
	description = S("Tobacco Leaves"),
	inventory_image = "smokeleaf_industries_tobacco_leaves.png",
	stack_max = 64,
	groups = {flammable = 2},
})

-- Smoking items
minetest.register_craftitem("smokeleaf_industries:joint", {
	description = S("Joint"),
	inventory_image = "smokeleaf_industries_joint.png",
	stack_max = 64,
	groups = {flammable = 3, smoking_item = 1},
	on_use = function(itemstack, user, pointed_thing)
		minetest.sound_play("smokeleaf_industries_smoke", {
			pos = user:get_pos(),
			max_hear_distance = 16,
			gain = 0.5,
		})
		user:get_meta():set_int("smokeleaf_high_time", 300)
		itemstack:take_item()
		return itemstack
	end,
})

minetest.register_craftitem("smokeleaf_industries:blunt", {
	description = S("Blunt"),
	inventory_image = "smokeleaf_industries_blunt.png",
	stack_max = 64,
	groups = {flammable = 3, smoking_item = 1},
	on_use = function(itemstack, user, pointed_thing)
		minetest.sound_play("smokeleaf_industries_smoke", {
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
minetest.register_craftitem("smokeleaf_industries:hemp_oil", {
	description = S("Hemp Oil"),
	inventory_image = "smokeleaf_industries_hemp_oil.png",
	stack_max = 64,
})

minetest.register_craftitem("smokeleaf_industries:hash", {
	description = S("Hash"),
	inventory_image = "smokeleaf_industries_hash.png",
	stack_max = 64,
	groups = {flammable = 3},
})

minetest.register_craftitem("smokeleaf_industries:glass_bong", {
	description = S("Glass Bong"),
	inventory_image = "smokeleaf_industries_glass_bong.png",
	stack_max = 1,
})

minetest.register_craftitem("smokeleaf_industries:grinder", {
	description = S("Grinder"),
	inventory_image = "smokeleaf_industries_grinder.png",
	stack_max = 1,
})

-- ============================================================================
-- NODE REGISTRATION - WEED PLANTS
-- ============================================================================

-- Register weed plants for each strain (8 growth stages)
for _, strain in ipairs(weed_strains) do
	for stage = 1, PLANT_GROWTH_STAGES do
		local nodename = "smokeleaf_industries:weed_" .. strain.name .. "_" .. stage
		local next_stage = stage < PLANT_GROWTH_STAGES and stage + 1 or stage

		minetest.register_node(nodename, {
			description = strain.title .. S(" (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
			drawtype = "plantlike",
			tiles = {"smokeleaf_industries_weed_" .. stage .. ".png"},
			inventory_image = "smokeleaf_industries_weed_" .. stage .. ".png",
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
					{items = {"smokeleaf_industries:seeds_" .. strain.name}, rarity = 2},
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
	minetest.register_node("smokeleaf_industries:hemp_" .. stage, {
		description = S("Hemp Plant (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
		drawtype = "plantlike",
		tiles = {"smokeleaf_industries_hemp_" .. stage .. ".png"},
		inventory_image = "smokeleaf_industries_hemp_stage.png",
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
				{items = {"smokeleaf_industries:hemp_seeds"}, rarity = 2},
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
	minetest.register_node("smokeleaf_industries:tobacco_" .. stage, {
		description = S("Tobacco Plant (Stage ") .. stage .. S("/") .. PLANT_GROWTH_STAGES .. S(")"),
		drawtype = "plantlike",
		tiles = {"smokeleaf_industries_tobacco_" .. stage .. ".png"},
		inventory_image = "smokeleaf_industries_tobacco_stage.png",
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
				{items = {"smokeleaf_industries:tobacco_seeds"}, rarity = 2},
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

-- Grow pot (indoor growing)
minetest.register_node("smokeleaf_industries:grow_pot", {
	description = S("Grow Pot"),
	tiles = {
		"smokeleaf_industries_grow_pot_top.png",
		"smokeleaf_industries_grow_pot_bottom.png",
		"smokeleaf_industries_grow_pot_side.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 1},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- LED Grow Light
minetest.register_node("smokeleaf_industries:grow_light_led", {
	description = S("LED Grow Light"),
	tiles = {
		"smokeleaf_industries_led_light_on.png",
		"smokeleaf_industries_led_light_off.png",
		"smokeleaf_industries_led_light_side.png",
	},
	paramtype2 = "facedir",
	light_source = 12,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- HPS Grow Light
minetest.register_node("smokeleaf_industries:grow_light_hps", {
	description = S("HPS Grow Light"),
	tiles = {
		"smokeleaf_industries_hps_light_on.png",
		"smokeleaf_industries_hps_light_off.png",
		"smokeleaf_industries_hps_light_side.png",
	},
	paramtype2 = "facedir",
	light_source = 14,
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- Drying Rack
minetest.register_node("smokeleaf_industries:drying_rack", {
	description = S("Drying Rack"),
	tiles = {
		"smokeleaf_industries_drying_rack_top.png",
		"smokeleaf_industries_drying_rack_bottom.png",
		"smokeleaf_industries_drying_rack_side.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, flammable = 1},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- Processing Machine
minetest.register_node("smokeleaf_industries:processing_machine", {
	description = S("Processing Machine"),
	tiles = {
		"smokeleaf_industries_machine_top.png",
		"smokeleaf_industries_machine_bottom.png",
		"smokeleaf_industries_machine_side.png",
		"smokeleaf_industries_machine_side.png",
		"smokeleaf_industries_machine_front.png",
		"smokeleaf_industries_machine_back.png",
	},
	paramtype2 = "facedir",
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
	sounds = {dig = {name = "default_dig_snappy", gain = 0.2}},
})

-- ============================================================================
-- CRAFTING RECIPES
-- ============================================================================

-- Hemp fiber from hemp (drying process)
for stage = 1, PLANT_GROWTH_STAGES do
	if stage == PLANT_GROWTH_STAGES then
		minetest.register_craft({
			output = "smokeleaf_industries:hemp_fiber 3",
			recipe = {
				{"smokeleaf_industries:hemp_" .. stage}
			}
		})
	end
end

-- Hemp rope from hemp fiber
minetest.register_craft({
	output = "smokeleaf_industries:hemp_rope 1",
	recipe = {
		{"smokeleaf_industries:hemp_fiber", "smokeleaf_industries:hemp_fiber", "smokeleaf_industries:hemp_fiber"},
	}
})

-- Joint crafting (weed buds + rolling paper)
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokeleaf_industries:joint",
		recipe = {
			{"smokeleaf_industries:dried_buds_" .. strain.name, "default:paper"},
		}
	})
end

-- Blunt crafting (weed buds + tobacco)
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokeleaf_industries:blunt",
		recipe = {
			{"smokeleaf_industries:dried_buds_" .. strain.name, "smokeleaf_industries:tobacco_leaves"},
		}
	})
end

-- Hash from buds
for _, strain in ipairs(weed_strains) do
	minetest.register_craft({
		output = "smokeleaf_industries:hash 1",
		recipe = {
			{"smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name},
			{"smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name},
			{"smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name, "smokeleaf_industries:buds_" .. strain.name},
		}
	})
end

-- ============================================================================
-- ABM (Active Block Modifier) - PLANT GROWTH
-- ============================================================================

-- Weed plant growth
for _, strain in ipairs(weed_strains) do
	for stage = 1, PLANT_GROWTH_STAGES - 1 do
		minetest.register_abm({
			label = "Weed growth - " .. strain.name .. " stage " .. stage,
			nodenames = {"smokeleaf_industries:weed_" .. strain.name .. "_" .. stage},
			neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass"},
			interval = strain.growth_time * 10,
			chance = GROWTH_CHANCE,
			action = function(pos, node, active_object_count, active_object_count_wider)
				-- Check light level
				local light = minetest.get_node_light(pos)
				if light and light >= 13 then
					local next_stage = stage + 1
					minetest.set_node(pos, {name = "smokeleaf_industries:weed_" .. strain.name .. "_" .. next_stage})
				end
			end,
		})
	end

	-- Harvest - mature stage gives buds
	minetest.register_abm({
		label = "Weed harvest - " .. strain.name,
		nodenames = {"smokeleaf_industries:weed_" .. strain.name .. "_" .. PLANT_GROWTH_STAGES},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass"},
		interval = 300,
		chance = 5,
		action = function(pos, node, active_object_count, active_object_count_wider)
			-- Buds appear on mature plant
			local meta = minetest.get_meta(pos)
			local buds = meta:get_int("buds") or 0
			meta:set_int("buds", buds + 1)
		end,
	})
end

-- Hemp plant growth
for stage = 1, PLANT_GROWTH_STAGES - 1 do
	minetest.register_abm({
		label = "Hemp growth stage " .. stage,
		nodenames = {"smokeleaf_industries:hemp_" .. stage},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass"},
		interval = math.floor(80 * 10 / HEMP_GROWTH_SPEED_MULTIPLIER),
		chance = GROWTH_CHANCE,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local light = minetest.get_node_light(pos)
			if light and light >= 13 then
				local next_stage = stage + 1
				minetest.set_node(pos, {name = "smokeleaf_industries:hemp_" .. next_stage})
			end
		end,
	})
end

-- Tobacco plant growth
for stage = 1, PLANT_GROWTH_STAGES - 1 do
	minetest.register_abm({
		label = "Tobacco growth stage " .. stage,
		nodenames = {"smokeleaf_industries:tobacco_" .. stage},
		neighbors = {"group:soil", "default:dirt", "default:dirt_with_grass"},
		interval = math.floor(85 * 10 / TOBACCO_GROWTH_SPEED_MULTIPLIER),
		chance = GROWTH_CHANCE,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local light = minetest.get_node_light(pos)
			if light and light >= 13 then
				local next_stage = stage + 1
				minetest.set_node(pos, {name = "smokeleaf_industries:tobacco_" .. next_stage})
			end
		end,
	})
end

-- ============================================================================
-- HELPER FUNCTIONS
-- ============================================================================

-- Get strain info
function smokeleaf_industries.get_strain_info(strain_name)
	return smokeleaf_industries.strains[strain_name]
end

-- Get all strains
function smokeleaf_industries.get_all_strains()
	return weed_strains
end

-- Check if plant is mature
function smokeleaf_industries.is_plant_mature(nodename)
	local stage = tonumber(nodename:match("_(%d+)$"))
	if not stage then return false end
	return stage == PLANT_GROWTH_STAGES
end

-- Get next growth stage
function smokeleaf_industries.get_next_growth_stage(nodename)
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
	
	local strain = smokeleaf_industries.strains[strain_name]
	if not strain then return end
	
	-- Simple effect: increase satiation and slight damage reduction
	local meta = player:get_meta()
	meta:set_int("smokeleaf_potency", math.floor(strain.potency * 100))
	meta:set_int("smokeleaf_effects_time", 300) -- 5 minutes
	
	-- Could add potion effects here if modifying player physics
	minetest.chat_send_player(player:get_player_name(), 
		minetest.colorize("#32CD32", "You feel the effects of " .. strain.title .. "..."))
end

smokeleaf_industries.apply_smoking_effects = apply_smoking_effects
