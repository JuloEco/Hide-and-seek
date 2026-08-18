--[[
    Hide and Seek - Script d'installation automatique
    
    INSTRUCTIONS :
    1. Copiez ce script dans un Script dans ServerScriptService
    2. Exécutez le jeu une fois (Play button)
    3. Le jeu sera automatiquement installé
    4. Vous pouvez supprimer ce script après l'installation
    
    Ce script crée :
    - Tous les dossiers nécessaires
    - Tous les scripts Lua
    - La salle par défaut
    - L'interface utilisateur
]]

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterPlayerScripts = game:GetService("StarterPlayerScripts")
local StarterGui = game:GetService("StarterGui")
local ServerStorage = game:GetService("ServerStorage")

local function createScript(parent, name, source)
    local script = Instance.new("Script")
    script.Name = name
    script.Source = source
    script.Parent = parent
    return script
end

local function createModuleScript(parent, name, source)
    local module = Instance.new("ModuleScript")
    module.Name = name
    module.Source = source
    module.Parent = parent
    return module
end

-- Script principal du serveur
local mainGameServerSource = [[
--[=[    Hide and Seek - Script principal côté serveur    ]]=]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local GameModule = require(ReplicatedStorage:WaitForChild("GameModule"))
local RoomModule = require(ReplicatedStorage:WaitForChild("RoomModule"))
local CamouflageModule = require(ReplicatedStorage:WaitForChild("CamouflageModule"))

local RemoteEvents = Instance.new("Folder")
RemoteEvents.Name = "RemoteEvents"
RemoteEvents.Parent = ReplicatedStorage

local StartGameEvent = Instance.new("RemoteEvent")
StartGameEvent.Name = "StartGame"
StartGameEvent.Parent = RemoteEvents

local EndGameEvent = Instance.new("RemoteEvent")
EndGameEvent.Name = "EndGame"
EndGameEvent.Parent = RemoteEvents

local SelectRoomEvent = Instance.new("RemoteEvent")
SelectRoomEvent.Name = "SelectRoom"
SelectRoomEvent.Parent = RemoteEvents

local ApplyCamouflageEvent = Instance.new("RemoteEvent")
ApplyCamouflageEvent.Name = "ApplyCamouflage"
ApplyCamouflageEvent.Parent = RemoteEvents

local PlayerDetectedEvent = Instance.new("RemoteEvent")
PlayerDetectedEvent.Name = "PlayerDetected"
PlayerDetectedEvent.Parent = RemoteEvents

local UpdateTimerEvent = Instance.new("RemoteEvent")
UpdateTimerEvent.Name = "UpdateTimer"
UpdateTimerEvent.Parent = RemoteEvents

local SetGamePhaseEvent = Instance.new("RemoteEvent")
SetGamePhaseEvent.Name = "SetGamePhase"
SetGamePhaseEvent.Parent = RemoteEvents

local gameState = {
    currentRoom = nil,
    gamePhase = "waiting",
    players = {},
    seekers = {},
    hiders = {},
    preparationTime = 180,
    gameTime = 300,
    timeRemaining = 0,
    selectedRoom = "DefaultRoom"
}

local function onPlayerAdded(player)
    gameState.players[player] = {
        isSeeker = false,
        isHider = false,
        detected = false,
        score = 0,
        character = nil
    }
    
    player.CharacterAdded:Connect(function(character)
        gameState.players[player].character = character
        for _, part in ipairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.Color = Color3.new(1, 1, 1)
                part.Material = Enum.Material.SmoothPlastic
            end
        end
    end)
end

Players.PlayerAdded:Connect(onPlayerAdded)
for _, player in ipairs(Players:GetPlayers()) do onPlayerAdded(player) end

SelectRoomEvent.OnServerEvent:Connect(function(player, roomName)
    gameState.selectedRoom = roomName
end)

StartGameEvent.OnServerEvent:Connect(function(player)
    if gameState.gamePhase ~= "waiting" then return end
    
    gameState.seekers = {}
    gameState.hiders = {}
    local playersList = {}
    for p, _ in pairs(gameState.players) do table.insert(playersList, p) end
    
    for i = #playersList, 2, -1 do
        local j = math.random(i)
        playersList[i], playersList[j] = playersList[j], playersList[i]
    end
    
    local numSeekers = math.min(2, #playersList)
    for i = 1, numSeekers do
        gameState.players[playersList[i]].isSeeker = true
        table.insert(gameState.seekers, playersList[i])
    end
    for i = numSeekers + 1, #playersList do
        gameState.players[playersList[i]].isHider = true
        table.insert(gameState.hiders, playersList[i])
    end
    
    gameState.currentRoom = RoomModule.loadRoom(gameState.selectedRoom)
    if gameState.currentRoom then
        RoomModule.placePlayersInRoom(gameState.currentRoom, playersList)
    end
    
    gameState.gamePhase = "preparing"
    gameState.timeRemaining = gameState.preparationTime
    
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "preparing", gameState.timeRemaining)
        local role = gameState.players[p].isSeeker and "seeker" or "hider"
        StartGameEvent:FireClient(p, role, gameState.seekers, gameState.hiders)
    end
    
    local timerConnection
    timerConnection = RunService.Heartbeat:Connect(function()
        if gameState.gamePhase == "preparing" or gameState.gamePhase == "hiding" or gameState.gamePhase == "seeking" then
            gameState.timeRemaining = gameState.timeRemaining - 0.1
            if math.floor(gameState.timeRemaining) ~= math.floor(gameState.timeRemaining + 0.1) then
                for _, p in ipairs(Players:GetPlayers()) do
                    UpdateTimerEvent:FireClient(p, math.max(0, math.floor(gameState.timeRemaining)))
                end
            end
            if gameState.timeRemaining <= 0 then
                if gameState.gamePhase == "preparing" then
                    gameState.gamePhase = "hiding"
                    gameState.timeRemaining = 30
                    for _, p in ipairs(Players:GetPlayers()) do
                        SetGamePhaseEvent:FireClient(p, "hiding", gameState.timeRemaining)
                    end
                elseif gameState.gamePhase == "hiding" then
                    gameState.gamePhase = "seeking"
                    gameState.timeRemaining = gameState.gameTime
                    for _, p in ipairs(Players:GetPlayers()) do
                        SetGamePhaseEvent:FireClient(p, "seeking", gameState.timeRemaining)
                    end
                elseif gameState.gamePhase == "seeking" then
                    endGame()
                end
            end
        else
            timerConnection:Disconnect()
        end
    end)
end)

ApplyCamouflageEvent.OnServerEvent:Connect(function(player, camouflageType, camouflageData)
    if gameState.players[player] and gameState.players[player].isHider then
        CamouflageModule.applyCamouflage(player, camouflageType, camouflageData)
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                ApplyCamouflageEvent:FireClient(p, player, camouflageType, camouflageData)
            end
        end
    end
end)

PlayerDetectedEvent.OnServerEvent:Connect(function(seeker, hider)
    if gameState.gamePhase ~= "seeking" then return end
    if not gameState.players[seeker] or not gameState.players[hider] then return end
    if not gameState.players[seeker].isSeeker or not gameState.players[hider].isHider then return end
    
    local seekerChar = gameState.players[seeker].character
    local hiderChar = gameState.players[hider].character
    if seekerChar and hiderChar then
        local seekerRoot = seekerChar:FindFirstChild("HumanoidRootPart")
        local hiderRoot = hiderChar:FindFirstChild("HumanoidRootPart")
        if seekerRoot and hiderRoot then
            local distance = (seekerRoot.Position - hiderRoot.Position).Magnitude
            if distance < 5 then
                local isWellCamouflaged = CamouflageModule.isWellCamouflaged(hider, gameState.currentRoom)
                if not isWellCamouflaged then
                    gameState.players[hider].detected = true
                    gameState.players[seeker].score = gameState.players[seeker].score + 100
                    for _, p in ipairs(Players:GetPlayers()) do
                        PlayerDetectedEvent:FireClient(p, hider, seeker)
                    end
                    local allDetected = true
                    for _, p in ipairs(gameState.hiders) do
                        if not gameState.players[p].detected then
                            allDetected = false
                            break
                        end
                    end
                    if allDetected then endGame() end
                end
            end
        end
    end
end)

function endGame()
    gameState.gamePhase = "ended"
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "ended", 0)
        EndGameEvent:FireClient(p, gameState.seekers, gameState.hiders, gameState.players)
    end
