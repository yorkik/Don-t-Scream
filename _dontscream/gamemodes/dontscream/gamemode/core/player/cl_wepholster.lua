-- Конфиг оружия на спине
local BackpackConfig = {
    ["ds_shotgun_beanbag"] = {
        model = "models/weapons/w_shot_m3super90_beanbag.mdl",
        bone = "ValveBiped.Bip01_Spine2",
        pos = { forward = -5, right = 3, up = -5 },
        ang = { pitch = -12, yaw = 180, roll = 0 }
    },
    ["ds_fuel"] = {
        model = "models/props_junk/gascan001a.mdl",
        bone = "ValveBiped.Bip01_Spine2",
        pos = { forward = -1, right = 6, up = 0 },
        ang = { pitch = -78, yaw = 90, roll = 0 }
    },
    -- ["weapon_ak47"] = {
    --     model = "models/weapons/w_rif_ak47.mdl",
    --     bone = "ValveBiped.Bip01_Spine2",
    --     pos = { forward = -12, right = 4, up = -3 },
    --     ang = { pitch = 90, yaw = 180, roll = 0 }
    -- },
}

local BackpackModels = {}

hook.Add("Think", "DrawBackpackWeapon", function()
    local ply = LocalPlayer()
    if not IsValid(ply) or not ply:Alive() then return end

    local weaponFound = nil
    for _, wep in pairs(ply:GetWeapons()) do
        local class = wep:GetClass()
        if BackpackConfig[class] then
            weaponFound = class
            break
        end
    end

    if not weaponFound then
        if IsValid(BackpackModels[ply]) then
            BackpackModels[ply]:Remove()
            BackpackModels[ply] = nil
        end
        return
    end

    local activeWep = ply:GetActiveWeapon()
    if IsValid(activeWep) and activeWep:GetClass() == weaponFound then
        if IsValid(BackpackModels[ply]) then
            BackpackModels[ply]:Remove()
            BackpackModels[ply] = nil
        end
        return
    end

    if not IsValid(BackpackModels[ply]) then
        local config = BackpackConfig[weaponFound]
        local ent = ClientsideModel(config.model, RENDERGROUP_OPAQUE)
        if IsValid(ent) then
            BackpackModels[ply] = ent
        end
    end

    local modelEnt = BackpackModels[ply]
    local config = BackpackConfig[weaponFound]
    if IsValid(modelEnt) and config then
        local bone = ply:LookupBone(config.bone)
        if bone then
            local pos, ang = ply:GetBonePosition(bone)
            if pos and ang then
                modelEnt:SetPos(
                    pos +
                    ang:Forward() * config.pos.forward +
                    ang:Right() * config.pos.right +
                    ang:Up() * config.pos.up
                )
                ang:RotateAroundAxis(ang:Right(), config.ang.pitch)
                ang:RotateAroundAxis(ang:Up(), config.ang.yaw)
                ang:RotateAroundAxis(ang:Forward(), config.ang.roll)
                modelEnt:SetAngles(ang)
            end
        end
    end
end)

hook.Add("EntityRemoved", "CleanupBackpackModel", function(ent)
    if ent:IsPlayer() then
        if IsValid(BackpackModels[ent]) then
            BackpackModels[ent]:Remove()
            BackpackModels[ent] = nil
        end
    end
end)