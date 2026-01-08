ABILITIES = {
	REG = {
		["esp"] = {
			title = LANG.Get('ESP'),
			cooldown = 60,
			button = KEY_X,
			check = function( ply )
				return true
			end,
			callback = function( ply )
				if SERVER then
					net.Start("EnableESPFromAbility")
					net.WriteEntity(ply)
					net.WriteFloat(CurTime() + 10)
					net.Send(ply)

					net.Start("EnableESPFromAbility")
					net.WriteEntity(ply)
					net.WriteFloat(CurTime() + 10)
					net.SendPVS(ply:GetPos())
				else
					net.Start("EnableESPFromAbility")
					net.SendToServer()
				end
			end
		},
		["cloak"] = {
			title = LANG.Get('CLOAK'),
			cooldown = 40,
			button = KEY_C,
			check = function( ply )
				return true
			end,
			callback = function( ply )
				if SERVER then
					net.Start("EnableCloak")
					net.WriteEntity(ply)
					net.WriteFloat(CurTime() + 5)
					net.Broadcast()
					
					timer.Simple(5, function()
						if IsValid(ply) then
							net.Start("DisableCloak")
							net.WriteEntity(ply)
							net.Broadcast()
						end
					end)
				end
			end
		},
		["jump"] = {
			title = LANG.Get('JUMP'),
			cooldown = 20,
			button = KEY_C,
			check = function( ply )
				return true
			end,
			callback = function( ply )
				ply:SetNWBool('jumpboost', true)
				timer.Simple(10, function()
					ply:SetNWBool('jumpboost', false)
				end)
			end
		},
		["skin"] = {
			title = LANG.Get('SKIN'),
			cooldown = 30,
			button = KEY_C,
			check = function( ply )
				return true
			end,
			callback = function( ply )
				local models = {
					'models/citizens/pavka/male_01.mdl',
					'models/citizens/pavka/male_02.mdl',
					'models/citizens/pavka/male_03.mdl',
					'models/citizens/pavka/male_04.mdl',
					'models/citizens/pavka/male_05.mdl',
					'models/citizens/pavka/male_06.mdl',
					'models/citizens/pavka/male_07.mdl',
					'models/citizens/pavka/male_08.mdl',
					'models/citizens/pavka/male_09.mdl',
					'models/citizens/pavka/male_10.mdl',
					'models/citizens/pavka/male_11.mdl',
					'models/citizens/pavka/female_01.mdl',
					'models/citizens/pavka/female_01_b.mdl',
					'models/citizens/pavka/female_02.mdl',
					'models/citizens/pavka/female_02_b.mdl',
					'models/citizens/pavka/female_03.mdl',
					'models/citizens/pavka/female_03_b.mdl',
					'models/citizens/pavka/female_04.mdl',
					'models/citizens/pavka/female_04_b.mdl',
					'models/citizens/pavka/female_06.mdl',
					'models/citizens/pavka/female_06_b.mdl',
					'models/citizens/pavka/female_07.mdl',
					'models/citizens/pavka/female_07_b.mdl',
				}

				ply:SetModel(table.Random(models))
				ply:Give('ds_hands')
				
				local bodygroups = ply:GetBodyGroups()
				for _, bg in ipairs(bodygroups) do
					local num = bg.num

					if num > 0 then
						ply:SetBodygroup(bg.id, math.random(0, num - 1))
					end 
				end

				timer.Simple(0.2, function()
					ply:SetBodygroup(5, 0)
				end)

				ply:SetNWBool('skinchange', true)
				timer.Simple(10, function()
					ply:SetModel('models/dejtriyev/cof/psycho.mdl')
					ply:StripWeapon('ds_hands')
					ply:SetNWBool('skinchange', false)
				end)
			end
		}
	}
}





function ABILITIES.GetAll()
	return ABILITIES.REG
end

function ABILITIES.GetByName( ply, name )
	for _, tbl in pairs( ply.FPAbilities ) do
		if tbl.name == name then
			return _
		end
	end
end

