local color_bg = Color(0, 0, 0, 190)

function SWEP:OpenAttMenu()
	self._attMenu = vgui.Create('DPanel')
	local pnl = self._attMenu

	pnl:SetSize(ScrW(), ScrH())

	function pnl:Paint(w, h)
		surface.SetDrawColor(color_bg)
		surface.DrawRect(0, 0, w, h)
	end

	qwb.attMenuOpened = true
end

function SWEP:CloseAttMenu()
	self._attMenu:Remove()
	self._attMenu = nil

	qwb.attMenuOpened = nil
end

function SWEP:ToggleAttMenu()
	if IsValid(self._attMenu) then
		self:CloseAttMenu()
	else
		self:OpenAttMenu()
	end
end

-- hook.Add('OnContextMenuOpen', 'qwb.att.menu', function()
-- 	local weap = LocalPlayer():GetActiveWeapon()
-- 	if not IsValid(weap) then return end
-- 	if not weap.IsQWB then return end

-- 	weap:ToggleAttMenu()
-- end)