if CLIENT then 
    local function DrawHalo()
		local ply = LocalPlayer()
		local trace = ply:GetEyeTrace()
		local hitpos = trace.HitPos
		local ent = trace.Entity

		for _, ent in ipairs(ents.FindByClass("ds_generator")) do
			if IsValid(ent) then
				halo.Add({ent}, Color(0, 255, 0), 1, 2, 2, true, true)
			end
		end

		if ply:GetPos():Distance(hitpos) > 75 then return end

		if IsValid(ent) and (ent:IsWeapon() or string.find(ent:GetClass(), "item_") or string.find(ent:GetClass(), "ds_")) then
			halo.Add({ent}, Color(255, 255, 255), 1, 2, 2, true, true)
		end
	end

	hook.Add("PreDrawHalos", "DrawItemHalo", DrawHalo)
    return 
end

if CLIENT then return end

local function PlayPickupSound(ply, ent)
    local pickupSound = "items/ammo_pickup.wav"

    local class = ent:GetClass()
    if string.find(class, "weapon_") then
        pickupSound = "items/weapon_pickup.wav"
    elseif string.find(class, "item_ammo") then
        pickupSound = "items/ammo_pickup.wav"
    elseif string.find(class, "item_health") then
        pickupSound = "items/medshot4.wav"
    end
    
	ply:DoAnimationEvent(ACT_PICKUP_GROUND)
    ply:EmitSound(pickupSound, 75, 100, 1)
end

local function ApplyPatch()
	for _, pl in ipairs(player.GetAll()) do pl:SetSaveValue("m_bPreventWeaponPickup", true) end

	local function RestoreItem(ent)
		if IsValid(ent) then ent._InUseBy = nil end
		hook.Remove("Tick", ent)
	end

	local function PickupItem(pl, ent)
		if pl ~= ent._InUseBy then return false end
		pl:SetSaveValue("m_bPreventWeaponPickup", true)
		hook.Remove("PlayerCanPickupItem", "\0OverridePickup")

		timer.Simple(0.01, function()
			if IsValid(pl) and IsValid(ent) then
				PlayPickupSound(pl, ent)
			end
		end)
		
		return true
	end

	hook.Add("PlayerSpawn", "\0DisablePickup", function(pl)
		pl:SetSaveValue("m_bPreventWeaponPickup", true)
	end, PRE_HOOK)

	do
		local inclusions = {
			item_ammo_357 = true,
			item_ammo_357_large = true,
			item_ammo_ar2 = true,
			item_ammo_ar2_altfire = true,
			item_ammo_ar2_large = true,
			item_ammo_crossbow = true,
			item_ammo_pistol = true,
			item_ammo_pistol_large = true,
			item_ammo_smg1 = true,
			item_ammo_smg1_grenade = true,
			item_ammo_smg1_large = true,
			item_battery = true,
			item_box_buckshot = true,
			item_healthkit = true,
			item_healthvial = true,
			item_rpg_round = true,
			item_suit = true}

		hook.Add("AcceptInput", "\0DisablePickup", function(ent, name, pl)
			if name ~= "Use" or not pl:IsPlayer() then return end
			local class = ent:GetClass()
			if ent:IsWeapon() and hook.Run("PlayerCanPickupWeapon", pl, ent) then
				pl:SetSaveValue("m_bPreventWeaponPickup", false)
				local succ = pl:PickupWeapon(ent, pl:HasWeapon(ent:GetClass()))
				pl:SetSaveValue("m_bPreventWeaponPickup", true)

				if succ then
					timer.Simple(0.01, function()
						if IsValid(pl) and IsValid(ent) then
							PlayPickupSound(pl, ent)
						end
					end)
				end
				
				return succ
			elseif inclusions[class] then
				ent._InUseBy = pl
				SuppressHostEvents(pl)
				pl:SetSaveValue("m_bPreventWeaponPickup", false)
				hook.Add("PlayerCanPickupItem", "\0OverridePickup", PickupItem, PRE_HOOK)
				hook.Add("__AfterTick", ent, RestoreItem)
				
				return true
			end
		end, PRE_HOOK)

		hook.Add("Tick", "__AfterTick", function() hook.Run("__AfterTick") end)
	end
end

local function DisablePatch()
	for _, pl in ipairs(player.GetAll()) do pl:SetSaveValue("m_bPreventWeaponPickup", false) end
	hook.Remove("PlayerSpawn", "\0DisablePickup")
	hook.Remove("AcceptInput", "\0DisablePickup")
end

if CreateConVar("sv_manualpickup", "1", bit.bor(FCVAR_ARCHIVE, FCVAR_NOTIFY), "", 0, 1):GetBool() then ApplyPatch() end

cvars.AddChangeCallback("sv_manualpickup", function(_, _, var)
	if tobool(var) then ApplyPatch() else DisablePatch() end
end)