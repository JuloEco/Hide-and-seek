--[[
    RoomModule - Gère les salles et leurs objets
]]

local RoomModule = {}
local ServerStorage = game:GetService("ServerStorage")
local Workspace = game:GetService("Workspace")

-- Liste des salles disponibles
local rooms = {}

-- Initialisation
function RoomModule.init()
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    if roomsFolder then
        for _, roomModel in ipairs(roomsFolder:GetChildren()) do
            if roomModel:IsA("Model") then
                rooms[roomModel.Name] = roomModel
            end
        end
    end
    
    -- Créer une salle par défaut si aucune n'existe
    if next(rooms) == nil then
        RoomModule.createDefaultRoom()
    end
end

-- Création d'une salle par défaut
function RoomModule.createDefaultRoom()
    local roomsFolder = ServerStorage:FindFirstChild("Rooms")
    if not roomsFolder then
        roomsFolder = Instance.new("Folder")
        roomsFolder.Name = "Rooms"
        roomsFolder.Parent = ServerStorage
    end
    
    local defaultRoom = Instance.new("Model")
    defaultRoom.Name = "DefaultRoom"
    
    -- Sol
    local floor = Instance.new("Part")
    floor.Name = "Floor"
    floor.Size = Vector3.new(100, 1, 100)
    floor.Position = Vector3.new(0, -0.5, 0)
    floor.Anchored = true
    floor.Color = Color3.new(0.2, 0.2, 0.3)
    floor.Material = Enum.Material.Concrete
    floor.Parent = defaultRoom
    
    -- Murs
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
    
    -- Objets pour le camouflage
    local box1 = Instance.new("Part")
    box1.Name = "Box1"
    box1.Size = Vector3.new(10, 5, 10)
    box1.Position = Vector3.new(20, 2.5, 20)
    box1.Anchored = true
    box1.Color = Color3.new(0.8, 0.4, 0.2)  -- Bois
    box1.Material = Enum.Material.Wood
    box1.Parent = defaultRoom
    
    local box2 = Instance.new("Part")
    box2.Name = "Box2"
    box2.Size = Vector3.new(8, 6, 8)
    box2.Position = Vector3.new(-20, 3, -20)
    box2.Anchored = true
    box2.Color = Color3.new(0.3, 0.6, 0.3)  -- Vert
    box2.Material = Enum.Material.Grass
    box2.Parent = defaultRoom
    
    local cylinder = Instance.new("Part")
    cylinder.Name = "Cylinder"
    cylinder.Shape = Enum.PartType.Cylinder
    cylinder.Size = Vector3.new(5, 10, 5)
    cylinder.Position = Vector3.new(30, 5, -30)
    cylinder.Anchored = true
    cylinder.Color = Color3.new(0.5, 0.5, 0.5)  -- Métal
    cylinder.Material = Enum.Material.Metal
    cylinder.Parent = defaultRoom
    
    -- Spawn points
    local spawn1 = Instance.new("SpawnLocation")
    spawn1.Name = "Spawn1"
    spawn1.Position = Vector3.new(-30, 1, -30)
    spawn1.Size = Vector3.new(4, 1, 4)
    spawn1.Parent = defaultRoom
    
    local spawn2 = Instance.new("SpawnLocation")
    spawn2.Name = "Spawn2"
    spawn2.Position = Vector3.new(30, 1, 30)
    spawn2.Size = Vector3.new(4, 1, 4)
    spawn2.Parent = defaultRoom
    
    local spawn3 = Instance.new("SpawnLocation")
    spawn3.Name = "Spawn3"
    spawn3.Position = Vector3.new(-30, 1, 30)
    spawn3.Size = Vector3.new(4, 1, 4)
    spawn3.Parent = defaultRoom
    
    local spawn4 = Instance.new("SpawnLocation")
    spawn4.Name = "Spawn4"
    spawn4.Position = Vector3.new(30, 1, -30)
    spawn4.Size = Vector3.new(4, 1, 4)
    spawn4.Parent = defaultRoom
    
    defaultRoom.Parent = roomsFolder
    rooms["DefaultRoom"] = defaultRoom
    print("✅ Salle par défaut créée")
end

-- Chargement d'une salle
function RoomModule.loadRoom(roomName)
    if rooms[roomName] then
        -- Nettoyer les salles existantes
        for _, room in pairs(rooms) do
            if room.model then
                room.model:Destroy()
            end
        end
        
        -- Cloner la salle dans Workspace
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

-- Obtention des objets d'une salle
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
                position = part.Position,
                shape = part.Shape or Enum.PartType.Block
            })
        end
    end
    return objects
end

-- Obtention des points de spawn
function RoomModule.getSpawnPoints(roomModel)
    local spawnPoints = {}
    for _, spawn in ipairs(roomModel:GetChildren()) do
        if spawn:IsA("SpawnLocation") then
            table.insert(spawnPoints, spawn)
        end
    end
    return spawnPoints
end

-- Placement des joueurs dans une salle
function RoomModule.placePlayersInRoom(room, players)
    if not room or not room.spawnPoints or #room.spawnPoints == 0 then
        for i, player in ipairs(players) do
            local x = (i - 1) * 10 - 20
            local spawnPos = Vector3.new(x, 5, 0)
            
            if player.Character then
                local humanoidRoot = player.Character:FindFirstChild("HumanoidRootPart")
                if humanoidRoot then
                    humanoidRoot.CFrame = CFrame.new(spawnPos)
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

-- Suppression d'une salle
function RoomModule.unloadRoom(room)
    if room and room.model then
        room.model:Destroy()
    end
end

-- Obtention de toutes les salles
function RoomModule.getAllRooms()
    return rooms
end

-- Initialisation automatique
RoomModule.init()

return RoomModule
