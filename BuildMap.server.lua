--//====================================================
--// HIDE & SEEK HOUSE - BUILD MAP
--// Partie 1 : Structure complète de la maison
--//====================================================

local Workspace = game:GetService("Workspace")

--------------------------------------------------------
-- NETTOYAGE
--------------------------------------------------------

if Workspace:FindFirstChild("HideSeekHouse") then
	Workspace.HideSeekHouse:Destroy()
end

local House = Instance.new("Model")
House.Name = "HideSeekHouse"
House.Parent = Workspace

--------------------------------------------------------
-- MATERIAUX / COULEURS
--------------------------------------------------------

local COLORS = {
	Wall = Color3.fromRGB(235,230,220),
	Floor = Color3.fromRGB(126,92,58),
	Ceiling = Color3.fromRGB(248,248,248),
	Trim = Color3.fromRGB(95,70,45),
	Glass = Color3.fromRGB(190,235,255)
}

--------------------------------------------------------
-- FONCTION PART
--------------------------------------------------------

local function Part(size,pos,color,material,parent)

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
-- SOL
--------------------------------------------------------

local function Floor(center,width,depth)

	return Part(
		Vector3.new(width,1,depth),
		center,
		COLORS.Floor,
		Enum.Material.WoodPlanks,
		House
	)

end

--------------------------------------------------------
-- PLAFOND
--------------------------------------------------------

local function Ceiling(center,width,depth,height)

	return Part(
		Vector3.new(width,1,depth),
		center + Vector3.new(0,height,0),
		COLORS.Ceiling,
		Enum.Material.SmoothPlastic,
		House
	)

end

--------------------------------------------------------
-- MURS
--------------------------------------------------------

local function Wall(size,pos)

	return Part(
		size,
		pos,
		COLORS.Wall,
		Enum.Material.Plaster,
		House
	)

end

--------------------------------------------------------
-- FENETRE
--------------------------------------------------------

local function Window(pos,width,height)

	Part(
		Vector3.new(width,height,0.2),
		pos,
		COLORS.Glass,
		Enum.Material.Glass,
		House
	)

	Part(
		Vector3.new(width+0.2,0.2,0.4),
		pos + Vector3.new(0,height/2,0),
		COLORS.Trim,
		Enum.Material.Wood,
		House
	)

	Part(
		Vector3.new(width+0.2,0.2,0.4),
		pos - Vector3.new(0,height/2,0),
		COLORS.Trim,
		Enum.Material.Wood,
		House
	)

	Part(
		Vector3.new(0.2,height,0.4),
		pos,
		COLORS.Trim,
		Enum.Material.Wood,
		House
	)

end

--------------------------------------------------------
-- PORTE
--------------------------------------------------------

local function Door(pos)

	Part(
		Vector3.new(4,8,0.3),
		pos + Vector3.new(0,4,0),
		Color3.fromRGB(105,70,40),
		Enum.Material.Wood,
		House
	)

end

--------------------------------------------------------
-- ESCALIER CENTRAL
--------------------------------------------------------

local function Staircase(origin)

	local width = 8
	local steps = 18
	local height = 0.5
	local depth = 1.2

	for i = 0,steps-1 do

		Part(
			Vector3.new(width,height,depth),
			origin + Vector3.new(
				0,
				i*height,
				i*depth
			),
			COLORS.Trim,
			Enum.Material.Wood,
			House
		)

	end

end

--------------------------------------------------------
-- TERRAIN
--------------------------------------------------------

Part(
	Vector3.new(180,1,180),
	Vector3.new(0,-1,0),
	Color3.fromRGB(75,140,70),
	Enum.Material.Grass,
	House
)

--------------------------------------------------------
-- REZ-DE-CHAUSSEE
--------------------------------------------------------

local H = 12

-- Hall
Floor(Vector3.new(0,0,0),28,24)
Ceiling(Vector3.new(0,0,0),28,24,H)

-- Salon
Floor(Vector3.new(-24,0,0),20,24)
Ceiling(Vector3.new(-24,0,0),20,24,H)

-- Cuisine
Floor(Vector3.new(24,0,0),20,24)
Ceiling(Vector3.new(24,0,0),20,24,H)

-- Bibliothèque
Floor(Vector3.new(-24,0,-24),20,20)
Ceiling(Vector3.new(-24,0,-24),20,20,H)

