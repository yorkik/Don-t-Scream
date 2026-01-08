function qwb.isPlayerRunning(ply)
	if not IsValid(ply) then return end

	return ply:KeyDown(IN_SPEED) and ply:GetVelocity():LengthSqr() > 0
end