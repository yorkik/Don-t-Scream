local scrw, scrh = ScrW(), ScrH()

local vigmat = Material("ds/hud/vignette.png")
local showAmmo = false
local lastKeyState = false
local ammoDisplayTime = 0
local ammoFadeAlpha = 0

hide = {
	["CHudHealth"] = true,
	["CHudBattery"] = true,
	["CHudAmmo"] = true,
	["CHudSecondaryAmmo"] = true,
	["CHudCrosshair"] = false
}

hook.Add("HUDShouldDraw", "donthud", function(name) if hide[name] then return false end end)
hook.Add("HUDDrawTargetID", "donttargetid", function() return false end)

local function Bloomvision()
	if LocalPlayer():Health() <=30 then
		DrawMotionBlur(0.4, 10, 0.01)
		DrawBloom(0.30, 5, 5, 0, 1, 0.5, 0.5, 0, 0)
		DrawMaterialOverlay("effects/bleed_overlay", 0.2)
	end
	if LocalPlayer():Health() <=15 then
		DrawMaterialOverlay("effects/invuln_overlay_red", 0.01)
	end
end
hook.Add("RenderScreenspaceEffects", "bloomvision", Bloomvision)

hook.Add("Think", "AmmoDisplayToggle", function()
    local currentKeyState = input.IsKeyDown(KEY_T) and input.IsKeyDown(KEY_LALT)
    
    if currentKeyState and not lastKeyState then
        showAmmo = true
        ammoDisplayTime = CurTime()
        ammoFadeAlpha = 255
    end
    
    lastKeyState = currentKeyState
end)

hook.Add("Think", "AmmoFadeHandler", function()
    if showAmmo and CurTime() - ammoDisplayTime > 1 then
        ammoFadeAlpha = math.max(0, ammoFadeAlpha - FrameTime() * 1000)
        if ammoFadeAlpha <= 0 then
            showAmmo = false
        end
    elseif not showAmmo then
        ammoFadeAlpha = 0
    end
end)

function GetAmmoStatus(clip, maxclip)
    if clip == maxclip then
        return LANG.Get('FULLAMMO'), Color(0, 255, 0)
    elseif clip >= maxclip * 0.75 then
        return LANG.Get('MNOGAAMMO'), Color(100, 255, 100)
    elseif clip >= maxclip * 0.5 then
        return LANG.Get('POLOVINAAMMO'), Color(255, 255, 0)
    elseif clip >= maxclip * 0.25 then
        return LANG.Get('MALOAMMO'), Color(255, 165, 0)
    elseif clip > 0 then
        return LANG.Get('OCHMALOAMMO'), Color(255, 100, 100)
    else
        return LANG.Get('NETUAMMO'), Color(255, 0, 0)
    end
end

function GM:HUDDrawAmmo()
    if ammoFadeAlpha <= 0 then return end
    
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    
    if not IsValid(wep) then return end
    
    local clip = wep:Clip1()
    local maxclip = wep:GetMaxClip1()
    
    if clip == -1 then return end
    
    local x, y = scrw / 1.5, scrh / 1.8
    
    local statusText, color = GetAmmoStatus(clip, maxclip)
    
    local textColor = Color(color.r, color.g, color.b, ammoFadeAlpha)
    
    draw.SimpleText(statusText, "ui.40", x, y, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

hook.Add("RenderScreenspaceEffects", "ApplyDarkness", function()
    if CLIENT then
        local colormod = {
            ["$pp_colour_addr"] = 0,
            ["$pp_colour_addg"] = 0,
            ["$pp_colour_addb"] = 0,
            ["$pp_colour_brightness"] = 0,
            ["$pp_colour_contrast"] = 0.8,
            ["$pp_colour_colour"] = 0.6,
            ["$pp_colour_mulr"] = 0,
            ["$pp_colour_mulg"] = 0,
            ["$pp_colour_mulb"] = 0
        }
        
        DrawColorModify(colormod)
    end
end)

function monsterhud()
    if isChuchelo(LocalPlayer():Team()) then
        if LocalPlayer():Team() == TEAM_SHOOTER then return end
        DrawMaterialOverlay( "models/props_lab/Tank_Glass001", 0 )
    end
end

hook.Add( "RenderScreenspaceEffects", "chuchelo", monsterhud)

function GM:vignette()
    surface.SetDrawColor(255, 255, 255, 255)
	surface.SetMaterial(vigmat)
	surface.DrawTexturedRect(0, 0, scrw, scrh)

    draw.SimpleText(LANG.Get('VERSIA') .. ': RELEASE', "ui.22", scrw / 36.003 / 5 - 8, scrh / 180 - 7, Color(255, 255, 255, 3), TEXT_ALIGN_LEFT, TEXT_ALIGN_RIGHT)
end

function GM:hudspec()
    local boxWidth = 275
    local boxHeight = 75
    local boxX = (scrw - boxWidth) / 2
    local boxY = (scrh - boxHeight) / 1.1

    local cornerLength = 15
    local cornerThickness = 3
    local cornerOffset = 0

    draw.Box(boxX, boxY, boxWidth, boxHeight, cornerLength, cornerThickness, cornerOffset)

    local text = team.GetName(LocalPlayer():Team())
    local textFont = "ui.40"
    local textColor = color_white
    
    surface.SetFont(textFont)
    local textWidth, textHeight = surface.GetTextSize(text)

    local textX = boxX + boxWidth / 1.98
    local textY = boxY + boxHeight / 2.2
    
    draw.SimpleText(text, textFont, textX, textY, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end

function GM:HUDPaint()
    if LocalPlayer():Alive() then
        self:hudspec()
        self:HUDDrawAmmo()
    end
    self:vignette()
end