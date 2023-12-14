local args = {...}
local Hooks = {}
local hooks = {}
local hacker = args[1]
local enemy = args[2]
local extensions = args[3]
local hackerkilled = args[4]
local IsValid = hacker.__IsValid
local ishacker = hacker.ishacker
local ignited = hacker.__ignited
local string_format = string.format

local CompileString = CompileString
local isfunction = isfunction

local dir = 'qtg_hacker_npc/' .. game.GetMap()

if !file.Exists('qtg_hacker_npc','DATA') then
    file.CreateDir('qtg_hacker_npc')
end

if not file.Exists(dir, 'DATA') then
    file.CreateDir(dir)
end

local function isinhooktbl(tblname,name)
    return (Hooks[tblname] and Hooks[tblname][name]) or false
end

local function rnname()
    local rnname = ''

    for i=1,math.random(10,15) do
        rnname = rnname..string.char(math.random(32,164))
    end

    return rnname
end

local old = {}

local function add(name, str)
    local funcstr = string_format([[
        local args = {...}
        local locals = args[1]
        
        local ishacker = locals[1] 
        local IsValid = locals[2] 
        local enemy = locals[3]
        local hacker = locals[4]
        local extensions = locals[5]

        %s
    ]], str)

    local oldstr = old[name]
    if oldstr then
        funcstr = oldstr .. '\n' .. str
    end
    
    local func = CompileString(funcstr,rnname())
    hooks[name] = func
    old[name] = funcstr

    hacker.hideupvalue(func)
end

extensions.getmodule('hook',function()
    Hooks = hook.GetTable()
    hacker.hooktbl = Hooks

    hacker.HookOverride()

    local hook_Call = hook.Call
    local funcstr = [[
        local args = {...}
        local hook_Call = args[1]
        local hooks = args[2]
        local hackerkilled = args[3]
        local ignited = args[4]

        local locals = args[5]
        local hacker = locals[4]

        local dmghooks = {
            ['EntityTakeDamage'] = true,
            ['PostEntityTakeDamage'] = true,
        }

        local gethooks = {
            ['EntityRemoved'] = true,
            ['EntityTakeDamage'] = true,
            ['PostEntityTakeDamage'] = true,
        }

        local block = {
            ['PreRegisterSENT'] = true,
            ['OnEntityCreated'] = true,
        }
        
        hacker.hideupvalue(dmghooks)
        hacker.hideupvalue(gethooks)
        hacker.hideupvalue(locals)
        hacker.hideupvalue(block)

        return function(name,tab,obj,...)
            local func = hooks[name]

            if func then
                local a,b,c = func(locals,{obj,...})

                if a ~= nil then
                    return a,b,c
                end
            end

            if block[name] and hacker.ishacker(obj) then return end

            if gethooks[name] then 
                if dmghooks[name] then
                    local args = {...}
                    local dmginfo = args[1]

                    if hacker.ishacker(dmginfo:GetAttacker()) then
                        hacker.RemoveFlags(obj,32768)
                        hook_Call(name, tab, obj, ...)
                        return
                    end
                end

                if (hackerkilled[obj] or ignited[obj]) then return end
            end

            return hook_Call(name, tab, obj, ...)
        end
    ]]

    hook.Call = CompileString(funcstr,'lua/includes/modules/hook.lua')(hook_Call,hooks,hackerkilled,ignited,{ishacker,IsValid,enemy,hacker,extensions})
end)

add('AcceptInput',[[
    if ishacker(args[2][1]) then return true end
]])

add('PhysgunPickup',[[
    if ishacker(args[2][2]) then return false end
]])

add('EntityTakeDamage',[[
    local ent = args[2][1]
    local dmginfo = args[2][2]

    local attacker = dmginfo:GetAttacker()

    if ishacker(ent) then
        if !GetConVar("qtg_hacker_pacifist"):GetBool() and (IsValid(attacker) and attacker:IsPlayer() and enemy[ent] ~= attacker) then
            local wep = attacker:GetActiveWeapon()
            if IsValid(wep) and hacker.Gnomify and hacker.GetClass(wep) == 'weapon_gnomify' then
                local d = DamageInfo()
                d:SetInflictor(attacker)
                hacker.Gnomify(attacker, {Entity = attacker}, d)

                return true
            end

            enemy[ent] = attacker
            ent:ResetBehaveThread()
        end

        return true
    end
]])

add('ShutDown',[[
    local class = hacker.classname
    local list = ents.FindByClass(class)
    local map = game.GetMap()

    local dir = 'qtg_hacker_npc/' .. map .. '/'

    for i = 1, #list do
        local ent = list[i]
        local data = {}

        data.pos = hacker.GetPos(ent)
        data.ang = hacker.GetAngles(ent)

        local fileName = string.format(dir .. "qtg_hacker_npc_%s.txt",i)
        extensions.file_Write(fileName, util.TableToJSON(data))
    end
]])

hacker.hideupvalue(hooks)
hacker.add_hook = add
