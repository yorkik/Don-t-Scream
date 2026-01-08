function SWEP:OnRemove()
	for k, v in pairs(self._attachments or {}) do
		if IsValid(v.csEnt) then v.csEnt:Remove() end
	end
end

local function drawOpticAttach(self, flags)
	local weap = self.parent
	if not IsValid(weap) then return end

	local ply = self:GetParent()
	if not IsValid(ply) then return end

	if ply:GetActiveWeapon() ~= weap then return end

	self:DrawModel(flags)

	if not qwb.ironsighted then return end

	local scopeMat = self.opticMat

	local attID = weap:LookupAttachment('muzzle')
	if not attID then return end

	local att = weap:GetAttachment(attID)
	if not att then return end

	local pos, ang = LocalToWorld(self.opticPos, self.opticAng or angle2, self:GetPos(), att.Ang)

	local w, h = unpack(self.opticSize)
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

net.Receive('qwb.setAttachment', function()
	local weap = net.ReadEntity()
	if not IsValid(weap) then return end

	local attachType, attachID = net.ReadString(), net.ReadString()

	local data = weap.Attachments[attachType] and weap.Attachments[attachType][attachID]
	if not data then return end

	weap._attachments = weap._attachments or {}
	weap._attachments[attachType] = weap._attachments[attachType] or {}

	local tbl = weap._attachments[attachType]
	tbl.id = attachID

	if IsValid(tbl.csEnt) then tbl.csEnt:Remove() end

	local owner = weap:GetOwner()

	if not IsValid(tbl.csEnt) then
		tbl.csEnt = ClientsideModel(data.mdl)
		tbl.csEnt:SetParent(LocalPlayer(), LocalPlayer():LookupAttachment('anim_attachment_rh'))
		tbl.csEnt:SetLocalPos(data.pos)
		tbl.csEnt:SetLocalAngles(data.ang)
		tbl.csEnt:SetModelScale(data.scale or 1)

		tbl.csEnt.parent = weap

		if data.opticPos and owner == LocalPlayer() then
			tbl.csEnt.opticPos = data.opticPos
			tbl.csEnt.opticAng = data.opticAng
			tbl.csEnt.opticSize = data.opticSize
			tbl.csEnt.opticMat = data.opticMat or weap.DefaultScopeMat

			tbl.csEnt.RenderOverride = drawOpticAttach
		end

		tbl.csEnt:Spawn()
	end
end)

net.Receive('qwb.removeAttachment', function()
	local weap = net.ReadEntity()
	if not IsValid(weap) then return end
	if not weap._attachments then return end

	local attachType = net.ReadString()
	if not weap._attachments[attachType] then return end

	if IsValid(weap._attachments[attachType].csEnt) then weap._attachments[attachType].csEnt:Remove() end

	weap._attachments[attachType] = nil
end)