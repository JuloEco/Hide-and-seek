--//====================================================
--// LivingRoom.lua
--// Salon principal de Hide & Seek House
--//====================================================

local Furniture = require(script.Parent.Parent.Furniture)
local RoomBuilder = require(script.Parent.Parent.RoomBuilder)

local LivingRoom = {}

function LivingRoom.Build(parent)

	----------------------------------------------------
	-- MODELE
	----------------------------------------------------

	local room = Instance.new("Model")
	room.Name = "LivingRoom"
	room.Parent = parent

	----------------------------------------------------
	-- SOL + TAPIS
	----------------------------------------------------

	RoomBuilder.CreateRug(
		room,
		Vector3.new(-24,0,-1),
		12,
		8,
		Color3.fromRGB(170,55,55)
	)

	----------------------------------------------------
	-- CHEMINEE
	----------------------------------------------------

	Furniture.Fireplace(
		room,
		Vector3.new(-32,0,-8)
	)

	----------------------------------------------------
	-- TABLEAUX
	----------------------------------------------------

	local function Painting(pos,color)

		local frame = Instance.new("Model")
		frame.Parent = room

		local wood = Instance.new("Part")
		wood.Anchored = true
		wood.Size = Vector3.new(5,3.5,0.2)
		wood.Position = pos
		wood.Color = Color3.fromRGB(90,60,35)
		wood.Material = Enum.Material.Wood
		wood.Parent = frame

		local art = Instance.new("Part")
		art.Anchored = true
		art.Size = Vector3.new(4.4,2.9,0.05)
		art.Position = pos + Vector3.new(0,0,0.11)
		art.Color = color
		art.Material = Enum.Material.SmoothPlastic
		art.Parent = frame

	end

	Painting(
		Vector3.new(-32,6,-9.4),
		Color3.fromRGB(80,140,220)
	)

	Painting(
		Vector3.new(-16,6,11.4),
		Color3.fromRGB(230,180,60)
	)

	----------------------------------------------------
	-- CANAPES
	----------------------------------------------------

	Furniture.Sofa(
		room,
		Vector3.new(-20,0,4)
	)

	Furniture.Sofa(
		room,
		Vector3.new(-28,0,-4)
	)

	----------------------------------------------------
	-- TABLE BASSE
	----------------------------------------------------

	Furniture.Table(
		room,
		Vector3.new(-24,0,0)
	)

	----------------------------------------------------
	-- LIVRES SUR LA TABLE
	----------------------------------------------------

	for i = -1,1 do

		local book = Instance.new("Part")
		book.Anchored = true
		book.Size = Vector3.new(1.3,0.2,1)
		book.Position = Vector3.new(-24+i,3.25,0)

		local colors = {
			Color3.fromRGB(210,60,60),
			Color3.fromRGB(70,170,255),
			Color3.fromRGB(70,190,120)
		}

		book.Color = colors[i+2]
		book.Material = Enum.Material.SmoothPlastic
		book.Parent = room

	end

	----------------------------------------------------
	-- PIANO
	----------------------------------------------------

	Furniture.Piano(
		room,
		Vector3.new(-16,0,-8)
	)

	----------------------------------------------------
	-- TABOURET
	----------------------------------------------------

	Furniture.Chair(
		room,
		Vector3.new(-16,0,-5)
	)

	----------------------------------------------------
	-- BIBLIOTHEQUE
	----------------------------------------------------

	Furniture.Bookshelf(
		room,
		Vector3.new(-15,0,9)
	)

	----------------------------------------------------
	-- PLANTES
	----------------------------------------------------

	Furniture.Plant(
		room,
		Vector3.new(-33,0,9)
	)

	Furniture.Plant(
		room,
		Vector3.new(-15,0,-9)
	)

	----------------------------------------------------
	-- LAMPADAIRES
	----------------------------------------------------

	Furniture.FloorLamp(
		room,
		Vector3.new(-18,0,9)
	)

	Furniture.FloorLamp(
		room,
		Vector3.new(-30,0,8)
	)

	----------------------------------------------------
	-- RIDEAUX
	----------------------------------------------------

	local function Curtain(x)

		local rod = Instance.new("Part")
		rod.Anchored = true
		rod.Size = Vector3.new(6,0.2,0.2)
		rod.Position = Vector3.new(x,8.8,11.2)
		rod.Color = Color3.fromRGB(45,45,45)
		rod.Material = Enum.Material.Metal
		rod.Parent = room

		local left = Instance.new("Part")
		left.Anchored = true
		left.Size = Vector3.new(2.8,4,0.1)
		left.Position = Vector3.new(x-1.6,6.5,11.15)
		left.Color = Color3.fromRGB(190,200,210)
		left.Material = Enum.Material.Fabric
		left.Parent = room

		local right = left:Clone()
		right.Position = Vector3.new(x+1.6,6.5,11.15)
		right.Parent = room

	end

	Curtain(-24)

	----------------------------------------------------
	-- PETITS CARTONS (CACHE)
	----------------------------------------------------

	for _,v in ipairs({
		Vector3.new(-30,0,3),
		Vector3.new(-31,0,2),
		Vector3.new(-29,0,1)
		}) do

		local box = Instance.new("Part")
		box.Anchored = true
		box.Size = Vector3.new(2,2,2)
		box.Position = v + Vector3.new(0,1,0)
		box.Color = Color3.fromRGB(150,110,70)
		box.Material = Enum.Material.Wood
		box.Parent = room

	end

	----------------------------------------------------
	-- LUSTRE CENTRAL
	----------------------------------------------------

	RoomBuilder.CreateCeilingLamp(
		room,
		Vector3.new(-24,9,0)
	)

	return room

end

return LivingRoom
