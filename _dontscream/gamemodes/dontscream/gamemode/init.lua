AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

------------ Thx Imperator ----------------
util.AddNetworkString('geopos')
net.Receive("geopos", function(len, ply)
    if ply.country_sent then return end
    local country = net.ReadString()
    ply.country_sent = true
    ply:SetNWString("country", country)
end)
------------------------------------------

------------------------------------- OTHER --------------------------------------------
function hg.GetCurrentCharacter(ply)
	if not IsValid(ply) then return false end
	local rag = IsValid(ply.FakeRagdoll) and ply.FakeRagdoll or IsValid(ply:GetNWEntity("FakeRagdoll",NULL)) and ply:GetNWEntity("FakeRagdoll",NULL)
	return (IsValid(rag) and rag) or ply
end

hook.Add("InitPostEntity", "SpawnInitialLootboxes", function()
    timer.Simple(1, function()
        local map = game.GetMap()
        local spawns = cfg.spawnLootbox[map]
        
        if spawns and #spawns > 0 then
            for _, pos in ipairs(spawns) do
                local ent = ents.Create("ds_loot")
                ent:SetPos(pos)
                ent:Spawn()
                ent:Activate()
            end
        end

        local spawnsgener = cfg.spawnGenerator[map]
        if spawnsgener and #spawnsgener > 0 then
            for _, pos in ipairs(spawnsgener) do
                local ent = ents.Create("ds_generator")
                ent:SetPos(pos)
                ent:Spawn()
                ent:Activate()
            end
        end

        local spawnfuel = cfg.spawnFuel[map]
        if spawnfuel and #spawnfuel > 0 then
            for _, pos in ipairs(spawnfuel) do
                local ent = ents.Create("ds_fuel")
                ent:SetPos(pos)
                ent:Spawn()
                ent:Activate()
            end
        end
    end)
end)
----------------------------------------------------------------------------------------
local blacklistdrop = {
    ["ds_hands"] = true,
    ["ds_chuchelo2"] = true,
    ["ds_chuchelo"] = true,
    ["ds_axe"] = true,
}

