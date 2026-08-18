--//====================================================
--// Furniture.lua
--// Meubles détaillés pour Hide & Seek House
--//====================================================

local Furniture = {}

--------------------------------------------------------
-- COULEURS
--------------------------------------------------------

local WOOD      = Color3.fromRGB(120,82,52)
local DARKWOOD  = Color3.fromRGB(82,55,35)
local FABRIC    = Color3.fromRGB(58,96,175)
local CUSHION   = Color3.fromRGB(82,125,210)
local METAL     = Color3.fromRGB(145,145,150)
local WHITE     = Color3.fromRGB(235,235,235)
local BLACK     = Color3.fromRGB(35,35,35)

--------------------------------------------------------
-- OUTIL
--------------------------------------------------------

local function P(parent,size,pos,color,material)

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
-- TABLE
--------------------------------------------------------

function Furniture.Table(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Table"
	m.Parent = parent

	P(m,Vector3.new(8,0.4,4),pos+Vector3.new(0,3,0),WOOD,Enum.Material.Wood)

	for x=-3.3,3.3,6.6 do
		for z=-1.3,1.3,2.6 do
			P(m,Vector3.new(0.4,3,0.4),pos+Vector3.new(x,1.5,z),DARKWOOD,Enum.Material.Wood)
		end
	end

	return m
end

--------------------------------------------------------
-- CHAISE
--------------------------------------------------------

function Furniture.Chair(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Chair"
	m.Parent = parent

	P(m,Vector3.new(2,0.3,2),pos+Vector3.new(0,1.6,0),WOOD,Enum.Material.Wood)

	P(m,Vector3.new(2,2,0.25),pos+Vector3.new(0,2.8,-0.85),WOOD,Enum.Material.Wood)

	for x=-0.8,0.8,1.6 do
		for z=-0.8,0.8,1.6 do
			P(m,Vector3.new(0.25,1.6,0.25),pos+Vector3.new(x,0.8,z),DARKWOOD,Enum.Material.Wood)
		end
	end

	return m
end

--------------------------------------------------------
-- CANAPE
--------------------------------------------------------

function Furniture.Sofa(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Sofa"
	m.Parent = parent

	P(m,Vector3.new(7,1,3),pos+Vector3.new(0,1,0),FABRIC,Enum.Material.Fabric)

	P(m,Vector3.new(7,2,0.7),pos+Vector3.new(0,2,-1.15),FABRIC,Enum.Material.Fabric)

	P(m,Vector3.new(0.7,2,3),pos+Vector3.new(-3.15,2,0),FABRIC,Enum.Material.Fabric)
	P(m,Vector3.new(0.7,2,3),pos+Vector3.new(3.15,2,0),FABRIC,Enum.Material.Fabric)

	for x=-2,2,2 do
		P(m,Vector3.new(1.6,0.5,1.2),pos+Vector3.new(x,1.8,-0.3),CUSHION,Enum.Material.Fabric)
	end

	for x=-2.7,2.7,5.4 do
		for z=-1.2,1.2,2.4 do
			P(m,Vector3.new(0.2,0.3,0.2),pos+Vector3.new(x,0.15,z),BLACK,Enum.Material.Metal)
		end
	end

	return m
end

--------------------------------------------------------
-- BIBLIOTHEQUE
--------------------------------------------------------

function Furniture.Bookshelf(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Bookshelf"
	m.Parent = parent

	P(m,Vector3.new(6,8,1),pos+Vector3.new(0,4,0),DARKWOOD,Enum.Material.Wood)

	for y=0.8,7,1 do
		P(m,Vector3.new(5.8,0.12,0.9),pos+Vector3.new(0,y,0),WOOD,Enum.Material.Wood)
	end

	local palette = {
		Color3.fromRGB(220,70,70),
		Color3.fromRGB(80,180,255),
		Color3.fromRGB(70,200,120),
		Color3.fromRGB(235,205,70),
		Color3.fromRGB(170,90,220)
	}

	for shelf=1,7 do

		for i=-2.4,2.4,0.45 do

			local h = math.random(7,12)/10

			P(
				m,
				Vector3.new(0.28,h,0.72),
				pos+Vector3.new(i,shelf-0.15+h/2,0),
				palette[math.random(#palette)],
				Enum.Material.SmoothPlastic
			)

		end

	end

	return m
end

--------------------------------------------------------
-- LIT
--------------------------------------------------------

function Furniture.Bed(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Bed"
	m.Parent = parent

	P(m,Vector3.new(6,0.6,8),pos+Vector3.new(0,0.3,0),DARKWOOD,Enum.Material.Wood)

	P(m,Vector3.new(5.6,1,7.6),pos+Vector3.new(0,1.1,0),WHITE,Enum.Material.Fabric)

	P(m,Vector3.new(5.6,0.5,2),pos+Vector3.new(0,1.85,-3),Color3.fromRGB(225,225,230),Enum.Material.Fabric)

	P(m,Vector3.new(6,3,0.4),pos+Vector3.new(0,1.5,-3.8),DARKWOOD,Enum.Material.Wood)

	return m
end

--------------------------------------------------------
-- ARMOIRE
--------------------------------------------------------

function Furniture.Wardrobe(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Wardrobe"
	m.Parent = parent

	P(m,Vector3.new(5,8,2),pos+Vector3.new(0,4,0),WOOD,Enum.Material.Wood)

	P(m,Vector3.new(0.15,7.6,1.8),pos+Vector3.new(-1.2,4,0),DARKWOOD,Enum.Material.Wood)
	P(m,Vector3.new(0.15,7.6,1.8),pos+Vector3.new(1.2,4,0),DARKWOOD,Enum.Material.Wood)

	local knob1 = Instance.new("Part")
	knob1.Shape = Enum.PartType.Ball
	knob1.Size = Vector3.new(0.18,0.18,0.18)
	knob1.Position = pos+Vector3.new(-0.3,4,1.02)
	knob1.Color = Color3.fromRGB(230,190,70)
	knob1.Material = Enum.Material.Metal
	knob1.Anchored = true
	knob1.Parent = m

	local knob2 = knob1:Clone()
	knob2.Position = pos+Vector3.new(0.3,4,1.02)
	knob2.Parent = m

	return m
end

--------------------------------------------------------
-- PLANTE
--------------------------------------------------------

function Furniture.Plant(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Plant"
	m.Parent = parent

	P(m,Vector3.new(1.6,1,1.6),pos+Vector3.new(0,0.5,0),Color3.fromRGB(110,70,40),Enum.Material.Wood)

	P(m,Vector3.new(0.35,2.4,0.35),pos+Vector3.new(0,2.2,0),Color3.fromRGB(70,120,55),Enum.Material.Wood)

	for i=1,8 do

		local angle = math.rad(i*45)

		local x = math.cos(angle)*0.7
		local z = math.sin(angle)*0.7

		P(
			m,
			Vector3.new(0.25,1.2,0.6),
			pos+Vector3.new(x,3,z),
			Color3.fromRGB(60,165,70),
			Enum.Material.Grass
		)

	end

	return m
end

--------------------------------------------------------
-- LAMPADAIRE
--------------------------------------------------------

function Furniture.FloorLamp(parent,pos)

	local m = Instance.new("Model")
	m.Name = "FloorLamp"
	m.Parent = parent

	P(m,Vector3.new(1.4,0.2,1.4),pos+Vector3.new(0,0.1,0),BLACK,Enum.Material.Metal)

	P(m,Vector3.new(0.15,5,0.15),pos+Vector3.new(0,2.6,0),BLACK,Enum.Material.Metal)

	local head = P(
		m,
		Vector3.new(1.8,0.7,1.8),
		pos+Vector3.new(0,5.3,0),
		Color3.fromRGB(255,240,190),
		Enum.Material.Neon
	)

	local light = Instance.new("PointLight")
	light.Range = 22
	light.Brightness = 1.5
	light.Parent = head

	return m
end

--------------------------------------------------------
-- CHEMINEE
--------------------------------------------------------

function Furniture.Fireplace(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Fireplace"
	m.Parent = parent

	P(m,Vector3.new(8,6,2),pos+Vector3.new(0,3,0),Color3.fromRGB(165,165,170),Enum.Material.Brick)

	P(m,Vector3.new(6,3,1.4),pos+Vector3.new(0,2.5,0.4),BLACK,Enum.Material.Slate)

	local fire = P(
		m,
		Vector3.new(3,0.5,1),
		pos+Vector3.new(0,1,0.3),
		Color3.fromRGB(255,140,30),
		Enum.Material.Neon
	)

	local light = Instance.new("PointLight")
	light.Color = Color3.fromRGB(255,170,80)
	light.Range = 16
	light.Brightness = 2
	light.Parent = fire

	return m
end

--------------------------------------------------------
-- PIANO
--------------------------------------------------------

function Furniture.Piano(parent,pos)

	local m = Instance.new("Model")
	m.Name = "Piano"
	m.Parent = parent

	P(m,Vector3.new(6,3,3),pos+Vector3.new(0,1.5,0),BLACK,Enum.Material.SmoothPlastic)

	P(m,Vector3.new(5.5,0.15,1),pos+Vector3.new(0,2.2,-1),WHITE,Enum.Material.SmoothPlastic)

	for x=-2.4,2.4,0.3 do

		P(
			m,
			Vector3.new(0.18,0.1,0.8),
			pos+Vector3.new(x,2.3,-1),
			BLACK,
			Enum.Material.SmoothPlastic
		)

	end

	return m
end

--------------------------------------------------------

return Furniture
