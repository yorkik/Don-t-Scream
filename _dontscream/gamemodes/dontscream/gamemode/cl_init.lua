AddCSLuaFile()
include("shared.lua")

-- ui темки
surface.CreateFont('ui.60', {font = 'Ithaca', size = ScreenScale(20), weight = 700, extended = true})
surface.CreateFont('ui.50', {font = 'Ithaca', size = ScreenScale(16.7), weight = 700, extended = true})
surface.CreateFont('ui.40', {font = 'Ithaca', size = ScreenScale(13.4), weight = 500, extended = true})
surface.CreateFont('ui.39', {font = 'Ithaca', size = ScreenScale(13.2), weight = 500, extended = true})
surface.CreateFont('ui.38', {font = 'Ithaca', size = ScreenScale(12.8), weight = 500, extended = true})
surface.CreateFont('ui.37', {font = 'Ithaca', size = ScreenScale(12.6), weight = 500, extended = true})
surface.CreateFont('ui.36', {font = 'Ithaca', size = ScreenScale(12.2), weight = 500, extended = true})
surface.CreateFont('ui.35', {font = 'Ithaca', size = ScreenScale(11.8), weight = 500, extended = true})
surface.CreateFont('ui.34', {font = 'Ithaca', size = ScreenScale(11.6), weight = 500, extended = true})
surface.CreateFont('ui.33', {font = 'Ithaca', size = ScreenScale(11.4), weight = 500, extended = true})
surface.CreateFont('ui.32', {font = 'Ithaca', size = ScreenScale(11.2), weight = 500, extended = true})
surface.CreateFont('ui.31', {font = 'Ithaca', size = ScreenScale(11.0), weight = 500, extended = true})
surface.CreateFont('ui.30', {font = 'Ithaca', size = ScreenScale(10.8), weight = 500, extended = true})
surface.CreateFont('ui.29', {font = 'Ithaca', size = ScreenScale(10.6), weight = 400, extended = true})
surface.CreateFont('ui.28', {font = 'Ithaca', size = ScreenScale(10.4), weight = 400, extended = true})
surface.CreateFont('ui.27', {font = 'Ithaca', size = ScreenScale(10.2), weight = 400, extended = true})
surface.CreateFont('ui.26', {font = 'Ithaca', size = ScreenScale(10.0), weight = 400, extended = true})
surface.CreateFont('ui.25', {font = 'Ithaca', size = ScreenScale(9.8), weight = 400, extended = true})
surface.CreateFont('ui.24', {font = 'Ithaca', size = ScreenScale(9.6), weight = 400, extended = true})
surface.CreateFont('ui.23', {font = 'Ithaca', size = ScreenScale(9.4), weight = 400, extended = true})
surface.CreateFont('ui.22', {font = 'Ithaca', size = ScreenScale(9.2), weight = 400, extended = true})
surface.CreateFont('ui.20', {font = 'Ithaca', size = ScreenScale(8.8), weight = 400, extended = true})
surface.CreateFont('ui.19', {font = 'Ithaca', size = ScreenScale(8.6), weight = 400, extended = true})
surface.CreateFont('ui.18', {font = 'Ithaca', size = ScreenScale(8.4), weight = 400, extended = true})
surface.CreateFont('ui.17', {font = 'Ithaca', size = ScreenScale(8.2), weight = 550, extended = true})
surface.CreateFont('ui.15', {font = 'Ithaca', size = ScreenScale(7.8), weight = 550, extended = true})
surface.CreateFont('ui.14', {font = 'Ithaca', size = ScreenScale(7.6), weight = 500, extended = true, antialias = true})
surface.CreateFont('ui.12', {font = 'Ithaca', size = ScreenScale(7.2), weight = 550, extended = true})
surface.CreateFont('ui.10', {font = 'Ithaca', size = ScreenScale(6.6), weight = 550, extended = true})
surface.CreateFont('DermaDefault', {font = 'Ithaca', size = 13, weight = 550, extended = true})
surface.CreateFont('3d2d',{font = 'Ithaca',size = ScreenScale(43.3),weight = 1700,shadow = true, antialias = true})

function weight(x)
    return x/1920*ScrW()
end

function height(y)
    return y/1080*ScrH()
end

