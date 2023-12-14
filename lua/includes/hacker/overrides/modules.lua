local args = {...}
local extensions = args[1]
local hacker = args[2]
local ENT = args[3]

local block = hacker.block
local qfunc = hacker.qfunc

local ipairs = ipairs
local rawset = rawset
local istable = istable
local isfunction = isfunction

extensions.getmodule('constraint', function()
    if CLIENT then return end

    constraint.RemoveAll = block(nil, constraint.RemoveAll, false, {})
    constraint.GetAllConstrainedEntities = block(nil, constraint.GetAllConstrainedEntities, false, {})
end)

extensions.getmodule('drive', function()
    if CLIENT then return end

    drive.PlayerStartDriving = qfunc(false, nil, drive.PlayerStartDriving, function(ply,ent)
        if hacker.ishacker(ent) then 
            return true 
        end
    end)
end)

extensions.getmodule('scripted_ents',function()
    local register = scripted_ents.Register
    register(ENT,hacker.classname)

    scripted_ents.Register = qfunc(false,nil,register,function(tbl,name)
        if name == hacker.classname then
            return false
        end
    end)

    return v
end)

extensions.getmodule('undo', function()
    if CLIENT then return end

    local undo_DoUndo = undo.Do_Undo
    undo.Do_Undo = function(tab,...)
        if istable(tab) then
            local entsList = tab.Entities or {}

            for i=1, #entsList do
                if hacker.ishacker(entsList[i]) then 
                    return 
                end
            end
        end

        return undo_DoUndo(tab,...)
    end
end)

extensions.getmodule('properties', function()
    if SERVER then return end

    local get = {'Filter','Action'}
    local properties_Add = properties.Add

    properties.Add = function(name,tab,...)
        if istable(tab) then
            for i = 1, #get do
                local k = get[i]
                local ref = tab[k]

                if !isfunction(ref) then continue end
                hacker.qfunc(false,tab,k,function(self,ent)
                    if hacker.ishacker(ent) then 
                        return false 
                    end
                end)
            end
        end

        return properties_Add(name,tab,...)
    end
end)