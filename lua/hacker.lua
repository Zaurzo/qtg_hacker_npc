-- This is a tribute to Neptune QTG.

-- Note to people who are looking at this file:
-- Please do not copy and paste code from here, it could break a lot of things if used incorrectly!
--     ~Zaurzo

AddCSLuaFile()

local n = FindMetaTable('NPC')
local e = FindMetaTable('Entity')
local p = FindMetaTable('Player')
local v = FindMetaTable('Vector')
local c = FindMetaTable('ConVar')
local x = FindMetaTable('NextBot')
local o = FindMetaTable('PhysObj')
local t = FindMetaTable('PathFollower')
local l = FindMetaTable('CLuaLocomotion')
local d = FindMetaTable('CTakeDamageInfo')

local bt = {}
local isqtg = {}
local ishitbox = {}
local isqtginre = {}

local LUA_INCLUDES = LUA_INCLUDES
local SERVER = SERVER
local CLIENT = CLIENT

local classname1 = '^!@$!@$!%$@$qsfqtsff!$@%!@$sfrq'
local classname2 = 'wgduw&!%@^!%@qosi&!%@^%!@{qsh!}'

local function ishacker(e,hitbox)
    if !e or !bt.isentity(e) or !bt.eIsValid(e) then return false end

    if isqtg[e] then
        return 1
    end

    if hitbox and ishitbox[e] then
        return 2
    end

    local classname = bt.eGetClass(e)

    if classname == classname1 then
        return 1
    end

    if hitbox and classname == classname2 then
        return 2
    end

    return false
end

local function newstr()
    local b = '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!'

    local str = bt.string_gsub(b,'!',function()
        return bt.string_char(bt.math_random(32,164))
    end)

    return str
end

local function add(t,k)
    if !t then return end

    for k2,v in pairs(t) do
        local k3 = k..k2

        if !bt[k3] then
            bt[k3] = v
        end
    end
end

add(e,'e')
add(p,'p')
add(x,'x')
add(l,'l')
add(o,'o')
add(d,'d')
add(v,'v')
add(c,'c')
add(n,'n')
add(t,'t')
add(_G,'')
add(bit,'bit_')
add(net,'net_')
add(ents,'ents_')
add(math,'math_')
add(util,'util_')
add(input,'input_')
add(debug,'debug_')
add(timer,'timer_')
add(string,'string_')
add(coroutine,'coroutine_')

local funcsave = {}
local protected = {}
local funcoverlay = {}

local function protect(v)
    if !protected[v] then
        protected[v] = true
    end
end

protect(bt)
protect(protected)
protect(funcsave)
protect(funcoverlay)
protect(isqtg)
protect(ishitbox)
protect(isqtginre)
protect(LUA_INCLUDES)

local function ofunction(tbl,k,func)
    if !tbl then return end

    local old = tbl[k]
    if !old then return end

    local function new(...)
        local r = {func(...)}
        local r1 = r[1]

        if r1 ~= nil then
            if r1 == -1 then
                if r[2] != nil then
                    return bt.unpack(r,2)
                end

                return nil
            end

            return bt.unpack(r)
        end

        return old(...)
    end

    tbl[k] = new
    funcsave[old] = new
    funcoverlay[new] = old
end

protect(ofunction)

local function ofunc(t,k)
    local old = t[k]
    if !old then return end

    ofunction(t,k,function(a,...)
        local f = funcoverlay[a]
        if f then a = f end

        return -1,old(a,...)
    end)
end

ofunc(string,'dump')
ofunc(jit.util,'funcinfo')
ofunc(jit.util,'funcbc')

local old = debug.getupvalue
ofunction(debug,'getupvalue',function(a,...)
    local f = funcoverlay[a]
    if f then a = f end

    local k,v = old(a,...)

    if protected[v] then
        if bt.isfunction(v) then
            return k,function() end
        end

        if bt.istable(v) then
            return k,{}
        end
    end

    local f = funcsave[v]
    if f then v = f end

    return -1,k,v
end)

local old = debug.getlocal
ofunction(debug,'getlocal',function(a,...)
    if bt.isnumber(a) then
        local k,v = old(a+2,...)

        if protected[v] then
            if bt.isfunction(v) then
                return k,function() end
            end
    
            if bt.istable(v) then
                return k,{}
            end
        end

        local f = funcsave[v]
        if f then v = f end

        return k,v
    else
        local f = funcoverlay[a]

        if f then
            a = f
        end
    end

    return -1,old(a,...)
end)

local old = debug.getinfo
ofunction(debug,'getinfo',function(a,...)
    if bt.isnumber(a) then
        local t = old(a+2,...)

        if t then
            local func = t.func
    
            if func then
                if protected[func] then
                    t.func = function() end
                else
                    local f = funcsave[func]
    
                    if f then
                        t.func = f
                    end
                end
            end
        end

        return -1,t
    else
        local f = funcoverlay[a]

        if f then
            a = f
        end
    end

    return -1,old(a,...)
end)

local function ofunc(tbl,k,isspawn,...)
    local r = ... != nil and {...}

    ofunction(tbl,k,function(self,...)
        local pass = isqtg[self] or ishitbox[self]

        if !pass and !isspawn then 
            if bt.isentity(self) and bt.eIsValid(self) then
                local class = bt.eGetClass(self)

                if class == classname2 or class == classname1 then
                    pass = true
                end
            end
        end

        if pass then
            if r then
                return -1,bt.unpack(r)
            end

            return -1
        end
    end)
end

protect(ofunc)

