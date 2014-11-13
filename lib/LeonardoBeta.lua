--[[
	Leonardo's Library
	Created: 15/01/2014
	Version: 1.5.0 beta
	Updated: 12/11/2014

	Last Changelog:

	Added botversion: returns a number variation of the already existent $botversion which returns string
	Added table.search: a new table.find which allow advanced searching methods for different value types
	Added drawvector: a hud function to draw a vector between (a/b) <-> (x/y) axis
	Added randomcolor: a randomizer for any color, gradient or not based in HSB with some other cool options
--]]


-- GLOBALS AND LOCAL VARIABLES

LIBS = LIBS or {}
LIBS.LEONARDO = "1.5.0b"

POLICY_NONE = 'None'
POLICY_CAVEBOT = 'Cavebot'
POLICY_TARGETING = 'Targeting'
POLICY_ALL = 'Cavebot & Targeting'

AREA_SQUARE_FILLED = 'Square (Filled)'
AREA_SQUARE_BORDER = 'Square (Border Only)'
AREA_SQUARE_DOUBLE_BORDER = 'Square (Double Border)'

local SA_POLICY = {POLICY_CAVEBOT, POLICY_TARGETING, POLICY_ALL}
local SA_TYPE = {AREA_SQUARE_FILLED, AREA_SQUARE_BORDER, AREA_SQUARE_DOUBLE_BORDER}

local slotNames = {
	["amulet"] = function() return {name = 'neck', obj = $neck} end,
	["neck"] = function() return {name = 'neck', obj = $neck} end,
	["weapon"] = function() return {name = 'rhand', obj = $rhand} end,
	["rhand"] = function() return {name = 'rhand', obj = $rhand} end,
	["shield"] = function() return {name = 'lhand', obj = $lhand} end,
	["lhand"] = function() return {name = 'lhand', obj = $lhand} end,
	["ring"] = function() return {name = 'finger', obj = $finger} end,
	["finger"] = function() return {name = 'finger', obj = $finger} end,
	["armor"] = function() return {name = 'chest', obj = $chest} end,
	["chest"] = function() return {name = 'chest', obj = $chest} end,
	["boots"] = function() return {name = 'feet', obj = $feet} end,
	["feet"] = function() return {name = 'feet', obj = $feet} end,
	["ammo"] = function() return {name = 'belt', obj = $belt} end,
	["belt"] = function() return {name = 'belt', obj = $belt} end,
	["helmet"] = function() return {name = 'head', obj = $head} end,
	["head"] = function() return {name = 'head', obj = $head} end,
	["legs"] = function() return {name = 'legs', obj = $legs} end,
}

local cityTemples = {
	-- thanks @Donatello for finding the positions:
	--{fx, lx, fy, ly, z}
	{32953, 32966, 32072, 32081, 7}, -- venore
	{32358, 32380, 32231, 32248, 7}, -- thais
	{32357, 32363, 31776, 31787, 7}, -- carlin
	{32718, 32739, 31628, 31640, 7}, -- abdendriel
	{33509, 33517, 32360, 32366, 7}, -- roshaamul
	{33208, 33225, 31804, 31819, 8}, -- edron
	{33018, 33033, 31511, 31531, 11}, -- farmine
	{33018, 33033, 31511, 31531, 13}, -- farmine
	{33018, 33033, 31511, 31531, 15}, -- farmine
	{33210, 33218, 32450, 32457, 1}, -- darashia
	{32642, 32662, 31920, 31929, 11}, -- kazordoon
	{32093, 32101, 32216, 32222, 7}, -- rookgaard
	{33442, 33454, 31312, 31326, 9}, -- gray island
	{32208, 32217, 31128, 31138, 7}, -- svargrond
	{33188, 33201, 32844, 32857, 8}, -- ankrahmun
	{32590, 32599, 32740, 32749, 6}, -- port hope
	{32313, 32321, 32818, 32830, 7}, -- liberty bay
	{32785, 32789, 31274, 31279, 7}, -- yalahar
	{33586, 33602, 31896, 31903, 6}, -- oramond
}

local defaultColors = {
	['red'] = {0, 16},
	['yellow'] = {47, 55},
	['blue'] = {180, 225},
	['green'] = {63, 179},
	['purple'] = {240, 280},
	['orange'] = {16, 43},
	['pink'] = {300, 336},
	['cyan'] = {168, 187},
	['monochrome'] = {},
}

