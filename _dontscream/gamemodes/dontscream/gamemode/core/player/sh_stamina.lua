local PLAYER = FindMetaTable("Player")
function PLAYER:BlockStamina()
    if SERVER then
        self:SetNWBool("StaminaBlocked", true)
    end
end

function PLAYER:UnblockStamina()
    if SERVER then
        self:SetNWBool("StaminaBlocked", false)
    end
end

MAX_STAMINA = 100
STAMINA_REGEN_RATE = 15
JUMP_STAMINA_COST = 17
SPRINT_STAMINA_DRAIN = 8

local breathSounds = {}

if SERVER then
    util.AddNetworkString("UpdateStamina")
    util.AddNetworkString("PlayBreathSound")
    util.AddNetworkString("StopBreathSound")
    util.AddNetworkString("SendBreathSound")

    local function GetBreathSound(ply)
        local model = ply:GetModel():lower()
        if string.find(model, "female") then
            return "dontscream/otdishka/ustal_f.wav"
        else
            return "dontscream/otdishka/ustal_m.wav"
        end
    end

    local function RegenerateStamina(ply)
        if IsValid(ply) and ply:Alive() then
            if ply:GetNWBool("StaminaBlocked", false) then return end
            local currentStamina = ply:GetNWInt("Stamina")
            local isStaminaRegenFromZero = ply:GetNWBool("IsStaminaRegenFromZero", false)
            
            if currentStamina < MAX_STAMINA and not ply:IsSprinting() and not ply:KeyDown(IN_SPEED) then
                local newStamina = math.min(MAX_STAMINA, currentStamina + STAMINA_REGEN_RATE * FrameTime())
                ply:SetNWInt("Stamina", newStamina)
                net.Start("UpdateStamina")
                net.WriteFloat(newStamina)
                net.Send(ply)

                if isStaminaRegenFromZero and not breathSounds[ply:EntIndex()] then
                    breathSounds[ply:EntIndex()] = true
                    local soundPath = GetBreathSound(ply)
                    net.Start("SendBreathSound")
                    net.WriteString(soundPath)
                    net.Send(ply)
                end

                if isStaminaRegenFromZero and newStamina >= MAX_STAMINA then
                    ply:SetNWBool("IsStaminaRegenFromZero", false)
                    breathSounds[ply:EntIndex()] = nil
                    net.Start("StopBreathSound")
                    net.Send(ply)
                end
            elseif currentStamina >= MAX_STAMINA and isStaminaRegenFromZero then
                ply:SetNWBool("IsStaminaRegenFromZero", false)
                breathSounds[ply:EntIndex()] = nil
                net.Start("StopBreathSound")
                net.Send(ply)
            end
        end
    end

    hook.Add("Think", "StaminaThink", function()
        for _, ply in ipairs(player.GetAll()) do
            if IsValid(ply) and ply:Alive() then
                if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNWBool("StaminaBlocked", false) then 
                    RegenerateStamina(ply)
                else
                    local isStaminaRegenFromZero = ply:GetNWBool("IsStaminaRegenFromZero", false)
                    
                    if ply:KeyPressed(IN_JUMP) then
                        local currentStamina = ply:GetNWInt("Stamina")
                        if currentStamina <= JUMP_STAMINA_COST or isStaminaRegenFromZero then
                            ply:SetNWInt("Stamina", 0)
                            ply:SetNWBool("IsSprinting", false)
                            ply:ConCommand("-speed")
                            ply:SetJumpPower(0)
                            timer.Simple(0.1, function()
                                if IsValid(ply) then
                                    ply:SetJumpPower(200)
                                end
                            end)
                        else
                            ply:SetNWInt("Stamina", currentStamina - JUMP_STAMINA_COST)
                            ply:SetJumpPower(200)
                        end
                    end

                    if ply:KeyDown(IN_SPEED) then
                        local vel = ply:GetVelocity()
                        local moveSpeed = math.sqrt(vel.x^2 + vel.y^2)
                        
                        local currentStamina = ply:GetNWInt("Stamina")
                        if isStaminaRegenFromZero then
                            ply:SetNWBool("IsSprinting", false)
                            ply:ConCommand("-speed")
                        elseif currentStamina > 0 and moveSpeed > 10 then
                            local newStamina = math.max(0, currentStamina - SPRINT_STAMINA_DRAIN * FrameTime())
                            ply:SetNWInt("Stamina", newStamina)
                            ply:SetNWBool("IsSprinting", true)
                            net.Start("UpdateStamina")
                            net.WriteFloat(newStamina)
                            net.Send(ply)
                            if newStamina <= 0 then
                                ply:ConCommand("-speed")
                            end
                        else
                            ply:SetNWBool("IsSprinting", false)
                            if moveSpeed <= 10 then
                                RegenerateStamina(ply)
                            end
                        end
                    else
                        ply:SetNWBool("IsSprinting", false)

                        local currentStamina = ply:GetNWInt("Stamina")
                        if currentStamina == 0 and not ply:GetNWBool("IsStaminaRegenFromZero", false) then
                            ply:SetNWBool("IsStaminaRegenFromZero", true)
                            breathSounds[ply:EntIndex()] = nil
                        end
                        
                        RegenerateStamina(ply)
                    end
                end
            end
        end
    end)

    hook.Add("StartCommand", "BlockCommandsDuringRegen", function(ply, cmd)
        if IsValid(ply) and ply:Alive() then
            if ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetNWBool("StaminaBlocked", false) then return end
            if not ply:GetMoveType() == MOVETYPE_WALK then return end
            if ply:GetNWBool("IsStaminaRegenFromZero", false) then
                cmd:RemoveKey(IN_SPEED)
                cmd:RemoveKey(IN_JUMP)
            end
        end
    end)

    net.Receive("PlayBreathSound", function(len, ply)
    end)
