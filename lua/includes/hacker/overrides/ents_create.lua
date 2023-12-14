local args = {...}
local hacker = args[1]
local extensions = args[2]
local hackerkilled = args[3]

local hideupvalue = hacker.hideupvalue
local ents_Create = ents.Create
local debug_getinfo = debug.getinfo
local debug_getlocal = debug.getlocal
local string_sub = string.sub
local string_char = string.char
local string_gsub = string.gsub
local math_random = math.random

local CompileString = CompileString

local getclasses = {}
local disabledHooks = {}

local function genstr()
    local b = 'xxxxxxxxxxxx'

    local s = string_gsub(b,'x',function()
        return string_char(math_random(65,90))
    end)

    return s
end

local function ofunction(a,b,c)
    local uref = a[b]
    if not uref then return end

    local e = debug_getinfo(uref,'S')
    local n = string_sub(e.source,2)

    n = n ~= '[C]' and n or genstr()

    local g = [[
        local h = {...}
        local c = h[2]

        h[1](h)

        return function(...)
            local r = c(h[3],...)

            if r then
                return r
            end

            return h[3](...)
        end
    ]]

    local func = CompileString(g,n)(hideupvalue,c,uref)

    if func then
        a[b] = func
    end
end

local function getstack(class)
    local a = false

    for i=1,1000 do
        local b = debug_getinfo(i,'f')
        if not b or a then break end

        for i2=1,1000 do
            local c,d = debug_getlocal(i,i2)
            if not c or a then break end

            if isentity(d) and hackerkilled[d] then
                if class and hacker.GetClass(d) ~= class then
                    continue
                end

                a = true
                break
            end
        end
    end

    return a
end

--[[
local function checkstack_ofunc(a,b)
    ofunction(a,b,function(uref,...)
        local t = {...}
        local c = nil

        local s = getstack()

        for i=1,#t do
            local f = t[i]

            if isfunction(f) then
                if s and extensions.hasfunction(f,ents_Create,{ents,'Create'}) then
                    c = true
                    break
                end
            end
        end

        return c
    end)
end
--]]

ofunction(ents,'Create',function(ents_create,class)
    if class and disabledHooks[class] then
        disabledHooks[class] = nil
    end

    local a = getstack(class)

    if a then
        local e = ents_create('prop_dynamic')

        hacker.SetNoDraw(e,true)
        hacker.SetModel(e,'models/error.mdl')

        hacker.T_Simple(0, function()
            if IsValid(e) then
                hacker.Remove(e)
            end
        end)

        return e
    end
end)

local debug_getupvalue = debug.getupvalue
local jit_util_funck = jit.util.funck
local jit_util_funcinfo = jit.util.funcinfo

local rawget = rawget
local rawset = rawset

local function getupvalues(func)
    local a = debug_getinfo(func,'uS')
    local t = {}
    
    if a.what == 'Lua' then
        for i = 1, a.nups do
            t[#t+1] = {debug_getupvalue(func, i)}
        end
    end

    return t
end

local function getgcconstants(func)
    local a = debug_getinfo(func,'S')
    local t = {}
    
    if a.what == 'Lua' then
        for i = -1, -jit_util_funcinfo(func).gcconsts, -1 do
            t[#t+1] = jit_util_funck(func, i)
        end
    end

    return t
end

local gethooks = {
    ['Think'] = true,
    ['Tick'] = true,
}

local function getallupvalues(func, vals)
    local t = getupvalues(func)
    vals = vals or {}

    for i = 1, #t do
        local b = t[i]
        local c = b[2]

        if c ~= func and isfunction(c) and debug_getinfo(c,'S').what == 'Lua' then
            getallupvalues(c, vals)
        end

        vals[#vals+1] = {b[1],c}
    end

    return vals
end

local function getallgcconstants(func, vals)
    local t = getgcconstants(func)
    local nups = getallupvalues(func)
    vals = vals or {}

    for i = 1, #nups do
        local upv = nups[i]
        local b = upv[2]

        if b ~= func and isfunction(b) and debug_getinfo(b,'S').what == 'Lua' then
            getallgcconstants(b, vals)
        end
    end

    for i = 1, #t do
        vals[#vals+1] = t[i]
    end

    return vals
end

-- back to that devious spaghetti qtg hacker coding again
function hacker.HookOverride()
    local old = hook.Add
    local Hooks = hook.GetTable()

    local getstr = {}
    local gcopy = {}

    for k, v in pairs(_G) do
        if isfunction(v) then
            gcopy[k] = true
        end
    end

    hook.Add = function(event, name, func, ...)
        if gethooks[event] and isfunction(func) then
            local gcconsts = getallgcconstants(func)
            local upvalues = getallupvalues(func)

            for i = 1, #gcconsts do
                local a = gcconsts[i]

                if not gcopy[a] then
                    if not getstr[a] then
                        getstr[a] = {{event, name}}
                    else
                        local b = getstr[a]
                        b[#b+1] = {event, name}
                    end
                end
            end

            for i = 1, #upvalues do
                local a = upvalues[i][2]

                if isstring(a) and not gcopy[a] then
                    if not getstr[a] then
                        getstr[a] = {{event, name}}
                    else
                        local b = getstr[a]
                        b[#b+1] = {event, name}
                    end
                end
            end
        end

        return old(event, name, func, ...)
    end

    local function rephook(a,b,classname)
        local c = Hooks[a][b]

        if c then
            Hooks[a][b] = function(...)
                if disabledHooks[classname] then return end
                return c(...)
            end
        end
    end

    local gettries = {}
    local scripted_ents_GetStored

    setmetatable(getstr,{
        __index = function(...) return rawget(...) end,
        __newindex = function(t,k,v)
            if scripted_ents and not scripted_ents_GetStored then
                scripted_ents_GetStored = scripted_ents.GetStored
            end

            hacker.T_Simple(0, function()
                if scripted_ents_GetStored(k) then
                    getclasses[k] = true

                    for i = 1, #v do
                        local a = v[i]
                        local b = a[1]

                        if Hooks[b] then
                            rephook(b,a[2],k)
                        end
                    end
                end
            end)
        end
    })

    function hacker.BreakRemakeHook(classname)
        if not getclasses[classname] then return end
        disabledHooks[classname] = true
    end
end
