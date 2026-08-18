--[[
    Hide and Seek - Script principal côté serveur
    Gère la logique du jeu, les phases, les joueurs et les salles
    
    INSTRUCTIONS :
    1. Placez ce script dans ServerScriptService
    2. Assurez-vous que tous les ModuleScripts sont dans ReplicatedStorage
    3. Exécutez le jeu
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

-- Attendre que les modules soient chargés
local GameModule = require(ReplicatedStorage:WaitForChild("GameModule"))
local RoomModule = require(ReplicatedStorage:WaitForChild("RoomModule"))
local CamouflageModule = require(ReplicatedStorage:WaitForChild("CamouflageModule"))

-- Créer les RemoteEvents
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

-- État du jeu
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

-- Initialisation des joueurs
local function onPlayerAdded(player)
    print(player.Name .. " a rejoint la partie")
    
    gameState.players[player] = {
        isSeeker = false,
        isHider = false,
        detected = false,
        score = 0,
        camouflageType = "none",
        camouflageData = nil,
        character = nil
    }
    
    player.CharacterAdded:Connect(function(character)
        gameState.players[player].character = character
        
        -- Rendre le personnage BLANC (comme demandé)
        local function setCharacterWhite(char)
            for _, part in ipairs(char:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.Color = Color3.new(1, 1, 1)
                    part.Material = Enum.Material.SmoothPlastic
                end
            end
        end
        
        setCharacterWhite(character)
        
        character.DescendantAdded:Connect(function(descendant)
            if descendant:IsA("BasePart") then
                descendant.Color = Color3.new(1, 1, 1)
                descendant.Material = Enum.Material.SmoothPlastic
            end
        end)
    end)
    
    player.CharacterRemoving:Connect(function()
        gameState.players[player].character = nil
    end)
end

local function onPlayerRemoving(player)
    print(player.Name .. " a quitté la partie")
    gameState.players[player] = nil
    
    for i, p in ipairs(gameState.seekers) do
        if p == player then
            table.remove(gameState.seekers, i)
            break
        end
    end
    
    for i, p in ipairs(gameState.hiders) do
        if p == player then
            table.remove(gameState.hiders, i)
            break
        end
    end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

for _, player in ipairs(Players:GetPlayers()) do
    onPlayerAdded(player)
end

-- Sélection d'une salle
SelectRoomEvent.OnServerEvent:Connect(function(player, roomName)
    gameState.selectedRoom = roomName
    print("Salle sélectionnée: " .. roomName)
end)

-- Début du jeu
StartGameEvent.OnServerEvent:Connect(function(player)
    if gameState.gamePhase ~= "waiting" then return end
    
    gameState.seekers = {}
    gameState.hiders = {}
    
    local playersList = {}
    for p, _ in pairs(gameState.players) do
        table.insert(playersList, p)
    end
    
    -- Mélanger les joueurs
    for i = #playersList, 2, -1 do
        local j = math.random(i)
        playersList[i], playersList[j] = playersList[j], playersList[i]
    end
    
    -- Les 1-2 premiers sont les chercheur
    local numSeekers = math.min(2, #playersList)
    for i = 1, numSeekers do
        gameState.players[playersList[i]].isSeeker = true
        gameState.players[playersList[i]].isHider = false
        table.insert(gameState.seekers, playersList[i])
    end
    
    -- Les autres sont les cacheurs
    for i = numSeekers + 1, #playersList do
        gameState.players[playersList[i]].isSeeker = false
        gameState.players[playersList[i]].isHider = true
        table.insert(gameState.hiders, playersList[i])
    end
    
    -- Charger la salle
    gameState.currentRoom = RoomModule.loadRoom(gameState.selectedRoom)
    
    -- Placer les joueurs dans la salle
    if gameState.currentRoom then
        RoomModule.placePlayersInRoom(gameState.currentRoom, playersList)
    else
        -- Placement par défaut
        for i, player in ipairs(playersList) do
            if player.Character then
                local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRoot then
                    humanoidRoot.CFrame = CFrame.new((i-1)*10 - 20, 5, 0)
                end
            end
        end
    end
    
    -- Démarrer la phase de préparation
    gameState.gamePhase = "preparing"
    gameState.timeRemaining = gameState.preparationTime
    
    -- Notifier tous les clients
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "preparing", gameState.timeRemaining)
        local role = gameState.players[p].isSeeker and "seeker" or "hider"
        StartGameEvent:FireClient(p, role, gameState.seekers, gameState.hiders)
    end
    
    -- Démarrer le timer
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

-- Application du camouflage
ApplyCamouflageEvent.OnServerEvent:Connect(function(player, camouflageType, camouflageData)
    if gameState.players[player] and gameState.players[player].isHider then
        gameState.players[player].camouflageType = camouflageType
        gameState.players[player].camouflageData = camouflageData
        
        CamouflageModule.applyCamouflage(player, camouflageType, camouflageData)
        
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= player then
                ApplyCamouflageEvent:FireClient(p, player, camouflageType, camouflageData)
            end
        end
    end
end)

-- Détection d'un joueur
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
                    
                    if allDetected then
                        endGame()
                    end
                end
            end
        end
    end
end)

-- Fin du jeu
function endGame()
    gameState.gamePhase = "ended"
    
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "ended", 0)
        EndGameEvent:FireClient(p, gameState.seekers, gameState.hiders, gameState.players)
    end
end

-- Réinitialisation du jeu
function resetGame()
    gameState.gamePhase = "waiting"
    gameState.seekers = {}
    gameState.hiders = {}
    
    for player, data in pairs(gameState.players) do
        data.isSeeker = false
        data.isHider = false
        data.detected = false
        data.score = 0
        data.camouflageType = "none"
        data.camouflageData = nil
        
        if data.character then
            CamouflageModule.resetCharacter(data.character)
        end
    end
    
    for _, p in ipairs(Players:GetPlayers()) do
        SetGamePhaseEvent:FireClient(p, "waiting", 0)
    end
end

-- Connexion pour réinitialiser le jeu
EndGameEvent.OnServerEvent:Connect(function(player)
    if gameState.gamePhase == "ended" then
        resetGame()
    end
end)

print("✅ Hide and Seek - Serveur initialisé")
