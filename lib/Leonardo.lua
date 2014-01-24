--[[
    Leonardo's Library
    Created: 15/01/2014
    Updated: 21/01/2014
    Version: 1.2.1

    --> Summary:
        --> Globals and Local variables;
        --> Local functions;

        --> Extension Class;
            -- printf;
            -- sprintf;

        --> Main functions:
            --> tosec; [fix]
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
            --> isbinded;
            --> maroundfilter;
            --> maroundfilterignore;
            --> paroundfilter;
            --> paroundfilterignore;
            --> unrust;
            --> antifurnituretrap;
            --> obfuscate; [disabled]
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
LIBS.LEONARDO = "1.2.1"


__CACHE = __CACHE or {
    ANTI_FURNITURE = {_houseitems = {}, _data = {}},
    CAN_CAST = {},
}

POLICY_NONE = 'None'
POLICY_CAVEBOT = 'Cavebot'
POLICY_TARGETING = 'Targeting'
POLICY_ALL = 'Cavebot & Targeting'

AREA_SQUARE_FILLED = 'Square (Filled)'
AREA_SQUARE_BORDER = 'Square (Border Only)'

local SA_POLICY = {POLICY_CAVEBOT, POLICY_TARGETING, POLICY_ALL}
local SA_TYPE = {AREA_SQUARE_FILLED, AREA_SQUARE_BORDER}

local UNRUSTED_ITEMS = {3357, 3358, 3359, 3360, 3362, 3364, 3370, 3371, 3372, 3377, 3381, 3382, 3557, 3558, 8063}
local RUST_ITEMS_COMMON = {8895, 8896, 8897, 8898, 8899}
local RUST_ITEMS_RARE = {8895, 8896, 8898, 8899}
local ADDON_ITEMS = {768, 769, 770, 3077, 3348, 3374, 3403, 5014, 5804, 5809, 5810, 5875, 5876, 5878, 5879, 5880, 5881, 5882, 5883, 5884, 5885, 5886, 5887, 5888, 5889, 5890, 5891, 5892, 5893, 5894, 5895, 5896, 5897, 5898, 5899, 5902, 5903, 5904, 5905, 5906, 5909, 5910, 5911, 5912, 5913, 5914, 5919, 5921, 5922, 5925, 5930, 5945, 5947, 5948, 6097, 6098, 6099, 6100, 6101, 6102, 6126, 6499, 7290, 12551, 12552, 12553, 12554, 12555, 12556, 12599, 12601, 12786, 12787, 12803, 14021, 14022, 14023, 16252, 16253, 16254, 16255, 16256, 16257}
local RASHID_ITEMS = {661, 662, 664, 667, 669, 672, 673, 680, 681, 683, 686, 688, 691, 692, 780, 781, 783, 786, 788, 791, 792, 795, 796, 798, 803, 805, 808, 809, 811, 812, 813, 814, 815, 816, 817, 818, 819, 820, 821, 822, 823, 824, 825, 826, 827, 828, 829, 830, 2958, 2991, 3002, 3006, 3007, 3008, 3010, 3016, 3017, 3018, 3019, 3025, 3055, 3063, 3290, 3314, 3315, 3326, 3327, 3328, 3330, 3332, 3333, 3334, 3339, 3340, 3342, 3344, 3356, 3360, 3364, 3366, 3386, 3397, 3404, 3408, 3414, 3420, 3421, 3435, 3436, 3440, 3441, 3442, 3550, 3554, 3556, 5461, 5710, 5741, 5810, 5917, 5918, 6095, 6096, 6131, 6299, 6553, 7379, 7380, 7381, 7382, 7383, 7384, 7386, 7387, 7388, 7389, 7390, 7392, 7402, 7403, 7404, 7406, 7408, 7414, 7415, 7418, 7419, 7422, 7424, 7425, 7426, 7427, 7429, 7430, 7432, 7434, 7437, 7438, 7449, 7452, 7456, 7457, 7460, 7461, 7462, 7463, 7464, 8022, 8027, 8045, 8049, 8050, 8052, 8057, 8061, 8063, 9013, 9014, 9017, 9302, 9303, 9304, 10457, 11674, 16163, 16164, 17828, 17829, 17852}
local YASIR_ITEMS = {647, 2933, 3044, 3058, 3735, 3736, 3741, 5479, 5804, 5809, 5875, 5876, 5877, 5878, 5879, 5880, 5881, 5882, 5883, 5884, 5885, 5890, 5891, 5893, 5894, 5895, 5896, 5897, 5898, 5899, 5901, 5902, 5904, 5905, 5906, 5909, 5910, 5911, 5912, 5913, 5914, 5919, 5920, 5921, 5922, 5925, 5930, 5948, 5954, 6491, 6525, 6534, 6535, 6536, 6537, 6539, 6540, 6546, 8031, 8143, 9040, 9053, 9054, 9055, 9631, 9633, 9634, 9635, 9636, 9637, 9638, 9639, 9640, 9641, 9642, 9643, 9644, 9645, 9646, 9647, 9648, 9649, 9650, 9651, 9652, 9657, 9658, 9659, 9660, 9661, 9662, 9663, 9665, 9666, 9667, 9668, 9683, 9684, 9685, 9686, 9688, 9689, 9690, 9691, 9692, 9693, 9694, 10196, 10272, 10273, 10274, 10275, 10276, 10277, 10278, 10279, 10280, 10281, 10282, 10283, 10291, 10292, 10293, 10295, 10296, 10297, 10299, 10300, 10301, 10302, 10303, 10304, 10305, 10306, 10307, 10308, 10309, 10311, 10312, 10313, 10314, 10316, 10317, 10318, 10319, 10320, 10321, 10397, 10404, 10405, 10407, 10408, 10409, 10410, 10411, 10413, 10414, 10415, 10417, 10418, 10420, 10444, 10449, 10450, 10452, 10453, 10454, 10455, 10456, 11443, 11444, 11445, 11446, 11448, 11449, 11450, 11451, 11452, 11453, 11454, 11455, 11456, 11457, 11458, 11463, 11464, 11465, 11466, 11467, 11469, 11470, 11471, 11472, 11473, 11474, 11475, 11476, 11477, 11478, 11479, 11480, 11481, 11482, 11483, 11484, 11485, 11486, 11487, 11488, 11489, 11490, 11491, 11492, 11493, 11510, 11511, 11512, 11513, 11514, 11515, 11539, 11652, 11658, 11659, 11660, 11661, 11666, 11671, 11672, 11673, 11680, 11684, 11702, 11703, 12541, 12730, 12737, 14008, 14009, 14010, 14011, 14012, 14013, 14017, 14041, 14044, 14076, 14077, 14078, 14079, 14080, 14081, 14082, 14083, 14753, 16130, 16131, 16132, 16133, 16134, 16135, 16137, 16139, 16140, 17461, 17462, 17826, 17847, 17848, 17850, 17853, 17854, 17855, 18924, 18925, 18926, 18927, 18928, 18929, 18930, 18993, 18994, 18995, 18996, 18997, 19110, 19111}
local GNOMISSION_ITEMS = {645, 902, 2848, 2852, 3013, 3014, 3068, 3249, 3295, 3306, 3323, 3341, 3387, 3398, 3424, 5803, 6527, 6561, 6566, 6568, 7184, 7416, 7417, 7453, 8021, 8025, 8029, 8039, 8041, 8055, 9394, 9606, 9613, 9619, 11679, 11693} -- missing Unholy Book
local ROCK_IN_A_HARD_PLACE_ITEMS = {12730, 13987, 13990, 13991, 13993, 13994, 13996, 13997, 13999, 14000, 14001, 14008, 14009, 14010, 14011, 14012, 14013, 14017, 14040, 14041, 14042, 14043, 14044, 14076, 14077, 14078, 14079, 14080, 14081, 14082, 14083, 14086, 14087, 14088, 14089, 14246, 14247, 14250, 14258, 14753}
local slotNames = {["amulet"] = "neck", ["weapon"] = "rhand", ["shield"] = "lhand", ["ring"] = "finger", ["armor"] = "chest", ["boots"] = "feet", ["ammo"] = "belt", ["helmet"] = "head"}

-- LOCAL FUNCTIONS

local function __crearoundf__callback(range, floor, list, cretype, ignore, f)
    local Creatures = {}

    foreach creature cre cretype do
        if f(cre) and cre.dist <= range and (cre.posz == $posz or floor) and ((not ignore and (#list == 0 or table.find(list, cre.name:lower()))) or (ignore and not table.find(list, cre.name:lower()))) then
            table.insert(Creatures, cre)
        end
    end

    return #Creatures
end

-- EXTENSION CLASS

function printf(str, ...)
    return print(sprintf(str, ...))
end

function sprintf(str, ...)
    return #{...} > 0 and tostring(str):format(...) or tostring(str)
end

-- MAIN FUNCTIONS

-- @name    tosec
-- @desc                Converts a time formatted string into seconds.
-- @param   {string}    str     The string to convert
-- @returns {number}

function tosec(str) -- Working, by sirmate
    local sum, time, units, index = 0, str:token(nil, ":"), {86400, 3600, 60, 1}, 1
    for i = #units - #time + 1, #units do
        sum, index = sum + ((tonumber(time[index]) or 0) * units[i]), index + 1
    end
    return math.max(sum, 0)
end

-- @name    formatnumber
-- @desc            Formats a number to show its units.
-- @param   {number}   num     The number to be formatted
-- @param   {string}    sep     The symbol to separate numbers, default is ",". (optional)
-- @returns {string}

function formatnumber(n, s) -- Working, by sirmate
    local result, sign, before, after, s = '', string.match(tostring(n), '^([%+%-]?)(%d*)(%.?.*)$'), s or ','

    while #before > 3 do
        result = s .. string.sub(before, -3, -1) .. result
        before = string.sub(before, 1, -4)
    end

    return sign .. before .. result .. after
end

-- @name    formattime
-- @desc            Converts a number to a date format string.
-- @param   {number}   num     The number to be converted
-- @param   {string}    pattern The pattern to format number, default is "DD:HH:MM:SS". (optional)
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
    foreach settingsentry e 'Cavebot/SpecialAreas' do
        if getsetting(e, 'Name'):lower() == name:lower() then
            local x, y, z = getsetting(e, 'Coordinates'):match('.-(%d+).-(%d+).-(%d+)')
            return {x = tonumber(x), y = tonumber(y), z = tonumber(z)}
        end
    end
    return {x = 0, y = 0, z = 0}
end

-- @name    setareaposition
-- @desc                Sets the special area initial position.
-- @param   {string}    name    The special area name.
-- @param   {number}   x       The special area x coordinate. (optional)
-- @param   {number}   y       The special area y coordinate. (optional)
-- @param   {number}   z       The special area z coordinate. (optional)
-- @returns {null}

function setareaposition(name, x, y, z) -- Working
    x, y, z = tonumber(x) or $posx, tonumber(y) or $posy, tonumber(z) or $posz

    foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name:lower() then
            return setsetting(sprintf("Cavebot/SpecialAreas/%s/Coordinates", areaname), sprintf("x:%s, y:%s, z:%s", x, y, z))
        end
    end
end

-- @name    getareasize
-- @desc                Returns the special area width and height.
-- @param   {string}    name    The special area name.
-- @returns {table}

function getareasize(name) -- working
    foreach settingsentry e 'Cavebot/SpecialAreas' do
        if getsetting(e, 'Name'):lower() == name:lower() then
            local w, h = getsetting(e, 'Size'):match('(%d+).-(%d+)')
            return {w = tonumber(w), h = tonumber(h)}
        end
    end

    return {w = 0, h = 0}
end

-- @name    setareasize
-- @desc                Sets the width and height for a special area.
-- @param   {string}    name    The special area name.
-- @param   {number}   width   The width lenght. (optional)
-- @param   {number}   height  The height lenght. (optional)
-- @returns {null}

function setareasize(name, w, h) -- working
    h, w = tonumber(h) or 1, tonumber(w) or 1

    foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name:lower() then
            return setsetting(sprintf("Cavebot/SpecialAreas/%s/Size", areaname), sprintf('%d to %d', w, h))
        end
    end
end

-- @name    getareapolicy
-- @desc                Returns the policy of a special area.
-- @param   {string}    name    The special area name.
-- @returns {string}

function getareapolicy(name) -- working
    foreach settingsentry e 'Cavebot/SpecialAreas' do
        if getsetting(e, 'Name'):lower() == name:lower() then
            return getsetting(e, "Policy")
        end
    end

    return POLICY_NONE
end

-- @name    getareapolicy
-- @desc                Sets the policy of a special area.
-- @param   {string}    name    The special area name.
-- @param   {string}        policy  The policy to setsetting. 'Cavebot', 'Targeting', 'Cavebot & Targeting' or 'None'. (optional)
-- @returns {null}

function setareapolicy(name, policy) -- working
    if type(policy) == 'string' and not table.find({"cavebot", "cavebot & targeting", "targeting", "none"}, policy:lower()) then
        policy = "None"
    elseif type(policy) == 'number' and policy > 0 and policy <= 3 then
        policy = SA_POLICY[policy]
    else
        policy = "None"
    end

    foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return setsetting(sprintf('Cavebot/SpecialAreas/%s/Policy', areaname), policy)
        end
    end
end

-- @name    getareaavoidance
-- @desc                Returns the avoidance of a special area.
-- @param   {string}    name    The special area name.
-- @returns {number}

function getareaavoidance(name) -- working
    foreach settingsentry e 'Cavebot/SpecialAreas' do
        if getsetting(e, 'Name'):lower() == name:lower() then
            return tonumber(getsetting(e, 'Avoidance'))
        end
    end

    return 0
end

-- @name    setareaavoidance
-- @desc                Sets the avoidance for a special area.
-- @param   {string}    name        The special area name.
-- @param   {number}   avoidance   The avoidance level. Minimum of 0 and maximum of 250. (optional)
-- @returns {number}

function setareaavoidance(name, avoid) -- working
    avoid = tonumber(avoid) or 0

    foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return setsetting(sprintf('Cavebot/SpecialAreas/%s/Avoidance', areaname), math.max(avoid, 0))
        end
    end
end

-- @name    getareaextrapolicy
-- @desc                Returns true if the extra policy given is enabled, false otherwise.
-- @param   {string}    name    The special area name.
-- @param	{string}	type    The extra policy type as 'loot', 'lure', 'looting' or 'luring'.
-- @returns {boolean}

function getareaextrapolicy(name, poltype)
	local t = type(poltype)
	poltype, name = t == 'string' and poltype:lower() or false, name:lower()

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


	foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return getsetting(sprintf('Cavebot/SpecialAreas/%s/%s', areaname, poltype)) == 'yes'
        end
    end

	return false
end

-- @name    setareaextrapolicy
-- @desc                Sets the extra policy for a special area.
-- @param   {string}    name        The special area name.
-- @param   {various}   poltype     The policy type as 'loot', 'lure', 'looting' or 'luring'.
-- @param	{various}   t           The value to turn option on or off as any true value or false value.
-- @returns {null}

function setareaextrapolicy(name, poltype, t)
	local typ = type(poltype)
	poltype, name = typ == 'string' and poltype:lower() or false, name:lower()

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


	foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return setsetting(sprintf('Cavebot/SpecialAreas/%s/%s', areaname, poltype), toyesno(t))
        end
    end
end

-- @name    getareatype
-- @desc                Returns the type name of a special area.
-- @param   {string}    name     The special area name.
-- @returns {string}

function getareatype(name)
	name = name:lower()

	foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return getsetting(sprintf('Cavebot/SpecialAreas/%s/Type', areaname))
        end
    end

	return nil
end

-- @name    setareatype
-- @desc                Sets the type of a special area.
-- @param   {string}    name     The special area name.
-- @param   {various}   type     The area type as 'filled' or 'border', 1 for filled or 2 for border.
-- @returns {null}

function setareatype(name, areatype)
	name = name:lower()
	local t = type(areatype)

	if t == 'string' then
		areatype = areatype:lower()

		if areatype:match('filled') then
			areatype = AREA_SQUARE_FILLED
		elseif areatype:match('border') then
			areatype = AREA_SQUARE_BORDER
		else
			return printerrorf("bad argument #2 to 'setareatype' ('Filled', 'Border', 'Square (Filled)' or 'Square (Border Only)' expected, got %s)", areatype)
		end
	elseif t == 'number' and areatype == 1 or areatype == 2 then
		areatype = SA_TYPE[areatype]
	else
		return printerrorf("bad argument #2 to 'setareatype' (string or number (1-2) expected, got %s%s)", t, areatype > 2 and " different than the value expected" or '')
	end

	foreach settingsentry e 'Cavebot/SpecialAreas' do
        local areaname = getsetting(e, 'Name')

        if areaname:lower() == name then
            return setsetting(sprintf('Cavebot/SpecialAreas/%s/Type', areaname), areatype)
        end
    end
end

-- @name    isbinded
-- @desc                Check if you have the current hotkeys binded on functions keyboard.
-- @param   {array}     bind¹, bind², ..., bind*    The list of the hotkeys to check.
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
-- @param   {number}   range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     nameÂ¹, nameÂ², name*, ...    The creature names list to consider. (optional)
-- @param   {function}  The filter function. (optional)
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
-- @param   {number}   range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     nameÂ¹, nameÂ², name*, ...    The creature names list to disconsider. (optional)
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
-- @param   {number}   range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     nameÂ¹, nameÂ², name*, ...    The creature names list to consider. (optional)
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
-- @param   {number}   range   The minimum distance range. (optional)
-- @param   {boolean}   floor   Set true to consider all floors or false to consider on the current floor. (optional)
-- @param   {array}     nameÂ¹, nameÂ², name*, ...    The creature names list to disconsider. (optional)
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
-- @param   {number}   value   Set the minimum value to consider items below this value as trash. (optional)
-- @returns {null}
-- @todo    Add rust remover to the used items;

function unrust(ignore, drop, value) -- Working
    local IgnoreCommon = ignore or true
    local DropTrash = drop or true
    local MinValue = math.max(value or 0, 0)

    if itemcount(9016) == 0 and clientitemhotkey(9016, "crosshair") == 'not found' then
        return nil
    end

    local Amount, Trash = {}, {}

    for _, Item in ipairs(UNRUSTED_ITEMS) do
        if itemvalue(Item) > MinValue then
            Amount[Item] = itemcount(Item)
        else
            table.insert(Trash, Item)
        end
    end

    local RustyItems = IgnoreCommon and RUST_ITEMS_RARE or RUST_ITEMS_COMMON

    for _, Item in ipairs(RustyItems) do
        if itemcount(Item) > 0 then
            useitemon(9016, Item, '0-15') waitping()
            increaseamountused(9016, 1)
        end
    end

    if DropTrash then
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
-- @param   {various}     weapon  The weapon name or ID to use.
-- @param   {number}   time    The maximum time to wait before start breaking items.
-- @returns {null}

function antifurnituretrap(weapon, time) -- Working
    local Weapon = weapon or 'machete'
    local MaxWait = math.max(time or 0, 0)

    if clientitemhotkey(Weapon, "crosshair") == 'not found' and itemcount(Weapon) == 0 then
        return nil
    end

    __CACHE.ANTI_FURNITURE._data = {}

    for x = SCREEN_LEFT, SCREEN_RIGHT do
        for y = SCREEN_TOP, SCREEN_BOTTOM do
            local pos, house = {x = x + $posx, y = y + $posy, z = $posz}, false
            local info = iteminfo(topitem(pos.x, pos.y, pos.z).id)

            if info.isunpass and not info.isunmove and tilereachable(pos.x, pos.y, pos.z, false) then
                for _, item in ipairs(__CACHE.ANTI_FURNITURE._houseitems) do
                    if item.x == pos.x and item.y == pos.y and item.z == pos.z then
                        house = true
                        break
                    end
                end

                if not house then
                    table.insert(__CACHE.ANTI_FURNITURE._data, {x = pos.x, y = pos.y, z = pos.z, id = info.id})
                end
            end
        end
    end

    table.sort(__CACHE.ANTI_FURNITURE._data, function(a, b)
        if math.max(math.abs($posx - a.x), math.abs($posy - a.y)) == math.max(math.abs($posx - b.x), math.abs($posy - b.y)) then
            if math.abs($posx - a.x) == math.abs($posx - b.x) then
                if math.abs($posy - a.y) == math.abs($posy - b.y) then
                    return a.id < b.id
                else
                    return math.abs($posy - a.y) < math.abs($posy - b.y)
                end
            else
                return math.abs($posx - a.x) < math.abs($posx - b.x)
            end
        else
            return math.max(math.abs($posx - a.x), math.abs($posy - a.y)) < math.max(math.abs($posx - b.x), math.abs($posy - b.y))
        end
    end)

    if $standtime >= MaxWait * 1000 then
        for i, item in pairs(__CACHE.ANTI_FURNITURE._data) do
            local x, y, z, id, house = item.x, item.y, item.z, item.id, false

            reachlocation(x, y, z) waitping()

            while id == topitem(x, y, z).id and tilereachable(x, y, z, false) do
                useitemon(Weapon, id, ground(x, y, z)) waitping(1.9, 2.1)

                foreach newmessage m do
                    if m.content:match("You are not invited") then
                        house = table.remove(__CACHE.ANTI_FURNITURE._data, i)
                        break
                    end
                end

                if house then
                    return table.insert(__CACHE.ANTI_FURNITURE._houseitems, house)
                end
            end
        end
    end
end

-- @name    getdistancebetween
-- @desc                Returns the distance between positions given or -1 if it's not located on the same floor.
-- @param   {various}     x   The x-axis position or the table with starting coordinates.
-- @param   {various}     y   The y-axis position or the table with destiny coordinates.
-- @param   {number}   z   The z-axis position.
-- @param   {number}   a   The x-axis destiny position.
-- @param   {number}   b   The y-axis destiny position.
-- @param   {number}   c   The z-axis destiny position.
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

-- @name    obfuscate
-- @desc                Generates a obfuscated code that contains the function given.
-- @param   {function}  func    The function to be obfuscated.
-- @returns {string}
-- @todo uncomment function when pcall and string.dump are added;

--function obfuscate(f)
--  local buff, script = "", string.dump(f())
--
--  for i = 1, script:len() do
--      buff = buff .. '\\' .. string.byte(script, i)
--  end
--
--  return buff
--end

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
-- @param   {various}   creature    The creature object, name or ID.
-- @returns {boolean}

function cancast(spell, creature) -- Working
    spell = type(spell) == 'table' and spell or spellinfo(spell)
    local CooldownControl, strike = __CACHE.CAN_CAST[spell.name:lower()] or 0, false

    if creature then
        creature = type(creature) == 'userdata' and creature or findcreature(creature)

        if spell.castarea ~= 'None' and spell.castarea ~= '' then
            strike = spell.words
        end
    end

    return (not strike or isonspellarea(creature, strike, $self.dir)) and $timems >= CooldownControl and $level >= spell.level and $mp >= spell.mp and $soul >= spell.soul and cooldown(spell.words) == 0
end

-- @name    unequipitem
-- @desc                Unequip an item located at the equipment slot given.
-- @param   {string}    slot    The equipment slot name.
-- @param   {string}    bp      The backpack to move item on. (optional)
-- @param   {number}   amount  The amount of items to move on. (optional)
-- @returns {null}

function unequipitem(slot, bp, amount) -- Working
    slot = slotNames[slot:lower()] or slot:lower()
    local item = loadstring(sprintf("return $%s", slot))()

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
-- @param   {table}     areaÂ¹, areaÂ², ..., area*    The area(s) range(s) in the format: {minimum x, maximum x, minimum y, maximum y, z}.
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
-- @param   {number}   dist    The area range distance.
-- @param   {various}     label   The label name or ID to go. (optional)
-- @param   {string}    section The label section name. (optional)
-- @returns {boolean}

function checklocation(dist, label, section) -- Working
    dist = type(dist) == 'number' and dist or 1

    if not ($posx <= $wptx + dist and $posx >= $wptx-dist and $posy <= $wpty + dist and $posy >= $wpty - dist and $posz == $wptz) then
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
--enables advanced cooldown control
_CAST = _CAST or cast
function cast(...)
    args = {...}
    local info = type(args[1]) == 'table' and args[1] or spellinfo(args[1])
    __CACHE.CAN_CAST[info.name:lower()] = $timems + info.duration

    return _CAST(...)
end

printf("Leonardo's library loaded, version: %s", LIBS.LEONARDO)
