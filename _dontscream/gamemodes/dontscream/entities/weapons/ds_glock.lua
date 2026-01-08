AddCSLuaFile()

SWEP.Base = 'weapon_base_qwb'

SWEP.WorldModel = 'models/homicbox_weapons/w_pist_glock18.mdl'

SWEP.PrintName = 'Glock-17'
SWEP.Category = "Don't Scream - Tools"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IronsightOffset = Vector(-10, -1.2, 3.95)
SWEP.IronsightAngle = Angle(0, 2, 0)

SWEP.Primary.Sound = 'Weapon_Glock.Single'
SWEP.Primary.Damage = 20
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0.01
SWEP.Primary.Delay = 0.1

SWEP.Primary.ClipSize = 17
SWEP.Primary.DefaultClip = 9999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'pistol'

SWEP.Recoil = 5
SWEP.HorizontalRecoil = 5

SWEP.HoldType = 'revolver'

SWEP.IsPistol = true

SWEP.HipFireRecoil = 2

SWEP.ShellType = '9mm'
SWEP.ShellOffset = Vector(-5, 1, -0.5)
SWEP.ShellVelocity = 50

SWEP.AimSound = Sound('weapons/ammopickup.wav')

SWEP.IsRloadSnd = true

SWEP.MagOutSoundDel = 0.1
SWEP.MagInSoundDel = 1.0
SWEP.BoltSoundDel = 1.6

SWEP.MagOutSound = Sound('weapons/glock/glock_clipout.wav')
SWEP.MagInSound = Sound('weapons/glock/glock_clipin.wav')
SWEP.BoltSound = Sound('weapons/glock/glock_sliderelease.wav')