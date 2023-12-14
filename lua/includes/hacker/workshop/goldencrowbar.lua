-- Golden Crowbar (Admin)
-- https://steamcommunity.com/sharedfiles/filedetails/?id=2845000530&searchtext=golden+crowbar

-- Let's break players' Ultimate Golden Crowbar right before their eyes.

local args = {...}
local hacker = args[1]
local workshop = args[2]

local rawset = rawset
local pass = function() end

if workshop.IsMounted(2845000530) then
    hacker.BreakGoldenCrowbar = function(goldencrowbar)
        if !hacker.__IsValid(goldencrowbar) then return end
        rawset(hacker.GetTable(goldencrowbar),'OnRemove',pass)

        local ef = EffectData()
        ef:SetOrigin(hacker.GetPos(goldencrowbar))

        for i = 1, 3 do
            goldencrowbar:EmitSound(string.format('physics/metal/metal_computer_impact_bullet%s.wav',math.random(1,3),75,150))
        end

        hacker.util_Effect('Explosion',ef)
        hacker.Remove(goldencrowbar)
    end

    if CLIENT then return end

    -- Golden Crowbar Reload Crash Fix
    hacker.add_hook('ShutDown',[[
        local list = ents.FindByClass('ent_gcrowbar_ultimate')

        for i = 1, #list do
            local ent = list[i]

            ent.OnRemove = function() end
            hacker.Remove(ent)
        end
    ]])
end
