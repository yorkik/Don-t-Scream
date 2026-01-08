AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')

AddCSLuaFile('sh_att.lua')
AddCSLuaFile('cl_att.lua')
AddCSLuaFile('cl_att_menu.lua')

include('shared.lua')

include('sh_att.lua')
include('sv_att.lua')

function SWEP:CreateShootRage()
	if not self.ShootRage then self.ShootRage = 0 end
	self.ShootRage = self.ShootRage + self.HorizontalRecoil / 15
end

function SWEP:SecondaryAttack()
	if self:GetSafetyStance() then return end

	if not IsValid(self:GetOwner()) then return end
	local owner = self:GetOwner()

	if qwb.isPlayerRunning(owner) then return end

	self.Ironsighted = not self.Ironsighted

	if self.AimSound then
		owner:EmitSound(self.AimSound, nil, nil, self.AimSoundVolume or 0.25)
	end
    
	if not self.IsPistol then
		if self.Ironsighted then
			self:SetHoldType("rpg")
			self.OriginalHoldType = self.HoldType
		else
			self:SetHoldType(self.OriginalHoldType or "normal")
		end
	end

	net.Start('qwb.setIronsight')
		net.WriteBool(self.Ironsighted)
	net.Send(owner)
end