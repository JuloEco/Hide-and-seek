--[[
    CamouflageModule - Gère les mécaniques de camouflage
]]

local CamouflageModule = {}
local GameModule = require(script.Parent.GameModule)

-- Application du camouflage
function CamouflageModule.applyCamouflage(player, camouflageType, camouflageData)
    if not player.Character then return end
    
    if camouflageType == "color" then
        CamouflageModule.applyColor(player, camouflageData)
    elseif camouflageType == "pose" then
        CamouflageModule.applyPose(player, camouflageData)
    elseif camouflageType == "object" then
        CamouflageModule.applyObject(player, camouflageData)
    elseif camouflageType == "shape" then
        CamouflageModule.applyShape(player, camouflageData)
    end
end

-- Application d'une couleur
function CamouflageModule.applyColor(player, colorData)
    if not player.Character then return end
    
    local color = colorData.color or Color3.new(1, 1, 1)
    
    for _, part in ipairs(player.Character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = color
            part.Material = Enum.Material.SmoothPlastic
        end
    end
end

-- Application d'une pose
function CamouflageModule.applyPose(player, poseData)
    if not player.Character then return end
    
    local pose = poseData.pose or "Standing"
    local humanoid = player.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    
    if pose == "Sitting" then
        humanoid.Sit = true
    elseif pose == "Lying" then
        humanoid.WalkSpeed = 0
        humanoid.JumpPower = 0
    elseif pose == "Crouching" then
        humanoid.WalkSpeed = 8
        humanoid.HipHeight = 0.5
    elseif pose == "Standing" then
        humanoid.Sit = false
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.HipHeight = 2
    end
end

-- Application d'une transformation en objet
function CamouflageModule.applyObject(player, objectData)
    if not player.Character then return end
    
    local color = objectData.color or Color3.new(0.8, 0.8, 0.8)
    CamouflageModule.applyColor(player, {color = color})
end

-- Application d'une transformation en forme géométrique
function CamouflageModule.applyShape(player, shapeData)
    if not player.Character then return end
    
    local color = shapeData.color or Color3.new(0.8, 0.8, 0.8)
    CamouflageModule.applyColor(player, {color = color})
    
    if player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 0
    end
end

-- Vérification si un joueur est bien camouflé
function CamouflageModule.isWellCamouflaged(player, room)
    if not player.Character then return false end
    
    local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return false end
    
    local playerColor = humanoidRoot.Color
    
    -- Comparer avec les couleurs des objets de la salle
    if room and room.objects then
        for _, obj in ipairs(room.objects) do
            local colorDistance = CamouflageModule.colorDistance(playerColor, obj.color)
            if colorDistance < 0.3 then
                return true
            end
        end
    end
    
    -- Si la couleur est proche du blanc, ce n'est pas un bon camouflage
    local whiteDistance = CamouflageModule.colorDistance(playerColor, Color3.new(1, 1, 1))
    if whiteDistance < 0.1 then
        return false
    end
    
    return false
end

-- Calcul de la distance entre deux couleurs
function CamouflageModule.colorDistance(color1, color2)
    local rDiff = color1.R - color2.R
    local gDiff = color1.G - color2.G
    local bDiff = color1.B - color2.B
    
    return math.sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
end

-- Réinitialisation du personnage
function CamouflageModule.resetCharacter(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Color = Color3.new(1, 1, 1)
            part.Material = Enum.Material.SmoothPlastic
        end
    end
    
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if humanoid then
        humanoid.Sit = false
        humanoid.WalkSpeed = 16
        humanoid.JumpPower = 50
        humanoid.HipHeight = 2
    end
end

-- Obtention de la palette de couleurs
function CamouflageModule.getColorPalette()
    return GameModule.Config.Colors
end

-- Obtention des poses disponibles
function CamouflageModule.getPoses()
    return GameModule.Config.Poses
end

-- Obtention des formes disponibles
function CamouflageModule.getShapes()
    return GameModule.Config.Shapes
end

return CamouflageModule
