if SERVER then
    util.AddNetworkString("VolumeInputESP")
    util.AddNetworkString("EnableESPFromVoice")
    util.AddNetworkString("EnableESPFromAbility")


    ESPForChuchela = ESPForChuchela or {}
    ESPEndTime = ESPEndTime or {}
    
    net.Receive("VolumeInputESP", function(len, ply)
        local volume = net.ReadFloat()
        local volumeThreshold = 32 / 300
        
        if volume >= volumeThreshold then
            for _, listener in ipairs(player.GetAll()) do
                if listener ~= ply and isChuchelo(listener:Team()) then
                    local canHear, isInRange = hook.Run("PlayerCanHearPlayersVoice", listener, ply)
                    if (canHear ~= false) and (isInRange ~= false) then
                        ESPForChuchela[listener:SteamID()] = CurTime() + 1
                        
                        net.Start("EnableESPFromVoice")
                        net.WriteEntity(listener)
                        net.WriteEntity(ply)
                        net.WriteFloat(CurTime() + 1)
                        net.Send(listener)
                        
                        for _, otherChuchelo in ipairs(player.GetAll()) do
                            if otherChuchelo ~= listener and otherChuchelo ~= ply and isChuchelo(otherChuchelo:Team()) then
                                net.Start("EnableESPFromVoice")
                                net.WriteEntity(otherChuchelo)
                                net.WriteEntity(ply)
                                net.WriteFloat(CurTime() + 1)
                                net.Send(otherChuchelo)
                            end
                        end
                    end
                end
            end
        end
    end)
    
    net.Receive("EnableESPFromAbility", function(len, ply)
        local lastUse = ply.LastESPTime or 0
        if CurTime() - lastUse < 3 then return end
        
        ESPEndTime[ply:SteamID()] = CurTime() + 10
        ply.LastESPTime = CurTime()
        
        net.Start("EnableESPFromAbility")
        net.WriteEntity(ply)
        net.WriteFloat(ESPEndTime[ply:SteamID()])
        net.Broadcast()
    end)
end

if CLIENT then
    ESPForChuchela = ESPForChuchela or {}
    LoudPlayers = LoudPlayers or {}
    ESPEndTime = ESPEndTime or {}
    
    net.Receive("EnableESPFromVoice", function()
        local playerWhoGotESP = net.ReadEntity()
        local loudPlayer = net.ReadEntity()
        local endTime = net.ReadFloat()
        
        if playerWhoGotESP:IsValid() and loudPlayer:IsValid() then
            if playerWhoGotESP == LocalPlayer() then
                ESPForChuchela[playerWhoGotESP:SteamID()] = endTime
            end
            LoudPlayers[loudPlayer:EntIndex()] = endTime
        end
    end)
    
    net.Receive("EnableESPFromAbility", function()
        local ply = net.ReadEntity()
        local endTime = net.ReadFloat()
        
        if ply:IsValid() then
            ESPEndTime[ply:SteamID()] = endTime
        end
    end)
    
    local function SendVolumeForESP()
        local ply = LocalPlayer()
        local volume = ply:VoiceVolume()
        if volume > .01 then
            net.Start("VolumeInputESP")
            net.WriteFloat(volume)
            net.SendToServer()
        end
    end
    
    hook.Add("PreDrawHalos", "AddPlayerHalosFromVoice", function()
        if not isChuchelo(LocalPlayer():Team()) then return end
        
        local steamID = LocalPlayer():SteamID()
        local espEndTime = ESPForChuchela[steamID] or 0
        local abilityEspEndTime = ESPEndTime[steamID] or 0
        local currentTime = CurTime()
        
        local loudEntities = {}
        
        if currentTime <= espEndTime then
            for entIdx, endTime in pairs(LoudPlayers) do
                if endTime > currentTime then
                    local ply = Entity(entIdx)
                    if ply and ply:IsValid() and ply:IsPlayer() then
                        table.insert(loudEntities, ply)
                    end
                end
            end
        end
        
        if currentTime <= abilityEspEndTime then
            local players = player.GetAll()
            local distance = 4096
            for _, ply in ipairs(players) do
                if ply ~= LocalPlayer() and ply:GetPos():Distance(LocalPlayer():GetPos()) <= distance then
                    if not table.HasValue(loudEntities, ply) then
                        table.insert(loudEntities, ply)
                    end
                end
            end
        end
        
        if #loudEntities > 0 then
            if currentTime <= espEndTime then
                halo.Add(loudEntities, Color(0, 255, 0), 2, 2, 2, true, true)
            else
                halo.Add(loudEntities, Color(255, 255, 255), 1, 1, 16, true, true)
            end
        end
    end)
    
    hook.Add("Think", "SendVolumeForESP", SendVolumeForESP)
end