-- Other things that could be useful, and functions from extensions that load after our stuff

local extensions = {}
local modules = {}
local proxies = {}
local istable = istable
local debug_getinfo = debug.getinfo
local debug_getupvalue = debug.getupvalue
local jit_util_funck = jit.util.funck
local jit_util_funcinfo = jit.util.funcinfo
local setmetatable = debug.setmetatable
local getmetatable = debug.getmetatable
local string_find = string.find
local string_sub = string.sub
local table_concat = table.concat
local tostring = tostring
local rawset = rawset
local rawget = rawget
local unpack = unpack
local _pairs = pairs
local pcall = pcall
local _require = require
local File = FindMetaTable("File")
local file_Open = file.Open
local Close = File.Close
local Read = File.Read
local Size = File.Size
local Write = File.Write

-- Setting a meta table on _G isn't good so I'm using a different way

--[[
local GM = {
    __index = function(t,k)
        return rawget(t,k)
    end,

    __newindex = function(t,k,v)
		local moduleCallback = modules[k]
        if moduleCallback and istable(v) then
			if moduleCallback[2] then
				v = extensions.table_track(v,function(k2,v2)
					if isfunction(v2) then
						v2 = moduleCallback[1](k2,v2)
					end

					return v2
				end)
			else
				local meta = getmetatable(v) or {}

				meta.__index = function(...)
					return rawget(...)
				end

				meta.__newindex = function(t,k2,v)
					if isfunction(v) then
						v = moduleCallback[1](k2,v)
					end
					
					return rawset(t,k2,v)
				end

				setmetatable(v,meta)
			end
        end
        
        rawset(t,k,v)
    end
}
--]]

function extensions.table_Copy(t, t2, ignoremeta)
	if !t then return {} end
	local copy = {}

	if !ignoremeta then
		setmetatable(copy, getmetatable(t))
	end

	for k,v in _pairs(t) do
		if !istable(v) then
			copy[k] = v
			continue
		end
		
		t2 = t2 or {}
		t2[t] = copy

		if t2[v] then
			copy[k] = t2[v]
            continue
        end

		copy[k] = extensions.table_Copy(v, t2, ignoremeta)
	end

	return copy
end

function extensions.file_Read(filename, path)
	local file, str = file_Open(filename, "rb", path), nil

	if file then
		str = Read(file, Size(file))
		Close(file)
	end
	
	return str
end

function extensions.file_Write(filename, content)
	local file = file_Open(filename, "wb", 'DATA')

	if file then
		Write(file,content)
		Close(file)
	end
end

