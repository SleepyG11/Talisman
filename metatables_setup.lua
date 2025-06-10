local function shallow_copy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		copy[k] = v
	end
	return copy
end

local function fbsfr(func)
	return function(t, ...)
		local obj = from_big_string(t)
		return obj[func](t, ...)
	end
end
local function fbsfp(func)
	return function(t, ...)
		local obj = from_big_string(t)
		return to_big_string(obj[func](t, ...))
	end
end

if Big then
	local original_string_meta = debug.getmetatable("")
	local string_indexable_funcs = {}
	for _, func_name in ipairs({
		"isNaN",
		"isInfinite",
		"isFinite",
		"isint",
		"compareTo",
		"lt",
		"gt",
		"lte",
		"gte",
		"eq",
		"toString",
		"to_number",
	}) do
		string_indexable_funcs[func_name] = fbsfr(func_name)
	end
	for _, func_name in ipairs({
		"neg",
		"abs",
		"min",
		"max",
		"normalize",
		"floor",
		"ceil",
		"clone",
		"add",
		"sub",
		"div",
		"mul",
		"rec",
		"logBase",
		"log10",
		"ln",
		"pow",
		"exp",
		"root",
		"slog",
		"tetrate",
		"arrow",
		"mod",
		"lambertw",
		"f_lambertw",
		"d_lambertw",

		"__add",
		"__sub",
		"__mul",
		"__div",
		"__mod",
		"__unm",
		"__pow",
		"__le",
		"__lt",
		"__ge",
		"__gt",
		"__eq",
	}) do
		string_indexable_funcs[func_name] = fbsfp(func_name)
	end
	string_indexable_funcs.__tostring = function(t)
		return number_format(from_big_string(t))
	end
	string_indexable_funcs.__concat = function(a, b)
		return tostring(from_big_string(a)) .. tostring(b)
	end
	local string_meta = shallow_copy(original_string_meta)
	string_meta.__index = function(t, key)
		return rawget(string_indexable_funcs, key) or rawget(string, key)
	end
	debug.setmetatable("", string_meta)
end
