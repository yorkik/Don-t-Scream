if SERVER then
	util.AddNetworkString("EnableCloak")
	util.AddNetworkString("DisableCloak")
end

if CLIENT then
	net.Receive("EnableCloak", function()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			hook.Add("PrePlayerDraw", "HidePlayer_" .. ply:EntIndex(), function(drawPly)
				if drawPly == ply then
					return true
				end
			end)
		end
	end)
	
	net.Receive("DisableCloak", function()
		local ply = net.ReadEntity()
		if IsValid(ply) then
			hook.Remove("PrePlayerDraw", "HidePlayer_" .. ply:EntIndex())
		end
	end)
end