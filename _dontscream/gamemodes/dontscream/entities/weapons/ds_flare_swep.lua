SWEP.Base = "weapon_base"
SWEP.PrintName = LANG.Get('FLARE')
SWEP.Category = "Don't Scream - Tools"
SWEP.Author = "Fuzzy"
SWEP.Instructions = ""

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/props_junk/flare.mdl"

SWEP.HoldType = "slam"

SWEP.Slot = 2

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.VElements = {
	["v_element"] = { 
		type = "Model", 
		model = "models/props_junk/flare.mdl", 
		bone = "ValveBiped.Bip01_R_Hand", 
		rel = "", 
		pos = Vector(0, 0.467, 0), 
		angle = Angle(0, 0, 180), 
		size = Vector(1.75, 1.75, 1.75), 
		color = Color(255, 255, 255, 255), 
		suppresslightning = false, 
		material = "", 
		skin = 0, 
		bodygroup = {} 
	}
}

SWEP.WElements = {
	["w_element"] = { 
		type = "Model", 
		model = "models/props_junk/flare.mdl", 
		bone = "ValveBiped.Bip01_R_Hand", 
		rel = "", 
		pos = Vector(3, 1, -2), 
		angle = Angle(-10, 0, 180), 
		size = Vector(1, 1, 1), 
		color = Color(255, 255, 255, 255), 
		suppresslightning = false, 
		material = "", 
		skin = 0, 
		bodygroup = {} 
	}
}

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.VMPos = Vector(0, 0, 0)
SWEP.VMAng = Angle(0, 0, 0)

SWEP.WMPos = Vector(-2.5, 3.5, 2)
SWEP.WMAng = Angle(10, 2, 180)

function SWEP:Initialize()
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:PrimaryAttack()
	self:GetOwner():AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)

    if CLIENT then return end

    local flare = ents.Create("ds_flare")
    if not IsValid(flare) then return end

    local pos = self:GetOwner():GetShootPos()
    local ang = self:GetOwner():GetAimVector():Angle()
    flare:SetPos(pos)
    flare:SetAngles(ang)
    flare:Spawn()
    flare:Activate()

    local phys = flare:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ang:Forward() * 500)
    end

    self:GetOwner():StripWeapon('ds_flare_swep')

    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:SecondaryAttack()
	self:GetOwner():AnimRestartGesture(GESTURE_SLOT_GRENADE, ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE, true)

    if CLIENT then return end

    local flare = ents.Create("ds_flare")
    if not IsValid(flare) then return end

    local pos = self:GetOwner():GetShootPos()
    local ang = self:GetOwner():GetAimVector():Angle()
    flare:SetPos(pos)
    flare:SetAngles(ang)
    flare:Spawn()
    flare:Activate()

    local phys = flare:GetPhysicsObject()
    if IsValid(phys) then
        phys:SetVelocity(ang:Forward() * 250)
    end

    self:GetOwner():StripWeapon('ds_flare_swep')

    self:SetNextPrimaryFire(CurTime() + 1)
end

function SWEP:DrawWorldModel()
	if IsValid(self.Owner) then
		local bone = self.Owner:LookupBone("ValveBiped.Bip01_R_Hand")
		if bone then
			local pos, ang = self.Owner:GetBonePosition(bone)
			if pos and ang then
				ang:RotateAroundAxis(ang:Right(), self.WMAng.p)
				ang:RotateAroundAxis(ang:Up(), self.WMAng.y)
				ang:RotateAroundAxis(ang:Forward(), self.WMAng.r)
				
				pos = pos + ang:Right() * self.WMPos.x + ang:Forward() * self.WMPos.y + ang:Up() * self.WMPos.z
				
				self:SetRenderOrigin(pos)
				self:SetRenderAngles(ang)
				self:DrawModel()
				return
			end
		end
	end
	
	self:SetRenderOrigin(nil)
	self:SetRenderAngles(nil)
	self:DrawModel()
end

function SWEP:ViewModelDrawn()
	local hand = self:GetOwner():LookupBone("ValveBiped.Bip01_R_Hand")
	if !hand then return end
	
	local pos, ang = self:GetOwner():GetBonePosition(hand)
	local viewmodel = self:GetOwner():GetViewModel()
	
	ang:RotateAroundAxis(ang:Right(), self.VMAng.p)
	ang:RotateAroundAxis(ang:Up(), self.VMAng.y)
	ang:RotateAroundAxis(ang:Forward(), self.VMAng.r)
	
	pos = pos + ang:Right() * self.VMPos.x + ang:Forward() * self.VMPos.y + ang:Up() * self.VMPos.z
	
	self:DrawModel()
end