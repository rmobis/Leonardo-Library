--[[
    Leonardo's Library
    Created: 15/01/2014
    Updated: 29/01/2014
    Version: 1.3.0

    --> Summary:
        --> Globals and Local variables;
        --> Local functions;

        --> Extension Class;
            -- printf;
            -- sprintf;
			-- loadstringf;
			-- table.tostring;

        --> Main functions:
            --> formatnumber;
            --> formattime;
            --> getareaposition;
            --> setareaposition;
            --> getareasize;
            --> setareasize;
            --> getareapolicy;
            --> setareapolicy;
            --> getareaavoidance;
            --> setareaavoidance;
			--> getareaextrapolicy;
			--> setareaextrapolicy;
			--> getareatype;
			--> setareatype;
			--> getareacomment;
			--> setareacomment;
            --> isbinded;
            --> maroundfilter;
            --> maroundfilterignore;
            --> paroundfilter;
            --> paroundfilterignore;
            --> unrust;
            --> antifurnituretrap;
            --> isabletocast;
            --> cancast;
            --> unequipitem;

        --> Fixes and Function Extensions
            -- unequip;
            -- cast;
        <--
    <--
]]--

-- GLOBALS AND LOCAL VARIABLES

LIBS = LIBS or {}
LIBS.LEONARDO = "1.3.0"

POLICY_NONE = 'None'
POLICY_CAVEBOT = 'Cavebot'
POLICY_TARGETING = 'Targeting'
POLICY_ALL = 'Cavebot & Targeting'

AREA_SQUARE_FILLED = 'Square (Filled)'
AREA_SQUARE_BORDER = 'Square (Border Only)'
AREA_SQUARE_DOUBLE_BORDER = 'Square (Double Border)'

local SA_POLICY = {POLICY_CAVEBOT, POLICY_TARGETING, POLICY_ALL}
local SA_TYPE = {AREA_SQUARE_FILLED, AREA_SQUARE_BORDER, AREA_SQUARE_DOUBLE_BORDER}

local EQUIPMENT_SLOTS = {["amulet"] = "neck", ["weapon"] = "rhand", ["shield"] = "lhand", ["ring"] = "finger", ["armor"] = "chest", ["boots"] = "feet", ["ammo"] = "belt", ["helmet"] = "head"}

-- LOCAL FUNCTIONS

