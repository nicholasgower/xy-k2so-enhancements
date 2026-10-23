local utils = {}

local t = data.raw.technology

--- Returns the first (arbitrary) key for a given value.
--- @param tbl table The table to search.
--- @param value any The value to search for.
--- @return any key key associated with the given value.
local function table_find(tbl, value)
	for i, v in pairs(tbl) do
		if (v == value) then
			return i
		end
	end
end
utils.table_find = table_find

--- Determines if a table contains a given value.
--- @param tbl table The table to search.
--- @param value any The value to search for.
--- @return boolean contained Set if the value is contained in the given table.
local function table_contains(tbl, value)
	return table_find(tbl, value) ~= nil
end
utils.table_contains = table_contains

--- Inserts a value into a table, if it doesn't already exist as a value.
--- @param tbl table
--- @param value any
local function insert_unique(tbl, value)
	if (table_contains(tbl, value)) then
		return false
	end
	table.insert(tbl, value)
	return true
end
utils.insert_unique = insert_unique

local function add_preqs(tech, preqs)
    local prototype = t[tech]
    if prototype == nil then
        return
    end

    for _, prereq in ipairs(preqs) do
        insert_unique(prototype.prerequisites, prereq)
    end
end
utils.tech_add_preqs = add_preqs

local function remove_preqs(tech, preqs_to_remove) -- Should be used before add_preqs() if both are needed
    if t[tech] then
        for _,to_remove in pairs(preqs_to_remove) do
            for i,existing_preq in pairs(t[tech].prerequisites) do
                if existing_preq == to_remove then
                    table.remove(t[tech].prerequisites, i)
                end
            end
        end
    end
end
utils.tech_remove_preqs = remove_preqs

local function remove_cards(tech, cards_to_remove) -- Should be used before add_preqs() if both are needed
    if t[tech] then
        for _,to_remove in pairs(cards_to_remove) do
            for i,existing_card in pairs(t[tech].unit.ingredients) do
                if existing_card[1] == to_remove then
                    table.remove(t[tech].unit.ingredients, i)
                end
            end
        end
    end
end
utils.tech_remove_cards = remove_cards

local function add_card(tech, card_to_add)
    local tech_prototype = t[tech]
    if (not tech_prototype) then
        log(tech..' - Tech does not exist!')
        return
    end

    for _, ingredient in ipairs(tech_prototype.unit.ingredients) do
        if (ingredient[1] == card_to_add) then
            return
        end
    end

    table.insert(tech_prototype.unit.ingredients, {card_to_add, 1})
end
utils.tech_add_card = add_card

local function order_from_index(list, prototype, lead)
    local lead = lead or 'z'
    for index,item in pairs(list) do
        local v = data.raw[prototype][item]
        if v then 
            local extra = ''
            if index < 10 then extra = '0' end
            v.order = lead..extra..tostring(index)
        end
    end
end
utils.order_from_index = order_from_index

local function replace_ingredient_name(recipe, old, new) -- Just for item names, good for swapping equiv. items
    local r = data.raw.recipe[recipe]
    if r then
        for _,v in pairs(r.ingredients) do
            if v.name == old then
                v.name = new
            end
        end
    end
end
utils.replace_ingred_name = replace_ingredient_name

--- Copies fluidbox metadata from old fluid entries to matching new entries.
--- Recipe rewrites that replace the whole ingredient/result table otherwise
--- discard indexes added by compatibility mods such as Muluna's data ports.
--- @param old_entries table|nil
--- @param new_entries table|nil
local function copy_fluidbox_metadata(old_entries, new_entries)
    for _, new_entry in ipairs(new_entries or {}) do
        if new_entry.type == 'fluid' then
            for _, old_entry in ipairs(old_entries or {}) do
                if old_entry.type == 'fluid' and old_entry.name == new_entry.name then
                    if old_entry.fluidbox_index ~= nil then
                        new_entry.fluidbox_index = old_entry.fluidbox_index
                    end
                    if old_entry.optional_fluidbox_indexes ~= nil then
                        new_entry.optional_fluidbox_indexes =
                            table.deepcopy(old_entry.optional_fluidbox_indexes)
                    end
                    break
                end
            end
        end
    end
end
utils.copy_fluidbox_metadata = copy_fluidbox_metadata

--- Replaces a recipe's ingredients while preserving fluidbox indexes.
--- @param recipe_name string
--- @param ingredients table
--- @return table|nil recipe
local function replace_recipe_ingredients(recipe_name, ingredients)
    local recipe = data.raw.recipe[recipe_name]
    if recipe == nil then
        return nil
    end
    copy_fluidbox_metadata(recipe.ingredients, ingredients)
    recipe.ingredients = ingredients
    return recipe
end
utils.replace_recipe_ingredients = replace_recipe_ingredients

--- Replaces a recipe's results while preserving fluidbox indexes.
--- @param recipe_name string
--- @param results table
--- @return table|nil recipe
local function replace_recipe_results(recipe_name, results)
    local recipe = data.raw.recipe[recipe_name]
    if recipe == nil then
        return nil
    end
    copy_fluidbox_metadata(recipe.results, results)
    recipe.results = results
    return recipe
end
utils.replace_recipe_results = replace_recipe_results

--- @param entity_type string
--- @param entity_id string
--- @param planet_id string
function utils.relax_conditions_for_planet(entity_type, entity_id, planet_id)
	local surface = data.raw["planet"][planet_id]
	if (surface == nil) then
		return
	end

	local prototype = data.raw[entity_type][entity_id]
	if (prototype == nil) then
		return nil
	end

	local surface_properties = surface.surface_properties or {}
	for _, condition in ipairs(prototype.surface_conditions or {}) do
		local surface_condition = surface_properties[condition.property]
		if (surface_condition) then
			if (condition.min > surface_condition) then
				condition.min = surface_condition
			end
			if (condition.max < surface_condition) then
				condition.max = surface_condition
			end
		end
	end
end

function utils.insert_unique(t, value)
    for _, v in ipairs(t) do
        if (v == value) then
            return
        end
    end
    table.insert(t, value)
end

return utils
