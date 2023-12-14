local args = {...}
local hacker = args[1]
local hackerkilled = args[2]

local Enemy = args[3]
local workshop = args[4]

local class = hacker.classname
local IsValid = hacker.__IsValid

local pacifist = CreateConVar('qtg_hacker_pacifist', 0, 128, 'Toggle if QTG Hacker NPCS should not attack.')
local uselaser = CreateConVar('qtg_hacker_uselaser', 1, 128, 'Toggle if QTG Hacker NPCS are allowed to use their laser attack.')
local firlaser = CreateConVar('qtg_hacker_usefirelaser', 1, 128, 'Toggle if QTG Hacker NPCS are allowed to use their fire laser attack.')
local allowjump = CreateConVar('qtg_hacker_allowjump', 1, 128, 'Toggle if QTG Hacker NPCS are allowed to jump.')
local allowteleport = CreateConVar('qtg_hacker_allowteleport', 1, 128, 'Toggle if QTG Hacker NPCS are allowed to use their teleport ability.')
local deflect = CreateConVar('qtg_hacker_deflect', 1, 128, 'Toggle if QTG Hacker NPCS are allowed to use their deflect ability.')
--local takeweps = CreateConVar('qtg_hacker_takeweapons', 1, 128, "Toggle if QTG Hacker NPCS are allowed to use take enemy players' weapons")

local ents_getall = ents.GetAll
local string_format = string.format
local math_random = math.random
local string_sub = string.sub
local string_gsub = string.gsub
local math_random = math.random
local string_char = string.char

local gstrbase = 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx'
gstrbase = gstrbase .. gstrbase .. gstrbase .. gstrbase

local function ValidEnemy(ent)
    return (ent:IsNPC() or ent:IsNextBot()) and (!hacker.ishacker(ent) and IsValid(ent))
end

local function DrGSafeRemove(ent)
	if !DrGBase or !isfunction(DrGBase.GetNextbots) or type(ent) ~= "NextBot" then return end
	table.RemoveByValue(DrGBase.GetNextbots(), ent)
end

local function obfustring(len, min, max)
    local str = gstrbase
    str = string_sub(str, 1, (len or 25))

    str = string_gsub(str, 'x', function()
        return string_char(math_random(min or 32, max or 164))
    end)

    return str
end

local function headpos(ent)
	if !IsValid(ent) then return end
	
    local model = ent:GetModel() or ""
    local eyes = ent:GetAttachment(ent:LookupAttachment("eyes"))

    if eyes then
        return eyes.Pos
    else
        return ent:LocalToWorld(ent:OBBCenter())
    end
end

local function CreateEntityRagdoll(ent, force)
    if !IsValid(ent) then return end
    
	local model = ent:GetModel()
    if model and util.IsValidRagdoll(model) then
        local ragdoll = ents.Create("prop_ragdoll")
        ragdoll:SetModel(model)
        ragdoll:SetPos(ent:GetPos())
        ragdoll:SetAngles(ent:GetAngles())
		ragdoll:SetBloodColor(ent:GetBloodColor())
		ragdoll:SetModelScale(ent:GetModelScale())
		ragdoll:SetMaterial(ent:GetMaterial())
		ragdoll:SetSkin(ent:GetSkin() or 0)
        ragdoll:Spawn()
    
        for i = 0, ragdoll:GetPhysicsObjectCount()-1 do
            local bone = ragdoll:GetPhysicsObjectNum(i)
            local pos, ang = ent:GetBonePosition(ragdoll:TranslatePhysBoneToBone(i))

            if !IsValid(bone) then continue end
            bone:SetAngles(ang)
            bone:SetPos(pos)

			if force then
				bone:SetVelocity(force)
			end
        end
    end
end

local hatslist = {
	{model = "models/player/items/all_class/trn_wiz_hat_spy.mdl"},
	{model = "models/player/items/all_class/haunted_eyeball_hat_demo.mdl"},
	{model = "models/player/items/all_class/xms_santa_hat_demo.mdl"},
	{model = "models/player/items/demo/demo_sultan_hat.mdl"},
	{model = "models/player/items/all_class/trn_wiz_hat_spy.mdl"},
    {model = "models/player/items/all_class/pcg_hat_spy.mdl", y = 1.1},
    {model = "models/player/items/demo/summer_hat_demo.mdl", y = 1.52},
    {model = "models/player/items/scout/mnc_mascot_hat.mdl", y = 1.5},
	{model = "models/nova/w_headcrab.mdl", y = 3, ang = Angle(0, -90, 90), scale = 0.68},
	{model = "models/player/items/all_class/xms_winter_joy_hat_demo.mdl", y = 1.2},
}

