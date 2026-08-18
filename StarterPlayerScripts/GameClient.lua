--[[
    GameClient - Script client principal
    Gère la logique côté client, les entrées et l'interface
]]

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local StarterGui = game:GetService("StarterGui")

-- Attendre que les modules soient chargés
local GameModule = require(ReplicatedStorage:WaitForChild("GameModule"))
local CamouflageModule = require(ReplicatedStorage:WaitForChild("CamouflageModule"))

-- RemoteEvents
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")
local StartGameEvent = RemoteEvents:WaitForChild("StartGame")
local EndGameEvent = RemoteEvents:WaitForChild("EndGame")
local SelectRoomEvent = RemoteEvents:WaitForChild("SelectRoom")
local ApplyCamouflageEvent = RemoteEvents:WaitForChild("ApplyCamouflage")
local PlayerDetectedEvent = RemoteEvents:WaitForChild("PlayerDetected")
local UpdateTimerEvent = RemoteEvents:WaitForChild("UpdateTimer")
local SetGamePhaseEvent = RemoteEvents:WaitForChild("SetGamePhase")

-- État local
local localPlayer = Players.LocalPlayer
local gameState = {
    role = "waiting",
    gamePhase = "waiting",
    timeRemaining = 0,
    seekers = {},
    hiders = {},
    detectedPlayers = {},
    currentRoom = nil
}

-- Créer l'interface
local function createGUI()
    -- Vérifier si l'interface existe déjà
    local existingGUI = localPlayer:FindFirstChild("PlayerGui")
    if existingGUI then
        for _, child in ipairs(existingGUI:GetChildren()) do
            if child.Name == "HideAndSeekGUI" then
                child:Destroy()
            end
        end
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "HideAndSeekGUI"
    gui.ResetOnSpawn = false
    gui.Parent = localPlayer:WaitForChild("PlayerGui")
    
    -- Frame du menu
    local menuFrame = Instance.new("Frame")
    menuFrame.Name = "MenuFrame"
    menuFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    menuFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    menuFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    menuFrame.BackgroundTransparency = 0.2
    menuFrame.BorderSizePixel = 0
    menuFrame.Visible = true
    menuFrame.Parent = gui
    
    -- Titre
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
    
    -- Sous-titre
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
    
    -- Liste des salles
    local roomsList = Instance.new("ScrollingFrame")
    roomsList.Name = "RoomsList"
    roomsList.Size = UDim2.new(1, -40, 0, 200)
    roomsList.Position = UDim2.new(0, 20, 0, 130)
    roomsList.BackgroundColor3 = Color3.new(0.3, 0.3, 0.4)
    roomsList.BackgroundTransparency = 0.5
    roomsList.BorderSizePixel = 0
    roomsList.ScrollBarThickness = 5
    roomsList.Parent = menuFrame
    
    -- Bouton Jouer
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
    
    -- Frame du jeu
    local gameFrame = Instance.new("Frame")
    gameFrame.Name = "GameFrame"
    gameFrame.Size = UDim2.new(1, 0, 1, 0)
    gameFrame.Position = UDim2.new(0, 0, 0, 0)
    gameFrame.BackgroundTransparency = 1
    gameFrame.Visible = false
    gameFrame.Parent = gui
    
    -- Barre d'informations
    local infoBar = Instance.new("Frame")
    infoBar.Name = "InfoBar"
    infoBar.Size = UDim2.new(1, 0, 0, 40)
    infoBar.Position = UDim2.new(0, 0, 0, 10)
    infoBar.BackgroundColor3 = Color3.new(0, 0, 0)
    infoBar.BackgroundTransparency = 0.5
    infoBar.BorderSizePixel = 0
    infoBar.Parent = gameFrame
    
    -- Phase du jeu
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
    
    -- Temps restant
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
    
    -- Rôle du joueur
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
    
    -- Instructions
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
    
    -- Boutons en bas
    local buttonsFrame = Instance.new("Frame")
    buttonsFrame.Name = "ButtonsFrame"
    buttonsFrame.Size = UDim2.new(1, 0, 0, 50)
    buttonsFrame.Position = UDim2.new(0, 0, 1, -60)
    buttonsFrame.BackgroundTransparency = 1
    buttonsFrame.Parent = gameFrame
    
    -- Bouton Camouflage
    local camouflageButton = Instance.new("TextButton")
    camouflageButton.Name = "CamouflageButton"
    camouflageButton.Text = "Camouflage"
    camouflageButton.Size = UDim2.new(0.2, 0, 1, -10)
    camouflageButton.Position = UDim2.new(0.05, 0, 0, 5)
    camouflageButton.BackgroundColor3 = Color3.new(0.3, 0.6, 0.8)
    camouflageButton.TextColor3 = Color3.new(1, 1, 1)
    camouflageButton.TextSize = 16
    camouflageButton.Font = Enum.Font.SourceSansBold
    camouflageButton.Visible = false
    camouflageButton.Parent = buttonsFrame
    
    -- Bouton Retour
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
    
    -- Frame de fin de partie
    local gameOverFrame = Instance.new("Frame")
    gameOverFrame.Name = "GameOverFrame"
    gameOverFrame.Size = UDim2.new(0.5, 0, 0.6, 0)
    gameOverFrame.Position = UDim2.new(0.25, 0, 0.2, 0)
    gameOverFrame.BackgroundColor3 = Color3.new(0.2, 0.2, 0.3)
    gameOverFrame.BackgroundTransparency = 0.2
    gameOverFrame.BorderSizePixel = 0
    gameOverFrame.Visible = false
    gameOverFrame.Parent = gui
    
    -- Titre de fin de partie
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
    
    -- Frame des scores
    local scoresFrame = Instance.new("ScrollingFrame")
    scoresFrame.Name = "ScoresFrame"
    scoresFrame.Size = UDim2.new(1, -40, 0, 300)
    scoresFrame.Position = UDim2.new(0, 20, 0, 90)
    scoresFrame.BackgroundTransparency = 1
    scoresFrame.ScrollBarThickness = 5
    scoresFrame.Parent = gameOverFrame
    
    -- Bouton Rejouer
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