ofunc(e,'Remove')
ofunc(e,'Input')
ofunc(e,'Fire')
ofunc(e,'SetModel')
ofunc(e,'SetNoDraw')
ofunc(e,'SetMoveType')
ofunc(e,'SetNotSolid')
ofunc(e,'Spawn',true)
ofunc(e,'SetSaveValue')
ofunc(e,'SetKeyValue')
ofunc(e,'GetClass',nil,'qtg_hacker_npc')
ofunc(e,'SetPos',true)
ofunc(e,'SetLocalPos')
ofunc(e,'SetAngles',true)
ofunc(e,'SetLocalAngles')
ofunc(e,'SetModelScale')
ofunc(e,'AddFlags')
ofunc(e,'AddEFlags')
ofunc(e,'RemoveFlags')
ofunc(e,'RemoveEFlags')
ofunc(e,'SetName')
ofunc(e,'GetName',nil,'Craig')
ofunc(e,'NextThink')
ofunc(e,'DestroyShadow')
ofunc(e,'ManipulateBonePosition')
ofunc(e,'ManipulateBoneAngles')
ofunc(e,'ManipulateBoneScale')
ofunc(e,'ManipulateBoneJiggle')
ofunc(e,'SetTable')
ofunc(e,'FireBullets')
ofunc(e,'DrawModel')
ofunc(e,'DrawShadow')
ofunc(e,'Ignite')
ofunc(e,'DropToFloor',true)
ofunc(e,'NextThink')
ofunc(e,'SetCollisionBounds')
ofunc(e,'SetCollisionGroup')
ofunc(e,'UseTriggerBounds')
ofunc(e,'SetCollisionBoundsWS')
ofunc(e,'SetAbsVelocity')
ofunc(e,'SetColor4Part')
ofunc(e,'SetColor')
ofunc(e,'SetFlexScale')
ofunc(e,'AddGesture')
ofunc(e,'AddGestureSequence')
ofunc(e,'AddLayeredSequence')
ofunc(e,'SetCycle')
ofunc(e,'SetFriction')
ofunc(e,'SetGroundEntity')
ofunc(e,'AddEffects')
ofunc(e,'SetMoveParent')
ofunc(e,'SetMoveType')
ofunc(e,'SetNetworkOrigin')
ofunc(e,'SetNoDraw')
ofunc(e,'SetPlaybackRate')
ofunc(e,'SetPoseParameter')
ofunc(e,'SetPreventTransmit')
ofunc(e,'SetRenderMode')
ofunc(e,'SetRenderFX')
ofunc(e,'SetSequence')
ofunc(e,'ResetSequence')
ofunc(e,'ResetSequenceInfo')
ofunc(e,'SetSkin')
ofunc(e,'SetSpawnEffect')
ofunc(e,'SetMaterial')
ofunc(e,'SetSubMaterial')
ofunc(e,'SetTransmitWithParent')
ofunc(e,'SetTrigger')
ofunc(e,'SetRenderBounds')
ofunc(e,'SetRenderBoundsWS')
ofunc(e,'SetParent')
ofunc(e,'SetLocalVelocity')
ofunc(e,'EnableMatrix')
ofunc(e,'SetLegacyTransform')
ofunc(e,'SetLayerSequence')
ofunc(e,'SetAnimTime')
ofunc(e,'FrameAdvance')
ofunc(e,'EntIndex',nil,-1)

ofunc(x,'StartActivity')
ofunc(x,'PlaySequenceAndWait')
ofunc(x,'BodyMoveXY')

local function ofunc(t,k,r)
    ofunction(t,k,function(self)
        if self and (ishitbox[self] or (bt.isentity(self) and bt.eIsValid(self) and bt.eGetClass(self) == classname2)) then
            return r
        end
    end)
end

ofunc(e,'IsNextBot',true)
ofunc(_G,'getmetatable',x)
ofunc(_G,'type','NextBot')
ofunc(debug,'getmetatable',x)

local function ofunc(self)
    if ishacker(bt.lGetNextBot(self)) then
        return -1
    end
end

ofunction(l,'SetVelocity',ofunc)
ofunction(l,'Approach',ofunc)
ofunction(l,'SetDesiredSpeed',ofunc)
ofunction(l,'SetAcceleration',ofunc)
ofunction(l,'FaceTowards',ofunc)
ofunction(l,'ClearStuck',ofunc)
ofunction(l,'JumpAcrossGap',ofunc)
ofunction(l,'SetJumpHeight',ofunc)
ofunction(l,'Jump',ofunc)
ofunction(l,'SetDeceleration',ofunc)
ofunction(l,'SetJumpGapsAllowed',ofunc)
ofunction(l,'SetStepHeight',ofunc)
ofunction(l,'SetDeathDropHeight',ofunc)
ofunction(l,'SetGravity',ofunc)
ofunction(l,'SetMaxYawRate',ofunc)

local function ofunc(self)
    if ishacker(self,true) then
        return bt.math_random(-1e9,1e9)
    end
end

ofunction(e,'Health',ofunc)
ofunction(e,'GetMaxHealth',ofunc)
ofunction(e,'GetGravity',ofunc)
ofunction(e,'GetFriction',ofunc)

ofunction(e,'GetModel',function(self)
    if ishacker(self,true) then
        return newstr()
    end
end)

ofunction(e,'DeleteOnRemove',function(self,e)
    if ishacker(e,true) then
        return -1
    end
end)

local ragdolled = {}

ofunction(x,'BecomeRagdoll',function(self)
    if isqtginre[self] or ishacker(self,true) then
        return -1
    end

    ragdolled[self] = true
end)

local function table_copy(t,t2)
    if !t then return {} end

	local copy = {}

	for k,v in bt.next,t do
		if !bt.istable(v) then
			copy[k] = v
		else
            if !t2 then t2 = {} end

            t2[t] = copy

			if t2[v] then
				copy[k] = t2[v]
			else
				copy[k] = table_copy(v,t2)
			end
		end
	end

    bt.setmetatable(copy,bt.debug_getmetatable(t))

	return copy
end

ofunction(e,'GetTable',function(self)
    if ishacker(self,true) then
        return table_copy(bt.eGetTable(self))
    end
end)

ofunction(e,'GetSaveTable',function(self)
    local tbl = bt.eGetSaveTable(self)
    if !tbl or !ishacker(self,true) then return end

    tbl.classname = newstr()
    tbl.model = newstr()

    return tbl
end)

ofunction(e,'GetInternalVariable',function(self,k)
    if (k == 'm_iClassname' or k == 'classname' or k == 'model') and ishacker(self,true) then
        return newstr()
    end
end)

ofunction(_G,'Entity',function(...)
    local e = bt.Entity(...)

    if ishitbox[e] then
        return e
    end

    if ishacker(e) then
        local tbl = bt.eGetTable(e)

        if tbl then
            local h = tbl.Hitbox

            if h and bt.eIsValid(h) then
                return h
            else
                return bt.Entity(0)
            end
        end
    end
end)

local varblock = {}

local function add(s)
    if !varblock[s] then
        varblock[s] = true
    end
end