end

if CLIENT then
    local stamina = MAX_STAMINA
    local lastStamina = MAX_STAMINA
    local displayStamina = MAX_STAMINA
    local lerpSpeed = 5
    local breathSound = nil
    local currentBreathSoundPath = ""

    net.Receive("UpdateStamina", function()
        stamina = net.ReadFloat()
    end)

    net.Receive("SendBreathSound", function()
        local soundPath = net.ReadString()
        if soundPath ~= currentBreathSoundPath then
            currentBreathSoundPath = soundPath
        end
        
        if not breathSound or not breathSound:IsPlaying() then
            LocalPlayer():EmitSound(soundPath, 75, 100, 0.5)
        end
    end)

    net.Receive("StopBreathSound", function()
        if currentBreathSoundPath ~= "" then
            LocalPlayer():StopSound(currentBreathSoundPath)
        end
    end)

    hook.Add("HUDPaint", "DrawStaminaBar", function()
        local ply = LocalPlayer()
        if not IsValid(ply) or not ply:Alive() then return end

        if stamina >= MAX_STAMINA then
            displayStamina = MAX_STAMINA
        elseif displayStamina ~= stamina then
            displayStamina = Lerp(FrameTime() * lerpSpeed, displayStamina, stamina)
        end

        if displayStamina >= MAX_STAMINA then return end
        if ply:GetNWBool("StaminaBlocked", false) then return end

        local x = ScreenScale(320)
        local y = ScreenScale(295)
        local width = 200
        local height = 20
        local padding = 4
        local cornerLength = 6
        local cornerThickness = 2
        local cornerOffset = 0

        draw.Box(x - width / 2, y, width, height, cornerLength, cornerThickness, cornerOffset)

        local barWidth = (displayStamina / MAX_STAMINA) * (width - padding * 2)
        surface.SetDrawColor(255, 255, 255)
        surface.DrawRect(x - width / 2 + padding, y + padding, barWidth, height - padding * 2)
    end)
end