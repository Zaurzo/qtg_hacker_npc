local Registry = debug.getregistry()
local Hacker = {}
local args = {...}
local hackerkilled = args[1]
local Entity = Registry["Entity"]
local Player = Registry["Player"]
local NextBot = Registry["NextBot"]
local PathFollower = Registry["PathFollower"]
local CLuaLocomotion = Registry['CLuaLocomotion']
local EValid = Entity.IsValid
local GetClass = Entity.GetClass
local isentity = isentity
local string_find = string.find
local tostring = tostring
local rawset = rawset
local istable = istable
local isstring = isstring
local isfunction = isfunction

local GetNextBot = SERVER and CLuaLocomotion.GetNextBot or nil
local PValid = SERVER and PathFollower.IsValid or nil

local function IsValid(obj)
    if !obj then return end

    if isentity(obj) then
        return EValid(obj)
    elseif string_find(tostring(obj), "Path") then
        return PValid(obj)
    end

    return Registry[2]["IsValid"](obj)
end

local function ishacker(ent)
    if isentity(ent) and IsValid(ent) and GetClass(ent) == Hacker.classname then
        return true
    end

    return false
end

local function AddHackerFunction(obj, key, alias)
    local func = obj
    if istable(obj) then
        func = obj[key]
    end

    if isfunction(func) then
        Hacker[alias or key] = func
    end
end

local qfuncs = {}
local function qfunc(hide, meta, key, override, alias)
    local func = key
    local ref = key

    if istable(meta) then
        func = meta[key]
        ref = meta[key]
    end

    if !ref or qfuncs[ref] then return end

    if hide then
        Hacker.hideupvalue(ref)
    end

    func = function(...)
        local shouldOverride = {override(...)}

        if #shouldOverride > 0 then
            return unpack(shouldOverride)
        end

        return ref(...)
    end

    qfuncs[ref] = override

    if isstring(key) and istable(meta) then
        AddHackerFunction(ref, key, alias)
        rawset(meta,key,func)
    else
        return func
    end
end

local function block(meta, key, checkspawn, ...)
    local isloco = meta == CLuaLocomotion
    local returns = {...}

    return qfunc(false, meta, key, function(self)
        if (isloco and self and ishacker(GetNextBot(self))) or (ishacker(self) and (!checkspawn or self.HackerSpawned)) then
            return #returns > 0 and unpack(returns) or ''
        end
    end,(isloco and ('loco_'..key)) or nil)
end

do
    local old = game.CleanUpMap

    function game.CleanUpMap(send,filter,...)
        if !istable(filter) then filter = {} end
        local num = #filter
        
        filter[num+1] = Hacker.classname
        filter[num+2] = "qtg_hacker_headwear"

        return old(send,filter,...)
    end
end