function ABILITIES.GetByKey( ply, button )
	local tbl = {}

	for i, _ in pairs( ply.FPAbilities ) do
		if ABILITIES.REG[_.name].button == button then
			tbl[#tbl + 1] = _.name
		end
	end

	return tbl
end

if SERVER then

util.AddNetworkString('FPAbilities')

function ABILITIES.Sync( ply )
	net.Start( "FPAbilities" )
		net.WritePlayer( ply )
		net.WriteTable( ply.FPAbilities )
	net.Broadcast()
end

function ABILITIES.SetupTeam( teamID, name )
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() == teamID then
            local abilityExists = false
            for _, ability in pairs(ply.FPAbilities or {}) do
                if ability.name == name then
                    abilityExists = true
                    break
                end
            end

            if not abilityExists then
                ply.FPAbilities = ply.FPAbilities or {}
                ply.FPAbilities[#ply.FPAbilities + 1] = {
                    name = name,
                    next = 0,
                    uses = ABILITIES.REG[name].uses or -1
                }
            end
        end
    end
    for _, ply in pairs(player.GetAll()) do
        if ply:Team() == teamID then
            ABILITIES.Sync( ply )
        end
    end
end

function ABILITIES.Setup( ply, name )
	ply.FPAbilities[#ply.FPAbilities + 1] = {
		name = name,
		next = 0,
		uses = ABILITIES.REG[name].uses or -1
	}

	ABILITIES.Sync( ply )
end

function ABILITIES.Remove( ply, name )
	ply.FPAbilities[ABILITIES.GetByName( ply, name )] = nil
	
	ABILITIES.Sync( ply )
end

function ABILITIES.Clear( ply )
	ply.FPAbilities = {}

	ABILITIES.Sync( ply )
end

function ABILITIES.Spend( ply, name, num )
	local eff = ABILITIES.GetByName( ply, name )
	
	if ply.FPAbilities[eff].uses > 0 then
		ply.FPAbilities[eff].uses = ply.FPAbilities[eff].uses - ( num or 1 )

		if ply.FPAbilities[eff].uses == 0 then
			ABILITIES.Remove( ply, name )
		end
	end
end

function ABILITIES.Use( ply, name )
	local ct = CurTime()

	local eff = ABILITIES.GetByName( ply, name )
	ply.FPAbilities[eff].next = ct + ABILITIES.REG[name].cooldown,

	ABILITIES.REG[name].callback( ply )

	ABILITIES.Sync( ply )
end

hook.Add( "PlayerButtonDown", "FPUseAbility", function( ply, button )
	local efftbl = ABILITIES.GetByKey( ply, button )

	for i, v in ipairs( efftbl ) do
		if ply.FPAbilities[ABILITIES.GetByName( ply, v)].next < CurTime() and ( !isfunction( ABILITIES.REG[v].check ) or ABILITIES.REG[v].check( ply ) ) then
			ABILITIES.Use( ply, v )
		end
	end
end)

else

hook.Add( "HUDPaint", "HUDAbilities", function()
	local ply = LocalPlayer()
	local abs = ply.FPAbilities or {}

	local size = ScreenScale( 19 )
	local gap = ScreenScale( 5 )
	local total_space = #abs * size + ( #abs - 1 ) * gap
	local start_pos = ( ScrW() - total_space )/2

	local cornerLength = 15
    local cornerThickness = 3
    local cornerOffset = 0

	for k, v in pairs( abs ) do
		local name = v.name

		local ratio = math.min( 1, ( abs[k].next - CurTime() ) / ABILITIES.REG[name].cooldown )

		local time = math.max( 0, abs[k].next - CurTime() )
		if time > 0 then
			draw.SimpleText( math.Round( time, time < 10 and 1 or 0 ), "ui.10", start_pos + size/2, ScrH() - size - gap*6/3.54, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local uses = v.uses
		if uses > -1 then
			draw.SimpleText( uses, "ui.10", start_pos + size/2, ScrH() - gap*4/4, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		render.SetStencilEnable( true )

	    render.ClearStencil()
	    
	    render.SetStencilTestMask( 255 )
	    render.SetStencilWriteMask( 255 )

	    render.SetStencilPassOperation( STENCILOPERATION_KEEP )
	    render.SetStencilZFailOperation( STENCILOPERATION_KEEP )

	    render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_NEVER )

	    render.SetStencilReferenceValue( 9 )
	    render.SetStencilFailOperation( STENCILOPERATION_REPLACE )

		draw.RoundedBox( 0, start_pos, ScrH() - size - gap, size, size, color_white )
		
		render.SetStencilFailOperation( STENCILOPERATION_KEEP )

		render.SetStencilCompareFunction( STENCILCOMPARISONFUNCTION_EQUAL )

		local lerpclr = color_black
		lerpclr.a = 225

		draw.Box(start_pos, ScrH() - size - gap, size, size, cornerLength, cornerThickness, cornerOffset)

		draw.SimpleText( ABILITIES.REG[name].title, "ui.15", start_pos + size/2, ScrH() - size/2 - gap, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		draw.SimpleText( string.upper( input.GetKeyName( ABILITIES.REG[name].button ) ), "ui.12", start_pos + size/1.2, ScrH() - size/1.25 - gap, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

		render.SetStencilEnable( false )

		start_pos = start_pos + ( size + gap )
	end
end )

net.Receive( "FPAbilities", function()
	net.ReadPlayer().FPAbilities = net.ReadTable()
end )

end