end

function resetGame()
    gameState.gamePhase = "waiting"
    gameState.seekers = {}
    gameState.hiders = {}
    for player, data in pairs(gameState.players) do
        data.isSeeker = false
        data.isHider = false
        data.detected = false
        data.score = 0
        if data.character then
            CamouflageModule.resetCharacter(data.character)
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "waiting", 0)
    end
end

EndGameEvent.OnServerEvent:Connect(function(player)
    if gameState.gamePhase == "ended" then
        resetGame()
    end
end)

print("✅ Hide and Seek - Serveur initialisé")
]]

-- Module GameModule
local gameModuleSource = [[
local GameModule = {}

GameModule.Config = {
    PreparationTime = 180,
    GameTime = 300,
    DetectionDistance = 5,
    Colors = {
        White = Color3.new(1, 1, 1),
        Black = Color3.new(0, 0, 0),
        Red = Color3.new(1, 0, 0),
        Green = Color3.new(0, 1, 0),
        Blue = Color3.new(0, 0, 1),
        Yellow = Color3.new(1, 1, 0),
        Pink = Color3.new(1, 0.7, 0.75),
        Brown = Color3.new(0.4, 0.2, 0.1),
        Gold = Color3.new(1, 0.8, 0.2)
    },
    Poses = {"Standing", "Sitting", "Lying", "Crouching"},
    Shapes = {"Triangle", "Square", "Pentagon", "Hexagon", "Circle"}
}

function GameModule.clamp(value, min, max)
    return math.max(min, math.min(max, value))
end

return GameModule
]]

