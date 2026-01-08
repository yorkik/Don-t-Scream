AddCSLuaFile()

DEFINE_BASECLASS( "base_anim" )

ENT.Spawnable		            	 = false        
ENT.AdminSpawnable		             = false 

ENT.PrintName		                 =  "Flare"
ENT.Author			                 =  "Fuzzy"
ENT.Category                         =  "Fun + Games"

sound.Add( {
	name = "flare_burning_idle",
	channel = CHAN_STATIC,
	volume = 1.0,
	level = 70,
	pitch = { 95, 110 },
	sound = "flare_burn_loop.wav"
} )

function ENT:Initialize()	
	if (SERVER) then
		self:SetModel("models/props_junk/flare.mdl")
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS  )
		self:SetUseType( ONOFF_USE )
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		
		local phys = self:GetPhysicsObject()
		
		if (phys:IsValid()) then
			phys:SetMass(5)
			phys:Wake()
			phys:EnableMotion(true)
		end 		
		
		local prop = ents.Create("prop_physics")
		prop:SetModel("models/props_junk/flare.mdl")
		prop:Spawn()
		prop:Activate()
		prop:SetPos(self:GetAttachment(1).Pos + self:GetUp() )
		prop:SetAngles(self:GetUp():Angle())
		prop:SetCollisionGroup(COLLISION_GROUP_IN_VEHICLE)
		prop:SetModelScale(0)
		prop:SetParent(self)
		
		self.IsOn = false
		self.Attachment = prop

		-- Автоматическое включение через 0.1 сек
		timer.Simple(0.1, function()
			if self:IsValid() then
				self.IsOn = true
				self:TurnOn()
				self:EmitSound("flare_ignition_initial.mp3")
				timer.Simple(2, function()
					if self:IsValid() then
						self:EmitSound("flare_burning_idle")
					end
				end)
			end
		end)

		-- Удаление через 15 сек
		timer.Simple(15, function()
			if self:IsValid() then
				self:Remove()
			end
		end)
	end
end

function ENT:SpawnFunction( ply, tr )
	if ( !tr.Hit ) then return end

	self.OWNER = ply
	local ent = ents.Create( self.ClassName )
	ent:SetPhysicsAttacker(ply)
	ent:SetPos( tr.HitPos + tr.HitNormal * 5   ) 
	ent:Spawn()
	ent:Activate()
	return ent
end

function ENT:TurnOn()
	self:SetNWBool("IsOn", true)
	if self.Attachment:IsValid() then 
		ParticleEffectAttach("hd_flare_01_red_main", PATTACH_POINT_FOLLOW, self.Attachment, 0)
	end
end

function ENT:Use(ply)
	-- Отключаем возможность включить/выключить через Use
end

function ENT:Think()
	if (CLIENT) then 
		if self:GetNWBool("IsOn") then 
			local dlight = DynamicLight( self:EntIndex() )
			if ( dlight ) then
				dlight.pos = self:GetPos()
				dlight.r = 255
				dlight.g = 25
				dlight.b = 25
				dlight.brightness = 4
				dlight.Decay = 1000
				dlight.Size = 256
				dlight.DieTime = CurTime() + 1
			end
		end 
	end
end

function ENT:OnRemove()
	self:StopSound("flare_burning_idle")
end

function ENT:Draw()
	self:DrawModel()
end