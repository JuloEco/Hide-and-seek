--//====================================================
--// Kitchen.lua
--// Cuisine moderne - Hide & Seek House
--//====================================================

local Furniture = require(script.Parent.Parent.Furniture)
local RoomBuilder = require(script.Parent.Parent.RoomBuilder)

local Kitchen = {}

--------------------------------------------------------
-- OUTIL
--------------------------------------------------------

local function Part(parent,size,pos,color,material)

	local p = Instance.new("Part")
	p.Anchored = true
	p.Size = size
	p.Position = pos
	p.Color = color
	p.Material = material
	p.TopSurface = Enum.SurfaceType.Smooth
	p.BottomSurface = Enum.SurfaceType.Smooth
	p.Parent = parent

	return p
end

--------------------------------------------------------
-- PLACARD
--------------------------------------------------------

local function Cabinet(parent,pos)

	local model = Instance.new("Model")
	model.Parent = parent

	Part(model,Vector3.new(4,3,2),pos+Vector3.new(0,1.5,0),
		Color3.fromRGB(225,225,225),Enum.Material.SmoothPlastic)

	Part(model,Vector3.new(4,0.15,2),pos+Vector3.new(0,3.08,0),
		Color3.fromRGB(45,45,45),Enum.Material.Granite)

	for x=-1,1,2 do
		local handle = Part(model,Vector3.new(0.08,0.8,0.08),
			pos+Vector3.new(x,1.5,1.02),
			Color3.fromRGB(160,160,165),Enum.Material.Metal)
	end

	return model
end

--------------------------------------------------------
-- PLACARD HAUT
--------------------------------------------------------

local function UpperCabinet(parent,pos)

	local model = Instance.new("Model")
	model.Parent = parent

	Part(model,Vector3.new(4,2.4,1.2),pos+Vector3.new(0,1.2,0),
		Color3.fromRGB(235,235,235),Enum.Material.SmoothPlastic)

	for x=-1,1,2 do
		Part(model,Vector3.new(0.08,0.7,0.08),
			pos+Vector3.new(x,1.2,0.62),
			Color3.fromRGB(160,160,160),Enum.Material.Metal)
	end

	return model
end

--------------------------------------------------------
-- FRIGO
--------------------------------------------------------

local function Fridge(parent,pos)

	local m = Instance.new("Model")
	m.Parent = parent

	Part(m,Vector3.new(3.5,7,3),pos+Vector3.new(0,3.5,0),
		Color3.fromRGB(235,238,240),Enum.Material.Metal)

	Part(m,Vector3.new(3.3,0.08,2.8),pos+Vector3.new(0,4.5,1.51),
		Color3.fromRGB(190,195,200),Enum.Material.Metal)

	for y=2.5,5.5,3 do
		Part(m,Vector3.new(0.08,1.2,0.08),
			pos+Vector3.new(1.4,y,1.52),
			Color3.fromRGB(140,140,145),Enum.Material.Metal)
	end

	return m
end

--------------------------------------------------------
-- FOUR
--------------------------------------------------------

local function Oven(parent,pos)

	local m = Instance.new("Model")
	m.Parent = parent

	Part(m,Vector3.new(4,3,2),pos+Vector3.new(0,1.5,0),
		Color3.fromRGB(60,60,60),Enum.Material.Metal)

	Part(m,Vector3.new(3,1.5,0.08),pos+Vector3.new(0,1.7,1.02),
		Color3.fromRGB(25,25,25),Enum.Material.Glass)

	for x=-1.2,1.2,0.8 do
		Part(m,Vector3.new(0.2,0.2,0.2),
			pos+Vector3.new(x,2.8,1.02),
			Color3.fromRGB(180,180,180),Enum.Material.Metal)
	end

	return m
end

--------------------------------------------------------
-- EVIER
--------------------------------------------------------

local function Sink(parent,pos)

	Cabinet(parent,pos)

	Part(parent,Vector3.new(2,0.2,1.2),pos+Vector3.new(0,3.15,0),
		Color3.fromRGB(170,170,175),Enum.Material.Metal)

	Part(parent,Vector3.new(0.15,1,0.15),pos+Vector3.new(0,3.7,0),
		Color3.fromRGB(180,180,180),Enum.Material.Metal)

	Part(parent,Vector3.new(0.6,0.15,0.6),pos+Vector3.new(0.3,4.1,0),
		Color3.fromRGB(180,180,180),Enum.Material.Metal)
