function SWEP:CanAttach(attachType, attachID)
	return true
end

function SWEP:SetAttach(attachType, attachID)
	if not self.Attachments[attachType] or not self.Attachments[attachType][attachID] then return end

	self._attachments = self._attachments or {}

	if self._attachments[attachType] == attachID then return end
	if not self:CanAttach(attachType, attachID) then return end

	self._attachments[attachType] = attachID

	net.Start('qwb.setAttachment')
		net.WriteEntity(self)
		net.WriteString(attachType)
		net.WriteString(attachID)
	net.Broadcast()
end

function SWEP:RemoveAttach(attachType)
	if not self._attachments then return end
	if not self._attachments[attachType] then return end

	self._attachments[attachType] = nil

	net.Start('qwb.removeAttachment')
		net.WriteEntity(self)
		net.WriteString(attachType)
	net.Broadcast()
end

net.Receive('qwb.setAttachment', function(_, ply)
	local weap = ply:GetActiveWeapon()
	if not IsValid(weap) or not weap.IsQWB or not weap.SetAttach then return end

	local attachType, attachID = net.ReadString(), net.ReadString()
	if not attachType or not attachID then return end

	weap:SetAttach(attachType, attachID)
end)

net.Receive('qwb.removeAttachment', function(_, ply)
	local weap = ply:GetActiveWeapon()
	if not IsValid(weap) or not weap.IsQWB or not weap.RemoveAttach then return end

	local attachType = net.ReadString()
	if not attachType then return end

	weap:RemoveAttach(attachType)
end)