-- Salle de jeux
Floor(Vector3.new(24,0,-24),20,20)
Ceiling(Vector3.new(24,0,-24),20,20,H)

--------------------------------------------------------
-- ETAGE
--------------------------------------------------------

local Y = 12

Floor(Vector3.new(0,Y,0),28,24)
Ceiling(Vector3.new(0,Y,0),28,24,H)

Floor(Vector3.new(-24,Y,0),20,24)
Ceiling(Vector3.new(-24,Y,0),20,24,H)

Floor(Vector3.new(24,Y,0),20,24)
Ceiling(Vector3.new(24,Y,0),20,24,H)

Floor(Vector3.new(-24,Y,-24),20,20)
Ceiling(Vector3.new(-24,Y,-24),20,20,H)

Floor(Vector3.new(24,Y,-24),20,20)
Ceiling(Vector3.new(24,Y,-24),20,20,H)

--------------------------------------------------------
-- MURS EXTERIEURS
--------------------------------------------------------

Wall(Vector3.new(68,12,1),Vector3.new(0,6,12))
Wall(Vector3.new(68,12,1),Vector3.new(0,6,-34))

Wall(Vector3.new(1,12,46),Vector3.new(-34,6,-11))
Wall(Vector3.new(1,12,46),Vector3.new(34,6,-11))

--------------------------------------------------------
-- ETAGE EXTERIEUR
--------------------------------------------------------

Wall(Vector3.new(68,12,1),Vector3.new(0,18,12))
Wall(Vector3.new(68,12,1),Vector3.new(0,18,-34))

Wall(Vector3.new(1,12,46),Vector3.new(-34,18,-11))
Wall(Vector3.new(1,12,46),Vector3.new(34,18,-11))

--------------------------------------------------------
-- CLOISONS RDC
--------------------------------------------------------

Wall(Vector3.new(1,12,24),Vector3.new(-14,6,0))
Wall(Vector3.new(1,12,24),Vector3.new(14,6,0))

Wall(Vector3.new(20,12,1),Vector3.new(-24,6,-12))
Wall(Vector3.new(20,12,1),Vector3.new(24,6,-12))

--------------------------------------------------------
-- CLOISONS ETAGE
--------------------------------------------------------

Wall(Vector3.new(1,12,24),Vector3.new(-14,18,0))
Wall(Vector3.new(1,12,24),Vector3.new(14,18,0))

Wall(Vector3.new(20,12,1),Vector3.new(-24,18,-12))
Wall(Vector3.new(20,12,1),Vector3.new(24,18,-12))

--------------------------------------------------------
-- PORTES
--------------------------------------------------------

Door(Vector3.new(-14,0,4))
Door(Vector3.new(14,0,4))
Door(Vector3.new(-24,0,-12))
Door(Vector3.new(24,0,-12))

Door(Vector3.new(-14,12,4))
Door(Vector3.new(14,12,4))
Door(Vector3.new(-24,12,-12))
Door(Vector3.new(24,12,-12))

--------------------------------------------------------
-- FENETRES
--------------------------------------------------------

for x = -24,24,16 do

	Window(Vector3.new(x,5,11.5),6,4)
	Window(Vector3.new(x,17,11.5),6,4)

end

for z = -26,4,14 do

	Window(Vector3.new(-33.5,5,z),6,4)
	Window(Vector3.new(33.5,5,z),6,4)

	Window(Vector3.new(-33.5,17,z),6,4)
	Window(Vector3.new(33.5,17,z),6,4)

end

--------------------------------------------------------
-- ESCALIER
--------------------------------------------------------

Staircase(Vector3.new(0,0,-4))

--------------------------------------------------------
-- LUSTRE
--------------------------------------------------------

local lightPart = Part(
	Vector3.new(2,2,2),
	Vector3.new(0,10.5,0),
	Color3.fromRGB(255,230,170),
	Enum.Material.Neon,
	House
)

local light = Instance.new("PointLight")
light.Range = 40
light.Brightness = 2.5
light.Color = Color3.fromRGB(255,245,220)
light.Parent = lightPart

--------------------------------------------------------

local LivingRoom = require(script.Parent.Rooms.LivingRoom)
local Kitchen = require(script.Parent.Rooms.Kitchen)

LivingRoom.Build(workspace.HideSeekHouse)
Kitchen.Build(workspace.HideSeekHouse)

print("Hide & Seek House : Structure créée !")