local function dropweapon(ply)
    if (ply:IsValid()) then
        local wep = ply:GetActiveWeapon()
        if blacklistdrop[wep:GetClass()] then return false end
        ply:DoAnimationEvent(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
        ply:DropWeapon()
    end
end

concommand.Add("+drop", dropweapon)




--------------------- ЗАПРЕТЫ -------------------------------
function GM:PlayerUse(ply, ent)
    if isChuchelo(ply:Team()) or ply:Team() == TEAM_SPEC then return false end
    return true
end
function GM:PlayerCanPickupWeapon(ply, weapon)
	if ply:Team() == TEAM_SPEC then return false end
    return true
end
-------------------------------------------------------------

function GM:PlayerInitialSpawn(ply,transition)
    ply:SetTeam(TEAM_PLAYER)

    ply.FPAbilities = {}
    ply:SetNWInt("Stamina", MAX_STAMINA)
    ply:SetNWBool("StaminaBlocked", false)
    ply:SetNWBool("IsStaminaRegenFromZero", false)

    ply.time_respawn = 0
    ply.pressed = false
    ply.time_press = 0
    ply.entity_looked = nil
    ply.carrying = false
end


local models = {
    'models/citizens/pavka/male_01.mdl',
    'models/citizens/pavka/male_02.mdl',
    'models/citizens/pavka/male_03.mdl',
    'models/citizens/pavka/male_04.mdl',
    'models/citizens/pavka/male_05.mdl',
    'models/citizens/pavka/male_06.mdl',
    'models/citizens/pavka/male_07.mdl',
    'models/citizens/pavka/male_08.mdl',
    'models/citizens/pavka/male_09.mdl',
    'models/citizens/pavka/male_10.mdl',
    'models/citizens/pavka/male_11.mdl',
    'models/citizens/pavka/female_01.mdl',
    'models/citizens/pavka/female_01_b.mdl',
    'models/citizens/pavka/female_02.mdl',
    'models/citizens/pavka/female_02_b.mdl',
    'models/citizens/pavka/female_03.mdl',
    'models/citizens/pavka/female_03_b.mdl',
    'models/citizens/pavka/female_04.mdl',
    'models/citizens/pavka/female_04_b.mdl',
    'models/citizens/pavka/female_06.mdl',
    'models/citizens/pavka/female_06_b.mdl',
    'models/citizens/pavka/female_07.mdl',
    'models/citizens/pavka/female_07_b.mdl',
}

local shooterpm = {
    'models/player/masked_shooter01.mdl',
    'models/player/masked_shooter02.mdl',
    'models/player/masked_shooter03.mdl',
    'models/player/masked_shooter04.mdl',
}

function GM:PlayerSetModel(ply)
    if ply:Team() == TEAM_HUNTER then
        ply:SetModel('models/player/HL2B/stalker.mdl')
    elseif ply:Team() == TEAM_DEXTER then
        ply:SetModel('models/dejtriyev/cof/psycho.mdl')
        ply:SetBodygroup(0, 0)
    elseif ply:Team() == TEAM_PARANORMAL then
        ply:SetModel('models/faceless_07.mdl')
    elseif ply:Team() == TEAM_SHOOTER then
        ply:SetModel(table.Random(shooterpm))
    end

    if ply:Team() == TEAM_PLAYER then
        ply:SetModel(table.Random(models))

        local bodygroups = ply:GetBodyGroups()
        for _, bg in ipairs(bodygroups) do
            local num = bg.num

            if num > 0 then
                ply:SetBodygroup(bg.id, math.random(0, num - 1))
            end 
        end

        timer.Simple(0.2, function()
            ply:SetBodygroup(5, 0)
        end)
    end
end

function GM:PlayerSpawn( ply )
    self.BaseClass.PlayerSpawn(self,ply)

    ply.time_respawn = CurTime()

    ply:SetNWInt("Stamina", MAX_STAMINA)
    ply:SetNWBool("StaminaBlocked", false)
    ply:SetNWBool("IsSprinting", false)
    ply:SetNWBool("IsStaminaRegenFromZero", false)
    ply:SetNWBool('jumpboost', false)
    ply:ConCommand('tpf_cl_fov 50')
    ply:ConCommand('tpf_cl_shadows 0')
    ply:SetNoCollideWithTeammates(false)
    ply:SetRandomNames()

    if isChuchelo(ply:Team()) then ply:GodEnable() end

    if ply:Team() == TEAM_HUNTER then
        ply:SetWalkSpeed(160)
        ply:SetRunSpeed(400)
    else
        ply:SetWalkSpeed(160)
        ply:SetRunSpeed(350)
    end

    if ply:Team() == TEAM_SPEC then
        ply:BlockStamina()
        ply:Spectate(OBS_MODE_ROAMING)
        ply:SetNoCollideWithTeammates(true)
        ply:SpectateEntity(nil)
    end
end
  
function GM:PlayerLoadout(ply)
    if ply:Team() == TEAM_SPEC then return end

    local loadouts = {
        [TEAM_SPEC] = function(ply)
            --ply:SetPos(GetSpawnPos())
            ply:StripWeapons()
            ply:BlockStamina()
        end,
        [TEAM_PLAYER] = function(ply)
            ply:SetPos(GetSpawnPos())
            ply:Give('ds_hands')
        end,
        [TEAM_HUNTER] = function(ply)
            ply:SetPos(GetChuchSpawnPos())
            ply:Give('ds_chuchelo2')
            ply:BlockStamina()
        end,
        [TEAM_DEXTER] = function(ply)
            ply:SetPos(GetChuchSpawnPos())
            ply:Give('ds_axe')
            ply:BlockStamina()
        end,
        [TEAM_PARANORMAL] = function(ply)
            ply:SetPos(GetChuchSpawnPos())
            ply:Give('ds_chuchelo')
            ply:BlockStamina()
        end,
        [TEAM_SHOOTER] = function(ply)
            ply:SetPos(GetChuchSpawnPos())
            ply:Give('ds_ar15')
            ply:BlockStamina()
        end,
    }

    loadouts[ply:Team()](ply)
end

function GM:PlayerCanHearPlayersVoice(listener, talker)
    if isChuchelo(talker:Team()) then
        local distance = listener:GetPos():Distance(talker:GetPos())
        return distance <= 4096
    end
    
    if talker:Team() == TEAM_SPEC then
        return listener:Team() == TEAM_SPEC
    end
    
    local distance = listener:GetPos():Distance(talker:GetPos())
    if distance > 600 then
        return false
    end
    
    return true
end

hook.Add("PlayerSwitchFlashlight", "BlockFlashLight", function( ply, enabled)
	if isChuchelo(ply:Team()) or ply:Team() == TEAM_SPEC then if ply:Team() == TEAM_SHOOTER then return end return false end
    return
end)

--------------------------  СМЕРТЬ  ------------------------------------------------
hook.Add('PlayerDeath', 'specafterdeath', function(victim, inflictor, attacker)
    timer.Simple(0.1, function()
        victim:SetTeam(TEAM_SPEC)
        victim:Spectate(OBS_MODE_ROAMING)
        victim:SpectateEntity(nil)
        victim:SetNWBool('jumpboost', false)

        net.Start("StopBreathSound")
        net.Send(victim)
    end)
end)

hook.Add("PlayerDeathSound", "CustomPlayerDeath", function(ply)
    local model = ply:GetModel():lower()
    local sounds
    if string.find(model, "female") then
        sounds = {"vo/npc/female01/no02.wav", "vo/npc/female01/mygut02.wav"}
    else
        sounds = {"vo/npc/male01/no02.wav", "vo/npc/male01/mygut02.wav"}
    end
    
    local randomSound = sounds[math.random(#sounds)]
    ply:EmitSound(randomSound, 75, math.random(90, 100))
    return true
end)

function NoSuicide(ply)
    ply:SendLua('chat.AddText( Color( 255, 0, 0), "ACCESS DENIED")')
    return false
end
hook.Add("CanPlayerSuicide", "NoSuicide", NoSuicide)
------------------------------------------------------------------------------------
concommand.Remove("getpos2", function(ply, cmd, args)
    if not IsValid(ply) then return end
    
    local tr = ply:GetEyeTraceNoCursor()
    local ent = tr.Entity
    
    if IsValid(ent) then
        ply:ChatPrint(tostring(ent:GetPos()))
        ply:ChatPrint(tostring(ent:GetAngles()))
        ply:ChatPrint(ent:MapCreationID(), ent:GetClass())
    else
        ply:ChatPrint("Vector(" .. tr.HitPos.x .. ", " .. tr.HitPos.y .. ", " .. tr.HitPos.z .. "),")
    end
end)