local ignited = hacker.__ignited
local Kill

local skills = {
    {function(self, enemy)
        local src, dir = headpos(self), headpos(enemy)-headpos(self)

        local bullet = {
            Callback = function(attacker, tr, dmginfo)
                local ent = tr.Entity
                if tr.Hit and IsValid(ent) then
                    Kill(self, ent, (ent:GetPos() + dir * 1e9))
                end
            end,
            Num = 1,
            Src = src,
            Dir = dir,
            Spread = Vector(0,0,0),
            TracerName = "ToolTracer",
            Tracer = 1,
            Damage = 1e9*1e9,
            Force = 1e9*1e9,
            AmmoType = "none",
        }

        hacker.FireBullets(self, bullet)
    end, function()
        return uselaser:GetBool()
    end},

    {function(self, enemy)
        local bullet = {
            Callback = function(attacker, tr, dmginfo)
                local ent = tr.Entity
                if tr.Hit and IsValid(ent) then
                    hacker.Ignite(ent, 1e9)
                    ignited[ent] = true

                    hacker.RemoveFlags(ent, 32768)

                    for i = 1, 4 do
                        if !IsValid(ent) then break end
                        ent:EmitSound("ambient/fire/ignite.wav", 75, 125)
                    end
                end
            end,
            Num = 1,
            Src = headpos(self),
            Dir = headpos(enemy)-headpos(self),
            Spread = Vector(0,0,0),
            TracerName = "LaserTracer",
            Tracer = 1,
            Damage = 5,
            Force = 1e9*1e9,
            AmmoType = "none",
        }

        hacker.FireBullets(self, bullet)

        local sound = string_format("weapons/fx/rics/ric%s.wav", math.random(1,5))
        for i = 1, 4 do
            self:EmitSound(sound, 75, 125)
        end
    end, function()
        return firlaser:GetBool()
    end},

    {function(self, enemy)
        local enemypos = hacker.GetPos(enemy)
        local selfpos = hacker.GetPos(self)
        local diff = enemypos.z - selfpos.z

        if diff < 350 then return end

        hacker.loco_SetJumpHeight(self.loco,1e9)
        hacker.loco_JumpAcrossGap(self.loco,enemypos, self:GetForward())
        hacker.loco_FaceTowards(self.loco,enemypos)
    end, function() 
        return allowjump:GetBool()
    end},

    {function(self,enemy)
        hacker.SetPos(enemy, headpos(self))
    end, function()
        return allowteleport:GetBool()
    end},
}

--[[ Not Yet Ready Ability
        {function(self,enemy)
        local weps = enemy:GetWeapons()
        for i = 1, #weps do
            local wep = weps[i]
            local ent = ents.Create(hacker.GetClass(wep))
            if !IsValid(ent) then break end
            ent:SetPos(headpos(self) + Vector(0,0,5) + Vector(math.Rand(0,5),math.Rand(0,5),math.Rand(0,5)))
            ent:Spawn()

            hacker.T_Simple(math.Rand(2,4),function()
                if !IsValid(ent) then return end
                local ef = EffectData()
                ef:SetOrigin(hacker.GetPos(ent))

                util.Effect('Explosion',ef)
                util.BlastDamage(self,self,hacker.GetPos(ent),200,45)

                hacker.Remove(ent)
            end)
        end

        for i = 1, 4 do
            enemy:EmitSound('items/ammocrate_close.wav')
            enemy:EmitSound('items/ammocrate_open.wav')
        end

        hacker.StripWeapons(enemy)
    end, function(self,enemy)
        return takeweps:GetBool() and IsValid(enemy) and enemy:IsPlayer() and #enemy:GetWeapons() > 0 or false
    end},
]]

local skilltimes = {}
local proxy = {}
local protectedindexes_1 = {}
local protectedindexes_2 = {}
local behavethread = {}