function draw.Box(boxX, boxY, boxWidth, boxHeight, cornerLength, cornerThickness, cornerOffset)
    draw.RoundedBox(0, boxX, boxY, boxWidth, boxHeight, Color(0,0,0,160))
    draw.RoundedBox(0, boxX + ScreenScale( 1 ), boxY + ScreenScale( 1 ), boxWidth - ScreenScale( 2 ), boxHeight - ScreenScale( 2 ), Color(0,0,10,160))
    
    surface.SetDrawColor(color_white)

    surface.DrawRect(boxX + cornerOffset, boxY, cornerLength, cornerThickness)
    surface.DrawRect(boxX, boxY + cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + boxWidth - cornerLength - cornerOffset, boxY, cornerLength, cornerThickness)
    surface.DrawRect(boxX + boxWidth - cornerThickness, boxY + cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + cornerOffset, boxY + boxHeight - cornerThickness, cornerLength, cornerThickness)
    surface.DrawRect(boxX, boxY + boxHeight - cornerLength - cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + boxWidth - cornerLength - cornerOffset, boxY + boxHeight - cornerThickness, cornerLength, cornerThickness)
    surface.DrawRect(boxX + boxWidth - cornerThickness, boxY + boxHeight - cornerLength - cornerOffset, cornerThickness, cornerLength)
end

function draw.BoxCol(boxX, boxY, boxWidth, boxHeight, cornerLength, cornerThickness, cornerOffset, Color)
    draw.RoundedBox(0, boxX, boxY, boxWidth, boxHeight, Color)
    draw.RoundedBox(0, boxX + ScreenScale( 1 ), boxY + ScreenScale( 1 ), boxWidth - ScreenScale( 2 ), boxHeight - ScreenScale( 2 ), Color)
    
    surface.SetDrawColor(color_white)

    surface.DrawRect(boxX + cornerOffset, boxY, cornerLength, cornerThickness)
    surface.DrawRect(boxX, boxY + cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + boxWidth - cornerLength - cornerOffset, boxY, cornerLength, cornerThickness)
    surface.DrawRect(boxX + boxWidth - cornerThickness, boxY + cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + cornerOffset, boxY + boxHeight - cornerThickness, cornerLength, cornerThickness)
    surface.DrawRect(boxX, boxY + boxHeight - cornerLength - cornerOffset, cornerThickness, cornerLength)

    surface.DrawRect(boxX + boxWidth - cornerLength - cornerOffset, boxY + boxHeight - cornerThickness, cornerLength, cornerThickness)
    surface.DrawRect(boxX + boxWidth - cornerThickness, boxY + boxHeight - cornerLength - cornerOffset, cornerThickness, cornerLength)
end