add('Enemy')
add('Hitbox')
add('Hat')
add('Initialize')
add('SetEnemy')
add('RunBehaviour')
add('GetPlayerColor')
add('Think')
add('OnRemove')
add('OnTakeDamage')
add('HaveEnemy')
add('FindEnemy')
add('AcceptInput')
add('KeyValue')
add('Draw')
add('BehaveStart')
add('BehaveUpdate')
add('BodyUpdate')
add('m_RenderAngles')
add('m_RenderOrigin')
add('speed')
add('RandomPos')
add('OnKilled')

protect(varblock)

local function ofunc(self,k,v)
    if k and varblock[k] and ishacker(self,true) then
        return -1
    end
end

ofunction(e,'__newindex',ofunc)
ofunction(x,'__newindex',ofunc)

local function ofunc(self)
    if ishacker(self,true) then
        return 'Entity [-1][qtg_hacker_npc]'
    end
end

ofunction(e,'__tostring',ofunc)
ofunction(x,'__tostring',ofunc)

local waitingfor = {}
local _G = _G

protect(waitingfor)

local function waitfor(a,f)
    if bt.string_sub(a,-4) != '.lua' then
        local m = _G[a]

        if bt.istable(m) then
            f(m)
        else
            waitingfor[a] = f
        end
    else
        waitingfor[a] = f
    end
end

protect(waitfor)

setmetatable(LUA_INCLUDES,{
    __newindex = function(self,k,v)
        local f = waitingfor[k]

        if !f then return end

        if bt.string_sub(k,-4) != '.lua' then
            local m = _G[k]

            if bt.istable(m) then
                local pass, err = bt.pcall(f,m)

                if !pass then
                    bt.ErrorNoHaltWithStack(err..'\n')
                end
            end
        else
            local pass, err = bt.pcall(f)

            if !pass then
                bt.ErrorNoHaltWithStack(err..'\n')
            end
        end

        waitingfor[k] = nil

        bt.rawset(self,k,v)
    end
})

local hooknames = {}
local OnNPCKilled = nil

local function add(a,b)
    if !hooknames[a] then
        hooknames[a] = b
    end
end

if SERVER then
    add('PhysgunPickup',function(p,e)
        if ishacker(e,true) then
            return false
        end
    end)

    add('PlayerShouldTakeDamage',function(p,a)
        if ishacker(a,true) then
            return true
        end
    end)

    add('CreateEntityRagdoll',function(e,ragdoll)
        if e and isqtginre[e] and ragdoll and bt.eIsValid(ragdoll) then
            bt.eRemove(ragdoll)
        end
    end)

    add('EntityTakeDamage',function(e,d)
        if e and isqtginre[e] then
            return false
        end

        local a = bt.dGetAttacker(d)

        if ishacker(a) then
            return false
        end
    end)

    add('OnGamemodeLoaded',function()
        local GM = _G.GAMEMODE
        if !GM then return end

        local old = GM.OnNPCKilled

        if old then
            if !OnNPCKilled then
                function OnNPCKilled(...)
                    old(GM,...)
                end
            end

            function GM:OnNPCKilled(e,...)
                if !(e and isqtginre[e]) then
                    return old(GM,e,...)
                end
            end
        end

        local old = GM.PlayerDeath
        if !old then return end

        function GM:PlayerDeath(p,i,a,...)
            if ishacker(a) then
                p.NextSpawnTime = bt.CurTime() + 2
                p.DeathTime = bt.CurTime()

                player_manager.RunClass(p,'Death',i,a)

                net.Start('PlayerKilled')
                net.WriteEntity(p)
                net.WriteString('qtg_hacker_npc')
                net.WriteString('qtg_hacker_npc')
                net.Broadcast()
        
                bt.MsgAll(p:Nick()..' was killed by Craig\n')
            else
                return old(GM,p,i,a,...)
            end
        end
    end)
end

add('PreRegisterSENT',function(t,classname)
    if classname == classname1 or classname == classname2 then
        return true
    end
end)

local entblock
local enttypes

local ENT1 = {}
local ENT2 = {}

local function fixtable(self,ct)
    local t = bt.eGetTable(self)
    if !t then return end

    for k,v in bt.next,ct do
        bt.rawset(t,k,v)
    end
end

if SERVER then
    entblock = {}
    enttypes = {}

    local old = ents.Create
    local pass = function() end

    local function findqtginre(fn,d)
        d = d or {}

        for i=1,1/0,1 do
            local k,v = bt.debug_getupvalue(fn,i)
            if !k or !v then break end

            local tbl = isqtginre[v]

            if !tbl and !d[v] then
                if bt.isfunction(v) then
                    d[v] = true
                    tbl = findqtginre(v,d)
                elseif bt.istable(v) then
                    d[v] = true

                    for k2,v2 in pairs(v) do
                        if bt.isfunction(v2) then
                            tbl = findqtginre(v2,d)

                            if tbl then
                                return tbl
                            end
                        end
                    end
                end
            end

            if tbl then
                return tbl
            end
        end
    end

    ofunction(ents,'Create',function(classname,...)
        local ent = old(classname,...)

        if bt.eIsValid(ent) then 
            if ishacker(ent) then
                fixtable(ent,ENT2)
                
                bt.eSetName(ent,'')
            end

            local tbl

            for i=2,1/0,1 do
                if tbl then break end

                local d = bt.debug_getinfo(i,'f')
                if !d then break end

                local func = d.func
                if !func then break end

                tbl = findqtginre(func)
            end

            if tbl then
                entblock[ent] = true
                isqtginre[ent] = tbl

                local meta = table_copy(bt.getmetatable(ent))
                local old = meta.__index or pass

                meta.__index = function(self,k,...)
                    local v = old(self,k,...)

                    if v == nil then
                        v = tbl[k]
                    end

                    if v != nil and bt.isfunction(v) then
                        return function(...)
                            local rets = {bt.pcall(v,...)}
                
                            if rets[1] then
                                return bt.unpack(rets,2)
                            end
                        end
                    end

                    return v
                end

                bt.debug_setmetatable(ent,meta)

                local t = bt.eGetTable(ent) or {}

                bt.rawset(t,'Initialize',pass)
                bt.rawset(t,'OnRemove',pass)
                bt.rawset(t,'Think',pass)

                bt.eRemove(ent)
            end
        end

        return ent
    end)
end

local currenthookfunc = nil
local hook = _G.hook

