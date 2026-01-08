local detector_maxrange = 1024

SWEP.PrintName			= LANG.Get('DETECTER')		
SWEP.Slot = 1
SWEP.SlotPos = 1
SWEP.Category = "Don't Scream - Tools"
SWEP.Author	= "Fuzzy"
SWEP.Contact = ""
SWEP.Purpose = ""
SWEP.Instructions = ""	
SWEP.Base	= "base_sweps_detector"
SWEP.HoldType = "revolver"
SWEP.ViewModelFOV = 65
SWEP.ViewModelFlip = true
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_arms.mdl"
SWEP.WorldModel = "models/lt_c/alienisolation/track3r/motion_track3r.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = true
SWEP.Spawnable	= true
SWEP.AdminSpawnable	= true

SWEP.UseDel = CurTime()

function SWEP:IdleTiming()
end

SWEP.Primary.Delay				= 0
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= 0
SWEP.Primary.NumShots			= 0
SWEP.Primary.Cone				= 0	
SWEP.Primary.ClipSize			= -1
SWEP.Primary.DefaultClip		= -1
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"
SWEP.Secondary.Delay			= 0
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= 0
SWEP.Secondary.NumShots			= 0
SWEP.Secondary.Cone		  		= 0
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic   		= false
SWEP.Secondary.Ammo         	= "none"

SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(1.652, 7.097, 5.008), angle = Angle(-12.851, 25.636, 25.993) },
	["ValveBiped.Grenade_body"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) }
}

SWEP.IronSightsPos = Vector(0, 0, 0)
SWEP.IronSightsAng = Vector(0, 0, 0)

SWEP.VElements = {
	["v_element"] = { type = "Model", model = "models/lt_c/alienisolation/track3r/motion_track3r.mdl", bone = "ValveBiped.Grenade_body", rel = "", pos = Vector(0, 0.467, 0), angle = Angle(0, 0, 180), size = Vector(1.75, 1.75, 1.75), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.WElements = {
	["w_element"] = { type = "Model", model = "models/lt_c/alienisolation/track3r/motion_track3r.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.937, 1.258, 0), angle = Angle(6.796, -11.094, -178.243), size = Vector(1, 1, 1), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

function SWEP:PrimaryAttack()
end

function SWEP:SecondaryAttack()
end

function SWEP:Deploy()
	timer.Simple( 0.75, function()	
	end)
	return true
end

SWEP.LastBeep = 0
function SWEP:Think()
	if CLIENT then
		local targets = {}
		for k,v in pairs(ents.GetAll()) do
			if v:IsPlayer() and v ~= LocalPlayer() and isChuchelo(v:Team()) then
				table.insert(targets, v)
			end
		end
		
		local dist = detector_maxrange + 1
		local closest_ent = nil
		
		for k,v in pairs(targets) do
			local pos = v:GetPos()
			local dir_to_target = pos - self.Owner:GetShootPos()
			local aim_vec = self.Owner:GetAimVector()
			local normalized_dir = dir_to_target:GetNormalized()
			local dot_product = normalized_dir:Dot(aim_vec)
			local cone_factor = (1 - math.Clamp(dot_product, 0, 0.5))
			
			local effective_dist = v:GetPos():Distance(self.Owner:GetPos()) * cone_factor
			
			if effective_dist < dist then
				dist = effective_dist
				closest_ent = v
			end
		end
		
		if dist < detector_maxrange then
			if self.LastBeep + dist/1000 - CurTime() <= 0 then
				self.LastBeep = CurTime() + 0.07
				self.Owner:EmitSound(Sound("detector/anom_prox.wav"), 75, 100)
			end
		end
	end
end