ORDER_RADIAL = function(a, b) return getdistancebetween(a, {$posx, $posy, $posz}) < getdistancebetween(b, {$posx, $posy, $posz}) end
ORDER_RADIAL_REVERSE = function(a, b) return ORDER_RADIAL(b, a) end
ORDER_EUCLIDEAN = function(a, b) return math.sqrt(math.abs(a[1] - $posx)^2 + math.abs(a[2] - $posy)^2) > math.sqrt(math.abs(b[1] - $posx)^2 + math.abs(b[2] - $posy)^2) end
ORDER_EUCLIDEAN_REVERSE = function(a, b) return ORDER_EUCLIDEAN(b, a) end
ORDER_REALDIST = function(a, b) return math.abs((a[1] - $posx) + (a[2] - $posy)) > math.abs((b[1] - $posx) + (b[2] - $posy)) end
ORDER_REALDIST_REVERSE = function(a, b) return ORDER_REALDIST(b, a) end
ORDER_RANDOM = function(a, b) return (a[1] * a[2] * a[3]) % LIB_CACHE.screentiles < (b[1] * b[2] * b[3]) % LIB_CACHE.screentiles end

-- LOCAL FUNCTIONS

LIB_CACHE = LIB_CACHE or {
	antifurniture = {},
	specialarea = {},
	cancast = {},
	isontemple = false,
	screentiles = math.random(10^2, 10^4)
}

local __FUNCTIONS = __FUNCTIONS or {
	CAST = cast,
}

