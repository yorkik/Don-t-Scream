if SERVER then
    AddCSLuaFile()
end

SWEP.PrintName = LANG.Get('ADRENALYN')
SWEP.Author = "Fuzzy"
SWEP.Instructions = "ЛКМ - Увеличить скорость бега на 10 секунд."
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Category = "Don't Scream - Tools"

SWEP.Slot = 2
SWEP.SlotPos = 1
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = true

SWEP.ViewModel = 'models/items/injector/w_meds_injector.mdl'
SWEP.WorldModel = 'models/items/injector/w_meds_injector.mdl'

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = ""

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = ""

function SWEP:Initialize()
    self:SetHoldType("slam")
end

function SWEP:PrimaryAttack()
    if SERVER then
        local ply = self.Owner
        
        ply.AdrenalineActive = true
        ply:SetNWBool("Obdolbos", true)
        ply:SetRunSpeed(400)
        ply:SetNWInt("Stamina", 100)
        ply:BlockStamina()
        ply:EmitSound("items/adrenalyn.wav", 75, 100, 100)
        ply:StripWeapon("ds_adrenalyn")

        timer.Simple(10, function()
            if IsValid(ply) and ply.AdrenalineActive then
                ply:SetNWBool("Obdolbos", false)
                ply:SetRunSpeed(350)
                ply:SetNWInt("Stamina", 100)
                ply:UnblockStamina()
                ply.AdrenalineActive = false
            end
        end)
    end
    
    if CLIENT then
        hook.Add("RenderScreenspaceEffects", "chuchelo_" .. self:EntIndex(), function()
            local ply = LocalPlayer()
            if not ply:GetNWBool("Obdolbos", false) then return end
            DrawMaterialOverlay("models/shadertest/predator", 0.5)
        end)
    end
    
    self:SetNextPrimaryFire(CurTime() + 0.2)
end

function SWEP:SecondaryAttack()
end

if CLIENT then -- Worldmodel offset
	local WorldModel = ClientsideModel(SWEP.WorldModel)

	WorldModel:SetSkin(8)
	WorldModel:SetNoDraw(true)

	function SWEP:DrawWorldModel()
		local owner = self:GetOwner()

		if (IsValid(owner)) then
			local offsetVec = Vector(3, -2, 3)
			local offsetAng = Angle(180, 0, 0)
			
			local boneid = owner:LookupBone("ValveBiped.Bip01_R_Hand") -- Right Hand
			if !boneid then return end

			local matrix = owner:GetBoneMatrix(boneid)
			if !matrix then return end

			local newPos, newAng = LocalToWorld(offsetVec, offsetAng, matrix:GetTranslation(), matrix:GetAngles())

			WorldModel:SetPos(newPos)
			WorldModel:SetAngles(newAng)

            WorldModel:SetupBones()
		else
			
			WorldModel:SetPos(self:GetPos())
			WorldModel:SetAngles(self:GetAngles())
			self:DrawModel()
		end

		WorldModel:DrawModel()

	end
end