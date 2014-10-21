--[[
	Map Class
	
	moved to dustbin because doesn't work in windbot
	to avoid hacking methods file read in global scope was disabled
	making impossible to read map files from the user app data
]]--

Map = {}
Map.__index = Map
Map.__class = "Map"

Map.__data = {
	--[[ The map folder where files are stored ]]--
	MAP_PATH = os.getenv("APPDATA") .. "\\Tibia\\Automap",
	
	--[[ The map file color structure ]]--
	MAP_COLORS = {
		{id = 000, color = color(000,000,000)},	-- black void
		{id = 024, color = color(000,204,000)},	-- grass or stone ground
		{id = 030, color = color(000,255,000)},	-- swamp
		{id = 040, color = color(051,000,204)},	-- water
		{id = 086, color = color(102,102,102)},	-- mountain or rock
		{id = 114, color = color(153,051,000)},	-- cave wall
		{id = 121, color = color(153,102,051)},	-- cave mud
		{id = 129, color = color(153,153,153)},	-- normal floor or road
		{id = 179, color = color(204,255,255)},	-- ice walls
		{id = 186, color = color(255,051,000)}, -- wall
		{id = 192, color = color(255,102,000)},	-- lava
		{id = 207, color = color(255,204,153)}, -- sand
		{id = 210, color = color(255,255,000)}, -- ladder, hole, rope point, stairs, teleporter
		{id = 215, color = color(255,255,255)}, -- snow
		{id = 255, color = color(150,000,255)}, -- unknown
	},
}

function Map.New(x, y, z, debugMode)
	local positions, index, data = {}, 1
	local file = io.open(string.format("%s\\%03d%03d%02d.map", Map.__data.MAP_PATH, x/256, y/256, z), "rb")
    	
	if file then
		data = file:read(65536)
		file:close()
	elseif debugMode then
		return printerrorf("[Map.New]: \'No such file found in %q\' (filename: %q)", Map.__data.MAP_PATH, string.format("%03d%03d%02d.map", x/256, y/256, z))
	end
	
	for ix = 0, 255 do
		for iy = 0, 255 do
			table.insert(positions, {x = ix + x, y = iy + y, z = z, color = data:byte(index)})
			index = index + 1
		end
	end
	
	local marksAmount = data:byte(index, index+4) or 0
	
	return setmetatable({debugmode = debugMode, positions = positions, marksAmount = marksAmount}, Map)
end

function Map:MarksAmount()
	return self.marksAmount
end

function Map:HasMarks()
	return self.marksAmount > 0
end

function Map:Tiles(separated)
	local i = 0
	
	return function()
		i = i + 1
		
		if self.positions[i] then
			return (separated and unpack({positions[i].x, positions[i].y, positions[i].z, positions[i].color})) or positions[i]
		end
		
		return nil
	end
end

function Map:GetColorByID(id)
	local pos = table.bynaryfind(self.__data.MAP_COLORS, id, 'id')
	
	if pos then
		return self.__data.MAP_COLORS[pos].color
	end
	
	return -1
end
