local allowpersistence = CreateConVar('qtg_hacker_persistence', 1, 128, 'Toggle if QTG Hacker NPCS should persist on server reload.')
if !allowpersistence:GetBool() then return end

local args = {...}
local hacker = args[1]
local extensions = args[2]

local IsValid = hacker.__IsValid
local util_JSONToTable = util.JSONToTable
local ents_Create = ents.Create

local dir = 'qtg_hacker_npc/' .. game.GetMap()
local files = (file.Find(dir .. '/*', 'DATA') or {})

for i = 1, #files do
    local fileName = dir .. '/' .. files[i]

    local src = extensions.file_Read(fileName,'DATA')
    local data = util_JSONToTable(src)

    if CLIENT then continue end
    hacker.T_Simple(0,function()
        local ent = ents_Create(hacker.classname)
        if !IsValid(ent) then return end

        hacker.SetPos(ent,data.pos)
        hacker.SetAngles(ent,data.ang)

        hacker.Spawn(ent)
        file.Delete(fileName)
    end)
end