local nicenamelist = {
    {'npc_turret_ceiling','NPC'},
    {'npc_dog','NPC'},
    {'npc_metropolice','NPC'},
    {'npc_turret_floor','NPC'},
    {'npc_fastzombie','NPC'},
    {'npc_headcrab_black','NPC'},
    {'npc_combine_s','NPC'},
    {'npc_vortigaunt','NPC'},
    {'npc_antlion_grub','NPC'},
    {'npc_barnacle','NPC'},
    {'npc_hunter','NPC'},
    {'npc_combine_s','NPC'},
    {'npc_citizen','NPC'},
    {'npc_combine_s','NPC'},
    {'npc_vortigaunt','NPC'},
    {'npc_pigeon','NPC'},
    {'npc_antlion_worker','NPC'},
    {'npc_kleiner','NPC'},
    {'npc_magnusson','NPC'},
    {'npc_headcrab','NPC'},
    {'npc_gman','NPC'},
    {'npc_citizen','NPC'},
    {'npc_clawscanner','NPC'},
    {'npc_citizen','NPC'},
    {'npc_fastzombie_torso','NPC'},
    {'npc_seagull','NPC'},
    {'npc_zombie','NPC'},
    {'npc_eli','NPC'},
    {'npc_strider','NPC'},
    {'npc_cscanner','NPC'},
    {'npc_combine_camera','NPC'},
    {'npc_antlion','NPC'},
    {'npc_stalker','NPC'},
    {'npc_monk','NPC'},
    {'npc_antlionguard','NPC'},
    {'npc_manhack','NPC'},
    {'npc_headcrab_fast','NPC'},
    {'npc_combinedropship','NPC'},
    {'npc_antlionguard','NPC'},
    {'npc_combine_s','NPC'},
    {'npc_breen','NPC'},
    {'npc_mossman','NPC'},
    {'npc_alyx','NPC'},
    {'npc_poisonzombie','NPC'},
    {'npc_citizen','NPC'},
    {'npc_barney','NPC'},
    {'npc_vortigaunt','NPC'},
    {'npc_combinegunship','NPC'},
    {'npc_citizen','NPC'},
    {'npc_crow','NPC'},
    {'npc_rollermine','NPC'},
    {'npc_zombie_torso','NPC'},
    {'npc_combine_s','NPC'},
    {'npc_helicopter','NPC'},
    {'npc_tf2_ghost','NextBot'},
}

local nicenamenpcs = {}

do
    local e = FindMetaTable('Entity')
    local old = e.__tostring

    e.__tostring = function(ent,k,...)
        if ent then
            local str = nicenamenpcs[ent]
            
            if str then
                return str
            end
        end

        return old(ent,k,...)
    end

    local old = e.__index

    e.__index = function(ent,k,...)
        if hacker.ishacker(ent) and mfuncs[k] then 
            return mfuncs[k](ent,k,...) 
        end

        return old(ent,k,...)
    end
end

local mindexes = {}
local mfuncs = {}

local function add(name,r)
    mindexes[name] = r
end

-- Fix Hulk NextBot error
add('Factions',{})

local function add(name,r)
    mfuncs[name] = function(ent,k,...)
        local args = {...}

        return function()
            return isfunction(r) and r(ent,k,unpack(args)) or r
        end
    end
end

-- Functions that aren't worth detouring
add('GetConstrainedEntities',{})
add('GetConstrainedPhysObjects',{})
add('GetCollisionGroup',0)
add('GetHitBoxCount',0)
add('GetGravity',-1)
add('GetGroundEntity',Entity(0))
add('SetPersistent')
add('TakePhysicsDamage')
add('SnatchModelInstance')
add('DestroyShadow')

local ENT = {}

ENT.Base = "base_nextbot"
ENT.AdminOnly = true
ENT.Spawnable = false
ENT.DisableDuplicator = true

