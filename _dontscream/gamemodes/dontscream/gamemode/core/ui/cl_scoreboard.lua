hook.Add('ScoreboardShow', 'dsScoreBoard', function()
    tab = vgui.Create('DPanel')
    tab:SetSize(weight(1200), height(800))
    tab:Center()
    tab:MakePopup()
    tab.Paint = function (self, w, h)
        draw.Blur(self)
        draw.Box(0, 0, w, h, 15, 3, 0)
    end

    local sp = vgui.Create('DScrollPanel', tab)
    sp:Dock(FILL)

    for k, pl in pairs(player.GetAll()) do
        local plrpnl = vgui.Create('DPanel', sp)
        plrpnl:Dock(TOP)
        plrpnl:DockMargin(10, 10, 10, 0)
        plrpnl:SetTall(50)
        plrpnl.Paint = function (self, w, h)
            draw.BoxCol(0, 0, w, h, 15, 3, 0, Color(48, 48, 48, 160))
            draw.SimpleText(pl:GetRandomNames(), 'ui.10', ScreenScale(17), 23, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            draw.SimpleText(pl:GetUserGroup(), 'ui.10', ScreenScale(195), 23, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
            draw.SimpleText(pl:Ping(), 'ui.10', ScreenScale(385), 23, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local plravt = vgui.Create("AvatarImage", plrpnl)
        plravt:SetSize(40, 40)
        plravt:SetPos(5, 5)
        plravt:SetPlayer(pl, 64)

        plrpnl.OnMousePressed = function(self, code)
            if code == MOUSE_LEFT then
                surface.PlaySound('buttons/blip1.wav')
                OpenPlayerInfo(pl)
            end
        end
    end

    return false
end)

hook.Add('ScoreboardHide', 'dsScoreBoard', function()
    tab:Remove()
    return false
end)

function OpenPlayerInfo(pl)
    local frame = vgui.Create('DFrame')
    frame:SetSize(350, 250)
    frame:Center()
    frame:MakePopup()
    frame:SetTitle(LANG.Get('TABINFO'))
    frame.Paint = function(self, w, h)
        draw.Blur(self)
        draw.Box(0, 0, w, h, 15, 3, 0)
    end

    local nickLabel = vgui.Create('DLabel', frame)
    nickLabel:SetPos(15, 30)
    nickLabel:SetSize(320, 20)
    nickLabel:SetText(LANG.Get('TABNICK') .. pl:Nick())
    nickLabel:SetColor(color_white)

    local steamIdLabel = vgui.Create('DLabel', frame)
    steamIdLabel:SetPos(15, 60)
    steamIdLabel:SetSize(320, 20)
    steamIdLabel:SetText('Steam ID: ' .. pl:SteamID())
    steamIdLabel:SetColor(color_white)

    local copyBtn = vgui.Create('DButton', frame)
    copyBtn:SetPos(15, 90)
    copyBtn:SetSize(120, 30)
    copyBtn:SetText(LANG.Get('TABIDCOPY'))
    copyBtn.DoClick = function()
        surface.PlaySound('buttons/blip1.wav')
        copyBtn:SetText(LANG.Get('TABIDCOPY2'))
        timer.Simple(1, function()
        	copyBtn:SetText(LANG.Get('TABIDCOPY'))
		end)
        SetClipboardText(pl:SteamID())
    end

    local country = pl:GetNWString("country", "none")
    local flagIcon = vgui.Create('DImage', frame)
    flagIcon:SetPos(15, 130)
    flagIcon:SetSize(32, 32)
    flagIcon:SetImage( "flags16/" .. string.lower(country) .. ".png" )

    local countryLabel = vgui.Create('DLabel', frame)
    countryLabel:SetPos(60, 135)
    countryLabel:SetSize(270, 20)
    countryLabel:SetText(LANG.Get('TABSTRANA') .. (country == 'none' and 'Неизвестно' or country))
    countryLabel:SetColor(color_white)
end