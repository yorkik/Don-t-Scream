local PANEL = {}

function PANEL:Init()
    self:SetSize(ScrW() * 0.8, ScrH() * 0.65)
    self:Center()
    self:MakePopup()
    self:SetTitle(LANG.Get('F4MENU'))
    self:ShowCloseButton(false)
    self:SetDraggable(true)
    self.Paint = function(s, w, h)
        draw.Blur(self)
        draw.Box(0, 0, w, h, 10, 2, 0)
    end

    local closeBtn = vgui.Create("DButton", self)
    closeBtn:SetSize(30, 30)
    closeBtn:SetPos(self:GetWide() - 40, 10)
    closeBtn:SetText("×")
    closeBtn:SetFont("DermaLarge")
    closeBtn:SetTextColor(Color(255, 255, 255))
    closeBtn.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(255, 0, 0, s:IsHovered() and 100 or 50))
    end
    closeBtn.DoClick = function()
        self:Remove()
    end
    
    self.TabContainer = vgui.Create("DPropertySheet", self)
    self.TabContainer:Dock(FILL)
    self.TabContainer:DockMargin(10, 0, 10, 10)
    self.TabContainer.Paint = function(s, w, h) end

    self:AddConfigTab(LANG.Get('F4MENUMAIN'), self:CreateMainTab())
    self:AddConfigTab(LANG.Get('F4MENUSETT'), self:CreateSettingsTab())
    self:AddConfigTab('Discord', nil, "https://discord.com/invite/cSmhecewkY")
    self:AddConfigTab(LANG.Get('F4MENUCONT'), nil, "https://steamcommunity.com/sharedfiles/filedetails/?id=3628823731")
end

function PANEL:AddConfigTab(name, panel, url)
    if url then
        local emptyPanel = vgui.Create("DPanel")
        emptyPanel:SetVisible(false)
        
        local sheet = self.TabContainer:AddSheet(name, emptyPanel, nil, nil, nil)
        if sheet and sheet.Tab then
            local btn = sheet.Tab
            btn.Paint = function(s, w, h)
                if s:IsActive() then
                    draw.BoxCol(0, 0, w, h, 6, 2, 0, Color(60, 60, 60, 255))
                else
                    draw.BoxCol(0, 0, w, h, 6, 2, 0, Color(40, 40, 40, 200))
                end
            end
            
            btn.DoClick = function()
                self:Remove()
                gui.OpenURL(url)
            end
        end
    else
        local sheet = self.TabContainer:AddSheet(name, panel, nil, nil, nil)
        if sheet and sheet.Tab then
            local btn = sheet.Tab
            btn.Paint = function(s, w, h)
                if s:IsActive() then
                    draw.BoxCol(0, 0, w, h, 6, 2, 0, Color(60, 60, 60, 255))
                else
                    draw.BoxCol(0, 0, w, h, 6, 2, 0, Color(40, 40, 40, 200))
                end
            end
        end
    end
end

function PANEL:CreateMainTab()
    local panel = vgui.Create("DPanel")
    panel:Dock(FILL)
    panel.Paint = function(s, w, h) end
    
    local html = vgui.Create("DHTML", panel)
    html:Dock(FILL)
    html:OpenURL("https://yorkik.github.io/dontscream.github.io")
    
    return panel
end

function PANEL:CreateSettingsTab()
    local panel = vgui.Create("DPanel")
    panel:Dock(FILL)
    panel.Paint = function(s, w, h)
        draw.BoxCol(0, 0, w, h, 10, 2, 0, Color(82, 82, 82, 100))
    end

    local scroll = vgui.Create("DScrollPanel", panel)
    scroll:Dock(FILL)
    scroll:DockMargin(10, 10, 10, 10)

    local form = vgui.Create("DForm", scroll)
    form:Dock(TOP)
    form:SetName(LANG.Get('F4MENUSETT'))

    local languageLabel = vgui.Create("DLabel", form)
    languageLabel:SetText(LANG.Get('SELECT_LANGUAGE'))
    languageLabel:SetTextColor(color_white)
    languageLabel:SizeToContents()

    local language = form:ComboBox("")
    language:AddChoice("Русский (Нужно перезайти)")
    language:AddChoice("English (Need to reconnect)")
    language.OnSelect = function(panel, index, value)
        if value == "Русский (Нужно перезайти)" then
            LANG.Set("russian")
        elseif value == "English (Need to reconnect)" then
            LANG.Set("english")
        end
    end

    form:AddItem(languageLabel, language)

    return panel
end

vgui.Register("MainMenu", PANEL, "DFrame")

hook.Add("PlayerButtonDown", "OpenMainMenu", function(ply, button)
    if button != KEY_F4 then return end
    if CLIENT and not IsFirstTimePredicted() then return end
    if IsValid(MainMenu) then
        MainMenu:Remove()
    else
        MainMenu = vgui.Create("MainMenu")
    end
    return true
end)