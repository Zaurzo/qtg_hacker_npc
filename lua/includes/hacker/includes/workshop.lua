local args = {...}
local workshop = {}

local addons = engine.GetAddons()
local addonList = {}

local fileTree = {}
local wsidTree = {}

local function GetLuaFiles(name,dir,tab)
	if !dir then dir = 'lua/' end

	local files = {}
	local f,d = file.Find(dir..'*',name)

	files = tab or files

	for k,v in ipairs(f) do
		files[#files+1] = dir .. v
	end

	for k,v in ipairs(d) do
		GetLuaFiles(name,dir..v..'/',files)
	end

	return files
end

local function InitializeWorkshopLib()
    for i = 1, #addons do
        local addon = addons[i]
        local title = addon.title
        local wsid = tonumber(addon.wsid)

        addonList[wsid] = addon
        wsidTree[title] = wsid

        --[[
        local files = {}
        
        if addon.mounted then
            files = GetLuaFiles(title)
        end

        for i = 1, #files do
            local luaFile = files[i]
            local old = fileTree[luaFile]

            if old then
                if istable(old) then
                    fileTree[luaFile] = {title,unpack(old)}
                else
                    fileTree[luaFile] = {title,old}
                end

                continue
            end

            fileTree[luaFile] = title
        end
        --]]
    end
end

function workshop.IsInstalled(wsid)
    return addonList[wsid] and true or false
end

function workshop.IsMounted(wsid)
    return addonList[wsid] and addonList[wsid].mounted or false
end

function workshop.GetWSIDByName(name)
    return wsidTree[name]
end

--[[
function workshop.WhereIs(luafile)
    return fileTree[luafile]
end
--]]

InitializeWorkshopLib()

return workshop