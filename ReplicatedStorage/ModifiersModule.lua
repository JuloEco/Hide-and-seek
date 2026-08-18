--[[
    ModifiersModule - Gère les modificateurs de salle
]]

local ModifiersModule = {}

-- Liste des modificateurs disponibles
ModifiersModule.Modifiers = {
    {
        id = "no_stay",
        name = "Interdiction de rester immobile",
        description = "Vous ne pouvez pas rester plus de 30 secondes dans la même position",
        duration = 30,
        category = "mouvement"
    },
    {
        id = "must_move",
        name = "Mouvement constant",
        description = "Vous devez constamment bouger pour maintenir votre camouflage",
        duration = 0,
        category = "mouvement"
    },
    {
        id = "color_change",
        name = "Changement de couleur aléatoire",
        description = "Votre couleur change aléatoirement toutes les 10 secondes",
        duration = 10,
        category = "apparence",
        apply = function(player)
            local CamouflageModule = require(game:GetService("ReplicatedStorage").CamouflageModule)
            local colors = CamouflageModule.getColorPalette()
            local randomColor = colors[math.random(#colors)]
            CamouflageModule.applyColor(player, {color = randomColor})
        end
    },
    {
        id = "invisibility",
        name = "Invisibilité temporaire",
        description = "Vous êtes partiellement invisible pendant 15 secondes",
        duration = 15,
        category = "spécial",
        apply = function(player)
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0.7
                    end
                end
            end
        end,
        remove = function(player)
            if player.Character then
                for _, part in ipairs(player.Character:GetDescendants()) do
                    if part:IsA("BasePart") then
                        part.Transparency = 0
                    end
                end
            end
        end
    },
    {
        id = "freeze",
        name = "Gel temporaire",
        description = "Vous ne pouvez pas bouger pendant 10 secondes",
        duration = 10,
        category = "mouvement",
        apply = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 0
                player.Character.Humanoid.JumpPower = 0
            end
        end,
        remove = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
                player.Character.Humanoid.JumpPower = 50
            end
        end
    },
    {
        id = "speed_boost",
        name = "Boost de vitesse",
        description = "Votre vitesse de déplacement est doublée pendant 20 secondes",
        duration = 20,
        category = "mouvement",
        apply = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 32
            end
        end,
        remove = function(player)
            if player.Character and player.Character:FindFirstChild("Humanoid") then
                player.Character.Humanoid.WalkSpeed = 16
            end
        end
    }
}

-- Activation d'un modificateur
function ModifiersModule.activateModifier(modifierId, player)
    for _, modifier in ipairs(ModifiersModule.Modifiers) do
        if modifier.id == modifierId then
            if modifier.apply then
                modifier.apply(player)
            end
            return true
        end
    end
    return false
end

-- Désactivation d'un modificateur
function ModifiersModule.deactivateModifier(modifierId, player)
    for _, modifier in ipairs(ModifiersModule.Modifiers) do
        if modifier.id == modifierId then
            if modifier.remove then
                modifier.remove(player)
            end
            return true
        end
    end
    return false
end

-- Obtention d'un modificateur par son ID
function ModifiersModule.getModifier(modifierId)
    for _, modifier in ipairs(ModifiersModule.Modifiers) do
        if modifier.id == modifierId then
            return modifier
        end
    end
    return nil
end

-- Obtention de tous les modificateurs
function ModifiersModule.getAllModifiers()
    return ModifiersModule.Modifiers
end

-- Obtention des modificateurs par catégorie
function ModifiersModule.getModifiersByCategory(category)
    local result = {}
    for _, modifier in ipairs(ModifiersModule.Modifiers) do
        if modifier.category == category then
            table.insert(result, modifier)
        end
    end
    return result
end

return ModifiersModule
