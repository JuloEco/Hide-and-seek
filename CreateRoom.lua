--//====================================================
--// RoomBuilder.lua
--// Générateur de pièces pour Hide & Seek House
--//====================================================

local RoomBuilder = {}

--------------------------------------------------------
-- CONFIGURATION
--------------------------------------------------------

RoomBuilder.Colors = {
	Wall     = Color3.fromRGB(236,231,222),
	Floor    = Color3.fromRGB(126,92,58),
	Ceiling  = Color3.fromRGB(248,248,246),
	Trim     = Color3.fromRGB(92,68,45),
	Glass    = Color3.fromRGB(190,235,255)
}

--------------------------------------------------------
-- PART
--------------------------------------------------------

local function createPart(parent,size,pos,color,material)

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

function RoomBuilder.CreateFloor(parent,center,width,depth)

	return createPart(
		parent,
		Vector3.new(width,1,depth),
		center,
		RoomBuilder.Colors.Floor,
		Enum.Material.WoodPlanks
	)

end

--------------------------------------------------------
-- PLAFOND
--------------------------------------------------------

function RoomBuilder.CreateCeiling(parent,center,width,depth,height)

	return createPart(
		parent,
		Vector3.new(width,1,depth),
		center + Vector3.new(0,height,0),
		RoomBuilder.Colors.Ceiling,
		Enum.Material.SmoothPlastic
	)

end

--------------------------------------------------------
-- MUR PLEIN
--------------------------------------------------------

function RoomBuilder.CreateWall(parent,size,pos)

	return createPart(
		parent,
		size,
		pos,
		RoomBuilder.Colors.Wall,
		Enum.Material.Plaster
	)

end

--------------------------------------------------------
-- FENÊTRE
--------------------------------------------------------

function RoomBuilder.CreateWindow(parent,pos,width,height)

	local frame = Instance.new("Model")
	frame.Name = "Window"
	frame.Parent = parent

	createPart(
		frame,
		Vector3.new(width,height,0.15),
		pos,
		RoomBuilder.Colors.Glass,
		Enum.Material.Glass
	)

	createPart(
		frame,
		Vector3.new(width+0.2,0.25,0.35),
		pos + Vector3.new(0,height/2,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	createPart(
		frame,
		Vector3.new(width+0.2,0.25,0.35),
		pos - Vector3.new(0,height/2,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	createPart(
		frame,
		Vector3.new(0.25,height,0.35),
		pos + Vector3.new(width/2,0,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	createPart(
		frame,
		Vector3.new(0.25,height,0.35),
		pos - Vector3.new(width/2,0,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	return frame

end

--------------------------------------------------------
-- PORTE
--------------------------------------------------------

function RoomBuilder.CreateDoor(parent,pos)

	local model = Instance.new("Model")
	model.Name = "Door"
	model.Parent = parent

	createPart(
		model,
		Vector3.new(4.2,0.3,0.4),
		pos + Vector3.new(0,8.15,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	createPart(
		model,
		Vector3.new(0.3,8,0.4),
		pos + Vector3.new(-2.1,4,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	createPart(
		model,
		Vector3.new(0.3,8,0.4),
		pos + Vector3.new(2.1,4,0),
		RoomBuilder.Colors.Trim,
		Enum.Material.Wood
	)

	local door = createPart(
		model,
		Vector3.new(3.8,7.8,0.25),
		pos + Vector3.new(0,3.9,0),
		Color3.fromRGB(110,73,42),
		Enum.Material.Wood
	)

	local knob = Instance.new("Part")
	knob.Shape = Enum.PartType.Ball
	knob.Size = Vector3.new(0.25,0.25,0.25)
	knob.Anchored = true
	knob.Material = Enum.Material.Metal
	knob.Color = Color3.fromRGB(230,190,70)
	knob.Position = pos + Vector3.new(1.4,4,0.18)
	knob.Parent = model

	return model

end

--------------------------------------------------------
-- PIÈCE COMPLÈTE
--------------------------------------------------------

function RoomBuilder.CreateRoom(parent,info)

	local room = Instance.new("Model")
	room.Name = info.Name or "Room"
	room.Parent = parent

	local c = info.Position
	local w = info.Width
	local d = info.Depth
	local h = info.Height

	RoomBuilder.CreateFloor(room,c,w,d)
	RoomBuilder.CreateCeiling(room,c,w,d,h)

	createPart(
		room,
		Vector3.new(w,h,1),
		c + Vector3.new(0,h/2,-d/2),
		RoomBuilder.Colors.Wall,
		Enum.Material.Plaster
	)

	createPart(
		room,
		Vector3.new(w,h,1),
		c + Vector3.new(0,h/2,d/2),
		RoomBuilder.Colors.Wall,
		Enum.Material.Plaster
	)

	createPart(
		room,
		Vector3.new(1,h,d),
		c + Vector3.new(-w/2,h/2,0),
		RoomBuilder.Colors.Wall,
		Enum.Material.Plaster
	)

	createPart(
		room,
		Vector3.new(1,h,d),
		c + Vector3.new(w/2,h/2,0),
		RoomBuilder.Colors.Wall,
		Enum.Material.Plaster
	)

	return room

end

--------------------------------------------------------
-- TAPIS
--------------------------------------------------------

function RoomBuilder.CreateRug(parent,pos,width,depth,color)

	local rug = createPart(
		parent,
		Vector3.new(width,0.05,depth),
		pos + Vector3.new(0,0.53,0),
		color,
		Enum.Material.Fabric
	)

	return rug

end

--------------------------------------------------------
-- LUSTRE
--------------------------------------------------------

function RoomBuilder.CreateCeilingLamp(parent,pos)

	local model = Instance.new("Model")
	model.Name = "CeilingLamp"
	model.Parent = parent

	createPart(
		model,
		Vector3.new(0.15,1.5,0.15),
		pos + Vector3.new(0,0.75,0),
		Color3.fromRGB(40,40,40),
		Enum.Material.Metal
	)

	local bulb = createPart(
		model,
		Vector3.new(1.2,0.5,1.2),
		pos + Vector3.new(0,1.7,0),
		Color3.fromRGB(255,240,190),
		Enum.Material.Neon
	)

	local light = Instance.new("PointLight")
	light.Range = 28
	light.Brightness = 2
	light.Color = Color3.fromRGB(255,244,220)
	light.Parent = bulb

	return model

end

--------------------------------------------------------

return RoomBuilder
