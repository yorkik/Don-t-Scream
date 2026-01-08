qwb = qwb or {}

local function includeClient(path)
    if SERVER then
        AddCSLuaFile(path)
    end

    if CLIENT then
        include(path)
    end
end

local function includeServer(path)
    if SERVER then
        include(path)
    end
end

local function includeShared(path)
    if SERVER then
        AddCSLuaFile(path)
    end

    include(path)
end

includeServer('qwb/sv_init.lua')
includeShared('qwb/sh_init.lua')
includeClient('qwb/cl_spawnmenu.lua')