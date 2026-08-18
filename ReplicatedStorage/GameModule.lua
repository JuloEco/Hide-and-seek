--[[
    GameModule - Module principal du jeu
    Contient les constantes et fonctions utilitaires
]]

local GameModule = {}

-- Configuration du jeu
GameModule.Config = {
    PreparationTime = 180,    -- 3 minutes en secondes
    GameTime = 300,           -- 5 minutes en secondes
    MinPlayers = 2,
    MaxSeekers = 2,
    DetectionDistance = 5,    -- Distance en studs pour détecter un joueur
    
    -- Palette de couleurs pour le camouflage
    Colors = {
        White = Color3.new(1, 1, 1),
        Black = Color3.new(0, 0, 0),
        Red = Color3.new(1, 0, 0),
        Green = Color3.new(0, 1, 0),
        Blue = Color3.new(0, 0, 1),
        Yellow = Color3.new(1, 1, 0),
        Cyan = Color3.new(0, 1, 1),
        Magenta = Color3.new(1, 0, 1),
        
        -- Nuances de gris
        LightGray = Color3.new(0.8, 0.8, 0.8),
        MediumGray = Color3.new(0.5, 0.5, 0.5),
        DarkGray = Color3.new(0.2, 0.2, 0.2),
        
        -- Couleurs pastel
        Pink = Color3.new(1, 0.7, 0.75),
        MintGreen = Color3.new(0.7, 1, 0.8),
        PastelBlue = Color3.new(0.7, 0.8, 1),
        PastelYellow = Color3.new(1, 0.9, 0.7),
        
        -- Couleurs terre
        Brown = Color3.new(0.4, 0.2, 0.1),
        Beige = Color3.new(0.9, 0.85, 0.7),
        Orange = Color3.new(1, 0.5, 0),
        
        -- Couleurs métalliques
        Gold = Color3.new(1, 0.8, 0.2),
        Silver = Color3.new(0.8, 0.8, 0.9),
        Copper = Color3.new(0.8, 0.5, 0.3)
    },
    
    -- Positions disponibles
    Poses = {
        "Standing",
        "Sitting", 
        "Lying",
        "Crouching"
    },
    
    -- Formes géométriques disponibles
    Shapes = {
        "Triangle",
        "Square",
        "Pentagon",
        "Hexagon",
        "Circle"
    }
}

-- Fonctions utilitaires
function GameModule.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

function GameModule.lerp(a, b, t)
    return a + (b - a) * t
end

function GameModule.distance(pos1, pos2)
    if pos1 and pos2 then
        return (pos1 - pos2).Magnitude
    end
    return 0
end

function GameModule.randomColor()
    local colors = {}
    for _, color in pairs(GameModule.Config.Colors) do
        table.insert(colors, color)
    end
    return colors[math.random(#colors)]
end

-- Vérification si un joueur est un chercheur
function GameModule.isSeeker(player, seekers)
    for _, p in ipairs(seekers) do
        if p == player then
            return true
        end
    end
    return false
end

-- Vérification si un joueur est un cacheur
function GameModule.isHider(player, hiders)
    for _, p in ipairs(hiders) do
        if p == player then
            return true
        end
    end
    return false
end

return GameModule