LIB_CACHE = LIB_CACHE or {
	antifurniture = {},
	specialarea = {},
	cancast = {},
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

function printf(str, ...)
    return print(sprintf(str, ...))
end

function sprintf(str, ...)
    return #{...} > 0 and tostring(str):format(...) or tostring(str)
end

function loadstringf(str, ...)
	return loadstring(sprintf(str, ...))
end

function table.tostring(self, sep, name)
	sep = sep or ''

	local str = ''

	for k, v in pairs(self) do
		local t, n = type(v), type(k)

		k = ((n ~= 'number' and tonumber(k) ~= nil) or tostring(k):match("[%s\'+]") ~= nil) and sprintf('[%q]', k) or k

		if t == 'string' then
			str = str .. sprintf("%s,%s", (n == 'number' and sprintf('%q', v)) or sprintf('%s = %q', k, v), sep)
		elseif t:match('number|boolean') then
			str = str .. sprintf("%s,%s", (n == 'number' and tostring(v)) or sprintf('%s = %s', k, tostring(v)), sep)
		elseif t == 'table' then
			str = str .. sprintf("%s,%s", (n == 'number' and table.tostring(v)) or sprintf('%s = %s', k, table.tostring(v)), sep)
		elseif t == 'userdata' and userdatastringformat then
			str = str .. sprintf("%s, %s", (n == 'number' and userdatastringformat(v)) or sprintf('%s = %s', k, userdatastringformat(v)), sep)
		end
	end

	return sprintf("%s{%s}", name and sprintf('%s = ', name) or '', str:sub(1, -(2 + #sep)))
end

-- MAIN FUNCTIONS

-- @name    tosec
-- @desc                Converts a time formatted string into seconds.
-- @param   {string}    str    The string to convert
-- @returns {number}

function tosec(str) -- Working, by sirmate
    local sum, time, units, index = 0, str:token(nil, ":"), {86400, 3600, 60, 1}, 1

    for i = #units - #time + 1, #units do
        sum, index = sum + ((tonumber(time[index]) or 0) * units[i]), index + 1
    end

    return math.max(sum, 0)
end

-- @name    formatnumber
-- @desc               Formats a number to show its units.
-- @param   {number}   num     The number to be formatted
-- @param   {string}   sep     The symbol to separate numbers, default is ",". (optional)
-- @param	{string}   pre     The preffix to append at the start of the number. (optional)
-- @param	{string}   suf     The suffix to append at the end of the number. (optional)
-- @returns {string}

function formatnumber(n, s, pre, suf)
	local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')

	return string.format("%s%s%s", pre or '', left .. (num:reverse():gsub('(%d%d%d)','%1' .. (s or ',')):reverse()) .. right, suf or '')
end

-- @name    formattime
-- @desc               Converts a number to a date format string.
-- @param   {number}   num     The number to be converted
-- @param   {string}   pattern The pattern to format number, default is "DD:HH:MM:SS". (optional)
-- @returns {string}

function formattime(n, pattern) -- Working, by sirmate
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

-- @name    getareaposition
-- @desc                Returns the coordinates of the given special area.
-- @param   {string}    name    The special area name to check.
-- @returns {table}

function getareaposition(name) -- working
    local setting = getareasetting(name, 'Coordinates')

	if setting then
		local x, y, z = setting:match(".-(%d+).-(%d+).-(%d+)")

		return {x = tonumber(x) or 0, y = tonumber(y) or 0, z = tonumber(z) or 0}
	end

	return {x = 0, y = 0, z = 0}
end

-- @name    setareaposition
-- @desc               Sets the special area initial position.
-- @param   {string}   name    The special area name.
-- @param   {number}   x       The special area x coordinate. (optional)
-- @param   {number}   y       The special area y coordinate. (optional)
-- @param   {number}   z       The special area z coordinate. (optional)
-- @returns {null}

function setareaposition(name, x, y, z) -- Working
    x, y, z = tonumber(x) or $posx, tonumber(y) or $posy, tonumber(z) or $posz

	return setareasetting(name, 'Coordinates', sprintf("x:%s, y:%s, z:%s", x, y, z))
end

-- @name    getareasize
-- @desc                Returns the special area width and height.
-- @param   {string}    name    The special area name.
-- @returns {table}

function getareasize(name) -- working
    local setting = getareasetting(name, 'Size')

	if setting then
		local w, h = setting:match('(%d+) to (%d+)')

		return {w = tonumber(w) or 0, h = tonumber(h) or 0}
	end

	return {w = 0, h = o}
end

-- @name    setareasize
-- @desc                Sets the width and height for a special area.
-- @param   {string}    name    The special area name.
-- @param   {number}    width   The width lenght. (optional)
-- @param   {number}    height  The height lenght. (optional)
-- @returns {null}

function setareasize(name, w, h) -- working
    h, w = tonumber(h) or 1, tonumber(w) or 1

	return setareasetting(name, 'Size', sprintf('%d to %d', w, h))
end

-- @name    getareapolicy
-- @desc                Returns the policy of a special area.
-- @param   {string}    name    The special area name.
-- @returns {string}

function getareapolicy(name) -- working
    local setting = getareasetting(name, 'Policy')

	return setting or POLICY_NONE
end

-- @name    setareapolicy
-- @desc                Sets the policy of a special area.
-- @param   {string}    name    The special area name.
-- @param   {string}    policy  The policy to setsetting. 'Cavebot', 'Targeting', 'Cavebot & Targeting' or 'None'. (optional)
-- @returns {null}

function setareapolicy(name, policy) -- working
    if type(policy) == 'string' and not table.find({"cavebot", "cavebot & targeting", "targeting", "none"}, policy:lower()) then
        policy = "None"
    elseif type(policy) == 'number' and policy > 0 and policy <= 3 then
        policy = SA_POLICY[policy]
    else
        policy = "None"
    end

    return setareasetting(name, 'Policy', policy)
end

-- @name    getareaavoidance
-- @desc                Returns the avoidance of a special area.
-- @param   {string}    name    The special area name.
-- @returns {number}

function getareaavoidance(name) -- working
    local setting = getareasetting(name, 'Avoidance')

    return tonumber(setting) or 0
end

-- @name    setareaavoidance
-- @desc                Sets the avoidance for a special area.
-- @param   {string}    name        The special area name.
-- @param   {number}    avoidance   The avoidance level. Minimum of 0 and maximum of 250. (optional)
-- @returns {number}

function setareaavoidance(name, avoid) -- working
    avoid = tonumber(avoid) or 0

    return setareasetting(name, 'Avoidance', avoid)
end

-- @name    getareaextrapolicy
-- @desc                Returns true if the extra policy given is enabled, false otherwise.
-- @param   {string}    name    The special area name.
-- @param	{string}	type    The extra policy type as 'loot', 'lure', 'looting' or 'luring'.
-- @returns {boolean}

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

-- @name    setareaextrapolicy
-- @desc                Sets the extra policy for a special area.
-- @param   {string}    name        The special area name.
-- @param   {various}   poltype     The policy type as 'loot', 'lure', 'looting' or 'luring'.
-- @param	{various}   toggle      The value to turn option on or off as any true value or false value.
-- @returns {null}

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

-- @name    getareatype
-- @desc                Returns the type name of a special area.
-- @param   {string}    name     The special area name.
-- @returns {string}

function getareatype(name)
	return getareasetting(name, 'Type') or 'None'
end

-- @name    setareatype
-- @desc                Sets the type of a special area.
-- @param   {string}    name     The special area name.
-- @param   {various}   type     The area type as 'filled', 'border', 'double', 1 for filled, 2 for border or 3 for double border.
-- @returns {null}

function setareatype(name, areatype)
	local t = type(areatype)

	if t == 'string' then
		areatype = areatype:lower()

		if areatype:match('filled') then
			areatype = AREA_SQUARE_FILLED
		elseif areatype:match('border') then
			areatype = AREA_SQUARE_BORDER
		elseif areatype:match('double') then
			areatype = AREA_SQUARE_DBORDER
		else
			return printerrorf("bad argument #2 to 'setareatype' ('Filled', 'Border', 'Double', 'Square (Filled)', 'Square (Border Only)' or 'Square (Double Border)' expected, got %s)", areatype)
		end
	elseif t == 'number' and areatype >= 1 or areatype <= 3 then
		areatype = SA_TYPE[areatype]
	else
		return printerrorf("bad argument #2 to 'setareatype' (string or number (1-3) expected, got %s%s)", t, t == 'number' and not table.find({1,2,3}, areatype) and " different than the value expected" or '')
	end

	return setareasetting(name, 'Type', areatype)
end

-- @name    getareacomment
-- @desc                Returns the comment of the special area given.
-- @param   {string}    name     The special area name.
-- @returns {string}

function getareacomment(name)
	return getareasetting(name, 'Comment') or ''
end

-- @name    getareacomment
-- @desc                Sets the comment of the special area given.
-- @param   {string}    name     The special area name.
-- @param   {string}    comment  The special area comment.
-- @returns {null}

function setareacomment(name, comment)
	return setareasetting(name, 'Comment', comment or '')
end

-- @name    isbinded
-- @desc                Check if you have the current hotkeys binded on functions keyboard.
-- @param   {array}     list    The list of the hotkeys to check.
-- @returns {boolean}

function isbinded(...) -- working
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

    return true
end

-- @name    maroundfilter
-- @desc                Returns the amount of monsters found in the range distance. Optionally you can add a function to filter those creatures.
-- @param   {number}    range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     list    The creature names list to consider. (optional)
-- @param   {function}  func    The filter function. (optional)
-- @returns {number}

function maroundfilter(range, floor, ...) -- Working
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

-- @name    maroundfilterignore
-- @desc                Returns the amount of monsters found in the range distance, excluding the creatures names found in the list. Optionally you can add a function to filter those creatures.
-- @param   {number}    range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     list    The creature names list to disconsider. (optional)
-- @param   {function}  func    The filter function. (optional)
-- @returns {number}

function maroundfilterignore(range, floor, ...) -- Working
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

-- @name    paroundfilter
-- @desc                Returns the amount of players found in the range distance, excluding the creatures names found in the list. Optionally you can add a function to filter those creatures.
-- @param   {number}    range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     list    The creature names list to consider. (optional)
-- @param   {function}  func    The filter function. (optional)
-- @returns {number}

function paroundfilter(range, floor, ...) -- Working
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

-- @name    paroundfilterignore
-- @desc                Returns the amount of players found in the range distance, excluding the creature names found in the list. Optionally you can add a function to filter those creatures.
-- @param   {number}    range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     list    The creature names list to disconsider. (optional)
-- @param   {function}  func    The filter function. (optional)
-- @returns {number}

function paroundfilterignore(range, floor, ...) -- Working
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

-- @name    unrust
-- @desc                Uses rust remover on all the valid rust items found.
-- @param   {boolean}   ignore  Set true to ignore common rust items or false to consider this type.
-- @param   {boolean}   drop    Set true to drop trash items.
-- @param   {number}    value   Set the minimum value to consider items below this value as trash. (optional)
-- @returns {null}

function unrust(ignore, drop, value) -- Working
    ignore = ignore or true
    drop = drop or true
    value = math.max(value or 0, 0)

    if itemcount(9016) == 0 and clientitemhotkey(9016, "crosshair") == 'not found' then
        return
    end

    local Amount, Trash = {}, {}

    for _, Item in ipairs({3357, 3358, 3359, 3360, 3362, 3364, 3370, 3371, 3372, 3377, 3381, 3382, 3557, 3558, 8063}) do
        if itemvalue(Item) >= value then
            Amount[Item] = itemcount(Item)
        else
            table.insert(Trash, Item)
        end
    end

    local RustyItems = ignore and {8895, 8896, 8898, 8899} or {8895, 8896, 8897, 8898, 8899}

    for _, Item in ipairs(RustyItems) do
        if itemcount(Item) > 0 then
            useitemon(9016, Item, '0-15') waitping()
            increaseamountused(9016, 1)
        end
    end

    if drop then
        for _, Item in ipairs(Trash) do
            if itemcount(Item) > 0 then
                moveitems(Item, "ground") waitping()
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

-- @name    antifurnituretrap
-- @desc                Breaks all the destructible items that block the path of your character.
-- @param   {various}   weapon  The weapon name or ID to use.
-- @param   {number}    time    The maximum time to wait before start breaking items.
-- @returns {null}

function antifurnituretrap(weapon, t) -- Working
	weapon = weapon or 'Machete'
	t = t or -1

	if clientitemhotkey(weapon, 'crosshair') == 'not found' and itemcount(weapon) == 0 then
		printerrorf('weapon "%s" was not found on the binded hotkeys and is not visible on the opened backpacks, please change settings.', itemname(weapon))
		waitping(100000)
	end

	if $standtime < t * 60 then
		return
	end

	local Furniture = {}

	for a = 1, 7 do
		local j = -a

		while j <= a do
			local i = -a

			while i <= a do
				local x, y, z = $posx + i, $posy + j, $posz
				local tile = gettile(x, y, z)

				if tilereachable(x, y, z, false) then
					for k = tile.itemcount, 1, -1 do
						local info = iteminfo(tile.item[k].id)

						if info.isunpass and not info.isunmove and not LIB_CACHE.antifurniture[ground(x, y, z)] then
							table.insert(Furniture, {x = x, y = y, z = z, id = info.id, top = k == tile.itemcount})
							break
						end
					end
				end

				if math.abs(j) ~= a then
					i = i + a * 2
				else
					i = i + 1
				end
			end
			j = j + 1
		end
	end

	if #Furniture > 0 then
		for _, item in ipairs(Furniture) do
			local x, y, z, id, top = item.x, item.y, item.z, item.id, item.top

			pausewalking(10000) reachlocation(x, y, z)
			foreach newmessage m do
				if m.content:match("You are not invited") then
					LIB_CACHE.antifurniture[ground(x, y, z)] = true
					return
				end
			end
			if top then
				while id == topitem(x, y, z).id and tilereachable(x, y, z, false) do
					useitemon(weapon, id, ground(x, y, z)) waitping()

					foreach newmessage m do
						if m.content:match("You are not invited") then
							LIB_CACHE.antifurniture[ground(x, y, z)] = true
							return
						end
					end
				end
			else
				browsefield(x, y, z) waitping(1.5, 2)
				local cont = getcontainer('Browse Field')
				for i = 1, cont.itemcount do
					local info = iteminfo(cont.item[i].id)

					if info.isunpass and not info.isunmove then
						while itemcount(cont.item[i].id, 'Browse Field') > 0 and tilereachable(x, y, z, false) do
							useitemon(weapon, info.id, "Browse Field") waitping()

							foreach newmessage m do
								if m.content:match("You are not invited") then
									LIB_CACHE.antifurniture[ground(x, y, z)] = true
									return
								end
							end
						end
					end
				end
			end
			pausewalking(0)
		end
	end
end

-- @name    getdistancebetween
-- @desc                Returns the distance between positions given or -1 if it's not located on the same floor.
-- @param   {various}   x   The x-axis position or the table with starting coordinates.
-- @param   {various}   y   The y-axis position or the table with destiny coordinates.
-- @param   {number}    z   The z-axis position.
-- @param   {number}    a   The x-axis destiny position.
-- @param   {number}    b   The y-axis destiny position.
-- @param   {number}    c   The z-axis destiny position.
-- @returns {number}

function getdistancebetween(x, y, z, a, b, c) -- Working
    if type(x) == 'table' and type(y) == 'table' and not (z and a and b and c) then
        if x.x and y.x then
            x,y,z,a,b,c = x.x, x.y, x.z, y.x, y.y, y.z
        elseif #x == 3 and #y == 3 then
            x,y,z,a,b,c = x[1], x[2], x[3], y[1], y[2], y[3]
        else
            return -1
        end
    end

    return z == c and math.max(math.abs(x - a), math.abs(y - b)) or -1
end

-- @name    isabletocast
-- @desc                Returns true if you are able to cast spell given.
-- @param   {various}   spell   The spell object, name or words.
-- @returns {boolean}

function isabletocast(spell) -- Working
    spell = type(spell) == 'table' and spell or spellinfo(spell)
    return $level >= spell.level and $mp >= spell.mp and $soul >= spell.soul and cooldown(spell.words) == 0
end

-- @name    cancast
-- @desc                Returns true if you are able to cast spell given and if the duration period for that spell has been depleted, optionally you can check if it's able to cast on to a creature.
-- @param   {various}   spell       The spell object, name or words.
-- @param   {various}   creature    The creature object, name or ID. (optional)
-- @returns {boolean}

function cancast(spell, cre) -- Working
    spell = type(spell) == 'table' and spell or spellinfo(spell)
    local cool, strike = LIB_CACHE.cancast[info.name:lower()] or 0, false

    if cre then
        cre = type(cre) == 'userdata' and cre or findcreature(cre)

        if spell.castarea ~= 'None' and spell.castarea ~= '' then
            strike = spell.words
        end
    end

    return (not strike or isonspellarea(cre, strike, $self.dir)) and $timems >= cool and $level >= spell.level and $mp >= spell.mp and $soul >= spell.soul and cooldown(spell.words) == 0
end

-- @name    unequipitem
-- @desc                Unequip an item located at the equipment slot given.
-- @param   {string}    slot    The equipment slot name.
-- @param   {string}    bp      The backpack to move item on. (optional)
-- @param   {number}    amount  The amount of items to move on. (optional)
-- @returns {null}

function unequipitem(slot, bp, amount) -- Working
    slot = EQUIPMENT_SLOTS[slot:lower()] or tostring(slot):lower()
    local item = loadstringf("return $%s", slot)()

    if item and item.id > 0 then
        if type(bp) == 'number' then
            amount = bp
            bp = '0-15'
        elseif not amount then
            amount = item.count
        end

        return moveitems(item.id, bp, slot, amount)
    end
end

-- @name    isinsidearea
-- @desc                Returns true if you are located inside an area with the range coordinates given.
-- @param   {table}     list    The area(s) range(s) in the format: {minimum x, maximum x, minimum y, maximum y, z}.
-- @returns {boolean}

function isinsidearea(...) -- Working
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

-- @name    pvpworld
-- @desc                Returns true if you are in a player versus player world, false otherwise.
-- @returns {boolean}

function pvpworld() -- Working
    return table.find({"Astera", "Calmera", "Candia", "Celesta", "Fidera", "Guardia", "Harmonia", "Honera", "Luminera", "Magera", "Menera", "Nerana", "Olympa", "Pacera", "Refugia", "Secura", "Unitera"}, $worldname) == nil
end

-- @name    checklocation
-- @desc                Checks if you are inside the waypoint location within the range given, if not goes to the label of section given, if section and label are not given, returns false or true if you are inside the location.
-- @param   {various}   dist    The area range distance or the statement to check like: checklocation(islocation(7) and $posz == 7).
-- @param   {various}   label   The label name or ID to go. (optional)
-- @param   {string}    section The label section name. (optional)
-- @returns {boolean}

function checklocation(dist, label, section) -- Working
	local t = type(dist)
    dist = (t == 'number' and dist > 0) and dist or false

    if t == 'number' and not ($posx <= $wptx + dist and $posx >= $wptx-dist and $posy <= $wpty + dist and $posy >= $wpty - dist and $posz == $wptz) then
        if not (label and section) then
            return false
        else
            gotolabel(label, section)
        end
    elseif t == 'boolean' and not dist then
        if not (label and section) then
            return false
        else
            gotolabel(label, section)
        end
	end

    return true
end

-- FIXES AND GENERAL EXTENSIONS

-- extend function
unequip = unequip or unequipitem
-- enables advanced cooldown control

function cast(...)
    local args = {...}
    local info = type(args[1]) == 'table' and args[1] or spellinfo(args[1])
    LIB_CACHE.cancast[info.name:lower()] = $timems + info.duration

    return __FUNCTIONS.CAST(...)
end

printf("Leonardo's library loaded, version: %s", LIBS.LEONARDO)