-- Module RoomModule
local roomModuleSource = [[
local RoomModule = {}
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")
local rooms = {}

function RoomModule.init()
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    if roomsFolder then
        for _, roomModel in ipairs(roomsFolder:GetChildren()) do
            if roomModel:IsA("Model") then
                rooms[roomModel.Name] = roomModel
            end
        end
    end
    if next(rooms) == nil then
        RoomModule.createDefaultRoom()
    end
end

function RoomModule.createDefaultRoom()
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    if not roomsFolder then
        roomsFolder = Instance.new("Folder")
        roomsFolder.Name = "Rooms"
        roomsFolder.Parent = ServerStorage
    end
    
    local defaultRoom = Instance.new("Model")
    defaultRoom.Name = "DefaultRoom"
    
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(100, 1, 100)
    floor.Position = Vector3.new(0, -0.5, 0)
    floor.Anchored = true
    floor.Color = Color3.new(0.2, 0.2, 0.3)
    floor.Material = Enum.Material.Concrete
    floor.Parent = defaultRoom
    
    local wall1 = Instance.new("Part")
    wall1.Name = "Wall1"
    wall1.Size = Vector3.new(100, 10, 1)
    wall1.Position = Vector3.new(0, 4.5, -50)
    wall1.Anchored = true
    wall1.Color = Color3.new(0.6, 0.6, 0.6)
    wall1.Material = Enum.Material.Concrete
    wall1.Parent = defaultRoom
    
    local wall2 = Instance.new("Part")
    wall2.Name = "Wall2"
    wall2.Size = Vector3.new(100, 10, 1)
    wall2.Position = Vector3.new(0, 4.5, 50)
    wall2.Anchored = true
    wall2.Color = Color3.new(0.6, 0.6, 0.6)
    wall2.Material = Enum.Material.Concrete
    wall2.Parent = defaultRoom
    
    local wall3 = Instance.new("Part")
    wall3.Name = "Wall3"
    wall3.Size = Vector3.new(1, 10, 100)
    wall3.Position = Vector3.new(-50, 4.5, 0)
    wall3.Anchored = true
    wall3.Color = Color3.new(0.6, 0.6, 0.6)
    wall3.Material = Enum.Material.Concrete
    wall3.Parent = defaultRoom
    
    local wall4 = Instance.new("Part")
    wall4.Name = "Wall4"
    wall4.Size = Vector3.new(1, 10, 100)
    wall4.Position = Vector3.new(50, 4.5, 0)
    wall4.Anchored = true
    wall4.Color = Color3.new(0.6, 0.6, 0.6)
    wall4.Material = Enum.Material.Concrete
    wall4.Parent = defaultRoom
    
    local box1 = Instance.new("Part")
    box1.Name = "Box1"
    box1.Size = Vector3.new(10, 5, 10)
    box1.Position = Vector3.new(20, 2.5, 20)
    box1.Anchored = true
    box1.Color = Color3.new(0.8, 0.4, 0.2)
    box1.Material = Enum.Material.Wood
    box1.Parent = defaultRoom
    
    local spawns = {Vector3.new(-30, 1, -30), Vector3.new(30, 1, 30), Vector3.new(-30, 1, 30), Vector3.new(30, 1, -30)}
    for i, spawnPos in ipairs(spawns) do
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Position = spawnPos
        spawn.Size = Vector3.new(4, 1, 4)
        spawn.Parent = defaultRoom
    end
    
    defaultRoom.Parent = roomsFolder
    rooms["DefaultRoom"] = defaultRoom
end

function RoomModule.loadRoom(roomName)
    if rooms[roomName] then
        for _, room in pairs(rooms) do
            if room.model then room.model:Destroy() end
        end
        local roomClone = rooms[roomName]:Clone()
        roomClone.Parent = Workspace
        return {
            name = roomName,
            model = roomClone,
            objects = RoomModule.getRoomObjects(roomClone),
            spawnPoints = RoomModule.getSpawnPoints(roomClone)
        }
    end
    return nil
end

function RoomModule.getRoomObjects(roomModel)
    local objects = {}
    for _, part in ipairs(roomModel:GetDescendants()) do
        if part:IsA("BasePart") and part.Name ~= "Floor" and not part.Name:match("Wall") then
            table.insert(objects, {
                name = part.Name,
                part = part,
                color = part.Color,
                material = part.Material,
                size = part.Size,
                position = part.Position
            })
        end
    end
    return objects
end

function RoomModule.getSpawnPoints(roomModel)
    local spawnPoints = {}
    for _, spawn in ipairs(roomModel:GetChildren()) do
        if spawn:IsA("SpawnLocation") then
            table.insert(spawnPoints, spawn)
        end
    end
    return spawnPoints
end

function RoomModule.placePlayersInRoom(room, players)
    if not room or not room.spawnPoints or #room.spawnPoints == 0 then
        for i, player in ipairs(players) do
            if player.Character then
                local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRoot then
                    humanoidRoot.CFrame = CFrame.new((i-1)*10 - 20, 5, 0)
                end
            end
        end
    else
        for i, player in ipairs(players) do
            local spawnIndex = (i - 1) % #room.spawnPoints + 1
            local spawn = room.spawnPoints[spawnIndex]
            if player.Character then
                local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRoot then
                    humanoidRoot.CFrame = spawn.CFrame + Vector3.new(0, 3, 0)
                end
            end
        end
    end
end

RoomModule.init()
return RoomModule
]]

