SWEP.Weight = 5
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = false
SWEP.CSMuzzleFlashes = true

SWEP.Base = 'weapon_base'
SWEP.IsQWB = true

SWEP.Author = 'qurs'
SWEP.Contact = ''
SWEP.Purpose = ''
SWEP.Instructions = ''

SWEP.ViewModel = 'models/weapons/v_knife_t.mdl'
SWEP.DefaultScopeMat = Material('materials/qwb/scope/awp.png')

SWEP.Category = 'qurs\' weapons base'

SWEP.Spawnable = false
SWEP.UseHands = true

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = 'none'

SWEP.ShellType = '9mm'

SWEP.SafetyStanceSound = Sound('weapons/smg1/switch_single.wav')
SWEP.ReloadSound = Sound('weapons/smg1/switch_single.wav')
SWEP.SoundZat = Sound('weapons/scout/scout_bolt.wav')

SWEP.MagOutSound = Sound('weapons/scout/scout_clipout.wav')
SWEP.MagInSound = Sound('weapons/scout/scout_clipin.wav')
SWEP.BoltSound = Sound('weapons/scout/scout_bolt.wav')

SWEP.MagOutSoundDel = 0.1
SWEP.MagInSoundDel = 1
SWEP.BoltSoundDel = 1.5


SWEP.IsRloadSnd = false
SWEP.IsSniper = false
SWEP.IsPistol = false

local angle_zero = Angle()

local passiveHoldTypes = {
	revolver = 'normal',
	ar2 = 'passive',
	smg = 'passive',
}

-- Thanks to octothorp team for this solution, which calculates the shot position
local defaultBulletPosAng = {
	default = { Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0) },

	revolver = { Vector(7.7, 0.4, 3.95), Angle(-3, 5.5, 0) },
	ar2 = { Vector(20, -0.8, 11.2), Angle(-9.5, 0, 0) },
	smg = { Vector(14, -0.8, 6.8), Angle(-9.5, 0, 0) },
}

function SWEP:CalculatePassiveHoldType()
	return passiveHoldTypes[self.HoldType] or 'normal'
end

function SWEP:SafetyStanceChanged(_, old, new)
	self:GetOwner():EmitSound(self.SafetyStanceSound)

	if new == true then
		self:SetHoldType(self.PassiveHoldType or self:CalculatePassiveHoldType())
	else
		self:SetHoldType(self.HoldType)
	end
end

function SWEP:SetupDataTables()
	self:NetworkVar('Bool', 0, 'SafetyStance')

	self:NetworkVar('Vector', 0, 'LocalMuzzlePos')
	self:NetworkVar('Angle', 0, 'LocalMuzzleAng')

	if SERVER then
		self:NetworkVarNotify('SafetyStance', self.SafetyStanceChanged)
	end
end

function SWEP:Initialize()
	self:SetHoldType(self.HoldType)

	local lpos, lang = unpack( defaultBulletPosAng[ self:GetHoldType() ] or defaultBulletPosAng.default )

	self._sourceLocalMuzzlePos = self.ShootPos or lpos
	self._sourceLocalMuzzleAng = self.ShootAng or lang

	if CLIENT then return end

	self:SetLocalMuzzlePos(self._sourceLocalMuzzlePos)
	self:SetLocalMuzzleAng(self._sourceLocalMuzzleAng)
end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	if SERVER then
		self.Ironsighted = false
	end

	return true
end

function SWEP:OnRemove()
	self:Holster()
end

function SWEP:Reload()
	if not IsFirstTimePredicted() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if owner:KeyDown(IN_USE) then return end
	if qwb.isPlayerRunning(owner) then return end

	self.OriginalHoldType = self.HoldType
	self:SetHoldType(self.OriginalHoldType or "normal")

	if self:GetClass() == "ds_shotgun_beanbag" then
		self:SetHoldType("shotgun")
		self.OriginalHoldType = self.HoldType
		timer.Simple(self:SequenceDuration(), function()
			if IsValid(self) and self:GetClass() == "ds_shotgun_beanbag" then
				self:SetHoldType(self.OriginalHoldType or "normal")
			end
		end)
	end

	if not self:DefaultReload(ACT_VM_RELOAD) then return end
	owner:SetAnimation(PLAYER_RELOAD)

	if self.IsRloadSnd then
		timer.Simple(self.MagOutSoundDel, function()
			self:EmitSound( self.MagOutSound )
		end)
		timer.Simple(self.MagInSoundDel, function()
			self:EmitSound( self.MagInSound )
		end)
		timer.Simple(self.BoltSoundDel, function()
			self:EmitSound( self.BoltSound )
		end)
	end

	if SERVER then
		self.Ironsighted = false

		net.Start('qwb.setIronsight')
			net.WriteBool(self.Ironsighted)
		net.Send(owner)
	end

	self:SetNextPrimaryFire(CurTime() + 2)