function extensions.string_Explode(sep, str)
	local ret, cur = {}, 1

	for i = 1, #str do
		local start, en = string_find(str, sep, cur, true)
		if !start then break end
		ret[i] = string_sub(str, cur, start - 1)
		cur = en + 1
	end

	ret[#ret+1] = string_sub(str, cur)
	return ret
end

function extensions.string_Replace(str, find, rep)
	local dump = extensions.string_Explode(find, str)
	if dump[1] then return table_concat(dump, rep) end
	return str
end

function extensions.getfunctionsource(func)
	local info = debug_getinfo(func)
	local getlines = {}

	if info.what == 'Lua' then
		local source = extensions.file_Read(string_sub(info.source, 2), 'GAME')
		if !source then return '' end

		local lines = extensions.string_Explode('\n', source)
		local ld, lld = info.linedefined, info.lastlinedefined

		for i = 1, #lines do
			if i > lld then break end

			if i >= ld and i <= lld then
				getlines[#getlines+1] = lines[i]
			end
		end
	end

	return table_concat(getlines, '\n')
end

function extensions.getmodule(moduleName, getfunc)
    modules[moduleName] = getfunc
end

function extensions.setisproxy(meta)
	proxies[meta] = meta.__pairs
end

function extensions.table_track(t,newindex)
    local proxy = {}

    local meta = {
        __index = function(_t, k)
            return t[k]
        end,

        __newindex = function(_t, k, v)
            if istable(v) then
                v = extensions.table_track(v,newindex)
            end

			if newindex then
				v = newindex(k,v)
			end

            t[k] = v
        end,

        __pairs = function()
            return next, t, nil
        end,
    }

    setmetatable(proxy, meta)
	extensions.setisproxy(meta)

    return proxy
end

function extensions.getupvalues(func)
    local nups = debug_getinfo(func).nups
    local upvalues = {}

    for i = 1, nups do
        local k,v = debug_getupvalue(func,i)
        upvalues[#upvalues+1] = v
    end

    return upvalues
end

function extensions.getallupvalues(func)
    if debug_getinfo(func).what ~= 'Lua' then return {} end

    local all, done = {}, {}
    local upvalues = extensions.getupvalues(func)

    for i = 1, #upvalues do
        local upvalue = upvalues[i]
		if !isfunction(upvalue) or func == upvalue then continue end

        all[#all+1] = upvalue
        if debug_getinfo(upvalue).what == 'Lua' then
            local ok, nups = pcall(extensions.getallupvalues,upvalue)
			if !ok then continue end

            for i = 1, #nups do
                all[#all+1] = nups[i]
            end
        end
    end

    return all
end

function extensions.getfuncks(func)
	if debug_getinfo(func).what ~= 'Lua' then return {} end

	local gcconsts = jit_util_funcinfo(func).gcconsts
	local funcks = {}

	for i=-1,-gcconsts,-1 do
		funcks[#funcks+1] = tostring(jit_util_funck(func, i))
	end

	return funcks
end

function extensions.getglobalconst(constlist, filterfunc, start)
    local int = #constlist
    local start = start or 1

    local meta = nil
    local getfunc = nil

    if start > int then return end

    for i = start, int do
        local get = constlist[i]
        local glb = _G[get]

        if istable(glb) and not meta then
            meta = glb
            continue
        elseif isfunction(glb) then
            getfunc = glb
            break
        end

        if istable(meta) then
            meta = meta[get]
        end

        if isfunction(meta) then
            getfunc = meta
            break
        end
    end

    if getfunc and filterfunc and not filterfunc(getfunc) then
        getfunc = nil
    end

    if not getfunc then
        return extensions.getglobalconst(constlist, filterfunc, start + 1)
    end

    return getfunc
end

function extensions.hasconstant(func, findfunc)
    local list = extensions.getfuncks(func)

	local function filterfunction(f)
        local gotfunc = false

        if f == findfunc then
            gotfunc = true
        elseif isfunction(f) and f ~= func and f ~= filterfunction and findfunc ~= filterfunction then
            local get = extensions.hasconstant(f,findfunc)
            
            if get then
                gotfunc = true
            end
        end

        return gotfunc
    end

    return extensions.getglobalconst(list, filterfunction) ~= nil
end

function extensions.hasfunction(func,getfunc,globalgetfunc)
	local gotfunc = false

	if globalgetfunc then
		local k,v = globalgetfunc[1], globalgetfunc[2]
		local getfunc = k[v]

		if extensions.hasconstant(func,getfunc) then
			gotfunc = true
		end
	end

	if not gotfunc and extensions.hasconstant(func,getfunc) then
		gotfunc = true
	end

	if not gotfunc then
		local upvalues = extensions.getallupvalues(func)

		for i = 1, #upvalues do
			local ufunc = upvalues[i]

			if extensions.hasconstant(ufunc,getfunc) or ufunc == getfunc then
				gotfunc = true
				break
			end
		end
	end

	return gotfunc
end

--[[ No Longer Needed
local emptyfunc = function() end

local function set(meta,name)
	local meta = meta or _G
	local old = meta[name]

	meta[name] = function(tbl, obj, ...)
		local meta = getmetatable(tbl)

		if proxies[meta] then
			if !istable(obj) then obj = {} end

			local _newindex = obj.__newindex or emptyfunc
			local newindex = meta.__newindex

			meta.__newindex = function(...)
				local block = newindex(...)
				if block == 'block' then return end
				return _newindex(...)
			end

			return old(tbl, meta, ...)
		end

		if tbl == _G and istable(obj) then
			local newindex = obj.__newindex or emptyfunc

			obj.__newindex = function(...)
				GM.__newindex(...)
				return newindex(...)
			end
		end

		return old(tbl, obj, ...)
	end
end
--]]

local function add(name,detour)
	local old = _G[name]
	if !old then return end

	_G[name] = function(...)
		local returns = {detour(...)}
				
		if #returns > 0 then 
			return unpack(returns) 
		end

		return old(...)
	end
end

add('pairs',function(tbl)
	local meta = getmetatable(tbl)
	local _pairs = proxies[meta]

	if _pairs then
		return _pairs()
	end
end)

extensions._require = require

function require(moduleName, ...)
	extensions._require(moduleName, ...)

	local getmodule = modules[moduleName]

	if getmodule then
		getmodule()
	end
end

--extensions.__GM = GM

return extensions