block(Entity, "Spawn", true)
block(Entity, "Remove")
block(Entity, "Fire")
block(Entity, "Input")
block(Entity, "SetPos", true)
block(Entity, "SetAngles", true)
block(Entity, "SetVelocity")
block(Entity, "SetLocalPos")
block(Entity, "SetLocalAngles")
block(Entity, "SetLocalVelocity")
block(Entity, "SetNoDraw")
block(Entity, "SetModel")
block(Entity, "SetModelScale")
block(Entity, "SetParent")
block(Entity, "SetName")
block(Entity, "SetMaterial")
block(Entity, "SetHealth")
block(Entity, "SetMaxHealth")
block(Entity, "SetSubMaterial")
block(Entity, "SetGravity")
block(Entity, "SetRenderMode")
block(Entity, "SetColor")
block(Entity, "SetColor4Part")
block(Entity, "SetKeyValue")
block(Entity, "SetNotSolid")
block(Entity, "SetCollisionGroup")
block(Entity, "SetCollisionBounds")
block(Entity, "SetMoveCollide")
block(Entity, "SetMoveParent")
block(Entity, "SetMoveType")
block(Entity, "SetFlexScale")
block(Entity, "SetCycle")
block(Entity, "SetOwner")
block(Entity, "SetCreator", true)
block(Entity, "SetModelName")
block(Entity, "SetAbsVelocity")
block(Entity, "PhysicsInit")
block(Entity, "PhysicsFromMesh")
block(Entity, "PhysicsDestroy")
block(Entity, "PhysicsInitConvex")
block(Entity, "PhysicsInitMultiConvex")
block(Entity, "PhysicsInitBox")
block(Entity, "PhysicsInitShadow")
block(Entity, "PhysicsInitSphere")
block(Entity, "PhysicsInitStatic")
block(Entity, "AlignAngles")
block(Entity, "AddCallback")
block(Entity, "AddEFlags")
block(Entity, "AddSolidFlags")
block(Entity, "AddGesture")
block(Entity, "AddGestureSequence")
block(Entity, "AddLayeredSequence")
block(Entity, "AddToMotionController")
block(Entity, "TakeDamage")
block(Entity, "TakeDamageInfo")
block(Entity, "RemoveFromMotionController")
block(Entity, "RemoveFlags")
block(Entity, "RemoveEFlags")
block(Entity, "RemoveSolidFlags")
block(Entity, "EnableConstraints")
block(Entity, "EnableCustomCollisions")
block(Entity, "FireBullets")
block(Entity, "DrawShadow")
block(Entity, "DrawModel")
block(Entity, "DropToFloor", true)
block(Entity, "NextThink")
block(Entity, "Ignite")
block(Entity, "GetName", nil, 'Craig')
block(Entity, "GetTable", nil, {})
block(Entity, "EntIndex", nil, 0)
block(Entity, "IsRagdoll", nil, true)
block(Entity, "GetPhysicsObject", nil, NULL)
block(Entity, "GetPhysicsObjectCount", nil, 0)
block(Entity, "ManipulateBoneScale")
block(Entity, "ManipulateBonePosition")
block(Entity, "ManipulateBoneJiggle")
block(Entity, "ManipulateBoneAngles")
block(NextBot, "StartActivity")
block(NextBot, "BecomeRagdoll")
block(debug,'getmetatable',nil,{})
block(_G,'getmetatable',nil,{})

block(CLuaLocomotion,'SetVelocity')
block(CLuaLocomotion,'Approach')
block(CLuaLocomotion,'SetDesiredSpeed')
block(CLuaLocomotion,'SetAcceleration')
block(CLuaLocomotion,'FaceTowards')
block(CLuaLocomotion,'ClearStuck')
block(CLuaLocomotion,'JumpAcrossGap')
block(CLuaLocomotion,'SetJumpHeight')

AddHackerFunction(CLuaLocomotion,'IsStuck','loco_IsStuck')
AddHackerFunction(Entity, "GetMaxHealth", "MaxHealth")
AddHackerFunction(Entity, "IsValid", "e_IsValid")
AddHackerFunction(Entity, "GetClass")
AddHackerFunction(Entity, "GetPos")
AddHackerFunction(Entity, "Health")
AddHackerFunction(Player, "CreateRagdoll")
AddHackerFunction(Player, "StripWeapons")
AddHackerFunction(Player, "KillSilent")
AddHackerFunction(Player, "Kill")
AddHackerFunction(ents, "GetAll")
AddHackerFunction(ents, "Create")
AddHackerFunction(timer, "Simple", "T_Simple")
AddHackerFunction(timer, "Create", "T_Create")
AddHackerFunction(timer, "Exists", "T_Exists")
AddHackerFunction(timer, "Remove", "T_Remove")
AddHackerFunction(debug, "getupvalue")
AddHackerFunction(debug, "getinfo")
AddHackerFunction(debug, "traceback", "debug_traceback")
AddHackerFunction(_G, "setmetatable")

local ignited = {}
local enemy = args[2]

qfunc(false, util, 'Effect', function(name, effectdata)
    local ent = effectdata and effectdata:GetEntity()
    
    if ishacker(ent) then
        return false
    end
end,'util_Effect')

qfunc(false, debug, 'setmetatable', function(obj)
    if ishacker(obj) or (isentity(obj) and Hacker.GetClass(obj) == 'qtg_hacker_headwear') then
        return false
    end
end,'d_setmetatable')

qfunc(false, Entity, "Extinguish", function(self)
    if ignited[self] then 
        return false 
    end
end)

qfunc(false, Entity, "AddFlags", function(self, flags)
    if ishacker(self) or (ignited[self] and flags == 32768) then
        return false 
    end
end)

Hacker.ishacker = ishacker
Hacker.__IsValid = IsValid

local nups = {}
local loc = Hacker.getinfo(1).source

local isfunction, istable = isfunction, istable
local _print = print

