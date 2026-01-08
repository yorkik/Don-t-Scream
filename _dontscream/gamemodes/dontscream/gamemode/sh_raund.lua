ROUND_WAITING = 0
ROUND_PREP = 1
ROUND_ACTIVE = 2
ROUND_POST = 3

local ROUND_SETTINGS = {
    MinPlayers = 3,
    PrepTime = 3,
    RoundTime = 600,
    PostTime = 10,
}

RoundState = ROUND_WAITING
RoundNumber = 0
RoundStartTime = 0
RoundEndTime = 0

if SERVER then
    util.AddNetworkString("RoundInfo")
    util.AddNetworkString("SurvivorWinMessage")

    function StartPrepPhase()
        timer.Remove("RoundTimer")

        ClearAllDeathRagdolls()
    
        RoundState = ROUND_PREP
        RoundNumber = RoundNumber + 1
        RoundStartTime = CurTime()
        RoundEndTime = RoundStartTime + ROUND_SETTINGS.PrepTime
    
        net.Start("RoundInfo")
            net.WriteUInt(RoundState, 3)
            net.WriteUInt(RoundNumber, 8)
            net.WriteFloat(RoundEndTime)
        net.Broadcast()
    
        timer.Create("RoundTimer", ROUND_SETTINGS.PrepTime, 1, function()
            StartActivePhase()
        end)

        for _, ent in ipairs(ents.FindByClass("ds_fuel")) do
            if IsValid(ent) then
                ent:Remove()
            end
        end
        
        for _, class in ipairs({
            "ds_adrenalyn",
            "ds_betablock", 
            "ds_flare_swep",
            "ds_detector",
            "ds_shotgun_beanbag"
        }) do
            for _, ent in ipairs(ents.FindByClass(class)) do
                if IsValid(ent) then
                    ent:Remove()
                end
            end
        end

        local map = game.GetMap()
        local spawnfuel = cfg.spawnFuel[map]
        if spawnfuel and #spawnfuel > 0 then
            for _, pos in ipairs(spawnfuel) do
                local ent = ents.Create("ds_fuel")
                ent:SetPos(pos)
                ent:Spawn()
                ent:Activate()
            end
        end

        for _, ent in ipairs(ents.FindByClass("ds_loot")) do
            if IsValid(ent) then
                ent:ResetForNewRound()
            end
        end

        for _, ent in ipairs(ents.FindByClass("ds_generator")) do
            if IsValid(ent) then
                ent:ResetGenerator()
                ent.RequiredSequence = {}
                ent:StopSound("ambient/machines/diesel_engine_idle1.wav")
            end
        end

        for _, ply in player.Iterator() do
            ply:StopSound("dontscream/trevoga.wav")
        end
    
        for _, ply in player.Iterator() do
            ply:SetTeam(TEAM_PLAYER)
            ply:KillSilent()
            ply:Spawn()
            ply:SetRandomNames()
            ABILITIES.Clear(ply)
            ply:UnblockStamina()
        end
    end
    
    function StartActivePhase()
        timer.Remove("RoundTimer")

        ClearAllDeathRagdolls()

        RoundState = ROUND_ACTIVE
        RoundStartTime = CurTime()
        RoundEndTime = RoundStartTime + ROUND_SETTINGS.RoundTime

        for _, ply in player.Iterator() do
            ply:EmitSound("dontscream/trevoga.wav")
        end

        net.Start("RoundInfo")
            net.WriteUInt(RoundState, 3)
            net.WriteUInt(RoundNumber, 8)
            net.WriteFloat(RoundEndTime)
        net.Broadcast()

        AssignRoles()

        timer.Create("CheckAlivePlayers", 1, 0, CheckAlivePlayers)
        timer.Create("CheckGenerators", 1, 0, CheckGenerators)

        timer.Create("RoundTimer", ROUND_SETTINGS.RoundTime, 1, function()
            StartPostPhase()
        end)
    end
    
    function CheckGenerators()
    if RoundState ~= ROUND_ACTIVE then 
        timer.Remove("CheckGenerators")
        return 
    end

    local activeGenerators = 0
    for _, ent in ipairs(ents.FindByClass("ds_generator")) do
        if IsValid(ent) then
            if ent.IsRunning then
                activeGenerators = activeGenerators + 1
            end
        end
    end

    RunningGenerators = activeGenerators

    if activeGenerators >= 3 then
        timer.Remove("CheckGenerators")
        timer.Remove("CheckAlivePlayers")
        timer.Remove("RoundTimer")

        net.Start("SurvivorWinMessage")
        net.Broadcast()
        StartPostPhase()
    end