end

function SWEP:GetMuzzlePos()
	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	local att = owner:GetAttachment( owner:LookupAttachment('anim_attachment_rh') )
	if not att then return end

	local lpos, lang = self:GetLocalMuzzlePos(), self:GetLocalMuzzleAng()
	local pos, ang = LocalToWorld(lpos, lang, att.Pos, att.Ang)

	return pos, ang
end

function SWEP:GetBoneAng()
	local ang = self:GetLocalMuzzleAng()
	local sourceAng = self._sourceLocalMuzzleAng
	local pitch = ang.p - sourceAng.p

	return Angle(-pitch, 0, 0)
end

function SWEP:GetBulletSourcePos()
	return self:GetMuzzlePos()
end

function SWEP:ShootBullet( src, dir, num_bullets, aimcone, tracer )
	local bullet = {}
	bullet.Num		= num_bullets
	bullet.Src		= src
	bullet.Dir		= dir
	bullet.Spread	= Vector( aimcone, aimcone, 0 )
	bullet.Tracer	= tracer or 5
	bullet.Force	= 1
	bullet.Damage	= self.Primary.Damage
	bullet.AmmoType = self.Primary.Ammo
	bullet.TracerName = self.TracerName

	self:GetOwner():FireBullets( bullet )
	self:TakePrimaryAmmo(1)

	self:ShootEffects()
end

function SWEP:MuzzleFlashCustom()
	if SERVER then
		net.Start('qwb.muzzleFlashLight')
			net.WriteEntity(self)
		net.SendPVS(self:GetBulletSourcePos())

		return
	end

	local effectData = EffectData()
	effectData:SetEntity(self)
	effectData:SetFlags(1)

	util.Effect('MuzzleFlash', effectData)
end

function SWEP:ShellEffect()
	if SERVER then return end
	if self.NoShell then return end

	local shellType = self.ShellType

	local effectData = EffectData()

	local pos = self:GetPos()
	if self.ShellOffset then
		local att = self:GetAttachment( self:LookupAttachment('muzzle') )
		if att then
			pos = LocalToWorld(self.ShellOffset, angle_zero, att.Pos, att.Ang)
		end
	end

	effectData:SetOrigin(pos)
	effectData:SetFlags(self.ShellVelocity or 75)

	util.Effect('EjectBrass_' .. shellType, effectData)
end

function SWEP:ShootEffects()
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	self:MuzzleFlashCustom()
	self:ShellEffect()

	self:EmitSound( self.Primary.Sound )

	if self.IsSniper then
		timer.Simple(0.6, function ()
			self:EmitSound( self.SoundZat )
		end)
	end

	self.RecoilAnimBack = nil
	self.RecoilAnim = true
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then return end
	if not IsValid(self) or not IsValid(self:GetOwner()) then return end
	local owner = self:GetOwner()

	local pos, ang = self:GetBulletSourcePos()
	if not pos or not ang then return end

	local forward = ang:Forward()

	owner:LagCompensation(true)
		self:ShootBullet(pos, forward, self.Primary.NumShots or 1, self.Primary.Spread or 0.01, 1)
	owner:LagCompensation(false)

	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)

	if SERVER then self:CreateShootRage() end

	if not self.IronSighted and self.HipFireRecoil then
		local pitch = math.random() >= 0.5 and -self.HipFireRecoil or self.HipFireRecoil
		local yaw = math.random() >= 0.5 and -self.HipFireRecoil or self.HipFireRecoil
		local roll = math.random() >= 0.5 and -self.HipFireRecoil or self.HipFireRecoil

		owner:SetViewPunchAngles(Angle(pitch, yaw, roll))
	end

	if self.PostPrimaryAttack then self:PostPrimaryAttack() end
end

function SWEP:CanPrimaryAttack()
	if self:GetSafetyStance() then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end

	if qwb.isPlayerRunning(owner) then return end

	if self:Clip1() <= 0 then
		self:EmitSound('weapons/clipempty_rifle.wav')
		self:SetNextPrimaryFire(CurTime() + 0.7)

		return false
	end

	if owner:WaterLevel() > 2 then return false end

	return true
end