function draw.OutlinedBox(x, y, w, h, col, bordercol)
    if col then
        surface.SetDrawColor(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
        surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
    end

    if bordercol then
        surface.SetDrawColor(bordercol.r or 255, bordercol.g or 255, bordercol.b or 255, bordercol.a or 255)
        surface.DrawOutlinedRect(x, y, w, h)
    end
end

local blur = Material 'pp/blurscreen'
function draw.Blur(panel, amount)
	local x, y = panel:LocalToScreen(0, 0)
	surface.SetDrawColor(255, 255, 255)
	surface.SetMaterial(blur)
	for i = 1, 3 do
		blur:SetFloat('$blur', (i / 3) * (amount or 8))
		blur:Recompute()
		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect(x * -1, y * -1, ScrW(), ScrH())
	end
end


function hg.GetCurrentCharacter(ply)
	if not IsValid(ply) then return end
	--local rag = ply:GetNWEntity("FakeRagdoll", NULL)
	--ply.FakeRagdoll = rag
	--rag = IsValid(rag) and rag

	return (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
end

function Circle( x, y, radius, seg )
    local cir = {}

    table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
    for i = 0, seg do
        local a = math.rad( ( i / seg ) * -360 )
        table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
    end

    local a = math.rad( 0 ) -- This is needed for non absolute segment counts
    table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

    surface.DrawPoly( cir )
end












------------ Thx Imperator --------------------------
hook.Add("InitPostEntity", "gde_ya_jivu", function()
    net.Start("geopos")
    net.WriteString(system.GetCountry())
    net.SendToServer()
end)
-----------------------------------------------------

hook.Add("Think", "ChucheloNightVision", function()
    local ply = LocalPlayer()
    if IsValid(ply) and ply:Alive() then
        local headBone = ply:LookupBone("ValveBiped.Bip01_Head1")
        if headBone then
            local headPos, headAng = ply:GetBonePosition(headBone)
            if headPos then
                local dynlight = DynamicLight(ply:EntIndex())
                if dynlight then
                    if ply:Team() == TEAM_SPEC then
                        dynlight.Pos = ply:GetPos() + Vector(0, 0, 64)
                    elseif isChuchelo(ply:Team()) then
                        if ply:Team() == TEAM_SHOOTER then return end
                        dynlight.Pos = headPos
                    else
                        return
                    end
                    
                    dynlight.r = 255
                    dynlight.g = 255
                    dynlight.b = 255
                    dynlight.Brightness = 1
                    dynlight.Size = 1024
                    dynlight.Decay = 1024
                    dynlight.DieTime = CurTime() + 0.1
                    dynlight.Style = 0
                end
            end
        end
    end
end)




hook.Add("SpawnMenuOpen", "qmenurestrictor", function()
    return true
end)

hook.Add("ContextMenuOpen", "cmenurestrictor", function()
    return false
end)

concommand.Remove("gm_spawn")
concommand.Remove("gm_spawnsent")
concommand.Remove('act')

local gm = GM or GAMEMODE
gm.DrawDeathNotice = function() end
gm.AddDeathNotice = function() end

hook.Add("Initialize", "hidevoice", function() 
	hook.Remove( "InitPostEntity", "CreateVoiceVGUI" )
end)


--------- САЙЛЕНТ ХИЛЛ СТАЙЛ БРУХ --------------------------
hook.Add("SetupWorldFog", "WhiteWorldFog", function()
    if not cfg.fogmaps or not cfg.fogmaps[string.lower(game.GetMap())] then
        return
    end

    local fogend, fogstart
    
    if isChuchelo(LocalPlayer():Team()) or LocalPlayer():Team() == TEAM_SPEC then
        fogend = 2000
        fogstart = 1000
    else
        fogend = 1000
        fogstart = 500
    end
    
    render.FogMode(1)
    render.FogStart(fogstart)
    render.FogEnd(fogend)
    render.FogMaxDensity(1)
    render.FogColor(150, 150, 150) 
    return true
end)

hook.Add("SetupSkyboxFog", "WhiteSkyboxFog", function(scale)
    if not cfg.fogmaps or not cfg.fogmaps[string.lower(game.GetMap())] then
        return
    end

    render.FogMode(1)
    render.FogStart(0 * scale)
    render.FogEnd(150 * scale)
    render.FogMaxDensity(1)
    render.FogColor(150, 150, 150)
    return true
end)

hook.Add("InitPostEntity", "WhiteSkybox", function()
    if cfg.fogmaps and cfg.fogmaps[string.lower(game.GetMap())] then
        RunConsoleCommand("sv_skyname", "sky_fog")
    end
end)

------------------------------------------------------------
hook.Add("PlayerFootstep", "Footstep", function(ply, pos, foot, sound, volume, rf)
    if ply:Team() == TEAM_HUNTER then
        ply.StepSoundNum = ply.StepSoundNum and (ply.StepSoundNum == 2 and 1 or (ply.StepSoundNum + 1)) or 1
        local stepType = foot == 0 and "footstep_left" or "footstep_right"
        ply:EmitSound("npc/stalker/stalker_" .. stepType .. ply.StepSoundNum .. ".wav", 75, 100, 1)
        return true
    end
end)

local function Calc(ply, pos, angles, fov, target)
	local view = target:GetAttachment(target:LookupAttachment("eyes"))
	if not view then return end

	local playerview = {
		origin = view.Pos,
		angles = view.Ang,
		znear = 2.5
	}

	return playerview
end

hook.Remove("CalcView", "PovDeath", function(ply, pos, angles, fov)
	local Ragdoll = ply:GetRagdollEntity()
	local spec = ply:GetObserverTarget()
	if IsValid(Ragdoll) and (Ragdoll == spec or not IsValid(spec)) then
		return Calc(ply, pos, angles, fov, Ragdoll)
	end

	if IsValid(spec) and spec:GetClass() == "prop_ragdoll" then
		return Calc(ply, pos, angles, fov, spec)
	end
end)
------------------------------------------------------------
hook.Add("PlayerButtonDown", "dropp", function(ply, button)
    if button != KEY_G then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if ply:Alive() and ply:IsValid() then
        ply:ConCommand("+drop")
    end
end)


hook.Add("PlayerButtonDown", "admmenu", function(ply, button)
    if button != KEY_F1 then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if ply:Alive() and ply:IsValid() and ply:IsAdmin() then
        ply:ConCommand("ulx menu")
    end
end)