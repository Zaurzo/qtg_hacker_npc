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

    local old ...more