function SWEP:Think()
	local owner = self:GetOwner()
	if not IsValid(self:GetOwner()) then return end

	if owner:KeyDown(IN_USE) and owner:KeyDown(IN_RELOAD) and (not self.SafetyStanceCD or CurTime() >= self.SafetyStanceCD) then
		self.SafetyStanceCD = CurTime() + 0.4
		self:SetSafetyStance( not self:GetSafetyStance() )
	end

	local passiveHoldType = self.PassiveHoldType or self:CalculatePassiveHoldType()
	if qwb.isPlayerRunning(owner) and self:GetHoldType() ~= passiveHoldType then
		self:SetHoldType(passiveHoldType)

		if self.Ironsighted then self.Ironsighted = false end
	elseif not qwb.isPlayerRunning(owner) and not self:GetSafetyStance() and self:GetHoldType() == passiveHoldType then
		self:SetHoldType(self.HoldType)
	end

	if not self.ShootRageDelta then self.ShootRageDelta = 0 end

	if self.ShootRage and self.ShootRage > 0 then
		self.ShootRageDelta = self.ShootRageDelta + 0.2

		self.ShootRage = self.ShootRage - 0.05
		if self.ShootRage < 0 then self.ShootRage = 0 end
	else
		self.ShootRageDelta = 0
	end

	if self.RecoilAnim then
		local bone = owner:LookupBone('ValveBiped.Bip01_R_Hand')
		local bone2 = owner:LookupBone('ValveBiped.Bip01_R_UpperArm')
		local needle = Angle(self.Recoil / 50 * 90, 0, 0)
		local needle2 = Angle(0, (self.ShootRage or 0) * math.sin(self.ShootRageDelta or 0), 0)

		owner:ManipulateBoneAngles( bone, LerpAngle(0.8, owner:GetManipulateBoneAngles(bone), needle), true )
		owner:ManipulateBoneAngles( bone2, LerpAngle(0.45, owner:GetManipulateBoneAngles(bone2), needle2), true )

		local ang = owner:GetManipulateBoneAngles(bone)
		if math.abs(ang[1] - needle[1]) <= 0.1 then
			self.RecoilAnim = nil
			self.RecoilAnimBack = true
		end
	elseif self.RecoilAnimBack then
		local bone = owner:LookupBone('ValveBiped.Bip01_R_Hand')
		local bone2 = owner:LookupBone('ValveBiped.Bip01_R_UpperArm')
		local needle = Angle(0, 0, 0)
		local needle2 = Angle(0, (self.ShootRage or 0) * math.sin(self.ShootRageDelta or 0), 0)

		owner:ManipulateBoneAngles( bone, LerpAngle(0.1, owner:GetManipulateBoneAngles(bone), needle), true )
		owner:ManipulateBoneAngles( bone2, LerpAngle(0.1, owner:GetManipulateBoneAngles(bone2), needle2), true )

		local ang = owner:GetManipulateBoneAngles(bone)
		if math.abs(ang[1] - needle[1]) <= 0.1 then
			self.RecoilAnimBack = nil
		end
	end

	-- if CLIENT then
	-- 	local bone = owner:LookupBone('ValveBiped.Bip01_R_Hand')
	-- 	local ang = self:GetBoneAng()
	-- 	owner:ManipulateBoneAngles(bone, ang)
	-- end

	-- if CLIENT then return end

	-- if owner.RecoilAnim then
	-- 	local curAng = self:GetLocalMuzzleAng()
	-- 	local sourceAng = self._sourceLocalMuzzleAng

	-- 	local needle = Angle(sourceAng[1] - (self.Recoil / 50 * 90), curAng[2], curAng[3])

	-- 	self:SetLocalMuzzleAng( LerpAngle(0.8, self:GetLocalMuzzleAng(), needle) )

	-- 	local ang = self:GetLocalMuzzleAng()
	-- 	if math.abs(ang[1] - needle[1]) <= 0.1 then
	-- 		owner.RecoilAnim = nil
	-- 		owner.RecoilAnimBack = true
	-- 	end
	-- elseif owner.RecoilAnimBack then
	-- 	local needle = self._sourceLocalMuzzleAng

	-- 	self:SetLocalMuzzleAng( LerpAngle(0.025, self:GetLocalMuzzleAng(), needle) )

	-- 	local ang = self:GetLocalMuzzleAng()
	-- 	if math.abs(ang[1] - needle[1]) <= 0.1 then
	-- 		owner.RecoilAnimBack = nil
	-- 	end
	-- end
end