end

--------------------------------------------------------
-- TABLEAU
--------------------------------------------------------

local function Picture(parent,pos)

	Part(parent,Vector3.new(4,3,0.2),pos,
		Color3.fromRGB(95,65,45),Enum.Material.Wood)

	Part(parent,Vector3.new(3.4,2.4,0.05),pos+Vector3.new(0,0,0.11),
		Color3.fromRGB(255,190,70),Enum.Material.SmoothPlastic)
end

--------------------------------------------------------
-- CONSTRUCTION
--------------------------------------------------------

function Kitchen.Build(parent)

	local room = Instance.new("Model")
	room.Name = "Kitchen"
	room.Parent = parent

	----------------------------------------------------
	-- TAPIS
	----------------------------------------------------

	RoomBuilder.CreateRug(
		room,
		Vector3.new(24,0,2),
		10,
		5,
		Color3.fromRGB(90,120,180)
	)

	----------------------------------------------------
	-- MUR DE TRAVAIL
	----------------------------------------------------

	Cabinet(room,Vector3.new(16,0,-8))
	Sink(room,Vector3.new(20,0,-8))
	Oven(room,Vector3.new(24,0,-8))
	Cabinet(room,Vector3.new(28,0,-8))

	UpperCabinet(room,Vector3.new(16,5,-8.4))
	UpperCabinet(room,Vector3.new(20,5,-8.4))
	UpperCabinet(room,Vector3.new(28,5,-8.4))

	----------------------------------------------------
	-- HOTTE
	----------------------------------------------------

	Part(room,Vector3.new(3,1.5,1.4),
		Vector3.new(24,7,-8.4),
		Color3.fromRGB(170,170,175),
		Enum.Material.Metal)

	----------------------------------------------------
	-- DOUBLE FRIGO
	----------------------------------------------------

	Fridge(room,Vector3.new(31,0,-5))

	----------------------------------------------------
	-- ILOT CENTRAL
	----------------------------------------------------

	for x=20,28,4 do
		Cabinet(room,Vector3.new(x,0,3))
	end

	----------------------------------------------------
	-- TABOURETS
	----------------------------------------------------

	for x=20,24,4 do
		Furniture.Chair(room,Vector3.new(x,0,7))
	end

	----------------------------------------------------
	-- TABLE
	----------------------------------------------------

	Furniture.Table(room,Vector3.new(18,0,9))

	Furniture.Chair(room,Vector3.new(13,0,9))
	Furniture.Chair(room,Vector3.new(23,0,9))
	Furniture.Chair(room,Vector3.new(18,0,5))
	Furniture.Chair(room,Vector3.new(18,0,13))

	----------------------------------------------------
	-- PLANTE
	----------------------------------------------------

	Furniture.Plant(room,Vector3.new(31,0,10))

	----------------------------------------------------
	-- LAMPADAIRES
	----------------------------------------------------

	Furniture.FloorLamp(room,Vector3.new(15,0,10))

	----------------------------------------------------
	-- TABLEAU
	----------------------------------------------------

	Picture(room,Vector3.new(30,6,11.3))

	----------------------------------------------------
	-- FRUITS SUR L'ILOT
	----------------------------------------------------

	local colors = {
		Color3.fromRGB(220,40,40),
		Color3.fromRGB(250,210,60),
		Color3.fromRGB(60,180,70)
	}

	for i=-1,1 do

		local apple = Instance.new("Part")
		apple.Shape = Enum.PartType.Ball
		apple.Size = Vector3.new(0.45,0.45,0.45)
		apple.Anchored = true
		apple.Position = Vector3.new(24+i*0.6,3.45,3)
		apple.Color = colors[i+2]
		apple.Material = Enum.Material.SmoothPlastic
		apple.Parent = room

	end

	----------------------------------------------------
	-- LUSTRE
	----------------------------------------------------

	RoomBuilder.CreateCeilingLamp(room,Vector3.new(24,9,3))

	return room

end

return Kitchen
