local workshop = include('includes/hacker/includes/workshop.lua')
local addoninfo,str = workshop.WhereIs('lua/includes/init.lua'),nil

local init_lua = file.Read('lua/includes/init.lua', 'GAME')
local find = 'include%("hacker/init%.lua"%)'

if not string.match(init_lua, find) and addoninfo ~= 'QTG Hacker NPC - NextBot' then
    if istable(addoninfo) then
        str = {}

        for k,v in ipairs(addoninfo) do
            str[#str+1] = string.format('%q',v)
        end

        str = table.concat(str,'\n')
        addoninfo = addoninfo[#addoninfo]
    end

    if !addoninfo then return end

    MsgN('\n[QTG Hacker NPC ERROR] Could not Initialize! (an addon you may have might be conflicting with the NPC.)')
    MsgN('Send this list and the error message in the Addon Bug Reports Disscussion:\n')
    MsgN((str or string.format('%q',addoninfo)) .. '\n')

    Error()
end
