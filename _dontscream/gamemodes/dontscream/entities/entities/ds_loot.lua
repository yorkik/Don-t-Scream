AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_gmodentity"
ENT.PrintName = "Ящик с лутом"
ENT.Author = "Fuzzy"
ENT.Category = "Don't Scream - Tools"
ENT.Spawnable = true
ENT.AdminOnly = true

ENT.LootItems = {
    {class = "ds_betablock", chance = 85},
    {class = "ds_adrenalyn", chance = 70},
    {class = "ds_flare_swep", chance = 58},
    {class = "ds_detector", chance = 45},
    {class = "ds_shotgun_beanbag", chance = 35},
}

if SERVER then
    function ENT:Initialize()
        self:SetModel("models/props_junk/wood_crate003a.mdl")
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetMoveType(MOVETYPE_VPHYSICS)
        self:SetSolid(SOLID_VPHYSICS)
        self:SetUseType(SIMPLE_USE)

        local phys = self:GetPhysicsObject()
        if IsValid( phys ) then
            phys:Wake()
            phys:EnableMotion( false )
        end
        self.PlayersUsedThisRound = {}
    end

    function ENT:Use(activator, caller)
        if not IsValid(activator) or not activator:IsPlayer() then return end
        if isChuchelo(activator:Team()) then return end
        if RoundState == ROUND_WAITING or RoundState == ROUND_POST then return end
        if self.PlayersUsedThisRound[activator:SteamID()] then return end


        activator:SendLua('LocalPlayer():DoAnimationEvent(ACT_GMOD_GESTURE_ITEM_GIVE)')
        self:EmitSound("items/ammocrate_open.wav", 75, 100, 1, CHAN_AUTO)

        local selectedItem = self:GetRandomItem()
        
        if selectedItem then
            local pos = self:GetPos()
            local spawnPos = pos + Vector(0, 0, 50)
            
            local ent = ents.Create(selectedItem.class)
            if IsValid(ent) then
                ent:SetPos(spawnPos)
                ent:Spawn()
                ent:Activate()
            else
                activator:ChatPrint("Ошибка при создании предмета!")
            end
        else
            activator:ChatPrint(LANG.Get('EMPLOOT'))
        end

        self.PlayersUsedThisRound[activator:SteamID()] = true
    end

    function ENT:GetRandomItem()
        local possibleItems = {}
        
        for _, item in ipairs(self.LootItems) do
            if math.random(1, 100) <= item.chance then
                table.insert(possibleItems, item)
            end
        end
        
        if #possibleItems > 0 then
            return table.Random(possibleItems)
        end
        
        return nil
    end

    function ENT:ResetForNewRound()
        self.PlayersUsedThisRound = {}
    end
end

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end