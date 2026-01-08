AddCSLuaFile()

SWEP.Base = 'weapon_base_qwb'

SWEP.WorldModel = 'models/weapons/w_shot_m3super90_beanbag.mdl'

SWEP.PrintName = 'M3 Super90 BeanBag'
SWEP.Category = "Don't Scream - Tools"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.Slot = 1
SWEP.SlotPos = 1

SWEP.IronsightOffset = Vector(-2.5, -0.95, 4.7)
SWEP.IronsightAngle = Angle(-5, -2, 0)
SWEP.IronsightZNear = 1

SWEP.Primary.Sound = 'Weapon_M3.Single'
SWEP.Primary.Damage = -1
SWEP.Primary.NumShots = 4
SWEP.Primary.Spread = 0.1
SWEP.Primary.Delay = 1

SWEP.Primary.ClipSize = 6
SWEP.Primary.DefaultClip = 4
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'Buckshot'

SWEP.Recoil = 15
SWEP.HorizontalRecoil = 25

SWEP.HipFireRecoil = 10

SWEP.HoldType = 'ar2'

SWEP.ShellType = '12Gauge'
SWEP.ShellOffset = Vector(-20, 1, -1.5)
SWEP.ShellVelocity = 100

SWEP.IconOverride = "weapons/beanbag.png"

SWEP.AimSound = Sound('weapons/ammopickup.wav')

SWEP.ReloadAnim = "shotgun"
SWEP.ReloadSound = ""
SWEP.FreezeDuration = 4

function SWEP.DoPlayerFreeze(victim, attacker, duration)
    if not IsValid(victim) or not victim:IsPlayer() then return end
    if not IsValid(attacker) or not attacker:IsPlayer() then return end
    if not isChuchelo(victim:Team()) then return end

    if victim:IsPlayer() then
        victim:ChatPrint("Вы были оглушены!")

        victim.IsFrozen = true

        victim:Freeze(true)

        timer.Simple(duration, function()
            if IsValid(victim) then
                victim.IsFrozen = false
                victim:Freeze(false)
                victim:ChatPrint("Эффект оглушения закончился.")
            end
        end)
    end
end

function SWEP:PostPrimaryAttack()
    local owner = self:GetOwner()
    
    local pos, ang = self:GetBulletSourcePos()
    if not pos or not ang then return end
    
    local forward = ang:Forward()

    for i = 1, self.Primary.NumShots do
        local bulletDir = forward + VectorRand() * self.Primary.Spread
        local trace = util.TraceLine({
            start = pos,
            endpos = pos + bulletDir * 8000,
            filter = owner
        })
        
        local hitEnt = trace.Entity
        if SERVER and IsValid(hitEnt) and hitEnt:IsPlayer() then
            self.DoPlayerFreeze(hitEnt, owner, self.FreezeDuration)
        end
    end
end