local function __crearoundf__callback(range, floor, list, cretype, ignore, f)
	local Creatures = {}

	foreach creature cre cretype do
		if f(cre) and cre.dist <= range and (cre.posz == $posz or floor) and ((not ignore and (#list == 0 or table.find(list, cre.name:lower()))) or (ignore and not table.find(list, cre.name:lower()))) then
			table.insert(Creatures, cre)
		end
	end

	return #Creatures
end

local function getareasetting(name, setting)
	name = name:lower()
	if LIB_CACHE.specialarea[name] then
		return getsetting(LIB_CACHE.specialarea[name].path, setting)
	else
		foreach settingsentry e 'Cavebot/SpecialAreas' do
			local n = getsetting(e, 'Name')
			LIB_CACHE.specialarea[n:lower()] = {path = e, name = n}

			if n:lower() == name then
				return getsetting(e, setting)
			end
		end
	end
	return nil
end

local function setareasetting(name, setting, v)
	name = name:lower()
	if LIB_CACHE.specialarea[name] then
		return setsetting(LIB_CACHE.specialarea[name].path, setting, v)
	else
		foreach settingsentry e 'Cavebot/SpecialAreas' do
			local n = getsetting(e, 'Name')
			LIB_CACHE.specialarea[n:lower()] = {path = e, name = n}

			if n:lower() == name then
				return setsetting(e, setting, v)
			end
		end
	end
end

-- EXTENSION CLASS

function botversion(n)
	n = n or $botversion

	return (tonumber(n:sub(1,1)) * 100) + (tonumber(n:sub(3,3)) * 10) + tonumber(n:sub(5,5))
end
BOT_VERSION = botversion()

function printf(str, ...)
	return print(sprintf(str, ...))
end

function sprintf(str, ...)
	return #{...} > 0 and tostring(str):format(...) or tostring(str)
end

function loadstringf(str, ...)
	return loadstring(sprintf(str, ...))
end

function printerrorf(str, ...)
	return printerror(sprintf(str, ...))
end

function table.search(self, value, argument, ...)
	local typeVal = type(value)
	local typeArg = type(argument)
	local val1, val2
	local args = {...}

	if typeVal == 'string' then
		if typeArg == 'boolean' then
			table.insert(args, 1, argument)
			argument = nil
		end

		-- string options
		-- disconsider case, partial match
		val1, val2 = unpack(args)
	elseif typeVal == 'number' then
		if typeArg == 'number' and #args == 1 then
			table.insert(args, 1, argument)
			argument = nil
		end

		-- number options
		-- between min, between max
		val1, val2 = unpack(args)
	elseif typeVal == 'boolean' then
		if typeArg == 'boolean' then
			table.insert(args, 1, argument)
			argument = nil
		end

		-- bool options
		-- convert values to bool
		val1 = args[1]
	end

	for k, v in pairs(self) do
		if typeVal == 'string' and type(k[argument] or v) == 'string' then
			local str1, str2, str3 = v:lower(), value:lower(), (argument ~= nil and k[argument] or ''):lower()

			if v == value or argument and k[argument] == value or (val1 and (str1 == str2 or (argument and str1 == str3))) or (val2 and (str1:find(str2) or str2:find(str1) or (argument and (str1:find(str3) or str3:find(str1))))) then
				return k
			end
		elseif typeVal == 'number' and type(k[argument] or v) == 'number' then
			if v == value or argument and k[argument] == value or (val1 and val2 and (v < val2 and v > val1 or argument and k[argument] < val2 and k[argument] > val1)) then
				return k
			end
		elseif typeVal == 'boolean' and type(k[argument] or v) == 'boolean' then
			if v == value or argument and k[argument] == value or (val1 and tobool(argument and k[argument] or v)) then
				return k
			end
		end
	end

	return nil
end

function table.tostring(self, name, sep)
	if name and not sep then
		sep = name
		name = nil
	elseif not (name or sep) then
		sep = ' '
	end

	local str = ''

	for k, v in pairs(self) do
		local t, n = type(v), type(k)

		k = ((n ~= 'number' and tonumber(k) ~= nil) or tostring(k):match("[%s\'+]") ~= nil) and sprintf('[%q]', k) or k

		if t == 'string' then
			str = str .. sprintf("%s,%s", (n == 'number' and sprintf('%q', v)) or sprintf('%s = %q', k, v), sep)
		elseif t == 'number' or t == 'boolean' then
			str = str .. sprintf("%s,%s", (n == 'number' and tostring(v)) or sprintf('%s = %s', k, tostring(v)), sep)
		elseif t == 'table' then
			str = str .. sprintf("%s,%s", (n == 'number' and table.tostring(v)) or sprintf('%s = %s', k, table.tostring(v)), sep)
		elseif t == 'userdata' and userdatastringformat then
			str = str .. sprintf("%s, %s", (n == 'number' and userdatastringformat(v)) or sprintf('%s = %s', k, userdatastringformat(v)), sep)
		end
	end

	return sprintf("%s{%s}", name and sprintf('%s = ', name) or '', str:sub(1, -(2 + #sep)))
end

function tosec(str)
	local sum, time, units, index = 0, str:token(nil, ":"), {86400, 3600, 60, 1}, 1

	for i = #units - #time + 1, #units do
		sum, index = sum + ((tonumber(time[index]) or 0) * units[i]), index + 1
	end

	return math.max(sum, 0)
end

function formatnumber(n, s)
	local result, sign, before, after, s = '', string.match(tostring(n), '^([%+%-]?)(%d*)(%.?.*)$'), s or ','

	while #before > 3 do
		result = s .. string.sub(before, -3, -1) .. result
		before = string.sub(before, 1, -4)
	end

	return sign .. before .. result .. after
end

function formattime(n, pattern)
	local units = {DD = math.floor(n / 86400 % 7), HH = math.floor(n / 3600 % 24), MM = math.floor(n / 60 % 60), SS = math.floor(n % 60)}

	if not pattern then
		if units.DD > 0 then
			pattern = "DD:HH:MM:SS"
		elseif units.HH > 0 then
			pattern = "HH:MM:SS"
		else
			pattern = "MM:SS"
		end
	else
		pattern = pattern:upper()
	end

	return pattern:gsub("%u%u", function(str) return string.format("%02d", units[str]) end)
end

function getareaposition(name)
	local setting = getareasetting(name, 'Coordinates')

	if setting then
		local x, y, z = setting:match(".-(%d+).-(%d+).-(%d+)")

		return {x = tonumber(x) or 0, y = tonumber(y) or 0, z = tonumber(z) or 0}
	end

	return {x = 0, y = 0, z = 0}
end

function setareaposition(name, x, y, z)
	x, y, z = tonumber(x) or $posx, tonumber(y) or $posy, tonumber(z) or $posz

	return setareasetting(name, 'Coordinates', sprintf("x:%s, y:%s, z:%s", x, y, z))
end

function getareasize(name)
	local setting = getareasetting(name, 'Size')

	if setting then
		local w, h = setting:match('(%d+) to (%d+)')

		return {w = tonumber(w) or 0, h = tonumber(h) or 0}
	end

	return {w = 0, h = o}
end

function setareasize(name, w, h)
	h, w = tonumber(h) or 1, tonumber(w) or 1

	return setareasetting(name, 'Size', sprintf('%d to %d', w, h))
end

function getareapolicy(name)
	local setting = getareasetting(name, 'Policy')

	return setting or POLICY_NONE
end

function setareapolicy(name, policy)
	local polType = type(policy)

	if polType == 'string' and not table.find({"cavebot", "cavebot & targeting", "targeting", "none"}, policy:lower()) then
		policy = "None"
	elseif polType == 'number' and policy > 0 and policy <= 3 then
		policy = SA_POLICY[policy]
	else
		policy = "None"
	end

	return setareasetting(name, 'Policy', policy)
end

function getareaavoidance(name)
	local setting = getareasetting(name, 'Avoidance')

	return tonumber(setting) or 0
end

function setareaavoidance(name, avoid)
	avoid = tonumber(avoid) or 0

	return setareasetting(name, 'Avoidance', avoid)
end

function getareaextrapolicy(name, poltype)
	local t = type(poltype)
	poltype = t == 'string' and poltype:lower() or false

	if poltype then
		if poltype:match('loot') then
			poltype = 'IgnoreWhenLooting'
		elseif poltype:match('luring') or poltype:match('lure') then
			poltype = 'IgnoreWhenLuring'
		else
			return printerrorf("bad argument #2 to 'getareaextrapolicy', ('Lure', 'Loot', 'Luring' or 'Looting' expected, got '%s')", poltype)
		end
	else
		return printerrorf("bad argument #2 to 'getareaextrapolicy', (string expected, got '%s')", t)
	end

	local setting = getareasetting(name, poltype)

	return setting ~= nil and setting == 'yes'
end

function setareaextrapolicy(name, poltype, t)
	local typ = type(poltype)
	poltype = typ == 'string' and poltype:lower() or false

	if poltype then
		if poltype:match('loot') then
			poltype = 'IgnoreWhenLooting'
		elseif poltype:match('luring') or poltype:match('lure') then
			poltype = 'IgnoreWhenLuring'
		else
			return printerrorf("bad argument #2 to 'getareaextrapolicy', ('Lure', 'Loot', 'Luring' or 'Looting' expected, got '%s')", poltype)
		end
	else
		return printerrorf("bad argument #2 to 'getareaextrapolicy', (string expected, got '%s')", typ)
	end

	return setareasetting(name, poltype, t)
end

function getareatype(name)
	return getareasetting(name, 'Type') or 'None'
end

function setareatype(name, areatype)
	local t = type(areatype)

	if t == 'string' then
		areatype = areatype:lower()

		if areatype:match('filled') then
			areatype = AREA_SQUARE_FILLED
		elseif areatype:match('border') then
			areatype = AREA_SQUARE_BORDER
		elseif areatype:match('double') then
			areatype = AREA_SQUARE_DOUBLE_BORDER
		else
			return printerrorf("bad argument #2 to 'setareatype' ('Filled', 'Border', 'Double', 'Square (Filled)', 'Square (Border Only)' or 'Square (Double Border)' expected, got %s)", areatype)
		end
	elseif t == 'number' and areatype >= 1 or areatype <= 3 then
		areatype = SA_TYPE[areatype]
	else
		return printerrorf("bad argument #2 to 'setareatype' (string or number (1-3) expected, got %s%s)", t, not table.find({1,2,3}, areatype) and " different than the value expected" or '')
	end

	return setareasetting(name, 'Type', areatype)
end

function getareacomment(name)
	return getareasetting(name, 'Comment') or ''
end

function setareacomment(name, comment)
	return setareasetting(name, 'Comment', comment or '')
end

function isbinded(...)
	if not $fasthotkeys then
		local temp, i, arg, info = {}, 1, {...}

		while arg[i] do
			if type(arg[i]) == 'table' then
				info = spellinfo(arg[i][1])
				temp[i] = {key = arg[i][1], type = #info.words > 0 and info.itemid == 0, force = arg[i][2]}
			else
				info = spellinfo(arg[i])
				temp[i] = {key = arg[i], type = #info.words > 0 and info.itemid == 0, force = "all"}
			end

			i = i + 1
		end

		for _, entry in ipairs(temp) do
			local func, params = clientitemhotkey, {"self", "target", "crosshair"}

			if entry.type then
				func, params = clienttexthotkey, {"automatic", "manual"}
			end

			if entry.force and not table.find(params, entry.force:lower()) then
				entry.force = 'all'
			end

			if func(entry.key, entry.force) == 'not found' then
				return false
			end
		end
	end

	return true
end

function maroundfilter(range, floor, ...)
	local Creatures, Callback = {...}, function(c) return true end

	if type(floor) == 'string' then
		table.insert(Creatures, floor)
		floor = false
	end

	if type(range) == 'boolean' then
		floor = range
		range = 7
	elseif type(range) == 'string' then
		table.insert(Creatures, range)
		range = 7
	end

	if type(Creatures[#Creatures]) == 'function' then
		Callback = table.remove(Creatures)
	end

	table.lower(Creatures)

	return __crearoundf__callback(range, floor, Creatures, 'mx', false, Callback)
end

function maroundfilterignore(range, floor, ...)
	local Creatures, Callback = {...}, function(c) return true end

	if type(floor) == 'string' then
		table.insert(Creatures, floor)
		floor = false
	end

	if type(range) == 'boolean' then
		floor = range
		range = 7
	elseif type(range) == 'string' then
		table.insert(Creatures, range)
		range = 7
	end

	if type(Creatures[#Creatures]) == 'function' then
		Callback = table.remove(Creatures)
	end

	table.lower(Creatures)

	return __crearoundf__callback(range, floor, Creatures, 'mx', true, Callback)
end

function paroundfilter(range, floor, ...)
	local Creatures, Callback = {...}, function(c) return true end

	if type(floor) == 'string' then
		table.insert(Creatures, floor)
		floor = false
	end

	if type(range) == 'boolean' then
		floor = range
		range = 7
	elseif type(range) == 'string' then
		table.insert(Creatures, range)
		range = 7
	end

	if type(Creatures[#Creatures]) == 'function' then
		Callback = table.remove(Creatures)
	end

	table.lower(Creatures)

	return __crearoundf__callback(range, floor, Creatures, 'px', false, Callback)
end

function paroundfilterignore(range, floor, ...)
	local Creatures, Callback = {...}, function(c) return true end

	if type(floor) == 'string' then
		table.insert(Creatures, floor)
		floor = false
	end

	if type(range) == 'boolean' then
		floor = range
		range = 7
	elseif type(range) == 'string' then
		table.insert(Creatures, range)
		range = 7
	end

	if type(Creatures[#Creatures]) == 'function' then
		Callback = table.remove(Creatures)
	end

	table.lower(Creatures)

	return __crearoundf__callback(range, floor, Creatures, 'px', true, Callback)
end

function unrust(ignore, drop, value)
	local IgnoreCommon = ignore or true
	local DropTrash = drop or true
	local MinValue = math.max(value or 0, 0)

	if itemcount(9016) == 0 and clientitemhotkey(9016, "crosshair") == 'not found' then
		return nil
	end

	local Amount, Trash = {}, {}

	for _, Item in ipairs({3357, 3358, 3359, 3360, 3362, 3364, 3370, 3371, 3372, 3377, 3381, 3382, 3557, 3558, 8063}) do
		if itemvalue(Item) >= MinValue then
			Amount[Item] = itemcount(Item)
		else
			table.insert(Trash, Item)
		end
	end

	local RustyItems = IgnoreCommon and {8895, 8896, 8898, 8899} or {8895, 8896, 8897, 8898, 8899}

	for _, Item in ipairs(RustyItems) do
		if itemcount(Item) > 0 then
			pausewalking(itemcount(Item) * 2000)
			useitemon(9016, Item, '0-15') waitping(1, 1.5)
			increaseamountused(9016, 1)
			pausewalking(0)
		end
	end

	if DropTrash then
		for _, Item in ipairs(Trash) do
			if itemcount(Item) > 0 then
				pausewalking(2000)
				moveitems(Item, "ground") waitping(1, 1.5)
				pausewalking(0)
			end
		end
	end

	for Item, Count in pairs(Amount) do
		local Current = itemcount(Item)

		if Current > Count then
			Amount[Item] = Current

			increaseamountlooted(Item, Current - Count)
		end
	end
end

function antifurnituretrap(weapon, stand)
	weapon = weapon or 'Machete'
	stand = (stand or 0) * 1000

	if clientitemhotkey(weapon, 'crosshair') == 'not found' and itemcount(weapon) == 0 then
		return "AntiFurniture[Issue1]: 'Weapon' given not found on hotkeys and not visible."
	end

	if $standtime > stand then
		local Furniture = {}

		for x, y, z in screentiles(ORDER_RADIAL, 7) do
			if tilereachable(x, y, z, false) and not LIB_CACHE.antifurniture[ground(x, y, z)] then
				local tile = gettile(x, y, z)

				for k = tile.itemcount, 1, -1 do
					local info = iteminfo(tile.item[k].id)

					if info.isunpass and not info.isunmove then
						table.insert(Furniture, {x = x, y = y, z = z, id = info.id, top = k == tile.itemcount})
						break
					end
				end
			end
		end

		if #Furniture > 0 then
			for _, item in ipairs(Furniture) do
				local x, y, z, id, top = item.x, item.y, item.z, item.id, item.top

				pausewalking(10000) reachlocation(x, y, z)

				foreach newmessage m do
					if m.content:match("You are not invited") then
						LIB_CACHE.antifurniture[ground(x, y, z)] = true
						return "AntiFurniture[Issue4]: Cancelling routine due to an item inside a house. (top item)"
					end
				end

				if top then
					while id == topitem(x, y, z).id and tilereachable(x, y, z, false) do
						useitemon(weapon, id, ground(x, y, z)) waitping()

						foreach newmessage m do
							if m.content:match("You are not invited") then
								LIB_CACHE.antifurniture[ground(x, y, z)] = true
								return "AntiFurniture[Issue4]: Cancelling routine due to an item inside a house. (top item)"
							end
						end
					end
				else
					browsefield(x, y, z) waitcontainer("browse field", true)
					local cont = getcontainer('Browse Field')

					for j = 1, cont.lastpage do
						for i = 1, cont.itemcount do
							local info = iteminfo(cont.item[i].id)

							if info.isunpass and not info.isunmove then
								while itemcount(cont.item[i].id, 'Browse Field') > 0 and tilereachable(x, y, z, false) do
									useitemon(weapon, info.id, "Browse Field") waitping()

									foreach newmessage m do
										if m.content:match("You are not invited") then
											LIB_CACHE.antifurniture[ground(x, y, z)] = true
											return "AntiFurniture[Issue3]: Cancelling routine due to an item inside a house. (browsing field)"
										end
									end
								end
							end
						end

						changepage('browse field', math.min(j + 1, cont.lastpage))
					end
				end

				pausewalking(0)
			end
		else
			return "AntiFurniture[Issue5]: Character is standing still without furnitures to break."
		end
	else
		return "AntiFurniture[Issue2]: Current standtime less than the required time."
	end

	return "AntiFurniture[No Issue]"
end

function getdistancebetween(x, y, z, a, b, c)
	if type(x) == 'table' and type(y) == 'table' and not (z and a and b and c) then
		if x.x and y.x then
			x, y, z, a, b, c = x.x, x.y, x.z, y.x, y.y, y.z
		elseif #x == 3 and #y == 3 then
			x, y, z, a, b, c = x[1], x[2], x[3], y[1], y[2], y[3]
		else
			return -1
		end
	end

	return z == c and math.max(math.abs(x - a), math.abs(y - b)) or -1
end

function isabletocast(spell)
	spell = ("userdata|table"):find(type(spell)) ~= nil and spell or spellinfo(spell)

	return spell.cancast
end

function cancast(spell, cre)
	spell = ("userdata|table"):find(type(spell)) ~= nil and spell or spellinfo(spell)

	local cool, strike = LIB_CACHE.cancast[spell.name:lower()] or 0, false

	if cre then
		cre = type(cre) == 'userdata' and cre or findcreature(cre)

		if spell.castarea ~= 'None' and spell.castarea ~= '' then
			strike = spell.words
		end
	end

	return (not strike or isonspellarea(cre, strike, $self.dir)) and $timems >= cool and $level >= spell.level and $mp >= spell.mp and $soul >= spell.soul and cooldown(spell.words) == 0
end

function unequipitem(slot, bp, amount)
	slot = slotNames[slot:lower()]

	if slot then
		item = slot()

		if item.obj.id > 0 then
			if type(bp) == 'number' then
				amount = bp
				bp = '0-15'
			elseif not amount then
				amount = item.obj.count
			end

			return moveitems(item.obj.id, bp, item.name, amount or item.obj.count)
		end
	end
end

function isinsidearea(...)
	local SpecialAreas = {...}

	if #SpecialAreas == 1 and type(SpecialAreas[1][1]) == 'table' then
		SpecialAreas = SpecialAreas[1]
	end

	for i, area in ipairs(SpecialAreas) do
		if #area == 5 then
			local a,b,c,d,e = unpack(area)

			if $posz == e and $posx <= b and $posx >= a and $posy <= d and $posy >= c then
				return true
			end
		end
	end

	return false
end

function pvpworld()
	return table.find({"Astera", "Calmera", "Candia", "Celesta", "Fidera", "Guardia", "Harmonia", "Honera", "Luminera", "Magera", "Menera", "Nerana", "Olympa", "Pacera", "Refugia", "Secura", "Unitera"}, $worldname) == nil
end

function checklocation(dist, label, section)
	local t = type(dist)
	dist = (t == 'number' and dist > 0) and dist or false

	if t == 'number' and not ($posx <= $wptx + dist and $posx >= $wptx-dist and $posy <= $wpty + dist and $posy >= $wpty - dist and $posz == $wptz) then
		if not (label and section) then
			return false
		else
			return gotolabel(label, section)
		end
	elseif t == 'boolean' and not dist then
		if not (label and section) then
			return false
		else
			return gotolabel(label, section)
		end
	end

	return true
end

function isontemple()
	local temp = isinsidearea(cityTemples)

	if $connected then
		LIB_CACHE.isontemple = temp
		return $pzone and temp
	else
		return LIB_CACHE.isontemple
	end
end

function withdrawitems(where, to, ...)
	local items = {...}
	local tempType = type(where)
	local waitFunc = function()
		return waitping(1.5, 2)
	end

	if tempType == 'string' then
		where = where:lower()

		if where:find('depot') or where:find('chest') then
			-- user input depot, but the correct name is 'Depot Chest'
			where = 'Depot Chest'
		elseif where:find('inbox') then
			-- used input inbox, but the correct name is 'Your Inbox'
			where = 'Your Inbox'
		else
			-- used input any container name
			where = getlootingdestination(where) or itemname(where)
		end
	elseif tempType == 'userdata' and where.objtype == 'container' then
		-- user input any container object, we only want the name
		where = where.name
	else
		return false
	end

	tempType = type(to)

	if tempType == 'table' then
		-- user input a table of items
		table.insert(items, 1, to)
		to = '0-15'
	elseif tempType == 'string' then
		if getcontainer(to).name == '' and tonumber(to:sub(1,1)) == nil then
			-- used input a invalid container and invalid index
			return false
		end

		to = getlootingdestination(to) or itemname(to)
	elseif tempType == 'userdata' and to.objtype == 'container' then
		-- used input a container object, we only want the name
		to = to.name
	end

	if type(items[#items]) == 'function' then
		waitFunc = table.remove(items)
	end

	for _, item in ipairs(items) do
		tempType = type(item)

		if tempType == 'table' then
			local bp, id, amount = itemname(item.backpack or item.bp or item[1]), item.name or item[2], item.amount or item.count or item[3] or 100

			if id and bp and amount then
				moveitemsupto(id, amount + itemcount(id, bp), bp, from) waitFunc()
			end
		elseif tempType == 'number' or tempType == 'string' then
			moveitems(item, to, where) waitFunc()
		end
	end

	return true
end

function screentiles(sortf, area, func)
	local tempType, xs, ys, xe, ye, Positions, i = type(sortf), -7, -5, 7, 5, {}, 0

	if tempType == 'table' and #sortf == 4 then
		xs, xe, ys, ye = sortf[1], sortf[2], sortf[3], sortf[4]
		sortf = false
	elseif tempType ~= 'function' then
		sortf = false
	end

	tempType = type(area)

	if tempType == 'function' then
		func = area
	elseif tempType == 'table' and #area == 4 then
		xs, xe, ys, ye = area[1], area[2], area[3], area[4]
	elseif tempType == 'number' then
		xs, xe, ys, ye = -area, area, -area, area
	end

	for x = xs, xe, xs < xe and 1 or -1 do
		for y = ys, ye, ys < ye and 1 or -1 do
			local _x, _y = $posx + x, $posy + y

			if tilehasinfo(_x, _y, $posz) then
				table.insert(Positions, {_x, _y, $posz})
			end
		end
	end

	if sortf then
		table.sort(Positions, sortf)
		
		if sortf == ORDER_RANDOM then
			-- little trick to get random values for ORDER_RANDOM every time it is used
			LIB_CACHE.screentiles = math.random(10^2, 10^4)
		end
	end

	return function()
		i = i + 1

		if Positions[i] then
			return func and func(Positions[i][1], Positions[i][2], Positions[i][3]) or Positions[i][1], Positions[i][2], Positions[i][3]
		end

		return
	end
end

function drawvector(x1, y1, x2, y2) -- By Lucas Terra
	drawline(x1, y1, x2-x1, y2-y1)
end

function randomcolor(options)
	local h, s, l = math.random(0, 360), math.random(0, 100) / 100, math.random(0, 100) / 100
	local monochrome = false
	
	if options.hue then
		local hueType = type(options.hue)
		
		if hueType == 'string' then
			options.hue = options.hue:lower()
			
			if defaultColors[options.hue] then
				if options.hue == 'monochrome' then
					h, s, monochrome = 0, 0, true
				else
					h = math.random(defaultColors[options.hue][1], defaultColors[options.hue][2])
				end
			end
		elseif hueType == 'number' and options.hue <= 360 and options.hue >= 0 then
			h = options.hue
		end
	end
	
	if (not monochrome) and options.saturation and options.saturation <= 100 and options.saturation >= 0 then
		s = options.saturation / 100
	end
	
	if options.brightness then
		local brightnessType = type(options.brightness)
		
		if brightnessType == 'string' then
			options.brightness = options.brightness:lower()
			
			if options.brightness == 'dark' then
				l = math.random(0, 33) / 100
			elseif options.brightness == 'light' then
				l = math.random(67, 100) / 100
			elseif options.brightness == 'medium' then
				l = math.random(34, 66) / 100
			end
		elseif brightnessType == 'number' and options.brightness <= 100 and options.brightness >= 0 then
			l = options.brightness / 100
		end
	end

	if options.amount then
		local tbl, opt = {}, table.copy(options)
		
		opt.amount = nil
		
		for i = 0, options.amount-1 do
			if options.gradient then
				table.insert(tbl, (i * 100 / options.amount) / 100)
			end
			
			table.insert(tbl, math.randomomcolor(opt))
		end
	
		return unpack(tbl)
	end
	
	-- the code below was basically copied from here:
	-- http://stackoverflow.com/questions/10393134/converting-hsl-to-rgb
	
	h = h / 60
	local chroma = (1 - math.abs(2 * l - 1)) * s
	local x = (1 - math.abs(h % 2 - 1)) * chroma
	local r, g, b = 0, 0, 0
	
	if h < 1 then
		r, g, b = chroma, x, 0
	elseif h < 2 then
		r, b, g = x, chroma, 0
	elseif h < 3 then
		r, g, b = 0, chroma, x
	elseif h < 4 then
		r, g, b = 0, x, chroma
	elseif h < 5 then
		r, g, b = x, 0, chroma
	else
		r, g, b = chroma, 0, x
	end
	
	local m = l - chroma / 2
	
	return color((r + m) * 256, (g + m) * 256, (b + m) * 256, options.transparency)
end

-- FIXES AND GENERAL EXTENSIONS

-- extend aliases
unequip = unequip or unequipitem
antifurniture = antifurniture or antifurnituretrap

-- enables advanced cooldown control in cancast
function cast(...)
	local args = {...}
	local info = ("userdata|table"):find(type(args[1])) ~= nil and args[1] or spellinfo(args[1])
	LIB_CACHE.cancast[info.name:lower()] = $timems + info.duration

	return __FUNCTIONS.CAST(...)
end

printf("Leonardo\'s library loaded, version: %s", LIBS.LEONARDO)