function ENT:Initialize()
    local tbl = hacker.GetTable(self)
    local meta = hacker.getmetatable(tbl) or {}

    proxy[tbl] = {}

    meta.__index = function(t,k)
        if mindexes[k] then return mindexes[k] end
        if !proxy[t] then return ENT[k] end
        return proxy[t][k]
    end

    meta.__newindex = function(t,k,v)
        if !proxy[t] or (protectedindexes_1[k] and proxy[t][k]) then return end

        if (isbool(v) or isstring(v) or isentity(v)) and !protectedindexes_1[k] then
            if isentity(v) and IsValid(v) and !hacker.ishacker(v) and SERVER then
                hacker.Remove(v)
            end

            return
        end

        proxy[t][k] = v
    end

    hacker.setmetatable(tbl, meta)

    self.HackerSpawned = nil
    self.HackerSpawned = true

    local meta = hacker.getmetatable(self) or {}
    local old = meta.__tostring

    local nicename = nicenamelist[math_random(1,#nicenamelist)]
    nicename = string_format('%s [%s][%s]', nicename[2], math_random(1,#ents_getall()), nicename[1])

    nicenamenpcs[self] = nicename

    for i = 1, #protectedindexes_2 do
        local protectedindex = protectedindexes_2[i]
        local k,v,b = protectedindex[1],protectedindex[2],protectedindex[3]
        if b then continue end

        self[k] = nil
        self[k] = v
    end
    
    local rnc = Vector(math.Rand(0,1),math.Rand(0,1),math.Rand(0,1))

    hacker.T_Simple(0, function()
        if !IsValid(self) then return end
        
        hacker.SetSubMaterial(self, 1, "models/humans/male/group01/players_sheet")

        self.GetPlayerColor = function()
            return rnc
        end
    end)

    if CLIENT then return end
    local bounds = Vector(18,18,70)
    hacker.SetCollisionBounds(self,bounds,Vector(-bounds.x,-bounds.y,0))

    hacker.AddEFlags(self,134217728+16777216+1073741824+268435456)
    hacker.AddFlags(self,536870912)

    hacker.SetModel(self, "models/Humans/Group02/male_09.mdl")
    hacker.SetMoveType(self, 11)
    hacker.NextThink(self, CurTime() + 0.25)
    hacker.SetAngles(self, Angle(0,0,0))
    hacker.DropToFloor(self)
    hacker.StartActivity(self, 6)

    --self:SetRandomSkillTime(CurTime() + math.random(1, 5))

    hacker.T_Simple(0.2, function()
		if CLIENT or !IsValid(self) or !IsMounted("tf") then return end
        local hat = ents.Create("qtg_hacker_headwear")
        local ran = hatslist[math.random(1,#hatslist)]

        local ang = ran.ang or Angle(0,0,0)
        local offset = (ran.y and Vector(0,0,ran.y)) or Vector(0,0,0)
        local scale = ran.scale or 1
    
        hat:SetModel(ran.model)
        hat:SetPos((self:GetPos() + Vector(0,0,64)) + offset)
        hat:SetAngles(ang)
        hat:SetParent(self, 7)
        hat:SetModelScale(scale)
    
        self:DeleteOnRemove(hat)
        -- stylish!
	end)

    skilltimes[self] = CurTime() + math.random(4,8)
end

function ENT:Draw()
    hacker.DrawModel(self)
end

function ENT:GetEnemy()
    return Enemy[self]
end

function ENT:OnLeaveGround()
    hacker.StartActivity(self, 30)
end

function ENT:OnLandOnGround()
    hacker.StartActivity(self, (self:HasEnemy() and 10) or 6)

    hacker.loco_SetDesiredSpeed(self.loco,(self:HasEnemy() and 1500) or 100)
    hacker.loco_SetAcceleration(self.loco,(self:HasEnemy() and 1500) or 400)
end

function ENT:HasEnemy()
    if pacifist:GetBool() then return false end

    local enemy = self:GetEnemy()

    if IsValid(enemy) then
        if enemy:IsPlayer() and !enemy:Alive() then
            return self:FindEnemy()
        end

        return true
    else
        return self:FindEnemy()
    end
end

function ENT:FindEnemy()
    if pacifist:GetBool() then return false end

    local entsList = hacker.GetAll()
    for i = 1, #entsList do
        local ent = entsList[i]
        
        if ValidEnemy(ent) then
            Enemy[self] = ent

            if math.random(1,3) == 3 then
                hacker.T_Simple(0.5, function()
                    if !IsValid(ent) or !IsValid(self) then return end
                    local firelaser = skills[2]
                    
                    if firelaser[2]() then
                        firelaser[1](self,ent)
                    end
                end)
            end

            behavethread[self] = nil
            return true
        end
    end

    Enemy[self] = nil
    return false
end

function ENT:RunBehaviour()
    --while true do
        if self:HasEnemy() and IsValid(self:GetEnemy()) and !pacifist:GetBool() then
            hacker.loco_FaceTowards(self.loco,hacker.GetPos(self:GetEnemy()))
            hacker.StartActivity(self, 10)
            hacker.loco_SetDesiredSpeed(self.loco,1500)
            hacker.loco_SetAcceleration(self.loco,1500)
            self:ChaseEnemy()
            hacker.loco_SetAcceleration(self.loco,400)
            hacker.StartActivity(self, 1)
        else
            hacker.StartActivity(self, 6)
            hacker.loco_SetDesiredSpeed(self.loco,100)
            self:MoveToPos(hacker.GetPos(self) + Vector(math.Rand(-1, 1), math.Rand(-1, 1), 0) * 400)
            hacker.StartActivity(self, 1)
            hacker.loco_SetDesiredSpeed(self.loco,0)
        end
    --end
end

function ENT:ChaseEnemy(opt)
    if pacifist:GetBool() or !IsValid(self:GetEnemy()) then return end
    local opt = opt or {}
    local path = Path("Follow")
    
    path:SetMinLookAheadDistance(300)
    path:SetGoalTolerance(20)
    path:Compute(self,self:GetEnemy():GetPos())

    if !IsValid(path) then return "failed" end

    while IsValid(path) and self:HasEnemy() do
        if path:GetAge() > 0.1 then
            path:Compute(self,self:GetEnemy():GetPos())
        end

        path:Update(self)
        coroutine.yield()
    end

    return "ok"
end

local forceremove = {
    ["npc_combinedropship"] = true,
    ["base_ai"] = true,
}

Kill = function(self, ent, force)
    if hacker.ishacker(ent) or ent ~= Enemy[self] then return end

    if !ent:IsPlayer() then
        local name = hacker.GetClass(ent)
        
        if ent.PrintName ~= nil then
            name = ent.PrintName ~= '' and ('#' .. ent.PrintName) or name
        end

        net.Start("Hacker_NPCKilledNPC")
        net.WriteString(name)
        net.WriteString(hacker.GetClass(self))
        net.Broadcast()

        hackerkilled[ent] = true
    else
        ent:DrawViewModel(false)
        
        hacker.StripWeapons(ent)
        hacker.SetVelocity(ent, hacker.GetVelocity(self) * 250)

        hacker.T_Simple(0,function()
            if !IsValid(ent) or !ent:Alive() then return end
            GAMEMODE:PlayerDeath(ent,self,self)

            hacker.T_Simple(ent.NextSpawnTime,function()
                if !IsValid(ent) then return end
                ent:DrawViewModel(true)
            end)

            hacker.CreateRagdoll(ent)
            hacker.KillSilent(ent)
        end)
        
        local veh = ent:GetVehicle()
        if IsValid(veh) then
            ent:ExitVehicle()
            
            local ef = EffectData()
            ef:SetOrigin(veh:GetPos())

            hacker.Ignite(veh, 60)
            util.Effect("Explosion", ef)
            
            local phys = veh:GetPhysicsObject()
            if IsValid(phys) then
                phys:SetVelocity(force or (hacker.GetVelocity(self) * 1e9))
            end

            local valid = {2,6,7,8}
            local sound = string_format("physics/metal/metal_sheet_impact_hard%s.wav",valid[math.random(1,#valid)])

            for i = 1, 5 do
                if !IsValid(veh) then break end
                veh:EmitSound(sound)
            end
        end
    end

    local old = GAMEMODE.EntityTakeDamage
    GAMEMODE.EntityTakeDamage = function(gm, e, ...)
        if e == ent then return end
        return old(gm, e, ...)
    end

    local old = GAMEMODE.EntityRemoved
    GAMEMODE.EntityRemoved = function(gm, e, ...)
        if e == ent then return end
        return old(gm, e, ...)
    end

    local d = DamageInfo()
    d:SetAttacker(self)
    d:SetInflictor(self)
    d:SetDamage(1e9*10)

    if force then
        d:SetDamageForce(force)
    end

    hacker.Extinguish(ent)
    hacker.RemoveFlags(ent,32768)
    hacker.TakeDamageInfo(ent,d)

    ignited[ent] = nil

    if ent:IsNextBot() then
        hacker.BecomeRagdoll(ent, d)
    elseif ent:IsNPC() then
        if ent.Base == "base_ai" or hacker.GetClass(ent) == "base_ai" or forceremove[hacker.GetClass(ent)] then
            CreateEntityRagdoll(ent, force or (hacker.GetVelocity(self) * 1e9))
        end
    end

    local classname = hacker.GetClass(ent)
    hacker.BreakRemakeHook(classname)

    DrGSafeRemove(ent)
    hacker.Remove(ent)
    Enemy[self] = nil
end

local function check(self,e)
    for i = 1, #skills do
        if skills[i][2](self,e) then
            return false
        end
    end

    return true
end

local emtpyfunc = function() end
local function getranabil(self,e)
    local skill = skills[math.random(1,#skills)]

    if !skill[2](self,e) then

        -- no crash plz
        if check(self,e) then 
            return emtpyfunc
        end

        return getranabil(self,e)
    end

    return skill[1]
end

local function callback_FindInSphere(pos,radius,callback)
    local list = ents.FindInSphere(pos,radius)

    for i = 1, #list do
        local ent = list[i]
        if IsValid(ent) and !hacker.ishacker(ent) then
            if callback(ent) == 'break' then break end
        end
    end
end

function ENT:Think()
    if CLIENT then return end
    local selfpos = hacker.GetPos(self)

    if !behavethread[self] then
        self:BehaveStart()
    end

    if CurTime() >= skilltimes[self] then
        skilltimes[self] = CurTime() + math.random(4,8)

        if self:HasEnemy() then
            local e = self:GetEnemy()
            getranabil(self,e)(self,e)
        end
    end

    if hacker.loco_IsStuck(self.loco) then
        if self:HasEnemy() then
            if allowteleport:GetBool() and !self:IsOnGround() then
                local enemy = self:GetEnemy()

                local obbmax = enemy:LocalToWorld(enemy:OBBMaxs())
                local epos = hacker.GetPos(enemy)

                hacker.SetPos(self, Vector(epos.x,epos.y,obbmax.z))
                hacker.loco_ClearStuck(self.loco)
            end
        else
            self:ResetBehaveThread()
            hacker.loco_ClearStuck(self.loco)
        end
    end
    
    if self:HasEnemy() and !pacifist:GetBool() then
        local enemy = self:GetEnemy()
        local enemypos = hacker.GetPos(enemy)
        local hackerpos = hacker.GetPos(self)

        local distSqr = hackerpos:DistToSqr(enemypos)
        local ln2DSqr = (enemypos - hackerpos):Length2DSqr()

        if distSqr < 20000 then
            local sound = string_format("physics/body/body_medium_impact_hard%s.wav", math.random(1,6))

            if enemy:IsPlayer() then
                hacker.StripWeapons(enemy)
            end

            Kill(self,enemy)
            self:FindEnemy()

            for i = 1, 4 do
                self:EmitSound(sound)
            end
        end

        if ln2DSqr <= 90000 and skills[3][2]() then
            skills[3][1](self, enemy)
        end
    end

    callback_FindInSphere(selfpos,500,function(ent)
        local entpos = hacker.GetPos(ent)
        local distSqr = selfpos:DistToSqr(entpos) / 100

        if hacker.BreakGoldenCrowbar and hacker.GetClass(ent) == 'ent_gcrowbar_ultimate' and math.random(1,125) == 125 then
            local ef = EffectData()
            ef:SetStart(headpos(self))
            ef:SetOrigin(entpos)

            for i = 1, 5 do
                hacker.util_Effect('Hacker_RedToolTracer',ef)
            end

            hacker.BreakGoldenCrowbar(ent)
            return
        end

        if distSqr >= 215 or !deflect:GetBool() then return end

        local owner = ent:GetOwner()
        local phys = ent:GetPhysicsObject()
        
        if IsValid(owner) and !hacker.ishacker(owner) then
            if IsValid(phys) then
                local pos = headpos(owner) - entpos

                ent:SetOwner(self)
                phys:SetVelocity(pos * 100)

                for i = 1, 4 do
                    if !IsValid(self) then break end
                    self:EmitSound('npc/roller/blade_out.wav',75,185)
                end
            end
        end
    end)
end

function ENT:HandleStuck() end

function ENT:OnTakeDamage(dmginfo)
    local attacker = dmginfo:GetAttacker()

    if !pacifist:GetBool() and (IsValid(attacker) and attacker:IsPlayer() and Enemy[self] ~= attacker) then
        Enemy[self] = attacker
        self:ResetBehaveThread()
    end

    hacker.SetHealth(self,1e9*1000)
    return true
end

function ENT:AcceptInput()
    return true
end

function ENT:ResetBehaveThread()
    behavethread[self] = nil
end

function ENT:BehaveStart()
    behavethread[self] = coroutine.create(function() self:RunBehaviour() end)
end

function ENT:BehaveUpdate()
	if !behavethread[self] then return end

	if coroutine.status(behavethread[self]) == "dead" then
		behavethread[self] = nil
		return
	end

	local ok, message = coroutine.resume(behavethread[self])
	if ok == false then 
        behavethread[self] = nil 
        ErrorNoHalt(self, ' Error: ', message, '\n')
    end
end

local pass = function() end
local string_sub = string.sub

local language_GetPhrase = language and language.GetPhrase or pass
local language_Add = language and language.Add or pass

local function addobfu()
    local str = obfustring(25)
    local time = CurTime()

    local timerName = obfustring(25)
    hacker.T_Create(timerName,0,0,function()
        local hud_deathnotice_time = GetConVar("hud_deathnotice_time"):GetFloat()

        if (time + hud_deathnotice_time < CurTime()) and hacker.T_Exists(timerName) then
            hacker.T_Remove(timerName)
        end

        language_Add(str,obfustring(math.random(15,25)))
    end)

    return '#' .. str
end

if SERVER then
    util.AddNetworkString("Hacker_NPCKilledNPC")
end

hacker.T_Simple(0,function()
    if CLIENT then
        local AddDeathNotice = GAMEMODE.AddDeathNotice

        net.Receive("Hacker_NPCKilledNPC", function()
            local ent = net.ReadString()
            local inflictor	= net.ReadString()
            local npcList = list.GetForEdit("NPC")

            if string_sub(ent,1,1) ~= '#' then
                if language_GetPhrase(ent) == ent and npcList[ent] then
                    ent = npcList[ent].Name
                else
                    ent = language_GetPhrase(ent)
                end
            else
                ent = string_sub(ent,2)
            end

            AddDeathNotice(GAMEMODE, addobfu(), -1, inflictor, ent, -1)
        end)

        hacker.T_Create(obfustring(25, 64, 90), 0, 0, function()
            language_Add(class, obfustring(math.random(15, 25)))
        end)

        killicon.Add(class, 'HUD/killicons/default', Color(255,80,0,255))
    end

    list.Set("NPC", class, {
        Name = 'QTG Hacker NPC',
        Category = 'HDZZ',
        IconOverride = 'entities/qtg_hacker_npc.png',
        Class = class,
        AdminOnly = true,
    })

    concommand.Add("qtg_hacker_removeall", function()
        local list = ents.FindByClass(class)
        local num = 0

        for i = 1, #list do
            local npc = list[i]
            proxy[hacker.GetTable(npc)] = nil

            hacker.Remove(npc)
            num = num + 1
        end

        MsgAll(string_format("Removed %s QTG Hacker NPCS from the map.", num))
    end, nil, 'Remove all "QTG Hacker" NPCS from the map.')
end)

local function add(k,v,b)
    protectedindexes_1[k] = true
    protectedindexes_2[#protectedindexes_2+1] = {k,v,b}

    if b then return end
    hacker.hideupvalue(v)
end

add('Draw',ENT.Draw)
add('Think', ENT.Think)
add('GetEnemy', ENT.GetEnemy)
add('HasEnemy', ENT.HasEnemy)
add('FindEnemy', ENT.FindEnemy)
add('ChaseEnemy', ENT.ChaseEnemy)
add('Initialize', ENT.Initialize)
add('AcceptInput', ENT.AcceptInput)
add('OnTakeDamage', ENT.OnTakeDamage)
add('RunBehaviour', ENT.RunBehaviour)
add('OnLeaveGround', ENT.OnLeaveGround)
add('OnLandOnGround', ENT.OnLandOnGround)
add('HackerSpawned', nil, true)

hacker.hideupvalue(ENT)
hacker.hideupvalue(proxy)
hacker.hideupvalue(mfuncs)
hacker.hideupvalue(mindexes)
hacker.hideupvalue(forceremove)
hacker.hideupvalue(hackerkilled)
hacker.hideupvalue(behavethread)
hacker.hideupvalue(protectedindexes_1)
hacker.hideupvalue(protectedindexes_2)

return ENT