-- Charger la liste des salles
local function loadRoomsList()
    local ServerStorage = game:GetService("ServerStorage")
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if not gui then return end
    
    local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
    if not hideAndSeekGUI then return end
    
    local menuFrame = hideAndSeekGUI:FindFirstChild("MenuFrame")
    if not menuFrame then return end
    
    local roomsList = menuFrame:FindFirstChild("RoomsList")
    if not roomsList then return end
    
    -- Effacer la liste actuelle
    for _, child in ipairs(roomsList:GetChildren()) do
        if child:IsA("TextButton") then
            child:Destroy()
        end
    end
    
    -- Ajouter les salles
    if roomsFolder then
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
                    gameState.currentRoom = room.Name:gsub("%.lua$", "")
                end)
            end
        end
    end
    
    -- Ajouter un bouton pour la salle par défaut
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
            gameState.currentRoom = "DefaultRoom"
        end)
    end
end

-- Gestion des événements
StartGameEvent.OnClientEvent:Connect(function(role, seekers, hiders)
    gameState.role = role
    gameState.seekers = seekers
    gameState.hiders = hiders
    gameState.detectedPlayers = {}
    
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
            
            -- Afficher les scores
            local scoresFrame = gameOverFrame and gameOverFrame:FindFirstChild("ScoresFrame")
            if scoresFrame then
                for _, child in ipairs(scoresFrame:GetChildren()) do
                    if child:IsA("TextLabel") then
                        child:Destroy()
                    end
                end
                
                -- Chercheur
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
                
                -- Cacheur
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
            local camouflageButton = hideAndSeekGUI:FindFirstChild("CamouflageButton")
            
            if phaseLabel then phaseLabel.Text = "Phase: " .. phase end
            if timerLabel then timerLabel.Text = "Temps: " .. math.floor(timeRemaining) .. "s" end
            if roleLabel then roleLabel.Text = "Rôle: " .. (gameState.role == "seeker" and "Chercheur" or "Cacheur") end
            
            if camouflageButton then
                camouflageButton.Visible = gameState.role == "hider"
            end
            
            if instructionsLabel then
                if phase == "preparing" then
                    instructionsLabel.Text = gameState.role == "hider" and "Préparez-vous ! Camouflez-vous avant que les chercheur ne commencent." or "Jouez au mini-jeu pendant que les cacheurs se préparent."
                elseif phase == "hiding" then
                    instructionsLabel.Text = "Attendez que les chercheur commencent à chercher."
                elseif phase == "seeking" then
                    instructionsLabel.Text = gameState.role == "seeker" and "Trouvez tous les cacheurs !" or "Restez caché et immobile !"
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
            if timerLabel then
                timerLabel.Text = "Temps: " .. math.floor(timeRemaining) .. "s"
            end
        end
    end
end)

PlayerDetectedEvent.OnClientEvent:Connect(function(hider, seeker)
    gameState.detectedPlayers[hider] = true
    
    local gui = localPlayer:FindFirstChild("PlayerGui")
    if gui then
        local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
        if hideAndSeekGUI then
            local gameFrame = hideAndSeekGUI:FindFirstChild("GameFrame")
            if gameFrame then
                local notification = Instance.new("TextLabel")
                notification.Text = hider.Name .. " a été trouvé par " .. seeker.Name .. "!"
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

-- Entrées clavier
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Escape then
        local gui = localPlayer:FindFirstChild("PlayerGui")
        if gui then
            local hideAndSeekGUI = gui:FindFirstChild("HideAndSeekGUI")
            if hideAndSeekGUI then
                -- Fermer les panneaux ouverts
                for _, child in ipairs(hideAndSeekGUI:GetChildren()) do
                    if child:IsA("Frame") and child.Name ~= "MenuFrame" and child.Name ~= "GameFrame" and child.Name ~= "GameOverFrame" then
                        child.Visible = false
                    end
                end
            end
        end
    end
end)

-- Initialisation
local function init()
    createGUI()
    loadRoomsList()
    setupButtons()
end

-- Attendre que le joueur soit chargé
localPlayer.CharacterAdded:Connect(function()
    init()
end)

-- Initialisation immédiate
init()

print("✅ Hide and Seek - Client initialisé")
