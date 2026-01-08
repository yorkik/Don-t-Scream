hook.Add("PlayerCanPickupWeapon", "RestrictWeaponSlots", function(ply, weapon)
    if isChuchelo(ply:Team()) then return end
    if not IsValid(weapon) then return false end

    local newSlot = weapon.Slot or 0
    local newClass = weapon:GetClass()

    for _, existingWeapon in ipairs(ply:GetWeapons()) do
        if IsValid(existingWeapon) and existingWeapon:GetClass() == newClass then
            return false
        end
    end

    if newSlot == 0 then return end

    for _, existingWeapon in ipairs(ply:GetWeapons()) do
        local existingSlot = existingWeapon.Slot or 0

        if newSlot == existingSlot and newClass ~= existingWeapon:GetClass() then
            return false
        end
    end

    return true
end)

hook.Add("WeaponEquip", "CheckWeaponSlotsOnEquip", function(weapon, ply)
    if not IsValid(weapon) or not IsValid(ply) then return end

    timer.Simple(0.1, function()
        if not IsValid(weapon) or not IsValid(ply) then return end

        local newSlot = weapon.Slot or 0
        local newClass = weapon:GetClass()

        if newSlot == 0 then return end

        for _, existingWeapon in ipairs(ply:GetWeapons()) do
            if existingWeapon ~= weapon and IsValid(existingWeapon) then
                local existingSlot = existingWeapon.Slot or 0
                local existingClass = existingWeapon:GetClass()

                if existingClass == newClass then
                    ply:DropWeapon(existingWeapon)
                    break
                end

                if newSlot == existingSlot then
                    ply:DropWeapon(existingWeapon)
                    break
                end
            end
        end
    end)
end)