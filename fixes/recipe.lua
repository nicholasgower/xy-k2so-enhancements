local util = require('util.util')

local function add_additional_category(recipe, category)
    local prototype = data.raw['recipe'][recipe]
    if prototype then
        if prototype.categories then
            for _, existing_category in ipairs(prototype.categories) do
                if (existing_category == category) then
                    return
                end
            end
            table.insert(prototype.categories, category)
        else
            prototype.categories = { "crafting", category }
        end
    end
end

local function add_additional_categories(recipes, category) -- Passing nil recipes or recipes with nil or existing additiona_categories is safe
    for _, r in pairs(recipes) do
        add_additional_category(r, category)
    end
end

local function add_ingredient_if_missing(name, ingredient_type, ingredient, amount)
    local recipe = data.raw.recipe[name]
    if (not recipe) then
        return
    end

    for _, existing in ipairs(recipe.ingredients or {}) do
        if (existing.type == ingredient_type and existing.name == ingredient) then
            return
        end
    end

    table.insert(recipe.ingredients, { type = ingredient_type, name = ingredient, amount = amount })
end

if mods['planet-muluna'] and mods['Moshine'] then
    -- Rework "Solar panel from silicon cell" recipe to be more effective instead of just being the same thing but with aluminum
    -- 5 silicon replaced with 1 silicon cell, steel plate replaced with aluminum electronic circuit requirement removed,
    -- Crafting time and most inputs 3x, but output 4x
    data.raw['recipe']['muluna-silicon-solar-panel'].energy_required = 30
    data.raw['recipe']['muluna-silicon-solar-panel'].ingredients = {
        {type = 'item', name = 'silicon-cell', amount = 4},
        {type = 'item', name = 'kr-iron-beam', amount = 12},
        {type = 'item', name = 'aluminum-plate', amount = 15},
        {type = 'item', name = 'kr-glass', amount = 30},
    }
    data.raw['recipe']['muluna-silicon-solar-panel'].results = {
        {type = 'item', name = 'solar-panel', amount = 4},
    }
end

if settings.startup['xy-processing-unit-alt'].value then
    if mods['Cerys-Moon-of-Fulgora'] then
        data.raw['recipe']['cerys-processing-units-from-nitric-acid'].energy_required = 12
        data.raw['recipe']['cerys-processing-units-from-nitric-acid'].surface_conditions = {
            {property = 'magnetic-field',
            min = 100,}
        }
        util.replace_recipe_ingredients('cerys-processing-units-from-nitric-acid', {
            {type = 'item', name = 'electronic-circuit', amount = 3}, 
            {type = 'item', name = 'advanced-circuit', amount = 6},
            {type = 'fluid', name = 'kr-nitric-acid', amount = 10},
        })
        util.replace_recipe_results('cerys-processing-units-from-nitric-acid', {
            {type = 'item', name = 'processing-unit', amount = 2},
        })
    end
    if mods['Paracelsin'] then -- This recipe is supposed to be an upgrade to the rare metals recipe isntead of being forced usage, so reduced time and adv circuits
        data.raw['recipe']['paracelsin-processing-units-from-nitric-acid'].energy_required = 10
        util.replace_recipe_ingredients('paracelsin-processing-units-from-nitric-acid', {
            {type = 'item', name = 'zinc-solder', amount = 3}, 
            {type = 'item', name = 'advanced-circuit', amount = 5},
            {type = 'fluid', name = 'nitric-acid', amount = 10},
        })
        util.replace_recipe_results('paracelsin-processing-units-from-nitric-acid', {
            {type = 'item', name = 'processing-unit', amount = 2},
        })
    end
    if mods['apia'] then -- Update to Apia's Processing Unit recipe to bring it in line with other K2SO Processing Unit recipes
        util.replace_recipe_ingredients('processing-unit-from-phosphoric-acid', {
            {type = 'item', name = 'polysaccharides', amount = 8},
            {type = 'item', name = 'advanced-circuit', amount = 6},
            {type = "fluid", name = "phosphoric-acid", amount = 10}
        })
        util.replace_recipe_results('processing-unit-from-phosphoric-acid', {
            {type = 'item', name = 'processing-unit', amount = 2},
        })
    end

    --[[data.raw['recipe']['kr-bio-processing-circuit'].ingredients = { -- Patched into basically this in the main mod now
        {type = 'item', name = 'advanced-circuit', amount = 6}, -- use more
        {type = 'item', name = 'pentapod-egg', amount = 1},
        {type = 'fluid', name = 'sulfuric-acid', amount = 10},
    }
    data.raw['recipe']['kr-bio-processing-circuit'].category = {'organic-or-assembling'}]] -- changed from EM plant
