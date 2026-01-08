local function chatuniversav(chatcommand, deistvie)
    return function(ply, text, team)
        if string.lower(text) == "!" .. chatcommand or string.lower(text) == "/" .. chatcommand then
            deistvie(ply, text, team)
            return ""
        end
    end
end

hook.Add("PlayerSay", "OpenDiscordLink", chatuniversav("ds", function(ply, text, team)
    ply:SendLua([[gui.OpenURL("https://discord.com/invite/cSmhecewkY")]])
end))