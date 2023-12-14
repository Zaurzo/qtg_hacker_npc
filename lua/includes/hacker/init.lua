----------------------------------

local CompileFile = CompileFile
local file_Open = file.Open

local function include(filename, path, ...)
    path = 'lua/includes/hacker/' .. path
    filename = filename or path

    --AddCSLuaFile(path)
    
    local f = file.Open(path, 'rb', 'GAME')

    if f then
        local data = f:Read(f:Size())

        if data then
            local func = CompileString(data, filename)

            if func then
                return func(...)
            end
        end
    end
end

----------------------------------

pcall(function()
    local enemy         = {}
    local hackerkilled  = {}

    local hacker        = include(nil, 'includes/meta.lua', hackerkilled, enemy, extensions)
    local extensions    = include(nil, "includes/extensions.lua")
    local workshop      = include(nil, 'includes/workshop.lua')
    local ENT           = include('gamemodes/base/entities/entities/base_nextbot.lua', "qtg_hacker_npc.lua", hacker, hackerkilled, enemy, workshop, extensions)

    include(nil, 'persistence.lua', hacker, extensions)
    include(nil, 'overrides/modules.lua', extensions, hacker, ENT)
    include(nil, 'overrides/ents_create.lua', hacker, extensions, hackerkilled)
    include(nil, 'overrides/modules/hook.lua', hacker, enemy, extensions, hackerkilled)
    include(nil, 'workshop/gnomifier.lua', workshop, hacker, extensions)
    include(nil, 'workshop/goldencrowbar.lua', hacker, workshop)

    if CLIENT then
        include(nil, 'effects/redtooltracer.lua')
    end

    hacker.hideupvalue(extensions)
end)