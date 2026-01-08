AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Генератор"
ENT.Author = "Fuzzy"
ENT.Category = "Don't Scream - Tools"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.FuelAmount = 0
ENT.MaxFuel = 100
ENT.IsRunning = false
ENT.IsStarting = false
ENT.StartProgress = 0
ENT.StartDuration = 10
ENT.QTEKeys = {"a", "b", "c", "d", "e", "f", "g"}
ENT.RequiredSequence = {}
ENT.CurrentSequenceIndex = 1
ENT.QTETimeout = 2
ENT.QTEStartTime = 0

if SERVER then
    util.AddNetworkString('GeneratorStartProgress')
    util.AddNetworkString('GeneratorFuelUpdate')
    util.AddNetworkString('StartGeneratorStart')
    util.AddNetworkString('GeneratorStartResult')
    util.AddNetworkString('ShowGeneratorQTE')
    util.AddNetworkString('HideGeneratorQTE')
    util.AddNetworkString('UpdateGeneratorQTE')
    util.AddNetworkString('QTEFailed')
    util.AddNetworkString('MouseQTEInput')

    function ENT:Initialize()
        self:SetModel("models/props_mining/diesel_generator.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid(phys) then
            phys:Wake()
            phys:EnableMotion(false)
        end
        
        self:ResetGenerator()
    end

    function ENT:ResetGenerator()
        self.FuelAmount = 0
        self.IsRunning = false
        self.IsStarting = false
        self.StartProgress = 0
        self.StartingPlayer = nil
        self.RequiredSequence = {}
        self.CurrentSequenceIndex = 1
        self.QTEStartTime = 0
        
        -- Отправляем обновления клиентам
        net.Start("GeneratorFuelUpdate")
        net.WriteEntity(self)
        net.WriteInt(0, 8)
        net.Broadcast()
        
        net.Start("GeneratorStartProgress")
        net.WriteEntity(self)
        net.WriteFloat(0)
        net.WriteBool(false)
        net.Broadcast()
    end

    function ENT:AddFuel(amount)
        self.FuelAmount = math.min(self.FuelAmount + amount, self.MaxFuel)
        net.Start("GeneratorFuelUpdate")
        net.WriteEntity(self)
        net.WriteInt(self.FuelAmount, 8)
        net.Broadcast()
    end

    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if RoundState == ROUND_WAITING or RoundState == ROUND_POST then return end

        local hasFuel = false
        local wep = activator:GetActiveWeapon()
        if IsValid(wep) and wep:GetClass() == "ds_fuel" then
            hasFuel = true
        end
        
        if hasFuel and self.FuelAmount < self.MaxFuel then
            self:AddFuel(25)
            activator:StripWeapon("ds_fuel")
            self:EmitSound('ambient/water/leak_1.wav')
            timer.Simple(3, function()
                self:StopSound('ambient/water/leak_1.wav')
            end)
        elseif self.FuelAmount >= 100 then
            if not self.IsRunning and not self.IsStarting then
                -- Начинаем процесс запуска
                self.IsStarting = true
                self.StartProgress = 0
                self.StartingPlayer = activator
                self.RequiredSequence = {}
                self.CurrentSequenceIndex = 1
                
                for i = 1, 4 do
                    local randomKey = table.Random(self.QTEKeys)
                    if randomKey then
                        table.insert(self.RequiredSequence, randomKey)
                    end
                end
                
                self.QTEStartTime = CurTime()
                
                net.Start("ShowGeneratorQTE")
                net.WriteEntity(self)
                net.WriteTable(self.RequiredSequence)
                net.WriteInt(self.CurrentSequenceIndex, 8)
                net.Send(activator)
                
                -- Таймер на время выполнения QTE
                timer.Create("GeneratorQTETimeout_" .. self:EntIndex(), self.QTETimeout, 1, function()
                    if IsValid(self) and self.IsStarting then
                        self:CancelGeneratorStart(activator)
                        net.Start("QTEFailed")
                        net.Send(activator)
                    end
                end)
            elseif self.IsRunning then
                self.IsRunning = false
                self:StopSound("ambient/machines/diesel_engine_idle1.wav")
                self:EmitSound("ambient/machines/engine1_stop.wav")
                
                net.Start("HideGeneratorQTE")
                net.Send(activator)
            end
        end
    end
    
    function ENT:HandleQTEInput(ply, key)
        if not IsValid(ply) or not self.IsStarting or ply ~= self.StartingPlayer then return end
        
        -- Сбрасываем таймер
        timer.Remove("GeneratorQTETimeout_" .. self:EntIndex())
        
        if self.CurrentSequenceIndex <= #self.RequiredSequence and key == self.RequiredSequence[self.CurrentSequenceIndex] then
            -- Правильная клавиша
            self.CurrentSequenceIndex = self.CurrentSequenceIndex + 1
            self.StartProgress = (self.CurrentSequenceIndex - 1) / #self.RequiredSequence
            
            if self.CurrentSequenceIndex > #self.RequiredSequence then
                -- Успешно завершена вся последовательность
                self.IsStarting = false
                self.IsRunning = true
                self.StartingPlayer = nil
                self:EmitSound("ambient/machines/diesel_engine_idle1.wav")
                
                net.Start("GeneratorStartResult")
                net.WriteEntity(self)
                net.WriteBool(true) -- success
                net.Broadcast()
                
                net.Start("HideGeneratorQTE")
                net.Send(ply)
            else
                -- Переходим к следующей клавише
                net.Start("UpdateGeneratorQTE")
                net.WriteEntity(self)
                net.WriteInt(self.CurrentSequenceIndex, 8)
                net.Send(ply)
                
                -- Новый таймер на следующую клавишу
                timer.Create("GeneratorQTETimeout_" .. self:EntIndex(), self.QTETimeout, 1, function()
                    if IsValid(self) and self.IsStarting then
                        self:CancelGeneratorStart(ply)
                        net.Start("QTEFailed")
                        net.Send(ply)
                    end
                end)
            end
        else
            -- Неправильная клавиша
            self:CancelGeneratorStart(ply)
            net.Start("QTEFailed")
            net.Send(ply)
        end
    end
    
    function ENT:CancelGeneratorStart(ply)
        if self.IsStarting and self.StartingPlayer == ply then
            self.IsStarting = false
            self.StartProgress = 0
            self.StartingPlayer = nil
            self.RequiredSequence = {}
            self.CurrentSequenceIndex = 1
            
            timer.Remove("GeneratorQTETimeout_" .. self:EntIndex())
            
            net.Start("HideGeneratorQTE")
            net.Send(ply)
        end
    end

    net.Receive("MouseQTEInput", function(len, ply)
        local ent = net.ReadEntity()
        local key = net.ReadString()
        
        if IsValid(ent) and ent:GetClass() == "ds_generator" then
            ent:HandleQTEInput(ply, key)
        end
    end)
    
    function ENT:Think()
        if self.IsRunning and self.FuelAmount > 0 then
            self.FuelAmount = self.FuelAmount - 0.01
            if self.FuelAmount <= 0 then
                self.FuelAmount = 0
                self.IsRunning = false
                self:StopSound("ambient/machines/diesel_engine_idle1.wav")
                self:EmitSound("ambient/machines/engine1_stop.wav")
                
                net.Start("GeneratorStartProgress")
                net.WriteEntity(self)
                net.WriteFloat(0)
                net.WriteBool(false)
                net.Broadcast()
                
                net.Start("HideGeneratorQTE")
                net.Broadcast()
            end
        end
    end
    
    function ENT:OnRemove()
    end
end

if CLIENT then
    local startProgress = {}
    local fuelAmount = {}
    local generatorStarting = {}
    local qtePanel = nil
    local requiredSequence = {}
    local currentSequenceIndex = {}

    net.Receive("GeneratorStartProgress", function()
        local ent = net.ReadEntity()
        local progress = net.ReadFloat()
        local isRunning = net.ReadBool()
        
        if IsValid(ent) then
            startProgress[ent:EntIndex()] = {progress = progress, isRunning = isRunning}
        end
    end)
    
    net.Receive("GeneratorFuelUpdate", function()
        local ent = net.ReadEntity()
        local fuel = net.ReadInt(8)
        
        if IsValid(ent) then
            fuelAmount[ent:EntIndex()] = fuel
        end
    end)
    
    net.Receive("StartGeneratorStart", function()
        local ent = net.ReadEntity()
        if IsValid(ent) then
            generatorStarting[ent:EntIndex()] = true
        end
    end)
    
    net.Receive("GeneratorStartResult", function()
        local ent = net.ReadEntity()
        local success = net.ReadBool()
        
        if IsValid(ent) then
            if success then
                startProgress[ent:EntIndex()] = {progress = 1, isRunning = true}
            end
            generatorStarting[ent:EntIndex()] = false
        end
    end)
    
    net.Receive("ShowGeneratorQTE", function()
        local ent = net.ReadEntity()
        local seq = net.ReadTable()
        local index = net.ReadInt(8)
        if IsValid(ent) then
            requiredSequence[ent:EntIndex()] = seq
            currentSequenceIndex[ent:EntIndex()] = index
            
            -- Создаем QTE панель
            if IsValid(qtePanel) then
                qtePanel:Remove()
            end
            
            qtePanel = vgui.Create("DFrame")
            qtePanel:SetSize(250, 220)
            qtePanel:SetPos(ScrW() / 2 - 125, ScrH() / 2 - 125)
            qtePanel:SetTitle("")
            qtePanel:ShowCloseButton(false)
            qtePanel:SetDraggable(false)
            qtePanel:MakePopup()
            qtePanel.Paint = function(self, w, h)
                draw.RoundedBox(8, 0, 0, w, h, Color(30, 30, 30, 240))
            end
            
            local titleLabel = vgui.Create("DLabel", qtePanel)
            titleLabel:SetText(LANG.Get('ZAPUSKGEN'))
            titleLabel:SetPos(9, 30)
            titleLabel:SetSize(230, 30)
            titleLabel:SetContentAlignment(5)
            titleLabel:SetTextColor(color_white)
            titleLabel:SetFont("ui.24")
            
            local sequenceLabel = vgui.Create("DLabel", qtePanel)
            sequenceLabel:SetPos(10, 90)
            sequenceLabel:SetSize(230, 60)
            sequenceLabel:SetContentAlignment(5)
            sequenceLabel:SetTextColor(Color(0, 255, 0))
            sequenceLabel:SetFont("ui.40")
            
            -- Создаем кнопки для мыши
            local buttonSize = 30
            local buttonSpacing = 5        -- Уменьшаем расстояние между кнопками
            local totalWidth = buttonSize * 7 + buttonSpacing * 6  -- 30*7 + 5*6 = 240
            local startX = (250 - totalWidth) / 2  -- Центрируем

            local keyButtons = {}
            for i, key in ipairs({"a", "b", "c", "d", "e", "f", "g"}) do
                local btn = vgui.Create("DButton", qtePanel)
                btn:SetPos(startX + (i-1) * (buttonSize + buttonSpacing), 180)
                btn:SetSize(buttonSize, buttonSize)
                btn:SetText(key:upper())
                btn:SetFont("ui.24")
                btn:SetTextColor(color_white)
                btn.Paint = function(self, w, h)
                    if self:IsHovered() then
                        draw.RoundedBox(4, 0, 0, w, h, Color(100, 100, 100, 255))
                    else
                        draw.RoundedBox(4, 0, 0, w, h, Color(70, 70, 70, 255))
                    end
                end
                btn.DoClick = function()
                    surface.PlaySound('buttons/blip1.wav')
                    net.Start("MouseQTEInput")
                    net.WriteEntity(ent)
                    net.WriteString(key)
                    net.SendToServer()
                end
                keyButtons[key] = btn
            end
            
            local seqText = ""
            for i, key in ipairs(seq) do
                if i == index then
                    seqText = seqText .. key:upper() .. " "
                else
                    seqText = seqText .. key:upper() .. " "
                end
            end
            sequenceLabel:SetText(seqText)
        end
    end)
    
    net.Receive("UpdateGeneratorQTE", function()
        local ent = net.ReadEntity()
        local index = net.ReadInt(8)
        if IsValid(ent) then
            currentSequenceIndex[ent:EntIndex()] = index
            
            if IsValid(qtePanel) then
                local seq = requiredSequence[ent:EntIndex()]
                if seq then
                    local sequenceLabel = qtePanel:GetChildren()[2]
                    
                    if IsValid(sequenceLabel) then
                        local seqText = ""
                        for i, key in ipairs(seq) do
                            if i == index then
                                seqText = seqText .. key:upper() .. " "
                            else
                                seqText = seqText .. key:upper() .. " "
                            end
                        end
                        sequenceLabel:SetText(seqText)
                    end
                end
            end
        end
    end)
    
    net.Receive("HideGeneratorQTE", function()
        if IsValid(qtePanel) then
            qtePanel:Remove()
            qtePanel = nil
        end
    end)
    
    net.Receive("QTEFailed", function()
        if IsValid(qtePanel) then
            qtePanel:Remove()
            qtePanel = nil
        end
    end)
    
    function ENT:Draw()
        self:DrawModel()

        if LocalPlayer():GetPos():Distance(self:GetPos()) < 200 then
            local pos = self:GetPos()
            local ang = self:GetAngles()
            
            -- Получаем центр модели
            local mins, maxs = self:GetModelBounds()
            local center = (mins + maxs) / 3
            local offset = Vector(0, 0, maxs.z * 0.3) 
            local worldPos = pos + ang:Right() * -26 + ang:Forward() * -18 + ang:Up() * center.z + ang:Up() * 28

            local uiAng = ang
            uiAng:RotateAroundAxis(uiAng:Up(), 180)
            uiAng:RotateAroundAxis(uiAng:Forward(), 90)
            
            cam.Start3D2D(worldPos, uiAng, 0.03)
                local scaleMultiplier = 0.2 / 0.03 -- ~6.6667
                surface.SetDrawColor(50, 50, 50, 255)
                surface.DrawRect(-45 * scaleMultiplier, -28 * scaleMultiplier, 90 * scaleMultiplier, 10 * scaleMultiplier)

                local fuel = fuelAmount[self:EntIndex()] or 0
                local fuelWidth = (fuel / 100) * 90 * scaleMultiplier
                surface.SetDrawColor(0, 255, 0, 255)
                surface.DrawRect(-45 * scaleMultiplier, -28 * scaleMultiplier, fuelWidth, 10 * scaleMultiplier)

                draw.SimpleText(LANG.Get('FUELGEN') .. fuel .. "%", "3d2d", 0, -38 * scaleMultiplier, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

                if startProgress[self:EntIndex()] then
                    local prog = startProgress[self:EntIndex()]
                    if prog.isRunning then
                        draw.SimpleText(LANG.Get('RABOTAETGEN'), "3d2d", 0, -45, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end
                end
            cam.End3D2D()
        end
    end
end