end
    
    function CheckAlivePlayers()
        if RoundState ~= ROUND_ACTIVE then 
            timer.Remove("CheckAlivePlayers")
            return 
        end
        
        local alivePlayers = 0
        for _, ply in player.Iterator() do
            if IsValid(ply) and ply:Team() == TEAM_PLAYER and ply:Alive() then
                alivePlayers = alivePlayers + 1
            end
        end
        
        if alivePlayers == 0 then
            timer.Remove("CheckAlivePlayers")
            timer.Remove("CheckGenerators")
            timer.Remove("RoundTimer")

            net.Start("MonsterWinMessage")
            net.Broadcast()
            StartPostPhase()
        end
    end
    
    function StartPostPhase()
        timer.Remove("CheckAlivePlayers")
        timer.Remove("CheckGenerators")
        timer.Remove("RoundTimer")

        ClearAllDeathRagdolls()
    
        RoundState = ROUND_POST
        RoundStartTime = CurTime()
        RoundEndTime = RoundStartTime + ROUND_SETTINGS.PostTime
    
        net.Start("RoundInfo")
            net.WriteUInt(RoundState, 3)
            net.WriteUInt(RoundNumber, 8)
            net.WriteFloat(RoundEndTime)
        net.Broadcast()

        for _, ply in player.Iterator() do
            ply:StopSound("dontscream/trevoga.wav")
        end
    
        for _, ply in player.Iterator() do
            if IsValid(ply) then
                ply:SetTeam(TEAM_SPEC)
                ply:Spectate(OBS_MODE_ROAMING)
                ply:SpectateEntity(nil)
                ply:Flashlight(false)
                ply:StripWeapons()
                ABILITIES.Clear(ply)
                ply:BlockStamina()
            end
        end
    
        timer.Create("RoundTimer", ROUND_SETTINGS.PostTime, 1, function()
            CheckForNextRound()
        end)
    end

    function CheckForNextRound()
        StartPrepPhase()
    end

    function AssignRoles()
        local players = {}
        for _, ply in player.Iterator() do
            if IsValid(ply) and ply:Team() == TEAM_PLAYER and ply:Alive() then
                table.insert(players, ply)
            end
        end

        if #players == 0 then return end

        local availableRoles = {TEAM_HUNTER, TEAM_DEXTER, TEAM_PARANORMAL} -- , TEAM_SHOOTER
        local chosenRole = table.Random(availableRoles)

        local ply = players[math.random(1, #players)]
        ply:SetTeam(TEAM_SHOOTER)
        ply:KillSilent()
        ply:Spawn()
        ply:BlockStamina()
        ply:Flashlight(false)
        ABILITIES.Setup(ply, 'esp')
        ABILITIES.SetupTeam(TEAM_PARANORMAL, "cloak")
        ABILITIES.SetupTeam(TEAM_HUNTER, "jump")
        ABILITIES.SetupTeam(TEAM_DEXTER, "skin")

        if ply:Team() == TEAM_SHOOTER then
            --ply:Flashlight(false)
            ABILITIES.Clear(ply)
        end
    end

    hook.Add("PlayerInitialSpawn", "PlayerJoinRound", function(ply)
        if not RoundState == ROUND_WAITING then
            timer.Simple(0.2, function()
                ply:SetTeam(TEAM_SPEC)
                ply:Spectate(OBS_MODE_ROAMING)
                ply:SpectateEntity(nil)
            end)
        end

        timer.Simple(1, function()
            if not IsValid(ply) then return end
            net.Start("RoundInfo")
                net.WriteUInt(RoundState, 3)
                net.WriteUInt(RoundNumber, 8)
                net.WriteFloat(RoundEndTime)
            net.Send(ply)
        end)

        if RoundState == ROUND_WAITING then
            local count = 0
            for _, p in player.Iterator() do
                if p:Team() ~= TEAM_SPEC then count = count + 1 end
            end
            if count >= ROUND_SETTINGS.MinPlayers then
                StartPrepPhase()
            end
        end
    end)

    hook.Add("Think", "AutoStartCheck", function()
        if RoundState == ROUND_WAITING and CurTime() % 5 < FrameTime() then
            local count = 0
            for _, ply in player.Iterator() do
                if ply:Team() ~= TEAM_SPEC then count = count + 1 end
            end
            if count >= ROUND_SETTINGS.MinPlayers then
                StartPrepPhase()
            end
        end
    end)

    util.AddNetworkString("MonsterWinMessage")
    util.AddNetworkString("SurvivorWinMessage")
    
    net.Receive("MonsterWinMessage", function(len, ply)
    end)

end

if CLIENT then
    ClientRoundState = ROUND_WAITING
    ClientRoundNumber = 0
    ClientRoundEndTime = 0

    net.Receive("RoundInfo", function(len)
        ClientRoundState = net.ReadUInt(3)
        ClientRoundNumber = net.ReadUInt(8)
        ClientRoundEndTime = net.ReadFloat()

        if ClientRoundState == ROUND_ACTIVE then
            for _, ply in pairs(player.GetAll()) do
                ply:PrintMessage(HUD_PRINTCENTER, LANG.Get('RUUUUN'))
            end
        end
    end)

    net.Receive("MonsterWinMessage", function()
        for _, ply in pairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTCENTER, LANG.Get('RNDLOST'))
        end
    end)

    net.Receive("SurvivorWinMessage", function()
        for _, ply in pairs(player.GetAll()) do
            ply:PrintMessage(HUD_PRINTCENTER, LANG.Get('SURVIVOR_WIN'))
        end
    end)

    hook.Add("HUDPaint", "DrawRoundTimer", function()
        local stateStr = LANG.Get('WAITPLY')
        if ClientRoundState == ROUND_PREP then stateStr = LANG.Get('PREP')
        elseif ClientRoundState == ROUND_ACTIVE then stateStr = ''
        elseif ClientRoundState == ROUND_POST then stateStr = LANG.Get('ENDRND') end
    
        local timeLeft = math.max(0, ClientRoundEndTime - CurTime())
        local timeStr = string.FormattedTime(timeLeft, "%02i:%02i")
    
        local cornerLength = 10
        local cornerThickness = 3
        local cornerOffset = 0

        local textColor = color_white
        if ClientRoundState == ROUND_PREP and timeLeft <= 5 then
            textColor = Color(255, 0, 0)
        elseif ClientRoundState == ROUND_ACTIVE and timeLeft <= 10 then
            textColor = Color(255, 0, 0)
        end
    
        draw.Box(ScreenScale(307.67), ScrH() * 0.0025, ScreenScale(32), ScreenScale(14), cornerLength, cornerThickness, cornerOffset)
    
        draw.SimpleText(stateStr, "ui.30", weight(972), weight(45), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        draw.SimpleText(timeStr, "ui.38", weight(972), ScrH() * 0.001, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
    end)
end