do
    local function create(obj)
        if istable(obj) then
            return {}
        elseif isfunction(obj) then
            return function() end
        end

        return ''
    end

    function debug.getupvalue(f,...)
        local k,v = Hacker.getupvalue(f,...)

        if nups[v] or (isfunction(f) and (Hacker.getinfo(f).source == loc or string_find(Hacker.getinfo(f).source,'lua/includes/hacker/includes/qtg_hacker_npc.lua'))) then
            v = create(v)
        end

        if qfuncs[v] then
            v = _print
        end

        return k,v
    end
end

function Hacker.hideupvalue(val)
    nups[val] = true
end

Hacker.hideupvalue(nups)
Hacker.hideupvalue(Hacker)
Hacker.hideupvalue(qfuncs)

local Vector, Angle, Color = Vector, Angle, Color
local math_random = math.random
local string_char = string.char
local string_format = string.format
local string_sub = string.sub
local string_upper = string.upper
local string_gsub = string.gsub

local language_GetPhrase = language and language.GetPhrase or function() end
local gstrbase = '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

gstrbase = gstrbase .. gstrbase .. gstrbase .. gstrbase

local function obfustring(len, min, max)
    local str = gstrbase
    str = string_sub(str, 1, (len or 25))

    str = string_gsub(str, '!', function()
        return string_char(math_random(min or 32, max or 164))
    end)

    return str
end

local list = {
    {'Health',function() 
        return math_random(-1e9,1e9) 
    end},

    {'GetPos',function()
        if CLIENT and !string_find(Hacker.debug_traceback(),'gamemodes/sandbox/entities/effects/propspawn.lua',1,true) then
            return Vector(math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9))
        end
    end},

    {'GetClass',function()
        if CLIENT then
            return obfustring(math_random(15,25))
        end
    end},

    {'GetColor',function()
        return Color(math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9))
    end},

    {'GetAngles',function()
        return Angle(math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9))
    end},

    {'GetVelocity',function() 
        return Vector(math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9)) 
    end},

    {'GetMaxHealth',function() 
        return math_random(-1e9,1e9) 
    end},

    {'GetColor4Part',function() -- why does this function exist lol
        return math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9)
    end},
}

do
    local function rblock(i)
        local ofnc = list[i]

        qfunc(false, Entity, ofnc[1], function(self)
            if ishacker(self) then
                return ofnc[2](self)
            end
        end)
    end

    rblock(1)
    rblock(2)
    rblock(3)
    rblock(4)
    rblock(5)
    rblock(6)
    rblock(7)
    rblock(8)

    local saveindexes = {}
    local string_lower = string.lower

    local function savevarblock(i,builderfunc)
        saveindexes[i] = (builderfunc or true)
    end

    savevarblock('m_iName')
    savevarblock('model')
    savevarblock('avelocity',Vector)
    savevarblock('velocity',Vector)
    savevarblock('m_angAbsRotation',Angle)
    savevarblock('m_angRotation',Angle)
    savevarblock('rendercolor',Color)

    block(Entity,'SetSaveValue')
    block(Entity,'GetSaveTable',nil,{})

    qfunc(false,Entity,'GetInternalVariable',function(self,name)
        local build = saveindexes[name]

        if ishacker(self) and build then
            return (isfunction(build) and build(math_random(-1e9,1e9),math_random(-1e9,1e9),math_random(-1e9,1e9))) or obfustring(math_random(15,25)) 
        end
    end)

    local rnnstr = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ___________________________________________'

    local function getrnn(len)
        return string_gsub(string_sub(gstrbase, 1, len), '!', function()
            local rnn = math_random(1, #rnnstr)
            return string_sub(rnnstr, rnn, rnn)
        end)
    end

    qfunc(false, Entity, 'GetModel', function(self)
        if ishacker(self) then
            return string_format('%s_/%s__/%s___/404.mdl',getrnn(10),getrnn(11),getrnn(12))
        end
    end)
end

Hacker.T_Simple(0, function()
    if CLIENT then
        qfunc(false, GAMEMODE, 'AddDeathNotice', function(self, attacker, team1, inflictor, victim)
            if language_GetPhrase(victim) == language_GetPhrase(Hacker.classname) then 
                return false 
            end
        end)
    end

    if SERVER then
        qfunc(false, GAMEMODE, 'OnNPCKilled', function(self, ent)
            if hackerkilled[ent] then 
                return false 
            end
        end)
    end
end)

Hacker.classname = string.lower(obfustring(25))
Hacker.__ignited = ignited

Hacker.block = block
Hacker.qfunc = qfunc

return Hacker