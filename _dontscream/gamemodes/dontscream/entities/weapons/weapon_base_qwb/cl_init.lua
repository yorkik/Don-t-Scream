include('shared.lua')

include('sh_att.lua')
include('cl_att.lua')
include('cl_att_menu.lua')

local size = 512
local RT = GetRenderTarget('qwb_scope', size, size)

local mat = CreateMaterial('qwb_scope', 'UnlitGeneric', {
	['$basetexture'] = RT:GetName(),
	['$translucent'] = 1,
	['$vertexcolor'] = 1,
})

local vector_origin = Vector()
local angle1, angle2 = Angle(0, 0, -90), Angle(-90, 0, 0)
local color_white, color_black = Color(255, 255, 255), Color(0, 0, 0)

local function draw_Circle( x, y, radius, seg )
	local cir = {}

	table.insert( cir, { x = x, y = y, u = 0.5, v = 0.5 } )
	for i = 0, seg do
		local a = math.rad( ( i / seg ) * -360 )
		table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )
	end

	local a = math.rad( 0 ) -- This is needed for non absolute segment counts
	table.insert( cir, { x = x + math.sin( a ) * radius, y = y + math.cos( a ) * radius, u = math.sin( a ) / 2 + 0.5, v = math.cos( a ) / 2 + 0.5 } )

	surface.DrawPoly( cir )
end

hook.Add('Think', 'qwb.renderScope', function()
	if not qwb.ironsighted then return end

	local weap = LocalPlayer():GetActiveWeapon()
	if not IsValid(weap) or not weap.IsQWB then return end

	local sightData = weap:GetAttach('sights')
	if not weap.ScopeOffset and (not sightData or not IsValid(sightData.csEnt) or not sightData.csEnt.opticPos) then return end

	local att = weap:GetAttachment( weap:LookupAttachment('muzzle') )
	if not att then return end
	local pos, ang = att.Pos, att.Ang

	local _, scopeAng = LocalToWorld( vector_origin, angle1, pos, ang )

	local data = sightData and weap.Attachments and weap.Attachments.sights and weap.Attachments.sights[ sightData.id ]

	render.PushRenderTarget(RT)
		render.RenderView({
			origin = pos,
			angles = scopeAng,
			fov = weap.ScopeFOV or (data and data.opticFOV) or 10,
		})
	render.PopRenderTarget()
end)

net.Receive('qwb.muzzleFlashLight', function()
	local weap = net.ReadEntity()
	if not IsValid(weap) then return end

	local dlight = DynamicLight( weap:EntIndex() )
	if dlight then
		dlight.pos = weap:GetBulletSourcePos()
		dlight.r = 255
		dlight.g = 145
		dlight.b = 10
		dlight.brightness = 1
		dlight.Decay = 6666
		dlight.Size = 512
		dlight.DieTime = CurTime() + 0.2
	end
end)

function SWEP:DrawWorldModel(flags)
	self:DrawModel(flags)

	if not self.ScopeOffset or not self.ScopeSize then return end
	if not qwb.ironsighted then return end

	local owner = self:GetOwner()
	if not IsValid(owner) then return end
	if owner ~= LocalPlayer() then return end

	local scopeMat = self.ScopeMat or self.DefaultScopeMat

	local att = self:GetAttachment( self:LookupAttachment('muzzle') )
	if not att then return end

	local pos, ang = LocalToWorld(self.ScopeOffset, angle2, att.Pos, att.Ang)

	local w, h = unpack(self.ScopeSize)
	local radius = math.max(w, h)
	local semiRadius = radius * 0.5

	qwb.fullyClearStencil()
	render.SetStencilEnable(true)
		render.SetStencilCompareFunction(STENCIL_ALWAYS)
		render.SetStencilFailOperation(STENCIL_ZERO)
		render.SetStencilZFailOperation(STENCIL_ZERO)
		render.SetStencilPassOperation(STENCIL_REPLACE)
		render.SetStencilReferenceValue(1)

		cam.Start3D2D(pos, ang, 0.01)
			draw.NoTexture()
			surface.SetDrawColor(color_black)
			draw_Circle(semiRadius, semiRadius, semiRadius, 30)
		cam.End3D2D()

		render.SetStencilCompareFunction(STENCIL_EQUAL)

		cam.Start3D2D(pos, ang, 0.01)
			surface.SetDrawColor(color_white)
			surface.SetMaterial(mat)
			surface.DrawTexturedRect(0, 0, w, h)

			surface.SetDrawColor(color_white)
			surface.SetMaterial(scopeMat)
			surface.DrawTexturedRect(0, 0, w, h)
		cam.End3D2D()
	render.SetStencilEnable(false)
end

function SWEP:SecondaryAttack()
end