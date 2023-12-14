-- Gnomifier [SWEP]
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2822275124

-- Let's Gnomify the players that try to attack us with this SWEP

local args = {...}
local workshop = args[1]
local hacker = args[2]
local extensions = args[3]

local CompileString = CompileString

local string_find = string.find
local string_gsub = string.gsub
local string_sub = string.sub

if workshop.IsMounted(2822275124) then
    timer.Simple(0, function()
        local SWEP = weapons.Get('weapon_gnomify')
        local src = extensions.getfunctionsource(SWEP.PrimaryAttack)

        local start, en = string_find(src, 'bullet.Callback = function', 1, true)
        local ens = string_find(src, 'bullet.Force = self.Primary.Force', 1, true)
        src = string_gsub('function Gnomify' .. string_sub(src,en+1,ens-1) .. '\nreturn Gnomify','self.Owner','attacker')

        -- Fix Error that happens on Lua Shutdown when you are gnomed
        src = extensions.string_Replace(src, 'ent.Targ:Spawn()', [[
            local num = ent.Targ:GetNumBodyGroups()
            if isnumber(num) then
                ent.Targ:Spawn()
            end
        ]])

        hacker.Gnomify = CompileString(src,'Gnomify')()
    end)
end