-- Module CamouflageModule
local camouflageModuleSource = [[
local CamouflageModule = {}
local GameModule = require(script.Parent.GameModule)

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

function CamouflageModule.applyObject(player, objectData)
    if not player.Character then return end
    local color = objectData.color or Color3.new(0.8, 0.8, 0.8)
    CamouflageModule.applyColor(player, {color = color})
end

function CamouflageModule.applyShape(player, shapeData)
    if not player.Character then return end
    local color = shapeData.color or Color3.new(0.8, 0.8, 0.8)
    CamouflageModule.applyColor(player, {color = color})
    if player.Character:FindFirstChild("Humanoid") then
        player.Character.Humanoid.WalkSpeed = 0
    end
end

function CamouflageModule.isWellCamouflaged(player, room)
    if not player.Character then return false end
    local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
    if not humanoidRoot then return false end
    local playerColor = humanoidRoot.Color
    if room and room.objects then
        for _, obj in ipairs(room.objects) do
            local colorDistance = CamouflageModule.colorDistance(playerColor, obj.color)
            if colorDistance < 0.3 then return true end
        end
    end
    local whiteDistance = CamouflageModule.colorDistance(playerColor, Color3.new(1, 1, 1))
    if whiteDistance < 0.1 then return false end
    return false
end

function CamouflageModule.colorDistance(color1, color2)
    local rDiff = color1.R - color2.R
    local gDiff = color1.G - color2.G
    local bDiff = color1.B - color2.B
    return math.sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff)
end

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

function CamouflageModule.getColorPalette()
    return GameModule.Config.Colors
end

function CamouflageModule.getPoses()
    return GameModule.Config.Poses
end

function CamouflageModule.getShapes()
    return GameModule.Config.Shapes
end

return CamouflageModule
]]

-- Module ModifiersModule
local modifiersModuleSource = [[
local ModifiersModule = {}

ModifiersModule.Modifiers = {
    {
        id = "no_stay",
        name = "Interdiction de rester immobile",
        description = "Vous ne pouvez pas rester plus de 30 secondes dans la même position",
        duration = 30,
        category = "mouvement"
    },
    {
        id = "color_change",
        name = "Changement de couleur",
        description = "Votre couleur change aléatoirement",
        duration = 10,
        category = "apparence"
    },
    {
        id = "invisibility",
        name = "Invisibilité",
        description = "Vous êtes partiellement invisible",
        duration = 15,
        category = "spécial"
    }
}

function ModifiersModule.getAllModifiers()
    return ModifiersModule.Modifiers
end

return ModifiersModule
]]

