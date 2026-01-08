AddCSLuaFile()

SWEP.Base = 'weapon_base_qwb'

SWEP.WorldModel = 'models/weapons/w_rif_m4a1.mdl'

SWEP.PrintName = 'AR-15'
SWEP.Category = "Don't Scream - Чучело"

SWEP.Spawnable = true
SWEP.AdminOnly = false

SWEP.IronsightOffset = Vector(-5, -.97, 6.45)
SWEP.IronsightAngle = Angle(-9, -2, 0)
SWEP.IronsightZNear = 0.4

SWEP.Primary.Sound = 'Weapon_M4A1.Single'
SWEP.Primary.Damage = 25
SWEP.Primary.NumShots = 1
SWEP.Primary.Spread = 0.01
SWEP.Primary.Delay = 0.1

SWEP.Primary.ClipSize = 20
SWEP.Primary.DefaultClip = 9999
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = 'ar2'

SWEP.Recoil = 5
SWEP.HorizontalRecoil = 7

SWEP.HoldType = 'ar2'

SWEP.HipFireRecoil = 2

SWEP.ShellType = '762Nato'
SWEP.ShellOffset = Vector(-14, -1, 1.5)
SWEP.ShellVelocity = 50

SWEP.AimSound = Sound('weapons/ammopickup.wav')

SWEP.IsRloadSnd = true

SWEP.MagOutSoundDel = 0.01
SWEP.MagInSoundDel = 0.6
SWEP.BoltSoundDel = 1.2

SWEP.MagOutSound = Sound('weapons/m4a1/m4a1_clipout.wav')
SWEP.MagInSound = Sound('weapons/m4a1/m4a1_clipin.wav')
SWEP.BoltSound = Sound('weapons/m4a1/m4a1_boltpull.wav')