end

if settings.startup['xy-lab-recipe-changes'].value then
    data.raw['item']['biolab'].weight = 200 * kg

    if mods['Paracelsin'] and mods['planet-muluna'] then
        util.replace_recipe_ingredients('cryolab', {
            {type = 'item', name = 'aluminum-plate', amount = 200},
            {type = 'item', name = 'quantum-processor', amount = 25},
            {type = 'item', name = 'electric-coil', amount = 25},
            {type = 'item', name = 'pentapod-egg', amount = 5},
            {type = 'item', name = 'biolab', amount = 3},
            {type = 'fluid', name = 'fluoroketone-cold', amount = 250},
        })
    end
end

if settings.startup['xy-spidertron-fish'].value then
    table.insert(data.raw.recipe['spidertron'].ingredients, {type = 'item', name = 'raw-fish', amount = 1})
end

if settings.startup['xy-mechanical-plant-more-recipes'].value and mods['Paracelsin'] then
    local recipes = require('util.lists')['mechanical-plant-more-recipes']
    add_additional_categories(recipes, 'mechanics')
end

if settings.startup['xy-secretas-polish'].value and mods['secretas'] then
    data.raw.recipe['speed-module-4-S'].ingredients = {
        {type = 'item', name = 'gold-plate', amount = 5},
        {type = 'item', name = 'quantum-processor', amount = 5},
        {type = 'item', name = 'kr-ai-core', amount = 5},
        {type = 'item', name = 'tungsten-plate', amount = 5},
        {type = 'item', name = 'speed-module-3', amount = 4},
    }
    data.raw.recipe['efficiency-module-4-S'].ingredients = {
        {type = 'item', name = 'gold-plate', amount = 5},
        {type = 'item', name = 'quantum-processor', amount = 5},
        {type = 'item', name = 'kr-ai-core', amount = 5},
        {type = 'item', name = 'bioflux', amount = 5},
        {type = 'item', name = 'efficiency-module-3', amount = 4},
    }
    data.raw.recipe['productivity-module-4-S'].ingredients = {
        {type = 'item', name = 'gold-plate', amount = 5},
        {type = 'item', name = 'quantum-processor', amount = 5},
        {type = 'item', name = 'kr-ai-core', amount = 5},
        {type = 'item', name = 'golden-biter-egg', amount = 5},
        {type = 'item', name = 'productivity-module-3', amount = 4},
    }
    data.raw.recipe['quality-module-4-S'].ingredients = {
        {type = 'item', name = 'gold-plate', amount = 5},
        {type = 'item', name = 'quantum-processor', amount = 5},
        {type = 'item', name = 'kr-ai-core', amount = 5},
        {type = 'item', name = 'supercapacitor', amount = 5},
        {type = 'item', name = 'quality-module-3', amount = 4},
    }
    data.raw.recipe['gold-railgun-turret'].ingredients = { -- WTF is this base recipe??
        {type = 'item', name = 'gold-plate', amount = 200},
        {type = 'item', name = 'kr-ai-core', amount = 50},
        {type = 'item', name = 'kr-imersium-beam', amount = 40},
        {type = 'item', name = 'supercapacitor', amount = 50},
        {type = 'item', name = 'railgun-turret', amount = 1},
    }
    local ingr0 = 'steel-plate'
    if mods['Paracelsin'] then ingr0 = 'zinc-solder' end
    data.raw.recipe['gold-heat-pipe'].ingredients = {
        {type = 'item', name = 'heat-pipe', amount = 1},
        {type = 'item', name = 'gold-plate', amount = 10},
        {type = 'item', name = ingr0, amount = 2},
    }
    data.raw['ammo-turret']['gold-railgun-turret'].subgroup = 'kr-railgun-turret'
    data.raw['ammo-turret']['gold-railgun-turret'].order = 'a02[gold-railgun-turret]'
    
    local ingr1 = 'quantum-processor'
    if mods['Paracelsin'] then ingr1 = 'electric-coil' end
    data.raw.recipe['hyper-inserter'].ingredients = { -- WTF is this base recipe part 2
        {type = 'item', name = 'gold-plate', amount = 10},
        {type = 'item', name = 'kr-ai-core', amount = 1},
        {type = 'item', name = ingr1, amount = 5},
        {type = 'item', name = 'supercapacitor', amount = 1},
        {type = 'item', name = 'kr-superior-inserter', amount = 1},
    }
end

if mods['rubia'] then
    data.raw.recipe['rubia-biofusion-promethium-science-pack'].icons[1].icon = '__k2so-assets__/icons/cards/promethium-research-data.png'
end