-- Script client
local gameClientSource = [[
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameModule = require(ReplicatedStorage:WaitForChild("GameModule"))
local CamouflageModule = require(ReplicatedStorage:WaitForChild("CamouflageModule"))

local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StartGameEvent = RemoteEvents:WaitForChild("StartGame")
local EndGameEvent = RemoteEvents:WaitForChild("EndGame")
local SelectRoomEvent = RemoteEvents:WaitForChild("SelectRoom")
local ApplyCamouflageEvent = RemoteEvents:WaitForChild("ApplyCamouflage")
local PlayerDetectedEvent = RemoteEvents:WaitForChild("PlayerDetected")
local UpdateTimerEvent = RemoteEvents:WaitForChild("UpdateTimer")
local SetGamePhaseEvent = RemoteEvents:WaitForChild("SetGamePhase")

local localPlayer = Players.LocalPlayer
local gameState = {role = "waiting", gamePhase = "waiting", timeRemaining = 0}

local function createGUI()
    local gui = Instance.new("ScreenGui")
    gui.Name = "HideAndSeekGUI"
    gui.ResetOnSpawn = false
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    -- Menu Frame
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    menuFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    menuFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    menuFrame.BackgroundTransparency = 0.2
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = true
    menuFrame.Parent = gui
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "TitleLabel"
    titleLabel.Text = "Hide and Seek"
    titleLabel.Size = UDim2.new(1, 0, 0, 50)
    titleLabel.Position = UDim2.new(0, 0, 0, 20)
    titleLabel.TextColor3 = Color3.new(1, 1, 1)
    titleLabel.TextSize = 24
    titleLabel.Font = Enum.Font.SourceSansBold
    titleLabel.BackgroundTransparency = 1
    titleLabel.TextScaled = true
    titleLabel.Parent = menuFrame
    
    local subtitleLabel = Instance.new("TextLabel")
    subtitleLabel.Name = "SubtitleLabel"
    subtitleLabel.Text = "Le jeu de cache-cache ultime"
    subtitleLabel.Size = UDim2.new(1, 0, 0, 30)
    subtitleLabel.Position = UDim2.new(0, 0, 0, 80)
    subtitleLabel.TextColor3 = Color3.new(0.8, 0.8, 0.8)
    subtitleLabel.TextSize = 18
    subtitleLabel.Font = Enum.Font.SourceSans
    subtitleLabel.BackgroundTransparency = 1
    subtitleLabel.Parent = menuFrame
    
    local roomsList = Instance.new("ScrollingFrame")
    roomsList.Name = "RoomsList"
    roomsList.Size = UDim2.new(1, -40, 0, 200)
    roomsList.Position = UDim2.new(0, 20, 0, 130)
    roomsList.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
    roomsList.BackgroundTransparency = 0.5
    roomsList.BorderSizePixel = 0
    roomsList.ScrollBarThickness = 5
    roomsList.Parent = menuFrame
    
    local playButton = Instance.new("TextButton")
    playButton.Name = "PlayButton"
    playButton.Text = "Jouer"
    playButton.Size = UDim2.new(0.4, 0, 0, 50)
    playButton.Position = UDim2.new(0.3, 0, 0, 350)
    playButton.BackgroundColor3 = Color3.new(0.4, 0.8, 0.4)
    playButton.TextColor3 = Color3.new(1, 1, 1)
    playButton.TextSize = 18
    playButton.Font = Enum.Font.SourceSansBold
    playButton.Parent = menuFrame
    
    -- Game Frame
    local gameFrame = Instance.new("Frame")
    gameFrame.Name = "GameFrame"
    gameFrame.Size = UDim2.new(1, 0, 1, 0)
    gameFrame.Position = UDim2.new(0, 0, 0, 0)
    gameFrame.BackgroundTransparency = 1
    gameFrame.Visible = false
    gameFrame.Parent = gui
    
    local infoBar = Instance.new("Frame")
    infoBar.Name = "InfoBar"
    infoBar.Size = UDim2.new(1, 0, 0, 40)
    infoBar.Position = UDim2.new(0, 0, 0, 10)
    infoBar.BackgroundColor3 = Color3.new(0, 0, 0)
    infoBar.BackgroundTransparency = 0.5
    infoBar.BorderSizePixel = 0
    infoBar.Parent = gameFrame
    
    local phaseLabel = Instance.new("TextLabel")
    phaseLabel.Name = "PhaseLabel"
    phaseLabel.Text = "Phase: waiting"
    phaseLabel.Size = UDim2.new(0.25, 0, 1, 0)
    phaseLabel.Position = UDim2.new(0, 10, 0, 0)
    phaseLabel.TextColor3 = Color3.new(1, 1, 1)
    phaseLabel.TextSize = 16
    phaseLabel.Font = Enum.Font.SourceSans
    phaseLabel.BackgroundTransparency = 1
    phaseLabel.TextXAlignment = Enum.TextXAlignment.Left
    phaseLabel.Parent = infoBar
    
    local timerLabel = Instance.new("TextLabel")
    timerLabel.Name = "TimerLabel"
    timerLabel.Text = "Temps: 0s"
    timerLabel.Size = UDim2.new(0.25, 0, 1, 0)
    timerLabel.Position = UDim2.new(0.25, 10, 0, 0)
    timerLabel.TextColor3 = Color3.new(1, 1, 0)
    timerLabel.TextSize = 16
    timerLabel.Font = Enum.Font.SourceSans
    timerLabel.BackgroundTransparency = 1
    timerLabel.TextXAlignment = Enum.TextXAlignment.Left
    timerLabel.Parent = infoBar
    
    local roleLabel = Instance.new("TextLabel")
    roleLabel.Name = "RoleLabel"
    roleLabel.Text = "Rôle: Attente"
    roleLabel.Size = UDim2.new(0.25, 0, 1, 0)
    roleLabel.Position = UDim2.new(0.5, 10, 0, 0)
    roleLabel.TextColor3 = Color3.new(1, 1, 1)
    roleLabel.TextSize = 16
    roleLabel.Font = Enum.Font.SourceSans
    roleLabel.BackgroundTransparency = 1
    roleLabel.TextXAlignment = Enum.TextXAlignment.Left
    roleLabel.Parent = infoBar
    
    local instructionsLabel = Instance.new("TextLabel")
    instructionsLabel.Name = "InstructionsLabel"
    instructionsLabel.Text = "Sélectionnez une salle et cliquez sur Jouer"
    instructionsLabel.Size = UDim2.new(0.9, 0, 0, 60)
    instructionsLabel.Position = UDim2.new(0.05, 0, 0, 70)
    instructionsLabel.TextColor3 = Color3.new(1, 1, 1)
    instructionsLabel.TextSize = 16
    instructionsLabel.Font = Enum.Font.SourceSans
    instructionsLabel.BackgroundTransparency = 1
    instructionsLabel.TextWrapped = true
    instructionsLabel.TextXAlignment = Enum.TextXAlignment.Left
    instructionsLabel.Parent = gameFrame
    
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonsFrame.Position = UDim2.new(0, 0, 1, -60)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = gameFrame
    
    local backButton = Instance.new("TextButton")
    backButton.Name = "BackButton"
    backButton.Text = "Retour au menu"
    backButton.Size = UDim2.new(0.2, 0, 1, -10)
    backButton.Position = UDim2.new(0.75, 0, 0, 5)
    backButton.BackgroundColor3 = Color3.new(0.8, 0.3, 0.3)
    backButton.TextColor3 = Color3.new(1, 1, 1)
    backButton.TextSize = 16
    backButton.Font = Enum.Font.SourceSansBold
    backButton.Parent = buttonsFrame
    
    -- Game Over Frame
    local gameOverFrame = Instance.new("Frame")
    gameOverFrame.Name = "GameOverFrame"
    gameOverFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    gameOverFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    gameOverFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    gameOverFrame.BackgroundTransparency = 0.2
    gameOverFrame.BorderSizePixel = 0
    gameOverFrame.Visible = false
    gameOverFrame.Parent = gui
    
    local gameOverTitle = Instance.new("TextLabel")
    gameOverTitle.Name = "GameOverTitle"
    gameOverTitle.Text = "Fin de la partie !"
    gameOverTitle.Size = UDim2.new(1, 0, 0, 50)
    gameOverTitle.Position = UDim2.new(0, 0, 0, 20)
    gameOverTitle.TextColor3 = Color3.new(1, 1, 0)
    gameOverTitle.TextSize = 24
    gameOverTitle.Font = Enum.Font.SourceSansBold
    gameOverTitle.BackgroundTransparency = 1
    gameOverTitle.TextScaled = true
    gameOverTitle.Parent = gameOverFrame
    
    local scoresFrame = Instance.new("ScrollingFrame")
    scoresFrame.Name = "ScoresFrame"
    scoresFrame.Size = UDim2.new(1, -40, 0, 300)
    scoresFrame.Position = UDim2.new(0, 20, 0, 90)
    scoresFrame.BackgroundTransparency = 1
    scoresFrame.ScrollBarThickness = 5
    scoresFrame.Parent = gameOverFrame
    
    local replayButton = Instance.new("TextButton")
    replayButton.Name = "ReplayButton"
    replayButton.Text = "Rejouer"
    replayButton.Size = UDim2.new(0.4, 0, 0, 50)
    replayButton.Position = UDim2.new(0.3, 0, 0, 410)
    replayButton.BackgroundColor3 = Color3.new(0.4, 0.8, 0.4)
    replayButton.TextColor3 = Color3.new(1, 1, 1)
    replayButton.TextSize = 18
    replayButton.Font = Enum.Font.SourceSansBold
    replayButton.Parent = gameOverFrame
    
    return gui
end

local function loadRoomsList()
    local ServerStorage = game:GetService("ServerStorage")
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui or not roomsFolder then return end
    
    local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
    if not hideAndSeekGUI then return end
    
    local menuFrame = hideAndSeekGUI:FindFirstChild("MenuFrame")
    if not menuFrame then return end
    
    local roomsList = menuFrame:FindFirstChild("RoomsList")
    if not roomsList then return end
    
    for _, child in ipairs(roomsList:GetChildren()) do
        if child:IsA("TextButton") then child:Destroy() end
    end
    
    for _, room in ipairs(roomsFolder:GetChildren()) do
        if room:IsA("Model") or room:IsA("ModuleScript") then
            local button = Instance.new("TextButton")
            button.Name = room.Name
            button.Text = room.Name:gsub("%.lua$", "")
            button.Size = UDim2.new(1, -20, 0, 40)
            button.Position = UDim2.new(0, 10, 0, (#roomsList:GetChildren() - 1) * 50 + 10)
            button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
            button.TextColor3 = Color3.new(1, 1, 1)
            button.Parent = roomsList
            button.MouseButton1Click:Connect(function()
                SelectRoomEvent:FireServer(room.Name:gsub("%.lua$", ""))
            end)
        end
    end
    
    if #roomsList:GetChildren() == 0 then
        local button = Instance.new("TextButton")
        button.Name = "DefaultRoom"
        button.Text = "DefaultRoom"
        button.Size = UDim2.new(1, -20, 0, 40)
        button.Position = UDim2.new(0, 10, 0, 10)
        button.BackgroundColor3 = Color3.new(0.3, 0.3, 0.5)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Parent = roomsList
        button.MouseButton1Click:Connect(function()
            SelectRoomEvent:FireServer("DefaultRoom")
        end)
    end
end

-- Événements
StartGameEvent.OnClientEvent:Connect(function(role, seekers, hiders)
    gameState.role = role
    gameState.seekers = seekers
    gameState.hiders = hiders
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local menuFrame = hideAndSeekGUI:FindFirstChild("MenuFrame")
            local gameFrame = hideAndSeekGUI:FindFirstChild("GameFrame")
            if menuFrame then menuFrame.Visible = false end
            if gameFrame then gameFrame.Visible = true end
        end
    end
end)

EndGameEvent.OnClientEvent:Connect(function(seekers, hiders, playersData)
    gameState.gamePhase = "ended"
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local gameFrame = hideAndSeekGUI:FindFirstChild("GameFrame")
            local gameOverFrame = hideAndSeekGUI:FindFirstChild("GameOverFrame")
            if gameFrame then gameFrame.Visible = false end
            if gameOverFrame then gameOverFrame.Visible = true end
            
            local scoresFrame = gameOverFrame and gameOverFrame:FindFirstChild("ScoresFrame")
            if scoresFrame then
                for _, child in ipairs(scoresFrame:GetChildren()) do
                    if child:IsA("TextLabel") then child:Destroy() end
                end
                
                local seekersLabel = Instance.new("TextLabel")
                seekersLabel.Text = "Chercheur:"
                seekersLabel.Size = UDim2.new(1, 0, 0, 30)
                seekersLabel.Position = UDim2.new(0, 0, 0, 0)
                seekersLabel.TextColor3 = Color3.new(1, 1, 1)
                seekersLabel.BackgroundTransparency = 1
                seekersLabel.Parent = scoresFrame
                
                for i, seeker in ipairs(seekers) do
                    local score = playersData[seeker] and playersData[seeker].score or 0
                    local seekerLabel = Instance.new("TextLabel")
                    seekerLabel.Text = seeker.Name .. ": " .. score
                    seekerLabel.Size = UDim2.new(1, 0, 0, 30)
                    seekerLabel.Position = UDim2.new(0, 0, 0, i * 30)
                    seekerLabel.TextColor3 = Color3.new(1, 1, 0)
                    seekerLabel.BackgroundTransparency = 1
                    seekerLabel.Parent = scoresFrame
                end
                
                local hidersLabel = Instance.new("TextLabel")
                hidersLabel.Text = "\nCacheur:"
                hidersLabel.Size = UDim2.new(1, 0, 0, 30)
                hidersLabel.Position = UDim2.new(0, 0, 0, (#seekers + 1) * 30)
                hidersLabel.TextColor3 = Color3.new(1, 1, 1)
                hidersLabel.BackgroundTransparency = 1
                hidersLabel.Parent = scoresFrame
                
                for i, hider in ipairs(hiders) do
                    local detected = playersData[hider] and playersData[hider].detected or false
                    local hiderLabel = Instance.new("TextLabel")
                    hiderLabel.Text = hider.Name .. ": " .. (detected and "Trouvé" or "Non trouvé")
                    hiderLabel.Size = UDim2.new(1, 0, 0, 30)
                    hiderLabel.Position = UDim2.new(0, 0, 0, (#seekers + 2 + i) * 30)
                    hiderLabel.TextColor3 = detected and Color3.new(1, 0, 0) or Color3.new(0, 1, 0)
                    hiderLabel.BackgroundTransparency = 1
                    hiderLabel.Parent = scoresFrame
                end
            end
        end
    end
end)

SetGamePhaseEvent.OnClientEvent:Connect(function(phase, timeRemaining)
    gameState.gamePhase = phase
    gameState.timeRemaining = timeRemaining
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local phaseLabel = hideAndSeekGUI:FindFirstChild("PhaseLabel")
            local timerLabel = hideAndSeekGUI:FindFirstChild("TimerLabel")
            local roleLabel = hideAndSeekGUI:FindFirstChild("RoleLabel")
            local instructionsLabel = hideAndSeekGUI:FindFirstChild("InstructionsLabel")
            
            if phaseLabel then phaseLabel.Text = "Phase: " .. phase end
            if timerLabel then timerLabel.Text = "Temps: " .. math.floor(timeRemaining) .. "s" end
            if roleLabel then roleLabel.Text = "Rôle: " .. (gameState.role == "seeker" and "Chercheur" or "Cacheur") end
            if instructionsLabel then
                if phase == "preparing" then
                    instructionsLabel.Text = gameState.role == "hider" and "Préparez-vous ! Camouflez-vous." or "Jouez au mini-jeu."
                elseif phase == "hiding" then
                    instructionsLabel.Text = "Attendez que les chercheur commencent."
                elseif phase == "seeking" then
                    instructionsLabel.Text = gameState.role == "seeker" and "Trouvez tous les cacheurs !" or "Restez caché !"
                end
            end
        end
    end
end)

UpdateTimerEvent.OnClientEvent:Connect(function(timeRemaining)
    gameState.timeRemaining = timeRemaining
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local timerLabel = hideAndSeekGUI:FindFirstChild("TimerLabel")
            if timerLabel then timerLabel.Text = "Temps: " .. math.floor(timeRemaining) .. "s" end
        end
    end
end)

PlayerDetectedEvent.OnClientEvent:Connect(function(hider, seeker)
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local gameFrame = hideAndSeekGUI:FindFirstChild("GameFrame")
            if gameFrame then
                local notification = Instance.new("TextLabel")
                notification.Text = hider.Name .. " trouvé par " .. seeker.Name .. "!"
                notification.Size = UDim2.new(0.5, 0, 0, 40)
                notification.Position = UDim2.new(0.25, 0, 0.8, 0)
                notification.TextColor3 = Color3.new(1, 0, 0)
                notification.BackgroundColor3 = Color3.new(0, 0, 0)
                notification.BackgroundTransparency = 0.5
                notification.Parent = gameFrame
                game:GetService("Debris"):AddItem(notification, 3)
            end
        end
    end
end)

-- Boutons
local function setupButtons()
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
    if not hideAndSeekGUI then return end
    
    local playButton = hideAndSeekGUI:FindFirstChild("PlayButton")
    if playButton then
        playButton.MouseButton1Click:Connect(function()
            StartGameEvent:FireServer()
        end)
    end
    
    local backButton = hideAndSeekGUI:FindFirstChild("BackButton")
    if backButton then
        backButton.MouseButton1Click:Connect(function()
            EndGameEvent:FireServer()
        end)
    end
    
    local replayButton = hideAndSeekGUI:FindFirstChild("ReplayButton")
    if replayButton then
        replayButton.MouseButton1Click:Connect(function()
            local gameOverFrame = hideAndSeekGUI:FindFirstChild("GameOverFrame")
            local menuFrame = hideAndSeekGUI:FindFirstChild("MenuFrame")
            if gameOverFrame then gameOverFrame.Visible = false end
            if menuFrame then menuFrame.Visible = true end
        end)
    end
end

-- Initialisation
local function init()
    createGUI()
    loadRoomsList()
    setupButtons()
end

localPlayer.CharacterAdded:Connect(function() init() end)
init()

print("✅ Hide and Seek - Client initialisé")
]]

-- Vérifier si les dossiers existent
if not ServerScriptService:FindFirstChild("MainGameServer") then
    createScript(ServerScriptService, "MainGameServer", mainGameServerSource)
end

if not ReplicatedStorage:FindFirstChild("GameModule") then
    createModuleScript(ReplicatedStorage, "GameModule", gameModuleSource)
end

if not ReplicatedStorage:FindFirstChild("RoomModule") then
    createModuleScript(ReplicatedStorage, "RoomModule", roomModuleSource)
end

if not ReplicatedStorage:FindFirstChild("CamouflageModule") then
    createModuleScript(ReplicatedStorage, "CamouflageModule", camouflageModuleSource)
end

if not ReplicatedStorage:FindFirstChild("ModifiersModule") then
    createModuleScript(ReplicatedStorage, "ModifiersModule", modifiersModuleSource)
end

if not StarterPlayerScripts:FindFirstChild("GameClient") then
    createScript(StarterPlayerScripts, "GameClient", gameClientSource)
end

-- Créer le dossier Rooms et la salle par défaut
if not ServerStorage:FindFirstChild("Rooms") then
    local roomsFolder = Instance.new("Folder")
    roomsFolder.Name = "Rooms"
    roomsFolder.Parent = ServerStorage
end

-- Vérifier si la salle par défaut existe
if not ServerStorage.Rooms:FindFirstChild("DefaultRoom") then
    -- Créer la salle par défaut
    local defaultRoom = Instance.new("Model")
    defaultRoom.Name = "DefaultRoom"
    
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(100, 1, 100)
    floor.Position = Vector3.new(0, -0.5, 0)
    floor.Anchored = true
    floor.Color = Color3.new(0.2, 0.2, 0.3)
    floor.Material = Enum.Material.Concrete
    floor.Parent = defaultRoom
    
    local wall1 = Instance.new("Part")
    wall1.Name = "Wall1"
    wall1.Size = Vector3.new(100, 10, 1)
    wall1.Position = Vector3.new(0, 4.5, -50)
    wall1.Anchored = true
    wall1.Color = Color3.new(0.6, 0.6, 0.6)
    wall1.Material = Enum.Material.Concrete
    wall1.Parent = defaultRoom
    
    local wall2 = Instance.new("Part")
    wall2.Name = "Wall2"
    wall2.Size = Vector3.new(100, 10, 1)
    wall2.Position = Vector3.new(0, 4.5, 50)
    wall2.Anchored = true
    wall2.Color = Color3.new(0.6, 0.6, 0.6)
    wall2.Material = Enum.Material.Concrete
    wall2.Parent = defaultRoom
    
    local wall3 = Instance.new("Part")
    wall3.Name = "Wall3"
    wall3.Size = Vector3.new(1, 10, 100)
    wall3.Position = Vector3.new(-50, 4.5, 0)
    wall3.Anchored = true
    wall3.Color = Color3.new(0.6, 0.6, 0.6)
    wall3.Material = Enum.Material.Concrete
    wall3.Parent = defaultRoom
    
    local wall4 = Instance.new("Part")
    wall4.Name = "Wall4"
    wall4.Size = Vector3.new(1, 10, 100)
    wall4.Position = Vector3.new(50, 4.5, 0)
    wall4.Anchored = true
    wall4.Color = Color3.new(0.6, 0.6, 0.6)
    wall4.Material = Enum.Material.Concrete
    wall4.Parent = defaultRoom
    
    local box1 = Instance.new("Part")
    box1.Name = "Box1"
    box1.Size = Vector3.new(10, 5, 10)
    box1.Position = Vector3.new(20, 2.5, 20)
    box1.Anchored = true
    box1.Color = Color3.new(0.8, 0.4, 0.2)
    box1.Material = Enum.Material.Wood
    box1.Parent = defaultRoom
    
    local spawns = {Vector3.new(-30, 1, -30), Vector3.new(30, 1, 30), Vector3.new(-30, 1, 30), Vector3.new(30, 1, -30)}
    for i, spawnPos in ipairs(spawns) do
        local spawn = Instance.new("SpawnLocation")
        spawn.Name = "Spawn" .. i
        spawn.Position = spawnPos
        spawn.Size = Vector3.new(4, 1, 4)
        spawn.Parent = defaultRoom
    end
    
    defaultRoom.Parent = ServerStorage.Rooms
end

print("✅ Hide and Seek - Installation terminée !")
print("✅ Tu peux supprimer ce script maintenant.")
print("✅ Clique sur le bouton Play pour commencer une partie !")