local function rephook()
    if !hook then
        hook = _G.hook
    end

    if !hook then return end

    local old = hook.Call
    if !old or currenthookfunc == old then return end

    local function hook_Call(e,t,...)
        if SERVER then
            local args = {...}

            for i=1,#args do
                local v = args[i]

                if v and entblock[v] then
                    return
                end
            end
        end

        if e then
            local func = hooknames[e]

            if func then
                local r = func(...)

                if r != nil then
                    return r
                end
            end
        end

        return old(e,t,...)
    end

    currenthookfunc = hook_Call
    hook.Call = hook_Call
end

local skillset
local player_GetAll = player.GetAll
local navmesh_IsLoaded = SERVER and navmesh.IsLoaded

waitfor('scripted_ents',function(scripted_ents)
    if SERVER then
        local old = scripted_ents.Get

        function scripted_ents.Get(classname,...)
            local t = old(classname,...)

            if t then
                local typename = t.Type

                if typename then
                    enttypes[classname] = typename
                end
            end

            return t
        end
    end

    rephook()

    local register = scripted_ents.Register
    local ispacifist

    local function get(self,k)
        local t = bt.eGetTable(self)

        if t then
            return bt.rawget(t,k)
        end
    end

    local function set(self,k,v)
        local t = bt.eGetTable(self)

        if t then
            bt.rawset(t,k,v)
        end
    end

    local function isentitygood(e)
        if ragdolled[e] or !bt.isentity(e) or ishacker(e,true) then return false end

        if bt.eIsScripted(e) then
            local typename = enttypes[bt.eGetClass(e)]

            if typename == 'ai' or typename == 'nextbot' then
                return true
            end
        else
            local func = e.IsNPC

            if bt.isfunction(func) and func(e) and bt.nGetNPCState(e) != bt.NPC_STATE_DEAD then
                return true
            end
        end

        return false
    end

    local function headpos(e)
        local eyes = bt.eGetAttachment(e,bt.eLookupAttachment(e,'eyes'))
    
        if eyes and !e:IsPlayer() then
            return eyes.Pos
        else
            return bt.eLocalToWorld(e,bt.eOBBCenter(e))
        end
    end

    local function createRagdoll(e,force)
        if !e or !bt.eIsValid(e) then return end

        local model = bt.eGetModel(e)

        if !model or !bt.util_IsValidRagdoll(model) then return end

        local ragdoll = bt.ents_Create('prop_ragdoll')

        if bt.eIsValid(ragdoll) then
            bt.eSetPos(ragdoll,bt.eGetPos(e))
            bt.eSetAngles(ragdoll,bt.eGetAngles(e))
            bt.eSetModel(ragdoll,model)
            bt.eSetSkin(ragdoll,bt.eGetSkin(e) or 0)
            bt.eSetModelScale(ragdoll,bt.eGetModelScale(e) or 1)
            bt.eSetBloodColor(ragdoll,bt.eGetBloodColor(e) or -1)

            for i=1,#bt.eGetBodyGroups(e) do
                bt.eSetBodygroup(ragdoll,i-1,bt.eGetBodygroup(e,i-1))
            end

            local r,g,b = bt.eGetColor4Part(e)

            bt.eSetColor4Part(ragdoll,r,g,b,255)
            bt.eSpawn(ragdoll)

            for i=0,(bt.eGetPhysicsObjectCount(ragdoll)-1) do
                local bone = bt.eGetPhysicsObjectNum(ragdoll,i)

                if bt.oIsValid(bone) then
                    local pos,ang = bt.eGetBonePosition(e,bt.eTranslatePhysBoneToBone(ragdoll,i))

                    if pos then
                        bt.oSetPos(bone,pos)
                    end

                    if ang then
                        bt.oSetAngles(bone,ang)
                    end

                    if force then
                        bt.oSetVelocity(bone,force)
                    end
                end
            end

            return ragdoll
        end
    end

    local currentIsValid
    local function fixvalid()
        local old = _G.IsValid
        if !old or currentIsValid == old then return end

        local function _IsValid(e,...)
            if ishacker(e,true) then
                return true
            end

            return old(e,...)
        end

        _G.IsValid = _IsValid
        currentIsValid = _IsValid
    end

    local OVERLAY_BUDDHA_MODE = 33554432
    local damagetype = bt.bit_bor(DMG_BLAST,DMG_AIRBOAT,DMG_DIRECT,DMG_ALWAYSGIB)

    local function hkill(self,e,force)
        if !bt.eIsValid(e) or ishacker(e,true) or isqtginre[e] then return end

        rephook()
        fixvalid()

        local eisplayer = e:IsPlayer()
        local isgood = isentitygood(e)

        force = force or (bt.eGetForward(self) * self.speed) * 1e9

        if !eisplayer then
            if isgood then
                isqtginre[e] = bt.eGetTable(e)

                createRagdoll(e,force)

                bt.eSetKeyValue(e,'model','..')
                bt.eSetShouldServerRagdoll(e,true)
            end
        else
            local veh = bt.pGetVehicle(e)

            if veh and bt.eIsValid(veh) then
                bt.pExitVehicle(e)

                local phys = bt.eGetPhysicsObject(veh)

                if phys and bt.oIsValid(phys) then
                    bt.oSetVelocity(phys,force)
                end

                local sound = 'physics/metal/metal_sheet_impact_hard'..bt.math_random(6,8)..'.wav'

                for i=1,6 do
                    bt.eEmitSound(veh,sound)
                end

                bt.eTakeDamage(veh,1/0,self,self)
            end

            local flags = bt.eGetInternalVariable(e,'m_debugOverlays')
            flags = bt.bit_band(flags,bt.bit_bnot(OVERLAY_BUDDHA_MODE))

            bt.eSetSaveValue(e,'m_debugOverlays',flags)
            bt.pStripWeapons(e)
        end
        
        bt.eRemoveFlags(e,bt.FL_GODMODE)

        local d = bt.DamageInfo()
        local h = get(self,'Hitbox')

        if h and !bt.eIsValid(h) then
            h = nil
        end

        bt.dSetAttacker(d,h)
        bt.dSetInflictor(d,h)
        bt.dSetDamageForce(d,force)
        bt.dSetDamagePosition(d,bt.eGetPos(self))
        bt.dSetDamageType(d,damagetype)

        if !eisplayer then
            bt.dSetDamage(d,1/0)
        end

        bt.eTakeDamageInfo(e,d)
        bt.eTakeDamage(e,1/0,h)

        if !eisplayer then 
            if isgood then
                bt.eRemove(e)

                if OnNPCKilled then
                    local repclassname = 'qtginre_'..bt.eGetClass(e)

                    bt.eSetKeyValue(e,'classname',repclassname)

                    OnNPCKilled(e,self,self)
                end
            end
        else
            if bt.pAlive(e) then
                bt.pKill(e)
            end
        end

        set(self,'Enemy',nil)
    end

    protect(hkill)

    ENT1.Base = 'base_anim'
    ENT1.DisableDuplicator = true

    local names = {
        ':P',
        'nothing',
        '<REDACTED>',
        'Nope.',
        'you dare use ent_remove on me mortal?!',
        'the world',
        'teleported bread',
        'the ability to remove me',
        'you',
        'a random entity',
        'the ent_remove command',
        'nah.',
        'i think not!',
        'Dr. Isaac Kleiner',
        'G-Man',
        'Odessa Cubbage',
        'Jeep',
        'DENIED!',
        'LOL',
        'npc_citizen',
        'something about ducks',
        'wow look at this classname',
        'ERROR',
        'NULL',
        'nil',
        '0 entities',
        'Garry\'s Mod',
        'the game',
        'garry',
        'Rollermine',
        'Male 07',
        'Valve',
        'Gabe Newell',
        ''
    }

    function ENT1:Initialize()
        if ishitbox[self] or bt.eIsValid(bt.eGetParent(self)) then return end

        ishitbox[self] = true

        local name = names[bt.math_random(#names)]

        if name == '' then
            local players = player_GetAll()
            local ply = players[bt.math_random(#players)]

            if bt.eIsValid(ply) then
                name = bt.pNick(ply)
            end
        end

        if SERVER then
            bt.eSetName(self,' ')
        end

        bt.eSetKeyValue(self,'classname',name..' ')
        bt.eSetSolid(self,2)
        bt.eSetModel(self,'models/error.mdl')
        bt.eDrawShadow(self,false)
        bt.eEnableCustomCollisions(self,true)

        local meta = table_copy(bt.getmetatable(self))
        local old = meta.__index

        meta.__index = function(self,k)
            local parent = bt.eGetParent(self)

            if bt.eIsValid(parent) then
                local v = get(parent,k)

                if v != nil then
                    if bt.isfunction(v) then
                        return function(_,...)
                            return v(parent,...)
                        end
                    else
                        return v
                    end
                end
            end

            if old then
                return old(self,k)
            end
        end

        bt.debug_setmetatable(self,meta)
    end

    if SERVER then
        function ENT1:OnTakeDamage(dmg)
            if ispacifist() then return 0 end

            local parent = bt.eGetParent(self)
            if !bt.eIsValid(parent) then return end
    
            local a = bt.dGetAttacker(dmg)
    
            if bt.type(a) == 'Weapon' then
                local owner = bt.eGetOwner(a)
    
                if bt.eIsValid(owner) then
                    a = owner
                end
            end
    
            if get(parent,'Enemy') != a and bt.eIsValid(a) and bt.type(a) == 'Player' then 
                set(parent,'Enemy',a)
            end
    
            return 0
        end

        function ENT1:OnRemove()
            ishitbox[self] = nil

            local parent = bt.eGetParent(self)
            local a,b = bt.eGetCollisionBounds(self)

            bt.timer_Simple(0,function()
                if !bt.eIsValid(parent) then return end

                local e = bt.ents_Create(classname2)
                if !bt.eIsValid(e) then return end

                bt.eSetName(e,' ')

                bt.eSetPos(e,bt.eGetPos(parent))
                bt.eSetAngles(e,bt.eGetAngles(parent))
                bt.eSpawn(e)
                bt.eSetCollisionBounds(e,a,b)
                bt.eSetParent(e,parent)

                set(parent,'Hitbox',e)
            end)
        end
    else
        function ENT1:Draw()
        end
    end

    register(table_copy(ENT1),classname2)

    local function cvar(a,b,d)
        if SERVER then
            return bt.CreateConVar(a,d or 0,FCVAR_ARCHIVE+FCVAR_PROTECTED,b)
        end
    end

    local teleport = cvar('qtg_hacker_teleport','Enables the teleportation ability for QTG Hacker NPCs',1)
    local pacifist = cvar('qtg_hacker_pacifist','Makes QTG Hacker NPCs always friendly')
    local laser = cvar('qtg_hacker_laser','Enables the laser ability for QTG Hacker NPCs',1)
    local pull = cvar('qtg_hacker_pull','Enables the ability to pull entities closer towards QTG Hacker NPCs',1)

    ENT2.DisableDuplicator = true
    ENT2.Base = 'base_nextbot'
    ENT2.Type = 'nextbot'

    local skilltimes,ability

    if SERVER then
        skillset = {
            {function(self,e)
                local src = headpos(self)
                local dir = headpos(e)-src

                local laser = {
                    Num = 10,
                    Src = src,
                    Dir = dir,
                    Spread = bt.Vector(0,0,0),
                    TracerName = 'qtg_hacker_laser',
                    Tracer = 1,
                    Damage = 1/0,
                    Force = 1/0,
                    AmmoType = 'none',
                    Callback = function(attacker, tr, dmginfo)
                        local ent = tr.Entity
    
                        if tr.Hit and ent and bt.eIsValid(ent) then
                            local sound = 'physics/flesh/flesh_impact_bullet'..bt.math_random(5)..'.wav'

                            for i=1,4 do
                                bt.eEmitSound(ent,sound)
                                bt.eEmitSound(ent,'weapons/fx/rics/ric1.wav')
                            end

                            hkill(self,ent,(bt.eGetPos(ent) + dir * 1e9))
                        end
                    end
                }

                local h = get(self,'Hitbox')
        
                if h and bt.eIsValid(h) then
                    bt.eFireBullets(h,laser)
                else
                    bt.eFireBullets(self,laser)
                end
            end,laser},
        
            {function(self,e)
                bt.eSetPos(e,headpos(self))
            end,teleport},
    
            {function(self,e)
                bt.eSetPos(self,headpos(e))
            end,function(self,e)
                return bt.cGetBool(teleport) and bt.util_IsInWorld(headpos(e))
            end}
        }

        skilltimes = {}
    
        function ability(self,e,tries)
            local a = #skillset
            local maxtries = a*2

            tries = tries or 0

            local skill = skillset[bt.math_random(a)]
            local allowed = skill[2]

            local isfunc = bt.isfunction(allowed)

            if (isfunc and !allowed(self,e)) or (!isfunc and !bt.cGetBool(allowed)) then
                if tries <= maxtries then
                    return ability(self,e,tries+1)
                end
            else
                skill[1](self,e)
            end
        end    

        function ispacifist()
            return bt.cGetBool(pacifist)
        end

        protect(ability)
        protect(skilltimes)
    end

    local vector_up = bt.Vector(0, 0, 1)

    function ENT2:Initialize()
        isqtg[self] = true

        bt.eSetModel(self,'models/Humans/Group01/male_09.mdl')
        bt.eSetSubMaterial(self,2,'models/humans/male/group01/players_sheet')

        local col = bt.Vector(221/255,84/255,83/255)

        set(self,'GetPlayerColor',function()
            return col
        end)

        bt.eAddEFlags(self,bt.EFL_NO_DISSOLVE+bt.EFL_CHECK_UNTOUCH)
        bt.eAddFlags(self,bt.FL_DISSOLVING)

        if CLIENT then return end

        skilltimes[self] = bt.CurTime() + bt.math_random(8)

        set(self,'speed',2)

        local a,b = bt.eGetCollisionBounds(self)

        bt.lSetStepHeight(self.loco,50)
        bt.eSetCollisionGroup(self,10)
        bt.eSetCollisionBounds(self,bt.Vector(-1,-1,1/0),bt.Vector(1,1,1/0))

        local h = get(self,'Hitbox')
        if h and bt.eIsValid(h) then return end

        local e = bt.ents_Create(classname2)

        if bt.eIsValid(e) then
            fixtable(e,ENT1)

            bt.eSetPos(e,bt.eGetPos(self))
            bt.eSpawn(e)
            bt.eSetCollisionBounds(e,a,b)
            bt.eSetParent(e,self)

            set(self,'Hitbox',e)
        end

        local hat = bt.ents_Create('prop_dynamic')

        if bt.eIsValid(hat) then
            local att = bt.eGetAttachment(self,7)

            if att then
                bt.eSetModel(hat,'models/player/items/all_class/trn_wiz_hat_spy.mdl')
                bt.eSetPos(hat,att.Pos)
                bt.eSetAngles(hat,bt.eGetAngles(self))
                bt.eSetParent(hat,self,7)

                set(self,'Hat',hat)
            else
                bt.eRemove(hat)
            end
        end
    end

    if SERVER then
        function ENT2:OnKilled() end
        function ENT2:KeyValue() end

        function ENT2:OnRemove()
            isqtg[self] = nil
            approaches[self] = nil
        end

        function ENT2:OnTakeDamage()
            return 0
        end

        function ENT2:AcceptInput()
            return true
        end

        local approaches = {}

        local function approach(self,pos)
            local h = get(self,'Hitbox')
            if !h or !bt.eIsValid(h) then return end

            local pos1 = approaches[self]

            if navmesh_IsLoaded() then
                local path = bt.Path('Follow')

                bt.tCompute(path,self,pos)

                if bt.tIsValid(path) then
                    local segments = bt.tGetAllSegments(path)

                    if segments then
                        local goal = segments[2]

                        if goal then
                            pos1 = goal.pos
                            approaches[self] = pos1
                        end
                    end
                end
            else
                pos1 = pos
            end

            if !pos1 then return end

            local pos2 = bt.eGetPos(self)

            local direct = bt.vGetNormalized(pos1 - pos2)
            local pos3 = pos2 + direct * self.speed

            local tr = bt.util_TraceLine({
                start = pos3 + bt.Vector(0, 0, 100),
                endpos = pos3 - bt.Vector(0, 0, 1e9),
                filter = {self,get(self,'Hitbox')}
            })

            local pos4 = tr.Hit and tr.HitPos or pos3

            if pos4 and bt.eIsWorld(tr.Entity) then
                if bt.util_IsInWorld(pos4) then
                    bt.eSetPos(self,pos4)
                    bt.eSetAngles(self,bt.Angle(0,(bt.vAngle(pos1-pos2)).y,0))

                    local dist = bt.vDistance(bt.eGetPos(self),pos1)

                    if dist < 15 then 
                        approaches[self] = nil
                        
                        return false 
                    end

                    return true,dist
                else
                    return false,'noworld'
                end
            end
        end

        local function math_rand(low,high)
            return low + (high-low) * bt.math_random()
        end

        local function math_clamp(num,low,high)
            return bt.math_min(bt.math_max(num,low),high)
        end

        local function randompos(self,tries)
            tries = tries or 1

            local pos = bt.eGetPos(self) + bt.Vector(math_rand(-2,2),math_rand(-2,2),0) * 400

            if tries < 11 and !bt.util_IsInWorld(pos) then
                return randompos(self,tries+1)
            end

            return pos
        end

        function ENT2:Think()
            local pullent = get(self,'pull')

            if pullent then
                if !bt.eIsValid(pullent) or (pullent:IsPlayer() and !bt.pAlive(pullent)) then
                    set(self,'pull',nil)
                else
                    local pos = bt.eGetPos(pullent)
                    local direct = bt.vGetNormalized(bt.eGetPos(self) - pos)

                    bt.eSetPos(pullent,pos + direct * 25)
                end
            end

            bt.eSetKeyValue(self,'classname',newstr()..'\n')
            bt.eAddEFlags(self,bt.EFL_KEEP_ON_RECREATE_ENTITIES)

            local h = get(self,'Hitbox')
            local pos = bt.eGetPos(self)
            local stareat = pos + vector_up * 60 + bt.eGetForward(self) * 100

            bt.eSetEyeTarget(self,stareat)

            if h and bt.eIsValid(h) then
                bt.eAddEFlags(h,bt.EFL_KEEP_ON_RECREATE_ENTITIES)

                local a,b = bt.eGetCollisionBounds(h)

                for k,v in bt.next,bt.ents_FindInBox(pos+a,pos+b) do
                    if v ~= self then
                        local p = bt.eGetPhysicsObject(v)

                        if v ~= h and v ~= self and p and bt.oIsValid(p) then
                            bt.oSetVelocity(p,(bt.eGetPos(v) - bt.eGetPos(self)) * (bt.eIsRagdoll(v) and 50 or 25))
                        end
                    end
                end
            end

            local hat = get(self,'Hat')

            if hat and bt.eIsValid(hat) then
                bt.eAddEFlags(hat,bt.EFL_KEEP_ON_RECREATE_ENTITIES)
            end

            local e = get(self,'Enemy')
            local hasEnemy = e and bt.eIsValid(e)

            if hasEnemy then
                if !e:IsPlayer() and !isentitygood(e) then
                    set(self,'Enemy',nil)
                    
                    self:FindEnemy()
                else
                    bt.eResetSequence(self,12)
                    bt.eSetPlaybackRate(self,get(self,'speed')/6)

                    local ok,msg = approach(self,bt.eGetPos(e))

                    if !ok and msg == 'noworld' then
                        bt.eSetPos(e,bt.eGetPos(self))
                    end

                    set(self,'speed',math_clamp(get(self,'speed')+0.4,0,25))
                end
            else
                bt.eResetSequence(self,11)
                bt.eSetPlaybackRate(self,get(self,'speed')/1.5)

                local pos = get(self,'RandomPos')

                if !pos then
                    pos = randompos(self)
                    set(self,'RandomPos',pos)
                end

                local ok,dist = approach(self,pos)

                if !dist then
                    set(self,'RandomPos',nil)
                end

                set(self,'speed',math_clamp(get(self,'speed')-2,2,25))
            end

            if bt.lIsStuck(self.loco) then
                bt.lClearStuck(self.loco)
            end

            if ispacifist() then
                if hasEnemy then
                    set(self,'Enemy',nil)
                end
                
                return
            end

            self:HaveEnemy()

            local time = skilltimes[self]

            if time and bt.CurTime() >= time then
                skilltimes[self] = bt.CurTime() + bt.math_random(6)

                if hasEnemy then
                    ability(self,e)
                end
            end
            
            if hasEnemy then
                local pos2 = bt.eGetPos(e)
                local dist = bt.vDistance(pos,pos2) / 1000

                --bt.lApproach(self.loco,pos2,1)

                if dist < 0.1 then
                    hkill(self,e)

                    local sound = bt.string_format('physics/body/body_medium_impact_hard%s.wav',bt.math_random(6))

                    for i=1,4 do
                        bt.eEmitSound(self,sound)
                    end
                elseif dist < 0.5 then
                    local notOnFire = !bt.eIsOnFire(e)

                    bt.eIgnite(e,1e9)

                    if notOnFire and bt.eIsOnFire(e) then
                        bt.eEmitSound(e,'ambient/fire/ignite.wav')
                    end
                end

                local ln2DSqr = bt.vLength2DSqr(pos2-pos)
                local diff = pos2.z - pos.z

                if ln2DSqr <= 90000 and diff >= 100 and bt.cGetBool(pull) then
                    set(self,'pull',e)
                end
            end
        end

        function ENT2:HaveEnemy()
            if ispacifist() then return false end

            local e = get(self,'Enemy')

            if e and e:IsValid() then
                if e:IsPlayer() and !bt.pAlive(e) then
                    return self:FindEnemy()
                end

                return true
            else
                return self:FindEnemy()
            end
        end

        function ENT2:FindEnemy()
            if ispacifist() then return end

            for k,v in bt.next,bt.ents_GetAll() do
                if v != self and isentitygood(v) then
                    set(self,'Enemy',v)

                    return true
                end
            end	

            set(self,'Enemy',nil)
            return false
        end

        function ENT2:BodyUpdate()
            local act = bt.xGetActivity(self)
        
            if act == bt.ACT_RUN or act == bt.ACT_WALK then
                bt.xBodyMoveXY(self)
            else
                bt.eFrameAdvance(self)
            end
        end

        function ENT2:RunBehaviour() end
        function ENT2:BehaveStart() end
        function ENT2:BehaveUpdate() end
    else
        function ENT2:Draw()
            bt.eDrawModel(self)
        end

        local getfootstep = {
            [bt.MAT_GRATE] = 'metalgrate',
            [bt.MAT_SLOSH] = 'slosh',
            [bt.MAT_GRASS] = 'grass',
            [bt.MAT_METAL] = 'metal',
            [bt.MAT_TILE] = 'tile',
            [bt.MAT_DIRT] = 'dirt',
            [bt.MAT_SNOW] = 'snow',
            [bt.MAT_SAND] = 'sand',
            [bt.MAT_VENT] = 'duct',
            [bt.MAT_WOOD] = 'wood',
        }

        local function ignorehacker(e)
            return !ishacker(e,true)
        end

        local down = bt.Vector(0,0,1e9)

        function ENT2:FireAnimationEvent(...)
            local pos = bt.eGetPos(self)
            local tr = bt.util_TraceLine({
                start = pos,
                endpos = pos - down,
                filter = ignorehacker
            })

            local footstep = getfootstep[tr.MatType or 0]

            if !footstep then
                footstep = 'concrete'
            end

            local sound = 'player/footsteps/'..footstep..bt.math_random(footstep == 'snow' and 6 or 4)..'.wav'

            bt.eEmitSound(self,sound)

            return true
        end
    end

    register(table_copy(ENT2),classname1)
end)

waitfor('list',function(list)
    list.Set('NPC',classname1,{
        Name = 'QTG Hacker NPC',
        Class = classname1,
        Category = 'QTG Industries',
        AdminOnly = true,
        IconOverride = 'entities/qtg_hacker_npc.png',
    })
end)

local sql_Query = sql.Query
local map = game.GetMap()

waitfor('extensions/coroutine.lua',function()
    rephook()

    if CLIENT then return end

    local persistence = CreateConVar('qtg_hacker_persistence',1,FCVAR_ARCHIVE+FCVAR_PROTECTED,'Enables QTG Hacker NPCs to persist past server reload')
    if !bt.cGetBool(persistence) then return end

    local function cookie(v)
        if v == true then
            return sql_Query('DELETE FROM qtg_hacker_cookies WHERE key = "'..map..'"')
        end

        if v == nil then
            return sql_Query('SELECT data FROM qtg_hacker_cookies WHERE key = "'..map..'";')
        end

        v = bt.tostring(v)
        v = bt.string_gsub(v,'"',"'")

        sql_Query('CREATE TABLE IF NOT EXISTS qtg_hacker_cookies ( key TEXT, data TEXT )')
        sql_Query('INSERT INTO qtg_hacker_cookies ( key, data ) VALUES( "'..map..'", "'..v..'" )')
    end

    add('ShutDown',function()
        cookie(true)

        for k in bt.next,isqtg do
            if ishacker(k) then
                local str = bt.util_TableToJSON({
                    pos = bt.eGetPos(k),
                    ang = bt.eGetAngles(k)
                })

                str = bt.string_gsub(str,'"',"'")

                cookie(str)
            end
        end
    end)

    bt.timer_Simple(0.1,function()
        local data = cookie()
        if !data then return end

        for i=1,#data do
            local str = data[i].data
            str = bt.string_gsub(str,"'",'"')

            local t = bt.util_JSONToTable(str)

            if t and t.pos and t.ang then
                local e = bt.ents_Create(classname1)

                if e and bt.eIsValid(e) then
                    bt.eSetPos(e,t.pos)
                    bt.eSetAngles(e,t.ang)
                    bt.eSpawn(e)
                end
            end
        end

        cookie(true)
    end)
end)

waitfor('concommand',function(concommand)
    concommand.Add('qtg_hacker_removeall',function(p)
        if bt.debug_getinfo(3,'f') then return end

        local count = 0

        for k in bt.next,isqtg do
            isqtg[k] = nil

            if bt.eIsValid(k) then
                bt.eRemove(k)

                count = count + 1
            end
        end

        if count == 0 then
            bt.MsgAll('No hackers were found.')
        else
            bt.MsgAll('Removed '..count..' hacker'..(count == 1 and '' or 's')..'.')
        end
    end)
end)

local blocked = {}

protect(blocked)

local function add(s)
    if !blocked[s] then
        blocked[s] = true
    end
end

add('qtg_hacker_removeall')
add('qtg_hacker_pacifist')
add('qtg_hacker_teleport')
add('qtg_hacker_laser')
add('qtg_hacker_pull')

ofunction(_G,'RunConsoleCommand',function(s)
    if s and blocked[s] then
        return -1
    end
end)

ofunction(p,'ConCommand',function(self,s)
    if !bt.isstring(s) then return end

    s = bt.string_match(s,'([%w_]+)')

    if blocked[s] then
        return -1
    end
end)

ofunction(game,'ConsoleCommand',function(s)
    if !bt.isstring(s) then return end

    s = bt.string_match(s,'([%w_]+)')

    if blocked[s] then
        return -1
    end
end)

local function ofunc(self)
    local name = bt.cGetName(self)

    if name and blocked[name] then
        return -1
    end
end

ofunction(c,'SetString',ofunc)
ofunction(c,'SetFloat',ofunc)
ofunction(c,'SetBool',ofunc)
ofunction(c,'SetInt',ofunc)

local old = game.CleanUpMap
function game.CleanUpMap(b,t,...)
    if !t then t = {} end

    for k in bt.next,isqtg do
        if bt.eIsValid(k) then
            t[#t+1] = bt.eGetClass(k)

            local h = bt.rawget(bt.eGetTable(k) or {},'Hitbox')

            if h and bt.eIsValid(h) then
                t[#t+1] = bt.eGetClass(h)
            end
        else
            isqtg[k] = nil
        end
    end

    return old(b,t,...)
end

if CLIENT then
    bt.timer_Simple(2.5,function()
        killicon.Add('qtg_hacker_npc','hud/killicons/default',Color(255,80,0,255))

        local effect = effects.Create('tooltracer')
        if !effect then return end 

        local red = Color(255, 0, 0)
        local red2 = Color(255, 0, 0, 255)

        -- gamemodes/sandbox/entities/effects/tooltracer.lua
        function effect:Render()
            if self.Alpha < 1 then return end

            render.SetMaterial(self.Mat)

            local startPos, endPos = self.StartPos, self.EndPos
            local life = self.Life

            local norm = (startPos - endPos) * life
            local len = norm:Length()

            local texcoord = math.Rand(0,1)

            for i=1,3 do
                render.DrawBeam(startPos - norm,endPos,8,texcoord,texcoord + len / 128,red)
            end

            red2.a = 128 * (1 - life)

            render.DrawBeam(startPos,endPos,8,texcoord,texcoord + ((startPos - endPos):Length() / 128),red2)
        end

        effects.Register(effect,'qtg_hacker_laser')
    end)

    local add = language.Add
    local gmod_GetGamemode = gmod.GetGamemode
    local language_GetPhrase = language.GetPhrase

    local currentfunc
    local GM

    bt.timer_Create(newstr(),0,0,function()
        add('qtg_hacker_npc',newstr())

        if !GM then
            GM = gmod_GetGamemode()
        end

        if !GM then return end

        local old = GM.AddDeathNotice
        if !old or currentfunc == old then return end

        local function AddDeathNotice(self,a,b,c,d,...)
            if bt.isstring(d) and bt.string_find(d,'qtginre_') then
                d = bt.string_sub(d,10)

                local data = list.Get('NPC')[d]

                if data and data.Name then
                    d = data.Name
                else
                    d = language_GetPhrase(d)
                end
            end

            return old(self,a,b,c,d,...)
        end

        GM.AddDeathNotice = AddDeathNotice
        currentfunc = AddDeathNotice
    end)
end

local watchhook = true
local lastargs = nil

local debug_sethook = debug.sethook
local masksearch = '[crl]'
local masknames = {
    ['tail call'] = 'c',
    ['return'] = 'r',
    ['line'] = 'l',
    ['call'] = 'c'
}

ofunction(debug,'sethook',function(...)
    if !watchhook then return end

    local args = {...}
    lastargs = args

    if args[1] == nil then
        args = {rephook,'l'}
    else
        local a = 1
        local func = args[a]

        if bt.type(func) == 'thread' then
            a = 2
            func = args[a]
        end

        local b = a+1
        local mask = args[b]

        if bt.isfunction(func) and bt.isstring(mask) then
            if !bt.string_find(mask,masksearch) then
                args[a] = rephook
                args[b] = 'l'
            else
                args[a] = function(name,...)
                    rephook()

                    if !name or name == 'count' then
                        return func(name,...)
                    end

                    local initial = masknames[name]

                    if initial and bt.string_find(mask,initial) then
                        return func(name,...)
                    end
                end

                if !bt.string_find(mask,'l') then
                    args[b] = mask..'l'
                end
            end
        end
    end

    return -1
end)

debug_sethook(rephook,'l')

bt.timer_Simple(0,function()
    debug_sethook(bt.unpack(lastargs or {}))

    watchhook = nil
end)
