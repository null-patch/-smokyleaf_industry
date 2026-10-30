-- Smokeleaf Industry v1.0.6 cultivation subsystem.
-- Re-implements the original Forge crop timing, tall crop states, NPK genetics,
-- fertilizers, crop analysis, Grow Pot cycle, Hemp shearing and Reflector lamps.

local MOD = "smokyleaf_industry"
local S = minetest.get_translator(MOD)
local MAX_NPK = 100
local NPK_TOLERANCE = 3
local WEED_MAX_AGE = 10
local TOBACCO_MAX_AGE = 6
local FIRST_TALL_AGE = 7
local HEMP_GROWTH_MULTIPLIER = 3.5

local strains = smokyleaf_industry.strains or {}
local strain_ids = {}
for id in pairs(strains) do strain_ids[#strain_ids + 1] = id end
table.sort(strain_ids)

local function clamp(value, low, high)
	return math.max(low, math.min(high, value))
end

local function chat(player, message, color)
	if player and player:is_player() then
		minetest.chat_send_player(player:get_player_name(), minetest.colorize(color or "#D8E7F4", message))
	end
end

local function is_protected(pos, player)
	if not player or not player:is_player() then return false end
	local name = player:get_player_name()
	if minetest.is_protected and minetest.is_protected(pos, name) then
		if minetest.record_protection_violation then minetest.record_protection_violation(pos, name) end
		return true
	end
	return false
end

local function give_or_drop(player, pos, stack)
	if not stack or stack:is_empty() then return end
	if player and player:is_player() then
		local leftover = player:get_inventory():add_item("main", stack)
		if leftover and not leftover:is_empty() then minetest.add_item(pos, leftover) end
	else
		minetest.add_item(pos, stack)
	end
end

local function itemstack(name, count)
	return ItemStack({name = name, count = count or 1})
end

local function soil_node_is_valid(name)
	if not name or name == "" then return false end
	if minetest.get_item_group(name, "soil") > 0 then return true end
	local known = {
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
	}
	return known[name] == true
end

local function soil_is_farmland(name)
	return name == "default:farmland"
		or name == "farming:soil"
		or name == "farming:soil_wet"
		or name == "mcl_farming:soil"
		or name == "mcl_farming:soil_wet"
		or (name and name:find("farmland", 1, true) ~= nil)
end

local function soil_growth_value(name)
	if not soil_node_is_valid(name) then return 0 end
	if name == "farming:soil_wet" or name == "mcl_farming:soil_wet" then return 3 end
	return 1
end

-- Parses the crop node naming scheme. Bottom crop nodes are the only nodes
-- with persistent crop metadata; top nodes are visual/support halves.
local function parse_crop_name(name)
	local strain, stage = name:match("^smokyleaf_industry:weed_(.+)_top_(%d+)$")
	if strain then return {family = "weed", strain = strain, stage = tonumber(stage), top = true, max_age = WEED_MAX_AGE} end
	strain, stage = name:match("^smokyleaf_industry:weed_(.+)_(%d+)$")
	if strain and strains[strain] then return {family = "weed", strain = strain, stage = tonumber(stage), top = false, max_age = WEED_MAX_AGE} end
	stage = name:match("^smokyleaf_industry:hemp_top_(%d+)$")
	if stage then return {family = "hemp", stage = tonumber(stage), top = true, max_age = WEED_MAX_AGE} end
	stage = name:match("^smokyleaf_industry:hemp_(%d+)$")
	if stage then return {family = "hemp", stage = tonumber(stage), top = false, max_age = WEED_MAX_AGE} end
	stage = name:match("^smokyleaf_industry:tobacco_(%d+)$")
	if stage then return {family = "tobacco", stage = tonumber(stage), top = false, max_age = TOBACCO_MAX_AGE} end
	return nil
end

local function bottom_node_name(info, age)
	local stage = age + 1
	if info.family == "weed" then return MOD .. ":weed_" .. info.strain .. "_" .. stage end
	if info.family == "hemp" then return MOD .. ":hemp_" .. stage end
	return MOD .. ":tobacco_" .. stage
end

local function top_node_name(info, age)
	local stage = age + 1
	if info.family == "weed" then return MOD .. ":weed_" .. info.strain .. "_top_" .. stage end
	return MOD .. ":hemp_top_" .. stage
end

local function node_is_replaceable(pos)
	local node = minetest.get_node(pos)
	if node.name == "air" then return true end
	return minetest.get_item_group(node.name, "buildable_to") > 0
end

local function get_crop_age(pos, info)
	local meta = minetest.get_meta(pos)
	local age = meta:get_int("growth_age")
	if meta:get_string("cultivation_schema") == "2" then return clamp(age, 0, info.max_age) end
	return clamp((info.stage or 1) - 1, 0, info.max_age)
end

local function update_tall_half(pos, info, age)
	if info.family == "tobacco" then return true end
	local top_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local top_node = minetest.get_node(top_pos)
	if age >= FIRST_TALL_AGE then
		local desired = top_node_name(info, age)
		local existing = parse_crop_name(top_node.name)
		if existing and existing.top then
			if top_node.name ~= desired then
				minetest.swap_node(top_pos, {name = desired, param2 = top_node.param2 or 0})
			end
		elseif node_is_replaceable(top_pos) then
			minetest.set_node(top_pos, {name = desired})
		else
			return false
		end
	else
		if parse_crop_name(top_node.name) and parse_crop_name(top_node.name).top then
			minetest.remove_node(top_pos)
		end
	end
	return true
end

local function set_crop_age(pos, info, age)
	age = clamp(age, 0, info.max_age)
	if not update_tall_half(pos, info, age) then return false end
	local node = minetest.get_node(pos)
	local desired = bottom_node_name(info, age)
	if node.name ~= desired then
		minetest.swap_node(pos, {name = desired, param2 = node.param2 or 0})
	end
	local meta = minetest.get_meta(pos)
	meta:set_int("growth_age", age)
	meta:set_string("cultivation_schema", "2")
	return true
end

local function crop_support_name(pos)
	local below = {x = pos.x, y = pos.y - 1, z = pos.z}
	return minetest.get_node(below).name
end

local function same_crop_near(pos, info, dx, dz)
	local target = {x = pos.x + dx, y = pos.y, z = pos.z + dz}
	local other = parse_crop_name(minetest.get_node(target).name)
	if not other or other.top or other.family ~= info.family then return false end
	-- The Forge has one UnidentifiedWeedCropBlock for every named strain, so
	-- neighboring strains count as the same crop for vanilla CropBlock spacing.
	if info.family == "weed" then return true end
	return true
end

-- CropBlock#getGrowthSpeed approximation: a soil base value plus quarter-weight
-- contributions from the surrounding 3x3 farmland/soil cells, with vanilla-like
-- crowding penalties. This is used by natural ticks and both original lamp types.
local function crop_growth_speed(pos, info, apply_hemp_multiplier)
	local speed = 1.0
	for dx = -1, 1 do
		for dz = -1, 1 do
			local soil_pos = {x = pos.x + dx, y = pos.y - 1, z = pos.z + dz}
			local value = soil_growth_value(minetest.get_node(soil_pos).name)
			if dx ~= 0 or dz ~= 0 then value = value / 4 end
			speed = speed + value
		end
	end
	local along_x = same_crop_near(pos, info, -1, 0) or same_crop_near(pos, info, 1, 0)
	local along_z = same_crop_near(pos, info, 0, -1) or same_crop_near(pos, info, 0, 1)
	local diagonal = same_crop_near(pos, info, -1, -1) or same_crop_near(pos, info, -1, 1)
		diagonal = diagonal or same_crop_near(pos, info, 1, -1) or same_crop_near(pos, info, 1, 1)
	if along_x and along_z then speed = speed / 2
	elseif diagonal then speed = speed / 2 end
	if apply_hemp_multiplier and info.family == "hemp" then speed = speed * HEMP_GROWTH_MULTIPLIER end
	return math.max(0.1, speed)
end

local function crop_light(pos)
	local light = minetest.get_node_light(pos)
	return light or 0
end

local function roll_original_crop_growth(pos, info, use_hemp_multiplier)
	local age = get_crop_age(pos, info)
	if age >= info.max_age then return false end
	local support = crop_support_name(pos)
	if support == MOD .. ":grow_pot" then return false end
	if not soil_node_is_valid(support) then return false end
	local threshold = info.family == "tobacco" and 9 or 11
	if crop_light(pos) < threshold then return false end
	if info.family ~= "tobacco" and age < FIRST_TALL_AGE then
		local above = {x = pos.x, y = pos.y + 1, z = pos.z}
		if not node_is_replaceable(above) then return false end
	end
	local speed = crop_growth_speed(pos, info, use_hemp_multiplier)
	local bound = math.floor(25 / speed) + 1
	if math.random(1, bound) ~= 1 then return false end
	return set_crop_age(pos, info, age + 1)
end

local function calculate_bud_count(meta, strain)
	if not strain then return 1 end
	local dn = math.abs(meta:get_int("nitrogen") - strain.n)
	local dp = math.abs(meta:get_int("phosphorus") - strain.p)
	local dk = math.abs(meta:get_int("potassium") - strain.k)
	if dn == 0 and dp == 0 and dk == 0 then return 3 end
	local off = 0
	if dn > NPK_TOLERANCE then off = off + 1 end
	if dp > NPK_TOLERANCE then off = off + 1 end
	if dk > NPK_TOLERANCE then off = off + 1 end
	if off == 0 then return 2 end
	return 1
end

local function calculate_genetic_stat(base, meta, strain)
	if not strain then return base end
	local dn = math.abs(meta:get_int("nitrogen") - strain.n)
	local dp = math.abs(meta:get_int("phosphorus") - strain.p)
	local dk = math.abs(meta:get_int("potassium") - strain.k)
	if dn == 0 and dp == 0 and dk == 0 then return clamp(base * 2, 0, 100) end
	local total_diff = dn + dp + dk
	local reduction = math.floor(base * 0.10 * total_diff + 0.5)
	local floor_value = math.max(1, math.floor(base / 2))
	return clamp(base - reduction, floor_value, 100)
end

local function make_bud_stack(strain_id, meta, count)
	local stack = itemstack(MOD .. ":buds_" .. strain_id, count)
	local data = stack:get_meta()
	local strain = strains[strain_id]
	if strain then
		data:set_string("strain_id", strain_id)
		data:set_int("thc", calculate_genetic_stat(strain.thc, meta, strain))
		data:set_int("cbd", calculate_genetic_stat(strain.cbd, meta, strain))
		data:set_int("nitrogen", meta:get_int("nitrogen"))
		data:set_int("phosphorus", meta:get_int("phosphorus"))
		data:set_int("potassium", meta:get_int("potassium"))
		data:set_int("ph", meta:get_int("ph"))
	end
	return stack
end

local function give_crop_drops(player, pos, info, age, meta)
	if info.family == "weed" then
		local seed_name = MOD .. ":seeds_" .. info.strain
		give_or_drop(player, pos, itemstack(seed_name, 1))
		if age >= info.max_age then
			local strain = strains[info.strain]
			local buds = make_bud_stack(info.strain, meta, calculate_bud_count(meta, strain))
			give_or_drop(player, pos, buds)
			give_or_drop(player, pos, itemstack(MOD .. ":hemp_leaf", 1))
		end
	elseif info.family == "hemp" then
		give_or_drop(player, pos, itemstack(MOD .. ":hemp_seeds", 1))
		if math.random() < 0.5 then give_or_drop(player, pos, itemstack(MOD .. ":hemp_seeds", 1)) end
		if age >= info.max_age then
			give_or_drop(player, pos, itemstack(MOD .. ":hemp_fiber", 1))
			give_or_drop(player, pos, itemstack(MOD .. ":hemp_leaf", 1))
		end
	elseif info.family == "tobacco" then
		give_or_drop(player, pos, itemstack(MOD .. ":tobacco_seeds", 1))
		if math.random() < 0.25 then give_or_drop(player, pos, itemstack(MOD .. ":tobacco_seeds", 1)) end
		if age >= info.max_age then
			give_or_drop(player, pos, itemstack(MOD .. ":tobacco_leaves", 1))
			if math.random() < 0.25 then give_or_drop(player, pos, itemstack(MOD .. ":tobacco_leaves", 1)) end
		end
	end
end

local function crop_on_dig(pos, node, digger)
	if is_protected(pos, digger) then return end
	local info = parse_crop_name(node.name)
	if not info then minetest.remove_node(pos); return end
	if info.top then
		local bottom = {x = pos.x, y = pos.y - 1, z = pos.z}
		local bottom_node = minetest.get_node(bottom)
		local bottom_info = parse_crop_name(bottom_node.name)
		if bottom_info and not bottom_info.top then
			local meta = minetest.get_meta(bottom)
			local age = get_crop_age(bottom, bottom_info)
			if bottom_info.family == "weed" or bottom_info.family == "hemp" then
				give_crop_drops(digger, bottom, bottom_info, age, meta)
			else
				give_crop_drops(digger, bottom, bottom_info, age, meta)
			end
			minetest.remove_node(bottom)
		end
		minetest.remove_node(pos)
		return
	end
	local meta = minetest.get_meta(pos)
	local age = get_crop_age(pos, info)
	give_crop_drops(digger, pos, info, age, meta)
	if info.family ~= "tobacco" and age >= FIRST_TALL_AGE then
		local top = {x = pos.x, y = pos.y + 1, z = pos.z}
		local top_info = parse_crop_name(minetest.get_node(top).name)
		if top_info and top_info.top then minetest.remove_node(top) end
	end
	minetest.remove_node(pos)
end

local function is_shears(stack)
	if not stack or stack:is_empty() then return false end
	local name = stack:get_name()
	return name == "default:shears" or name == "mcl_tools:shears"
		or minetest.get_item_group(name, "shears") > 0
end

local function hemp_on_rightclick(pos, node, clicker, wielded_stack)
	local info = parse_crop_name(node.name)
	if not info or info.family ~= "hemp" or info.top then return wielded_stack end
	if not is_shears(wielded_stack) or get_crop_age(pos, info) < WEED_MAX_AGE then return wielded_stack end
	if is_protected(pos, clicker) then return wielded_stack end
	local meta = minetest.get_meta(pos)
	local shear_count = meta:get_int("hemp_shear_count")
	if shear_count < 3 then
		meta:set_int("hemp_shear_count", shear_count + 1)
		give_or_drop(clicker, pos, itemstack(MOD .. ":hemp_leaf", 1))
		minetest.sound_play("default_dig_snappy", {pos = pos, gain = 0.45, max_hear_distance = 8}, true)
		if wielded_stack.add_wear then wielded_stack:add_wear(math.floor(65535 / 238)) end
		return wielded_stack
	end
	-- The fourth shear harvests the hemp plant, matching HempShearStage S0..S3.
	crop_on_dig(pos, node, clicker)
	if wielded_stack.add_wear then wielded_stack:add_wear(math.floor(65535 / 238)) end
	return wielded_stack
end

local function apply_fertilizer(pos, stack, player, fertilizer)
	local node = minetest.get_node(pos)
	local info = parse_crop_name(node.name)
	if info and info.top then
		pos = {x = pos.x, y = pos.y - 1, z = pos.z}
		node = minetest.get_node(pos)
		info = parse_crop_name(node.name)
	end
	if not info and node.name == MOD .. ":grow_pot" then
		pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		node = minetest.get_node(pos)
		info = parse_crop_name(node.name)
		if info and info.top then
			pos = {x = pos.x, y = pos.y - 1, z = pos.z}
			node = minetest.get_node(pos)
			info = parse_crop_name(node.name)
		end
	end
	if not info or info.top or (info.family ~= "weed" and info.family ~= "hemp") then return false end
	if is_protected(pos, player) then return false end
	local meta = minetest.get_meta(pos)
	if get_crop_age(pos, info) >= info.max_age then
		chat(player, S("This crop is fully grown. Harvest it before applying fertilizer."), "#F2C879")
		return false
	end
	meta:set_int("nitrogen", clamp(meta:get_int("nitrogen") + fertilizer.n, 0, MAX_NPK))
	meta:set_int("phosphorus", clamp(meta:get_int("phosphorus") + fertilizer.p, 0, MAX_NPK))
	meta:set_int("potassium", clamp(meta:get_int("potassium") + fertilizer.k, 0, MAX_NPK))
	meta:set_int("cultivation_schema", 2)
	chat(player, string.format("NPK updated: N %d | P %d | K %d", meta:get_int("nitrogen"), meta:get_int("phosphorus"), meta:get_int("potassium")), "#9AD58A")
	return true
end

-- Original 17 FertilizerItem stat deltas (N, P, K). Stats apply to the crop,
-- not its soil, and each nutrient is clamped to 0..100.
local fertilizers = {
	{"worm_castings", "Worm Castings", 2, 2, 2},
	{"compost", "Compost", 1, 1, 1},
	{"mycorrhizae", "Mycorrhizae", 0, 3, 1},
	{"dolomite_lime", "Dolomite Lime", -2, 4, -2},
	{"blood_meal", "Blood Meal", 4, 0, 0},
	{"phosphorus_feed", "Phosphorus Feed", 0, 5, 0},
	{"bat_guano", "Bat Guano", -1, 4, 1},
	{"kelp_meal", "Kelp Meal", 0, 0, 4},
	{"wood_ash", "Wood Ash", -1, -1, 5},
	{"bloom_booster", "Bloom Booster", -2, 4, 2},
	{"fruit_finisher", "Fruit Finisher", 0, -2, -2},
	{"nitrogen_boost", "Nitrogen Boost", 3, -1, 0},
	{"potash_boost", "Potash Boost", 0, -1, 3},
	{"balanced_boost", "Balanced Boost", 1, 1, 1},
	{"phosphorus_reducer", "Phosphorus Reducer", 0, -3, 0},
	{"potassium_reducer", "Potassium Reducer", 0, 0, -3},
	{"fish_emulsion", "Fish Emulsion", 2, 2, -1},
}

local fertilizers_by_item = {}
for _, entry in ipairs(fertilizers) do
	local id, title, n, p, k = entry[1], entry[2], entry[3], entry[4], entry[5]
	local fertilizer = {n = n, p = p, k = k, id = id}
	fertilizers_by_item[MOD .. ":" .. id] = fertilizer
	minetest.register_craftitem(MOD .. ":" .. id, {
		description = S(title) .. string.format("\nNitrogen: %+d  Phosphorus: %+d  Potassium: %+d", n, p, k),
		inventory_image = "smokyleaf_industry_fertilizer_" .. id .. ".png",
		stack_max = 64,
		groups = {fertilizer = 1, flammable = 1},
		on_place = function(stack, placer, pointed)
			if not pointed or pointed.type ~= "node" or not pointed.under then return stack end
			if apply_fertilizer(pointed.under, stack, placer, fertilizer) then
				if not (placer and placer:is_player() and minetest.is_creative_enabled and minetest.is_creative_enabled(placer:get_player_name())) then stack:take_item() end
			end
			return stack
		end,
	})
end

local function crop_analysis(pos, player)
	local node = minetest.get_node(pos)
	local pot_soil = ""
	if node.name == MOD .. ":grow_pot" then
		pot_soil = minetest.get_meta(pos):get_string("pot_soil")
		pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		node = minetest.get_node(pos)
		if not parse_crop_name(node.name) then
			chat(player, S("Grow Pot soil: ") .. (pot_soil ~= "" and pot_soil or S("empty")) .. "\n" .. S("No crop planted."), "#F2C879")
			return
		end
	end
	local info = parse_crop_name(node.name)
	if not info then chat(player, S("Plant Analyzer: target a weed, hemp, tobacco crop, or Grow Pot."), "#F2C879"); return end
	if info.top then pos = {x = pos.x, y = pos.y - 1, z = pos.z}; node = minetest.get_node(pos); info = parse_crop_name(node.name) end
	if not info then return end
	local meta = minetest.get_meta(pos)
	local age = get_crop_age(pos, info)
	local strain = info.family == "weed" and strains[info.strain] or nil
	local title = strain and strain.title or (info.family == "hemp" and S("Hemp") or S("Tobacco"))
	local bud_count = strain and calculate_bud_count(meta, strain) or 1
	local thc = strain and calculate_genetic_stat(strain.thc, meta, strain) or 0
	local cbd = strain and calculate_genetic_stat(strain.cbd, meta, strain) or 0
	local n, ph, k = meta:get_int("nitrogen"), meta:get_int("phosphorus"), meta:get_int("potassium")
	local exact = strain and n == strain.n and ph == strain.p and k == strain.k or false
	local tolerance = strain and math.abs(n - strain.n) <= NPK_TOLERANCE
		and math.abs(ph - strain.p) <= NPK_TOLERANCE and math.abs(k - strain.k) <= NPK_TOLERANCE or false
	local progress = math.floor((age / info.max_age) * 100 + 0.5)
	local is_pot = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name == MOD .. ":grow_pot"
	local fs = {
		"formspec_version[4]", "size[10.2,8.25]", "no_prepend[]",
		"bgcolor[#101720;both;#0B1017]", "box[0,0;10.2,8.25;#101720]",
		"box[0.25,0.25;9.7,0.8;#26384A]", "style_type[label;textcolor=#E6EEF7]",
		"label[0.55,0.52;SMOKELEAF INDUSTRIES  /  PLANT ANALYZER]",
		"box[0.25,1.25;4.55,2.65;#1A2735]",
		"label[0.55,1.52;PLANT IDENTIFICATION]",
		"label[0.55,1.98;" .. minetest.formspec_escape(title) .. "]",
		"label[0.55,2.42;Family: " .. minetest.formspec_escape(info.family:upper()) .. "]",
		"label[0.55,2.82;Growth age: " .. age .. " / " .. info.max_age .. "]",
		"label[0.55,3.22;" .. (is_pot and "Environment: GROW POT" or "Environment: FIELD CROP") .. "]",
		"box[5.05,1.25;4.9,2.65;#1A2735]",
		"label[5.35,1.52;GROWTH PROGRESS]",
		"box[5.35,2.05;4.15,0.38;#080E15]",
		string.format("box[5.35,2.05;%.3f,0.38;#65A96E]", 4.15 * progress / 100),
		"label[5.35,2.62;" .. progress .. "%  " .. (age >= info.max_age and "MATURE" or "GROWING") .. "]",
		"label[5.35,3.22;" .. (is_pot and ("Pot soil: " .. minetest.formspec_escape(pot_soil ~= "" and pot_soil or "none")) or "Natural crop cycle") .. "]",
		"box[0.25,4.1;4.55,3.45;#1A2735]",
		"label[0.55,4.38;GENETIC PROFILE]",
		"label[0.55,4.9;THC: " .. thc .. "%]",
		"label[0.55,5.35;CBD: " .. cbd .. "%]",
		"label[0.55,5.92;Expected yield: x" .. bud_count .. "]",
		"label[0.55,6.52;Genetics: " .. (strain and S("Named preset") or S("Hemp / tobacco")) .. "]",
		"box[5.05,4.1;4.9,3.45;#1A2735]",
		"label[5.35,4.38;NUTRIENT ANALYSIS  /  N-P-K]",
		"label[5.35,4.9;Nitrogen: " .. n .. "   /   Target: " .. (strain and strain.n or "—") .. "]",
		"label[5.35,5.35;Phosphorus: " .. ph .. "   /   Target: " .. (strain and strain.p or "—") .. "]",
		"label[5.35,5.8;Potassium: " .. k .. "   /   Target: " .. (strain and strain.k or "—") .. "]",
		"label[5.35,6.3;NPK status: " .. (exact and "OPTIMAL" or (tolerance and "WITHIN TOLERANCE" or (strain and "NEEDS ADJUSTMENT" or "NO TARGET"))) .. "]",
		"label[5.35,6.78;pH: " .. meta:get_int("ph") .. "]",
		"button_exit[8.35,7.72;1.35,0.38;close;CLOSE]",
	}
	local formname = MOD .. ":plant_analyzer"
	minetest.show_formspec(player:get_player_name(), formname, table.concat(fs, "\n"))
end

minetest.register_craftitem(MOD .. ":plant_analyzer", {
	description = S("Plant Analyzer") .. "\n" .. S("Right-click a crop to inspect growth, NPK, THC and CBD."),
	inventory_image = "smokyleaf_industry_plant_analyzer.png",
	stack_max = 1,
	on_place = function(stack, placer, pointed)
		if pointed and pointed.type == "node" and pointed.under and placer then crop_analysis(pointed.under, placer) end
		return stack
	end,
})

local function add_optional_craft(output, recipe, shapeless, count)
	for _, row in ipairs(recipe) do
		if type(row) == "table" then
			for _, ingredient in ipairs(row) do
				if ingredient and ingredient ~= "" and not minetest.registered_items[ingredient] then return false end
			end
		elseif row and row ~= "" and not minetest.registered_items[row] then return false end
	end
	local craft_recipe = recipe
	if shapeless then
		craft_recipe = {}
		for _, row in ipairs(recipe) do
			if type(row) == "table" then
				for _, ingredient in ipairs(row) do craft_recipe[#craft_recipe + 1] = ingredient end
			elseif row and row ~= "" then
				craft_recipe[#craft_recipe + 1] = row
			end
		end
	end
	local def = {output = output .. (count and (" " .. count) or " 1"), recipe = craft_recipe}
	if shapeless then def.type = "shapeless" end
	minetest.register_craft(def)
	return true
end

-- Recipes use Luanti Game materials where available. Missing optional-game
-- ingredients simply suppress that recipe rather than creating broken recipes.
add_optional_craft(MOD .. ":plant_analyzer", {{"default:steel_ingot", MOD .. ":hemp_fiber", "default:steel_ingot"}, {"default:glass", MOD .. ":hemp_rope", "default:glass"}}, false)

local fertilizer_recipes = {
	{"compost", {"default:leaves", "default:dirt", MOD .. ":hemp_fiber"}},
	{"worm_castings", {"default:dirt", MOD .. ":compost", "default:coal_lump"}},
	{"mycorrhizae", {MOD .. ":compost", "default:leaves", "default:papyrus"}},
	{"dolomite_lime", {"default:stone", "default:desert_sand", "default:clay_lump"}},
	{"blood_meal", {"default:apple", "default:dirt", MOD .. ":hemp_fiber"}},
	{"phosphorus_feed", {"default:coal_lump", "default:stone", MOD .. ":compost"}},
	{"bat_guano", {"default:coal_lump", "default:leaves", MOD .. ":compost"}},
	{"kelp_meal", {"default:papyrus", "default:papyrus", MOD .. ":tobacco_leaves"}},
	{"wood_ash", {"default:coal_lump", "default:tree", "default:dry_shrub"}},
	{"bloom_booster", {"default:dry_shrub", "default:papyrus", MOD .. ":hemp_seeds"}},
	{"fruit_finisher", {"default:apple", "default:papyrus", "default:leaves"}},
	{"nitrogen_boost", {"default:papyrus", "default:leaves", MOD .. ":hemp_seeds"}},
	{"potash_boost", {MOD .. ":wood_ash", "default:coal_lump", "default:leaves"}},
	{"balanced_boost", {MOD .. ":compost", "default:papyrus", MOD .. ":hemp_fiber"}},
	{"phosphorus_reducer", {"default:dry_shrub", "default:clay_lump", "default:papyrus"}},
	{"potassium_reducer", {"default:apple", "default:leaves", "default:clay_lump"}},
	{"fish_emulsion", {"default:coral_orange", "default:papyrus", MOD .. ":hemp_fiber"}},
}
for _, recipe in ipairs(fertilizer_recipes) do
	add_optional_craft(MOD .. ":" .. recipe[1], {recipe[2]}, true, 2)
end

-- Grow Pot soil and seed handling. The crop itself occupies the block above the
-- pot; the pot stores which soil was inserted and selects the original 60/90 s cycle.
local function remove_grow_pot_crop(crop_pos, info, player)
	if not info or info.top or (info.family ~= "weed" and info.family ~= "hemp") then return false end
	local pot_pos = {x = crop_pos.x, y = crop_pos.y - 1, z = crop_pos.z}
	if minetest.get_node(pot_pos).name ~= MOD .. ":grow_pot" then return false end
	if is_protected(pot_pos, player) or is_protected(crop_pos, player) then return false end
	local seed_name = info.family == "weed" and (MOD .. ":seeds_" .. info.strain) or (MOD .. ":hemp_seeds")
	give_or_drop(player, crop_pos, itemstack(seed_name, 1))
	local age = get_crop_age(crop_pos, info)
	if age >= FIRST_TALL_AGE then
		local top_pos = {x = crop_pos.x, y = crop_pos.y + 1, z = crop_pos.z}
		local top_info = parse_crop_name(minetest.get_node(top_pos).name)
		if top_info and top_info.top then minetest.remove_node(top_pos) end
	end
	minetest.remove_node(crop_pos)
	local pot_meta = minetest.get_meta(pot_pos)
	pot_meta:set_string("infotext", S("Grow Pot") .. " - Soil ready")
	pot_meta:set_int("auto_export_cooldown", 0)
	return true
end

local function harvest_grow_pot_crop(crop_pos, info, player)
	if not info or info.top or (info.family ~= "weed" and info.family ~= "hemp") then return false end
	local pot_pos = {x = crop_pos.x, y = crop_pos.y - 1, z = crop_pos.z}
	if minetest.get_node(pot_pos).name ~= MOD .. ":grow_pot" then return false end
	if minetest.get_meta(pot_pos):get_string("pot_soil") == "" then return false end
	if is_protected(pot_pos, player) or is_protected(crop_pos, player) then return false end
	local meta = minetest.get_meta(crop_pos)
	local age = get_crop_age(crop_pos, info)
	if age < info.max_age then return false end
	if info.family == "weed" then
		local strain = strains[info.strain]
		give_or_drop(player, crop_pos, make_bud_stack(info.strain, meta, calculate_bud_count(meta, strain)))
	else
		give_or_drop(player, crop_pos, itemstack(MOD .. ":hemp_fiber", 1))
		give_or_drop(player, crop_pos, itemstack(MOD .. ":hemp_leaf", 1))
	end
	set_crop_age(crop_pos, info, 0)
	meta:set_float("pot_growth_progress", 0)
	meta:set_int("hemp_shear_count", 0)
	minetest.get_meta(pot_pos):set_string("infotext", S("Grow Pot") .. " - Growing")
	chat(player, S("Harvest complete. The planted crop has restarted its growth cycle."), "#9AD58A")
	return true
end

local function get_grow_pot_harvest_products(crop_pos, info)
	local meta = minetest.get_meta(crop_pos)
	if info.family == "weed" then
		local strain = strains[info.strain]
		return {make_bud_stack(info.strain, meta, calculate_bud_count(meta, strain))}
	end
	return {itemstack(MOD .. ":hemp_fiber", 1), itemstack(MOD .. ":hemp_leaf", 1)}
end

local function try_grow_pot_auto_export(pot_pos, crop_pos, info)
	local target_pos = {x = pot_pos.x, y = pot_pos.y - 1, z = pot_pos.z}
	local target_meta = minetest.get_meta(target_pos)
	local inv = target_meta:get_inventory()
	if not inv then return false end
	local listname
	for _, candidate in ipairs({"main", "dst", "output", "items"}) do
		if inv:get_size(candidate) > 0 then listname = candidate; break end
	end
	if not listname then return false end
	local products = get_grow_pot_harvest_products(crop_pos, info)
	local leftovers = {}
	local inserted = false
	for _, product in ipairs(products) do
		if not product:is_empty() then
			local leftover = inv:add_item(listname, product)
			if leftover and not leftover:is_empty() then leftovers[#leftovers + 1] = leftover else inserted = true end
		end
	end
	if not inserted then return false end
	for _, leftover in ipairs(leftovers) do minetest.add_item(pot_pos, leftover) end
	set_crop_age(crop_pos, info, 0)
	local crop_meta = minetest.get_meta(crop_pos)
	crop_meta:set_float("pot_growth_progress", 0)
	crop_meta:set_int("hemp_shear_count", 0)
	return true
end

local is_bonemeal
local consume_one
local function grow_pot_rightclick(pos, node, clicker, stack)
	if not clicker or not clicker:is_player() or is_protected(pos, clicker) then return stack end
	local meta = minetest.get_meta(pos)
	if stack and not stack:is_empty() then
		local name = stack:get_name()
		if name == MOD .. ":plant_analyzer" then
			crop_analysis(pos, clicker)
			return stack
		end
		local crop_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
		local crop_info = parse_crop_name(minetest.get_node(crop_pos).name)
		local fertilizer = fertilizers_by_item[name]
		if fertilizer and crop_info then
			if apply_fertilizer(crop_pos, stack, clicker, fertilizer) then return consume_one(stack, clicker) end
			return stack
		end
		if is_bonemeal and is_bonemeal(stack) and crop_info and not crop_info.top then
			if is_protected(crop_pos, clicker) then return stack end
			local age = get_crop_age(crop_pos, crop_info)
			if age < crop_info.max_age then
				set_crop_age(crop_pos, crop_info, math.min(crop_info.max_age, age + math.random(2, 5)))
				return consume_one(stack, clicker)
			end
			return stack
		end
		local strain_id = name:match("^smokyleaf_industry:seeds_(.+)$")
		local crop_name = strain_id and strains[strain_id] and (MOD .. ":weed_" .. strain_id .. "_1")
		if name == MOD .. ":hemp_seeds" then crop_name = MOD .. ":hemp_1" end
		if crop_name then
			if meta:get_string("pot_soil") == "" then
				chat(clicker, S("Insert soil into the Grow Pot before planting."), "#F2C879")
				return stack
			end
			if minetest.get_node(crop_pos).name ~= "air" then
				chat(clicker, S("The Grow Pot already has a crop or its planting space is obstructed."), "#F2C879")
				return stack
			end
			if is_protected(crop_pos, clicker) then return stack end
			minetest.set_node(crop_pos, {name = crop_name})
			local crop_meta = minetest.get_meta(crop_pos)
			crop_meta:set_string("cultivation_schema", "2")
			crop_meta:set_int("growth_age", 0)
			crop_meta:set_int("ph", 7)
			crop_meta:set_int("nitrogen", 0)
			crop_meta:set_int("phosphorus", 0)
			crop_meta:set_int("potassium", 0)
			crop_meta:set_int("thc", strain_id and strains[strain_id].thc or 0)
			crop_meta:set_int("cbd", strain_id and strains[strain_id].cbd or 0)
			crop_meta:set_string("strain_id", strain_id or "")
			crop_meta:set_int("growpot", 1)
			crop_meta:set_string("growpot_soil", meta:get_string("pot_soil"))
			crop_meta:set_float("pot_growth_progress", 0)
			meta:set_string("infotext", S("Grow Pot") .. " - Growing")
			return consume_one(stack, clicker)
		end
		if soil_node_is_valid(name) and minetest.registered_nodes[name] then
			if meta:get_string("pot_soil") ~= "" then
				chat(clicker, S("Grow Pot already contains soil."), "#F2C879")
				return stack
			end
			meta:set_string("pot_soil", name)
			meta:set_string("infotext", S("Grow Pot") .. " - " .. name)
			if not (minetest.is_creative_enabled and minetest.is_creative_enabled(clicker:get_player_name())) then stack:take_item() end
			return stack
		end
		return stack
	end
	local crop_pos = {x = pos.x, y = pos.y + 1, z = pos.z}
	local crop_info = parse_crop_name(minetest.get_node(crop_pos).name)
	if crop_info then
		local controls = clicker:get_player_control()
		if controls and controls.sneak and remove_grow_pot_crop(crop_pos, crop_info, clicker) then return stack end
		if harvest_grow_pot_crop(crop_pos, crop_info, clicker) then return stack end
		chat(clicker, S("The Grow Pot crop is not ready to harvest."), "#F2C879")
		return stack
	end
	local controls = clicker:get_player_control()
	if not controls or not controls.sneak then
		chat(clicker, S("Sneak and right-click to remove the soil."), "#B9D8F4")
		return stack
	end
	local soil = meta:get_string("pot_soil")
	if soil ~= "" then
		local leftover = clicker:get_inventory():add_item("main", itemstack(soil, 1))
		if leftover and not leftover:is_empty() then minetest.add_item(pos, leftover) end
		meta:set_string("pot_soil", "")
		meta:set_string("infotext", S("Grow Pot") .. " - Empty")
	end
	return stack
end

minetest.override_item(MOD .. ":grow_pot", {
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("pot_soil") == "" then meta:set_string("pot_soil", "") end
		meta:set_string("infotext", S("Grow Pot") .. " - Empty")
	end,
	on_rightclick = grow_pot_rightclick,
})

-- Node helpers for the original multi-block 11-age weed/hemp plants.
local function crop_node_groups(family, top)
	local groups = {snappy = 3, flammable = 2, plant = 1, attached_node = 1}
	if family == "weed" then groups.weed = 1 end
	if family == "hemp" then groups.hemp = 1 end
	if family == "tobacco" then groups.tobacco = 1 end
	if top then groups.not_in_creative_inventory = 1 end
	return groups
end

is_bonemeal = function(stack)
	if not stack or stack:is_empty() then return false end
	local name = stack:get_name()
	return name == "default:bone_meal" or name == "mcl_bone_meal:bone_meal"
		or minetest.get_item_group(name, "bonemeal") > 0
		or minetest.get_item_group(name, "bone_meal") > 0
end

consume_one = function(stack, player)
	if player and player:is_player() and minetest.is_creative_enabled
		and minetest.is_creative_enabled(player:get_player_name()) then return stack end
	stack:take_item()
	return stack
end

local function crop_on_rightclick(pos, node, clicker, stack)
	local info = parse_crop_name(node.name)
	if not info or not clicker or not clicker:is_player() then return stack end
	if info.top then
		pos = {x = pos.x, y = pos.y - 1, z = pos.z}
		node = minetest.get_node(pos)
		info = parse_crop_name(node.name)
	end
	if not info or info.top or is_protected(pos, clicker) then return stack end

	-- Route the analyzer through the node callback; Luanti does not call an
	-- item's on_place handler when the pointed node already handles right-click.
	if stack and stack:get_name() == MOD .. ":plant_analyzer" then
		crop_analysis(pos, clicker)
		return stack
	end

	-- FertilizerItem.useOn equivalent. Node callbacks take precedence over an
	-- item's on_place callback in Luanti, so route fertilizer interaction here.
	local fertilizer = stack and fertilizers_by_item[stack:get_name()]
	if fertilizer then
		if apply_fertilizer(pos, stack, clicker, fertilizer) then return consume_one(stack, clicker) end
		return stack
	end

	-- CropBlock bonemeal growth (random 2..5 stages), including Grow Pot crops.
	if is_bonemeal(stack) then
		local age = get_crop_age(pos, info)
		if age < info.max_age then
			local increment = math.random(2, 5)
			if set_crop_age(pos, info, math.min(info.max_age, age + increment)) then
				minetest.sound_play("default_dig_snappy", {pos = pos, gain = 0.35, max_hear_distance = 8}, true)
				return consume_one(stack, clicker)
			end
		end
		return stack
	end

	-- Hemp can be sheared three times for leaves; the fourth shear harvests it.
	if info.family == "hemp" and is_shears(stack) and get_crop_age(pos, info) >= WEED_MAX_AGE then
		local pot_below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name == MOD .. ":grow_pot"
		if not pot_below then return hemp_on_rightclick(pos, node, clicker, stack) end
	end

	-- The Forge Grow Pot can harvest or remove its planted crop without destroying the pot.
	if stack and stack:is_empty() then
		local controls = clicker:get_player_control()
		local pot_below = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name == MOD .. ":grow_pot"
		if pot_below and controls and controls.sneak then
			remove_grow_pot_crop(pos, info, clicker)
		else
			harvest_grow_pot_crop(pos, info, clicker)
		end
	end
	return stack
end

local function override_crop_node(name, family, top)
	minetest.override_item(name, {
		drop = "",
		groups = crop_node_groups(family, top),
		on_dig = crop_on_dig,
		on_rightclick = crop_on_rightclick,
	})
end

for _, id in ipairs(strain_ids) do
	for stage = 1, 11 do
		override_crop_node(MOD .. ":weed_" .. id .. "_" .. stage, "weed", false)
	end
	for stage = 8, 11 do
		local stage_texture = 8
		local top_name = MOD .. ":weed_" .. id .. "_top_" .. stage
		minetest.register_node(top_name, {
			description = S("Tall Weed Crop Top"),
			drawtype = "plantlike",
			tiles = {"smokyleaf_industry_weed_" .. stage_texture .. ".png^[colorize:#" .. string.format("%06X", strains[id].color) .. ":18"},
			inventory_image = "smokyleaf_industry_weed_" .. stage_texture .. ".png",
			paramtype = "light", sunlight_propagates = true, walkable = false,
			buildable_to = true, floodable = true, waving = 1, drop = "",
			groups = crop_node_groups("weed", true),
			on_dig = crop_on_dig,
			on_rightclick = crop_on_rightclick,
		})
	end
end
for stage = 1, 11 do override_crop_node(MOD .. ":hemp_" .. stage, "hemp", false) end
for stage = 8, 11 do
	minetest.register_node(MOD .. ":hemp_top_" .. stage, {
		description = S("Tall Hemp Crop Top"), drawtype = "plantlike",
		tiles = {"smokyleaf_industry_hemp_8.png"}, inventory_image = "smokyleaf_industry_hemp_stage.png",
		paramtype = "light", sunlight_propagates = true, walkable = false,
		buildable_to = true, floodable = true, waving = 1, drop = "",
		groups = crop_node_groups("hemp", true), on_dig = crop_on_dig,
		on_rightclick = crop_on_rightclick,
	})
end
for stage = 1, 7 do override_crop_node(MOD .. ":tobacco_" .. stage, "tobacco", false) end

-- Preserve v1.0.0-v1.0.5 saved seed/crop/bud names by mapping obsolete placeholder
-- strain identities to the closest original Forge preset. New worlds see only the
-- original 25 strain names.
local legacy_strain_map = {
	purple_kush = "purple_haze", northern_lights = "white_widow", grandmaster_flash = "blue_cookies",
	strawberry_cough = "strawberry_shortcake", critical_mass = "bubble_kush", green_crack = "jack_herer",
	pineapple_express = "lemon_haze", durban_poison = "amnesia_haze", blue_dream = "blue_ice",
	girl_scout_cookies = "birthday_cake", gorilla_glue = "carbon_fiber", chemdawg = "sour_diesel",
	ak_47 = "ak47", super_lemon_haze = "lemon_haze", trainwreck = "ghost_train", skywalker_og = "og_kush",
	bruce_banner = "pink_kush", wedding_cake = "birthday_cake", midnight_express = "moonbow",
	cherry_pie = "strawberry_shortcake",
}
for old_id, new_id in pairs(legacy_strain_map) do
	for stage = 1, 8 do
		minetest.register_alias(MOD .. ":weed_" .. old_id .. "_" .. stage, MOD .. ":weed_" .. new_id .. "_" .. stage)
	end
	for _, prefix in ipairs({"seeds_", "buds_", "dried_buds_"}) do
		minetest.register_alias(MOD .. ":" .. prefix .. old_id, MOD .. ":" .. prefix .. new_id)
	end
end
minetest.register_alias(MOD .. ":weed_ak_47_9", MOD .. ":weed_ak47_9")
minetest.register_alias(MOD .. ":tobacco_8", MOD .. ":tobacco_7")
minetest.register_alias(MOD .. ":weed_ak_47_10", MOD .. ":weed_ak47_10")
minetest.register_alias(MOD .. ":weed_ak_47_11", MOD .. ":weed_ak47_11")
minetest.register_alias(MOD .. ":seeds_ak_47", MOD .. ":seeds_ak47")
minetest.register_alias(MOD .. ":buds_ak_47", MOD .. ":buds_ak47")
minetest.register_alias(MOD .. ":dried_buds_ak_47", MOD .. ":dried_buds_ak47")

-- One-time crop migration for existing worlds. Old v1.0.5 crops were single-block
-- 8-stage plants; stage 8 becomes age 7 and receives the original upper half.
local crop_lbm_nodes = {}
for _, id in ipairs(strain_ids) do for stage = 1, 11 do crop_lbm_nodes[#crop_lbm_nodes + 1] = MOD .. ":weed_" .. id .. "_" .. stage end end
for stage = 1, 11 do crop_lbm_nodes[#crop_lbm_nodes + 1] = MOD .. ":hemp_" .. stage end
for stage = 1, 7 do crop_lbm_nodes[#crop_lbm_nodes + 1] = MOD .. ":tobacco_" .. stage end
minetest.register_lbm({
	label = "Smokeleaf original cultivation data migration",
	name = MOD .. ":cultivation_v106_migration",
	nodenames = crop_lbm_nodes,
	run_at_every_load = false,
	action = function(pos, node)
		local info = parse_crop_name(node.name)
		if not info or info.top then return end
		local meta = minetest.get_meta(pos)
		if meta:get_string("cultivation_schema") == "2" then return end
		local age = clamp((info.stage or 1) - 1, 0, info.max_age)
		if info.family ~= "tobacco" and info.stage == 8 then age = info.max_age end
		meta:set_string("cultivation_schema", "2")
		meta:set_string("crop_family", info.family)
		meta:set_int("growth_age", age)
		if info.family == "hemp" and meta:get_int("ph") == 0 then meta:set_int("ph", 7) end
		if info.family == "weed" then
			local strain = strains[info.strain]
			meta:set_string("strain_id", info.strain)
			meta:set_int("thc", strain and strain.thc or 0)
			meta:set_int("cbd", strain and strain.cbd or 0)
			meta:set_int("nitrogen", 0); meta:set_int("phosphorus", 0); meta:set_int("potassium", 0)
		end
		local below = {x = pos.x, y = pos.y - 1, z = pos.z}
		if minetest.get_node(below).name == MOD .. ":grow_pot" then
			meta:set_int("growpot", 1)
			local pot_meta = minetest.get_meta(below)
			if pot_meta:get_string("pot_soil") == "" then pot_meta:set_string("pot_soil", "default:dirt") end
			meta:set_string("growpot_soil", pot_meta:get_string("pot_soil"))
		end
		if info.family ~= "tobacco" and age >= FIRST_TALL_AGE then update_tall_half(pos, info, age) end
	end,
})

-- Original Grow Pot full-cycle timer: 60 seconds with farmland soil, 90 seconds
-- with other inserted soil. It requires light >=12 and only accepts weed/hemp seeds.
local pot_crop_nodes = {}
for _, id in ipairs(strain_ids) do for stage = 1, 10 do pot_crop_nodes[#pot_crop_nodes + 1] = MOD .. ":weed_" .. id .. "_" .. stage end end
for stage = 1, 10 do pot_crop_nodes[#pot_crop_nodes + 1] = MOD .. ":hemp_" .. stage end
minetest.register_abm({
	label = "Smokeleaf Grow Pot original 60/90 second growth",
	nodenames = pot_crop_nodes,
	interval = 1,
	chance = 1,
	action = function(pos, node)
		local info = parse_crop_name(node.name)
		if not info or info.top or (info.family ~= "weed" and info.family ~= "hemp") then return end
		local below = {x = pos.x, y = pos.y - 1, z = pos.z}
		if minetest.get_node(below).name ~= MOD .. ":grow_pot" then return end
		if crop_light(pos) < 12 then return end
		local pot_meta = minetest.get_meta(below)
		local soil = pot_meta:get_string("pot_soil")
		if soil == "" then return end
		local duration = soil_is_farmland(soil) and 60 or 90
		local meta = minetest.get_meta(pos)
		local age = get_crop_age(pos, info)
		if age >= info.max_age then
			local cooldown = meta:get_int("auto_export_cooldown")
			if cooldown > 0 then
				meta:set_int("auto_export_cooldown", cooldown - 1)
			else
				meta:set_int("auto_export_cooldown", 20)
				try_grow_pot_auto_export(below, pos, info)
			end
			return
		end
		local progress = meta:get_float("pot_growth_progress") + 1
		local step_seconds = duration / info.max_age
		while progress >= step_seconds and age < info.max_age do
			progress = progress - step_seconds
			age = age + 1
			if not set_crop_age(pos, info, age) then break end
		end
		meta:set_float("pot_growth_progress", progress)
	end,
})

-- Minecraft random-tick emulation: default randomTickSpeed=3 over a 16^3 section
-- at 20 game ticks/second gives ~68 seconds between random ticks for a particular
-- crop. Each random tick then uses the original nextInt(floor(25/growthSpeed)+1)==0.
local natural_crop_nodes = {}
local tobacco_crop_nodes = {}
for _, id in ipairs(strain_ids) do for stage = 1, 10 do natural_crop_nodes[#natural_crop_nodes + 1] = MOD .. ":weed_" .. id .. "_" .. stage end end
for stage = 1, 10 do natural_crop_nodes[#natural_crop_nodes + 1] = MOD .. ":hemp_" .. stage end
for stage = 1, TOBACCO_MAX_AGE do tobacco_crop_nodes[#tobacco_crop_nodes + 1] = MOD .. ":tobacco_" .. stage end
minetest.register_abm({
	label = "Smokeleaf Forge-style weed and hemp random ticks",
	nodenames = natural_crop_nodes,
	interval = 1,
	chance = 68,
	action = function(pos, node)
		local info = parse_crop_name(node.name)
		if not info or info.top then return end
		local meta = minetest.get_meta(pos)
		if meta:get_int("growpot") == 1 or crop_support_name(pos) == MOD .. ":grow_pot" then return end
		roll_original_crop_growth(pos, info, true)
	end,
})
minetest.register_abm({
	label = "Smokeleaf vanilla tobacco random ticks",
	nodenames = tobacco_crop_nodes,
	interval = 1,
	chance = 68,
	action = function(pos, node)
		local info = parse_crop_name(node.name)
		if info and not info.top then roll_original_crop_growth(pos, info, false) end
	end,
})

-- Original grow lights: 3x3 search, five blocks below, vertical line of sight,
-- two candidates every 100 game ticks. As in Forge, the light's attempt uses
-- CropBlock#getLocalGrowthSpeed without the hemp natural-growth x3.5 multiplier.
local function line_clear_from_light(light_pos, crop_pos)
	for y = light_pos.y - 1, crop_pos.y + 1, -1 do
		if y > crop_pos.y then
			local block = minetest.get_node({x = crop_pos.x, y = y, z = crop_pos.z})
			local def = minetest.registered_nodes[block.name]
			if def and def.walkable ~= false then return false end
		end
	end
	return true
end

local function accelerate_below_light(light_pos, attempts)
	local candidates = {}
	for dx = -1, 1 do
		for dz = -1, 1 do
			for depth = 1, 5 do
				local p = {x = light_pos.x + dx, y = light_pos.y - depth, z = light_pos.z + dz}
				local info = parse_crop_name(minetest.get_node(p).name)
				local crop_support = {x = p.x, y = p.y - 1, z = p.z}
				if info and not info.top and (info.family == "weed" or info.family == "hemp")
					and minetest.get_node(crop_support).name ~= MOD .. ":grow_pot"
					and get_crop_age(p, info) < info.max_age and line_clear_from_light(light_pos, p) then
					candidates[#candidates + 1] = {pos = p, info = info}
				end
			end
		end
	end
	for _ = 1, math.min(attempts, #candidates) do
		local index = math.random(1, #candidates)
		local candidate = table.remove(candidates, index)
		local speed = crop_growth_speed(candidate.pos, candidate.info, false)
		local bound = math.floor(25 / speed) + 1
		if math.random(1, bound) == 1 then set_crop_age(candidate.pos, candidate.info, get_crop_age(candidate.pos, candidate.info) + 1) end
	end
end

minetest.register_abm({
	label = "Smokeleaf original grow light acceleration",
	nodenames = {MOD .. ":grow_light_led_active", MOD .. ":grow_light_hps_active"},
	interval = 5,
	chance = 1,
	action = function(pos) accelerate_below_light(pos, 2) end,
})

-- Original Reflector: insert an HPS/Dual Arc lamp, light output 15, one growth
-- attempt every 100 game ticks, and lamp life 18,000 / 54,000 game ticks.
local function set_reflector_state(pos, active)
	local node = minetest.get_node(pos)
	local target = active and (MOD .. ":reflector_active") or (MOD .. ":reflector")
	if node.name ~= target then minetest.swap_node(pos, {name = target, param2 = node.param2 or 0}) end
end

local function reflector_on_timer(pos, elapsed)
	local meta = minetest.get_meta(pos)
	local remaining = meta:get_int("lamp_remaining_ticks") - math.max(1, math.floor((elapsed or 1) * 20 + 0.5))
	if remaining <= 0 then
		meta:set_int("lamp_remaining_ticks", 0)
		meta:set_string("lamp_kind", "")
		meta:set_int("growth_tick_counter", 0)
		set_reflector_state(pos, false)
		meta:set_string("infotext", S("Reflector") .. " - Lamp burned out")
		return false
	end
	meta:set_int("lamp_remaining_ticks", remaining)
	local counter = meta:get_int("growth_tick_counter") + math.max(1, math.floor((elapsed or 1) * 20 + 0.5))
	if counter >= 100 then
		counter = counter % 100
		accelerate_below_light(pos, 1)
	end
	meta:set_int("growth_tick_counter", counter)
	meta:set_string("infotext", string.format("Reflector - %s (%d min remaining)", meta:get_string("lamp_kind"), math.ceil(remaining / 1200)))
	return true
end

local function reflector_rightclick(pos, node, player, stack)
	if not player or not player:is_player() or is_protected(pos, player) then return stack end
	local meta = minetest.get_meta(pos)
	local lamp_name = stack and stack:get_name() or ""
	local lamp_ticks = lamp_name == MOD .. ":hps_lamp" and 18000 or (lamp_name == MOD .. ":dual_arc_lamp" and 54000 or 0)
	if lamp_ticks > 0 and meta:get_int("lamp_remaining_ticks") <= 0 then
		local saved_ticks = stack:get_meta():get_int("remaining_ticks")
		local left = saved_ticks > 0 and math.min(lamp_ticks, saved_ticks) or lamp_ticks
		if left <= 0 then chat(player, S("This lamp is burned out."), "#F2C879"); return stack end
		meta:set_string("lamp_kind", lamp_name == MOD .. ":hps_lamp" and "HPS" or "Dual Arc")
		meta:set_int("lamp_remaining_ticks", left)
		meta:set_int("growth_tick_counter", 0)
		if not (minetest.is_creative_enabled and minetest.is_creative_enabled(player:get_player_name())) then stack:take_item() end
		set_reflector_state(pos, true)
		minetest.get_node_timer(pos):start(1)
		meta:set_string("infotext", S("Reflector") .. " - " .. meta:get_string("lamp_kind"))
		return stack
	end
	if (not stack or stack:is_empty()) and meta:get_int("lamp_remaining_ticks") > 0 then
		local kind = meta:get_string("lamp_kind")
		local name = kind == "HPS" and (MOD .. ":hps_lamp") or (MOD .. ":dual_arc_lamp")
		local max_ticks = kind == "HPS" and 18000 or 54000
		local lamp = itemstack(name, 1)
		lamp:get_meta():set_int("remaining_ticks", meta:get_int("lamp_remaining_ticks"))
		give_or_drop(player, pos, lamp)
		meta:set_int("lamp_remaining_ticks", 0)
		meta:set_string("lamp_kind", "")
		meta:set_int("growth_tick_counter", 0)
		set_reflector_state(pos, false)
		meta:set_string("infotext", S("Reflector") .. " - Empty")
		return stack
	end
	return stack
end

local function reflector_place(stack, placer, pointed)
	if not pointed or pointed.type ~= "node" or not pointed.under or not pointed.above then return stack end
	local place_pos = pointed.above
	local support_pos = {x = place_pos.x, y = place_pos.y + 1, z = place_pos.z}
	local support = minetest.get_node(support_pos)
	local support_def = minetest.registered_nodes[support.name]
	if not support_def or support.name == "air" or support_def.walkable == false then
		chat(placer, S("The Reflector must be mounted beneath a solid block."), "#F2C879")
		return stack
	end
	return minetest.item_place_node(stack, placer, pointed)
end

local function reflector_destruct(pos)
	local meta = minetest.get_meta(pos)
	local remaining = meta:get_int("lamp_remaining_ticks")
	if remaining <= 0 then return end
	local kind = meta:get_string("lamp_kind")
	local name = kind == "HPS" and (MOD .. ":hps_lamp") or (MOD .. ":dual_arc_lamp")
	local max_ticks = kind == "HPS" and 18000 or 54000
	local lamp = itemstack(name, 1)
	lamp:get_meta():set_int("remaining_ticks", remaining)
	minetest.add_item(pos, lamp)
end

minetest.register_craftitem(MOD .. ":hps_lamp", {
	description = S("HPS Lamp") .. "\n" .. S("15 minutes in a Reflector"),
	inventory_image = "smokyleaf_industry_hps_lamp.png", stack_max = 1,
	on_place = function(stack, placer, pointed) return stack end,
})
minetest.register_craftitem(MOD .. ":dual_arc_lamp", {
	description = S("Dual Arc Lamp") .. "\n" .. S("45 minutes in a Reflector"),
	inventory_image = "smokyleaf_industry_dual_arc_lamp.png", stack_max = 1,
	on_place = function(stack, placer, pointed) return stack end,
})

local reflector_def = {
	description = S("Reflector"),
	drawtype = "nodebox",
	node_box = {type = "fixed", fixed = {-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}},
	selection_box = {type = "fixed", fixed = {-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}},
	collision_box = {type = "fixed", fixed = {-0.5, 0.25, -0.5, 0.5, 0.5, 0.5}},
	paramtype = "light", paramtype2 = "facedir", sunlight_propagates = true,
	walkable = false, tiles = {"smokyleaf_industry_reflector.png"},
	groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2},
	drop = MOD .. ":reflector", on_rightclick = reflector_rightclick,
	on_destruct = reflector_destruct,
	on_place = reflector_place,
}
minetest.register_node(MOD .. ":reflector", reflector_def)
minetest.override_item(MOD .. ":reflector", {on_place = reflector_place})
local reflector_active_def = table.copy(reflector_def)
reflector_active_def.description = S("Reflector (Lamp Installed)")
reflector_active_def.tiles = {"smokyleaf_industry_reflector_active.png"}
reflector_active_def.light_source = 15
reflector_active_def.groups = {snappy = 2, choppy = 2, oddly_breakable_by_hand = 2, not_in_creative_inventory = 1}
reflector_active_def.on_timer = reflector_on_timer
minetest.register_node(MOD .. ":reflector_active", reflector_active_def)

-- Register these recipes after their output nodes/items exist, and after HPS Lamp
-- is registered so the Dual Arc Lamp ingredient is not filtered out.
add_optional_craft(MOD .. ":reflector", {{"default:steel_ingot", MOD .. ":hemp_rope", "default:steel_ingot"}, {MOD .. ":hemp_fiber", "default:glass", MOD .. ":hemp_fiber"}, {"default:steel_ingot", MOD .. ":hemp_rope", "default:steel_ingot"}}, false)
add_optional_craft(MOD .. ":hps_lamp", {{"default:glass", "default:glass", "default:glass"}, {"default:coal_lump", "default:torch", "default:coal_lump"}, {"default:glass", "default:glass", "default:glass"}}, false)
add_optional_craft(MOD .. ":dual_arc_lamp", {{"default:steel_ingot", "default:diamond", "default:steel_ingot"}, {"default:glass", MOD .. ":hps_lamp", "default:glass"}}, false)

-- One-time metadata migration for old stage nodes and existing Grow Pots.
minetest.register_lbm({
	label = "Smokeleaf Grow Pot soil compatibility",
	name = MOD .. ":grow_pot_soil_v106",
	nodenames = {MOD .. ":grow_pot"},
	run_at_every_load = false,
	action = function(pos)
		local meta = minetest.get_meta(pos)
		if meta:get_string("pot_soil") == "" then
			local above = {x = pos.x, y = pos.y + 1, z = pos.z}
			if parse_crop_name(minetest.get_node(above).name) then
				meta:set_string("pot_soil", "default:dirt")
				meta:set_string("infotext", S("Grow Pot") .. " - default:dirt")
			end
		end
	end,
})

-- Expose cultivation queries for other Lua mods and future machines.
smokyleaf_industry.get_crop_stats = function(pos)
	local node = minetest.get_node(pos)
	local info = parse_crop_name(node.name)
	if not info then return nil end
	if info.top then pos = {x = pos.x, y = pos.y - 1, z = pos.z}; node = minetest.get_node(pos); info = parse_crop_name(node.name) end
	if not info then return nil end
	local meta = minetest.get_meta(pos)
	local strain = info.family == "weed" and strains[info.strain] or nil
	return {
		family = info.family,
		strain = info.strain,
		age = get_crop_age(pos, info),
		max_age = info.max_age,
		thc = strain and calculate_genetic_stat(strain.thc, meta, strain) or 0,
		cbd = strain and calculate_genetic_stat(strain.cbd, meta, strain) or 0,
		nitrogen = meta:get_int("nitrogen"),
		phosphorus = meta:get_int("phosphorus"),
		potassium = meta:get_int("potassium"),
		optimal_n = strain and strain.n or 0,
		optimal_p = strain and strain.p or 0,
		optimal_k = strain and strain.k or 0,
		bud_count = strain and calculate_bud_count(meta, strain) or 1,
		npk_optimal = strain and meta:get_int("nitrogen") == strain.n
			and meta:get_int("phosphorus") == strain.p and meta:get_int("potassium") == strain.k or false,
		npk_within_tolerance = strain and math.abs(meta:get_int("nitrogen") - strain.n) <= NPK_TOLERANCE
			and math.abs(meta:get_int("phosphorus") - strain.p) <= NPK_TOLERANCE
			and math.abs(meta:get_int("potassium") - strain.k) <= NPK_TOLERANCE or false,
		is_in_grow_pot = minetest.get_node({x = pos.x, y = pos.y - 1, z = pos.z}).name == MOD .. ":grow_pot",
		ph = meta:get_int("ph"),
	}
end

minetest.log("action", "[Smokeleaf Industries] Original-style cultivation loaded: 25 strains, 17 fertilizers, 11-age weed/hemp, 7-age tobacco, Grow Pot and Reflector.")
