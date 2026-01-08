GM.Name = "Don't Scream"
-- не трогайте плиз (если тронишь маму шалава)
GM.Author = "Fuzzy & Kutarum"
------------------------------
GM.Website = "https://steamcommunity.com/id/yorkik/"

hg = hg or {}
cfg = cfg or {}
LANG = LANG or {}

--\\ AUTOINCLUDE //
BASE_LUA_PATH = GM.FolderName
BASE_GAMEMODE_PATH = GM.FolderName.."/gamemode"

MODULES_PATH = BASE_GAMEMODE_PATH.."/modules"
CORE_PATH = BASE_GAMEMODE_PATH.."/core"

CVRandom = math.random

local function includeCommonModules()
	if SERVER then
		include( MODULES_PATH.."/sv_module.lua" )
		AddCSLuaFile( MODULES_PATH.."/sh_module.lua" )
		AddCSLuaFile( MODULES_PATH.."/cl_module.lua" )
		print( "||||| LOADED MAIN MODULES" )
	else
		include( MODULES_PATH.."/cl_module.lua" )
	end

	include( MODULES_PATH.."/sh_module.lua" )
end

local function includeGamemodeFiles(path)
	local files, dirs = file.Find( BASE_GAMEMODE_PATH.."/*.lua", "LUA" )
	
	if SERVER then
		print( "" )
		print( "|||||||||||||||||||||| DS | AUTOINCLUDE - GAMEMODE" )
	end
	
	for k, v in pairs( files ) do
		if v == "init.lua" or v == "shared.lua" or v == "cl_init.lua" then 
			continue 
		end
		
		local filepath = BASE_GAMEMODE_PATH.."/"..v
		
		if string.StartWith( v, "sv_" ) then
			if SERVER then
				include( filepath )
				print( "||||| LOADED SERVER GM FILE: "..filepath )
			end
		elseif string.StartWith( v, "cl_" ) then
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED CLIENT GM FILE: "..filepath )
			else
				include( filepath )
			end
		else
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED SHARED GM FILE: "..filepath )
			end
			
			include( filepath )
		end
	end
	
	if SERVER then
		print( "|||||||||||||||||||||| DS | AUTOINCLUDE - GAMEMODE" )
		print( "" )
	end
end

local function includeModules()
	local files, dirs = file.Find( MODULES_PATH.."/*", "LUA" )
	
	for k, v in pairs( dirs or {} ) do
		local modulePath = MODULES_PATH.."/"..v
		local moduleFiles, moduleDirs = file.Find( modulePath.."/*.lua", "LUA" )
		
		if SERVER then
			print( "" )
			print( "|||||||||||||||||||||| DS | AUTOINCLUDE - MODULE: "..v )
		end
		
		for kf, vf in pairs( moduleFiles or {} ) do
			local filepath = modulePath.."/"..vf
			
			if string.StartWith( vf, "sv_" ) then
				if SERVER then
					include( filepath )
					print( "||||| LOADED SERVER MODULE FILE: "..filepath )
				end
			elseif string.StartWith( vf, "cl_" ) then
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED CLIENT MODULE FILE: "..filepath )
				else
					include( filepath )
				end
			else
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED SHARED MODULE FILE: "..filepath )
				end
				
				include( filepath )
			end
		end
		
		if SERVER then
			print( "|||||||||||||||||||||| DS | AUTOINCLUDE - MODULE: "..v )
			print( "" )
		end
	end
end

local function includeByPath( path )
	local files, dirs = file.Find( path.."/*.lua", "LUA" )

	if SERVER then
		print( "" )
		print( "|||||||||||||||||||||| DS | AUTOINCLUDE - "..path )
	end

	for k, v in pairs( files ) do
		if v == "sv_module.lua" or v == "sh_module.lua" or v == "cl_module.lua" then 
			continue 
		end

		local filepath = path.."/"..v

		if string.StartWith( v, "sv_" ) then
			if SERVER then
				include( filepath )
				print( "||||| LOADED SERVER MODULE: "..filepath )
			end
		elseif string.StartWith( v, "cl_" ) then
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED CLIENT MODULE: "..filepath )
			else
				include( filepath )
			end
		else
			if SERVER then
				AddCSLuaFile( filepath )
				print( "||||| LOADED SHARED MODULE: "..filepath )
			end

			include( filepath )
		end
	end

	if SERVER then
		print( "|||||||||||||||||||||| DS | AUTOINCLUDE - "..path )
		print( "" )
	end
end

local function includeCore()
	local files, dirs = file.Find( CORE_PATH.."/*", "LUA" )
	
	for k, v in pairs( dirs or {} ) do
		local corePath = CORE_PATH.."/"..v
		local coreFiles, coreDirs = file.Find( corePath.."/*.lua", "LUA" )
		
		if SERVER then
			print( "" )
			print( "|||||||||||||||||||||| DS | AUTOINCLUDE - CORE: "..v )
		end
		
		for kf, vf in pairs( coreFiles or {} ) do
			local filepath = corePath.."/"..vf
			
			if string.StartWith( vf, "sv_" ) then
				if SERVER then
					include( filepath )
					print( "||||| LOADED SERVER CORE FILE: "..filepath )
				end
			elseif string.StartWith( vf, "cl_" ) then
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED CLIENT CORE FILE: "..filepath )
				else
					include( filepath )
				end
			else
				if SERVER then
					AddCSLuaFile( filepath )
					print( "||||| LOADED SHARED CORE FILE: "..filepath )
				end
				
				include( filepath )
			end
		end
		
		if SERVER then
			print( "|||||||||||||||||||||| DS | AUTOINCLUDE - CORE: "..v )
			print( "" )
		end
	end
end

includeGamemodeFiles()
--includeByPath(MODULES_PATH)
-- includeModules()
includeCore()
includeByPath(CORE_PATH)






----------- TEAMS ---------------------------------------------------------------------------------
function GM:CreateTeams()
	TEAM_SPEC = 1
	TEAM_PLAYER = 2
	TEAM_HUNTER = 3
	TEAM_DEXTER = 4
	TEAM_PARANORMAL = 5
	TEAM_SHOOTER = 6

	team.SetUp(TEAM_SPEC, LANG.Get('SPEC'), Color(0, 0, 0))
	team.SetUp(TEAM_PLAYER, LANG.Get('PLAYER'), Color(255, 255, 255))
	team.SetUp(TEAM_HUNTER, LANG.Get('HUNTER'), Color(114, 0, 0))
	team.SetUp(TEAM_DEXTER, LANG.Get('DEXTER'), Color(114, 0, 0))
	team.SetUp(TEAM_PARANORMAL, LANG.Get('PARANORMAL'), Color(114, 0, 0))
	team.SetUp(TEAM_SHOOTER, LANG.Get('SHOOTER'), Color(114, 0, 0))

end
---------------------------------------------------------------------------------------------------
function isChuchelo(teamID)
    local chucheloTeams = {TEAM_HUNTER, TEAM_DEXTER, TEAM_PARANORMAL, TEAM_SHOOTER}
    
    for _, chucheloTeam in ipairs(chucheloTeams) do
        if teamID == chucheloTeam then
            return true
        end
    end
    
    return false
end
---------------------------------------------------------------------------------------------------
function GetSpawnPos()
    local map = game.GetMap()
    local spawns = cfg.spawnPly[map]
    
    if spawns and #spawns > 0 then
        return spawns[math.random(1, #spawns)]
    end
    
    return Vector(0, 0, 0)
end

function GetChuchSpawnPos()
    local map = game.GetMap()
    local spawns = cfg.spawnChuch[map]
    
    if spawns and #spawns > 0 then
        return spawns[math.random(1, #spawns)]
    end
    
    return Vector(0, 0, 0)
end
---------------------------------------------------------------------------------------------------



local lean_amount = 16
local lean_speed = 1

local function CanPlayerLean(ply)
    if not ply:OnGround() then return false end
    return true
end

concommand.Add("lean_left", function(ply, cmd, args)
    if not CanPlayerLean(ply) then return end
    local current = ply:GetNW2Bool("LeanLeft")
    if current then
        ply:SetNW2Bool("LeanLeft", false)
    else
        ply:SetNW2Bool("LeanLeft", true)
        ply:SetNW2Bool("LeanRight", false)
    end
end)

concommand.Add("lean_right", function(ply, cmd, args)
    if not CanPlayerLean(ply) then return end
    local current = ply:GetNW2Bool("LeanRight")
    if current then
        ply:SetNW2Bool("LeanRight", false)
    else
        ply:SetNW2Bool("LeanRight", true)
        ply:SetNW2Bool("LeanLeft", false)
    end
end)

hook.Add("SetupMove", "BoneLeanSystem", function(ply, mv, cmd)
    local fraction = ply:GetNW2Float("BoneLeanFraction", 0)
    local leanLeft = ply:GetNW2Bool("LeanLeft")
    local leanRight = ply:GetNW2Bool("LeanRight")
    
    if leanLeft and not leanRight then
        fraction = Lerp(FrameTime() * 5 * lean_speed, fraction, -1)
    elseif leanRight and not leanLeft then
        fraction = Lerp(FrameTime() * 5 * lean_speed, fraction, 1)
    else
        fraction = Lerp(FrameTime() * 5 * lean_speed, fraction, 0)
    end
    
    ply:SetNW2Float("BoneLeanFraction", fraction)
end)

local function angle_offset(new, old)
    local _, ang = WorldToLocal(vector_origin, new, vector_origin, old)
    return ang
end

local function ManipulateSpineBones(ply, roll)
    if CLIENT then ply:SetupBones() end

    if halt_leaning then
        return
    end

    for _, bone_name in ipairs({"ValveBiped.Bip01_Spine", "ValveBiped.Bip01_Spine1", "ValveBiped.Bip01_Head1"}) do
        local bone = ply:LookupBone(bone_name)

        if not bone then continue end

        local ang
        local old_ang

        local matrix = ply:GetBoneMatrix(bone)

        if IsValid(matrix) then
            ang = matrix:GetAngles()
            old_ang = matrix:GetAngles()
        else
            _, ang = ply:GetBonePosition(bone)
            _, old_ang = ply:GetBonePosition(bone)
        end

        if bone_name != "ValveBiped.Bip01_Head1" then
            local eyeangles = ply:EyeAngles()
            eyeangles.x = 0
            local forward = eyeangles:Forward()
            ang:RotateAroundAxis(forward, roll)
        else
            local eyeangles = ply:EyeAngles()
            local forward = eyeangles:Forward()
            ang:RotateAroundAxis(forward, -roll)
        end

        ang = angle_offset(ang, old_ang)

        ply:ManipulateBoneAngles(bone, ang, false)
    end
end

hook.Add("Think", "ApplyBoneLean", function()
    for _, ply in ipairs(player.GetAll()) do
        local leanAmount = ply:GetNW2Float("BoneLeanFraction", 0)
        if math.abs(leanAmount) > 0.01 then
            ManipulateSpineBones(ply, leanAmount * lean_amount * 0.5)
        end
    end
end)



--------------------------- ЗАЛУПА ---------------------------------------------------------------
hook.Add("StartCommand", "shit", function(ply, cmd)
	if (ply:GetMoveType()~=MOVETYPE_NOCLIP) then
		local velocityXY = Vector(ply:GetVelocity().x, ply:GetVelocity().y, 0)
        if (velocityXY:Length() > 190) then
			if !ply:Crouching() then
					cmd:RemoveKey(IN_DUCK)
			end
			if ply:Crouching() then
				cmd:SetButtons(IN_DUCK)
			end		
		end
	end
end)

hook.Add("SetupMove", "DisableJumpBoost", function(ply, mv, cmd)
	if ply:GetNWBool('jumpboost', false) then return end
    if mv:KeyPressed(IN_JUMP) and ply:OnGround() and ply:GetJumpPower() > 0 then
        mv:SetForwardSpeed(0)
        mv:SetSideSpeed(0)
    end
end)

hook.Add( "CalcMainActivity", "Alter Crouch and Run Anim", function( Player, Velocity )
	if Player:IsOnGround() and Velocity:Length() > Player:GetRunSpeed() - 10 and (( IsValid(Player:GetActiveWeapon()) and Player:GetActiveWeapon():GetHoldType() == "normal" ) or Player:GetActiveWeapon() == NULL) then
		if Player:Team() == TEAM_HUNTER then return end
		return ACT_HL2MP_RUN_FAST, -1
	end	
	if Player:IsOnGround() and (( IsValid(Player:GetActiveWeapon()) and Player:GetActiveWeapon():GetHoldType() == "normal" ) or Player:GetActiveWeapon() == NULL) and Player:Crouching() and Velocity:Length2DSqr() < 1 and Player:GetSequence() ~= Player:LookupSequence("pose_ducking_02") and Player:GetSequence() ~= Player:LookupSequence("run_all_01") and Player:GetSequence() ~= Player:LookupSequence("idle_all_01") and Player:GetSequence() ~= Player:LookupSequence("walk_all") and Player:GetSequence() ~= Player:LookupSequence("cwalk_all") then
		if Player:Team() == TEAM_HUNTER then return end
		local crouch_anim = Player:LookupSequence("pose_ducking_01")
		return ACT_MP_JUMP, crouch_anim
	else
		return
	end

end)
--------------------------------------------------------------------------------------------------















function hg.eye(ply, dist, ent, aim_vector, startpos)
	if !ply:IsPlayer() then return false end
	local fakeCam = IsValid(ent) and ent != ply
	local ent = (IsValid(ent) and ent) or (IsValid(ply.FakeRagdoll) and ply.FakeRagdoll) or ply
	local bon = ent:LookupBone("ValveBiped.Bip01_Head1")
	if not bon then return end
	if not IsValid(ply) then return end
	if not ply.GetAimVector then return end
	
	local aim_vector = isvector(aim_vector) and aim_vector or ply:GetAimVector()

	if not bon or not ent:GetBoneMatrix(bon) then
		local tr = {
			start = ply:EyePos(),
			endpos = ply:EyePos() + aim_vector * (dist or 60),
			filter = ply
		}
		return ply:EyePos(), aim_vector * (dist or 60), ply//util.TraceLine(tr)
	end

	/*if (ply.InVehicle and ply:InVehicle() and IsValid(ply:GetVehicle())) then
		local veh = ply:GetVehicle()
		local vehang = veh:GetAngles()
		local tr = {
			start = ply:EyePos() + vehang:Right() * -6 + vehang:Up() * 4,
			endpos = ply:EyePos() + aim_vector * (dist or 60),
			filter = ply
		}
		return util.TraceLine(tr), nil, headm
	end*/

	local headm = ent:GetBoneMatrix(bon)
	
	if CLIENT and ply.headmat then headm = ply.headmat end

	--local att_ang = ply:GetAttachment(ply:LookupAttachment("eyes")).Ang
	--ply.lerp_angle = LerpFT(0.1, ply.lerp_angle or Angle(0,0,0), ply:GetNWBool("TauntStopMoving", false) and att_ang or aim_vector:Angle())
	--aim_vector = ply.lerp_angle:Forward()

	local eyeAng = aim_vector:Angle()

	local eyeang2 = aim_vector:Angle()
	eyeang2.p = 0

	local pos = startpos or headm:GetTranslation() + (fakeCam and (headm:GetAngles():Forward() * 2 + headm:GetAngles():Up() * -2 + headm:GetAngles():Right() * 3) or (eyeAng:Up() * 1 + eyeang2:Forward() * 4))
	
	local trace = hg.hullCheck(ply:EyePos() - vector_up * 10,pos,ply)

	--[[if CLIENT then
		cam.Start3D()
			render.DrawWireframeBox(trace.HitPos,angle_zero,traceBuilder.mins,traceBuilder.maxs,color_white)
		cam.End3D()
	end--]]
	
	//local tr = {}
	//tr.start = trace.HitPos
	//tr.endpos = tr.start + aim_vector * (dist or 60)
	//tr.filter = {ply,ent}

	return trace.HitPos, aim_vector * (dist or 60), {ply, ent}, trace, headm//util.TraceLine(tr), trace, headm
end

function hg.eyeTrace(ply, dist, ent, aim_vector, startpos)
	local start, aim, filter, trace, headm = hg.eye(ply, dist, ent, aim_vector, startpos)
	if not start then return end
	if not isvector(start) then return end
	return util.TraceLine({
		start = start,
		endpos = start + aim,
		filter = filter
	}), trace, headm
end

local lend = 2
local vec = Vector(lend,lend,lend)
local traceBuilder = {
	mins = -vec,
	maxs = vec,
	mask = MASK_SOLID,
	collisiongroup = COLLISION_GROUP_DEBRIS
}
local util_TraceHull = util.TraceHull
function hg.hullCheck(startpos,endpos,ply)
	if ply:InVehicle() then return {HitPos = endpos} end
	traceBuilder.start = IsValid(ply.FakeRagdoll) and endpos or startpos
	traceBuilder.endpos = endpos
	traceBuilder.filter = {ply, ply.FakeRagdoll, ply:InVehicle() and ply:GetVehicle()}
	local trace = util_TraceHull(traceBuilder)

	return trace
end

function hg.clamp(vecOrAng, val)
	vecOrAng[1] = math.Clamp(vecOrAng[1], -val, val)
	vecOrAng[2] = math.Clamp(vecOrAng[2], -val, val)
	vecOrAng[3] = math.Clamp(vecOrAng[3], -val, val)
	return vecOrAng
end


FrameTimeClamped = 1/66
ftlerped = 1/66

local def = 1 / 144

local FrameTime, TickInterval, engine_AbsoluteFrameTime = FrameTime, engine.TickInterval, engine.AbsoluteFrameTime
local Lerp, LerpVector, LerpAngle = Lerp, LerpVector, LerpAngle
local math_min = math.min
local math_Clamp = math.Clamp


function hg.FrameTimeClamped(ft)
	--do return math.Clamp(ft or ftlerped,0.001,0.1) end
	return math_Clamp(1 - math.exp(-0.5 * game.GetTimeScale()), 0.000, 0.02)
end

--[[function hg.FrameTimeClamped(ft)
	--do return math.Clamp(ftlerped,0.001,0.016) end
	return math_Clamp(1 - (0.5 ^ (ft or ftlerped)), 0.001, 0.016)
end--]]

local FrameTimeClamped_ = hg.FrameTimeClamped

local function lerpFrameTime(lerp,frameTime)
	return math_Clamp(1 - lerp ^ (frameTime or FrameTime()), 0, 1)-- * (host_timescale())
end

local function lerpFrameTime2(lerp,frameTime)
	--do return math_Clamp(lerp * ftlerped * 150,0,1) end
	--do return math_Clamp(1 - lerp ^ ftlerped,0,1) end
	if lerp == 1 then return 1 end
	return math_Clamp(lerp * FrameTimeClamped_(frameTime) * 150, 0, 1)-- * (host_timescale())
end

hg.lerpFrameTime2 = lerpFrameTime2
hg.lerpFrameTime = lerpFrameTime

function LerpFT(lerp, source, set)
	return Lerp(lerpFrameTime2(lerp), source, set)
end

function LerpVectorFT(lerp, source, set)
	return LerpVector(lerpFrameTime2(lerp), source, set)
end

function LerpAngleFT(lerp, source, set)
	return LerpAngle(lerpFrameTime2(lerp), source, set)
end


function hg.KeyDown(owner,key)
	if not IsValid(owner) then return false end
	owner.keydown = owner.keydown or {}
	local localKey
	if CLIENT then
		if owner == LocalPlayer() then
			localKey = owner.organism and owner:KeyDown(key) or false
		else
			localKey = owner.keydown[key]
		end
	end
	return SERVER and owner:IsPlayer() and owner:KeyDown(key) or CLIENT and localKey
end







if CLIENT then
    vp_punch_angle = Angle()
    vp_punch_angle_last = Angle()
    vp_punch_angle2 = Angle()
    vp_punch_angle_last2 = Angle()
    -- Предполагается, что ftlerped, PUNCH_DAMPING и PUNCH_SPRING_CONSTANT определены где-то выше
    -- Пример их возможного определения (если их нет):
    -- ftlerped = FrameTime() -- или Lerp для плавности
    -- PUNCH_DAMPING = 5
    -- PUNCH_SPRING_CONSTANT = 50

    hook.Add("Think", "viewpunch_think", function()
        local ftlerped = FrameTime() -- Используйте FrameTime() или вашу переменную для сглаживания
        local PUNCH_DAMPING = 5 -- Убедитесь, что это значение определено
        local PUNCH_SPRING_CONSTANT = 50 -- Убедитесь, что это значение определено

        if not vp_punch_angle_velocity then vp_punch_angle_velocity = Angle() end -- Добавьте инициализацию, если вдруг не произошла

        if not vp_punch_angle:IsZero() or not vp_punch_angle_velocity:IsZero() then
            vp_punch_angle = vp_punch_angle + vp_punch_angle_velocity * ftlerped
            local damping = 1 - (PUNCH_DAMPING * ftlerped)
            if damping < 0 then damping = 0 end
            vp_punch_angle_velocity = vp_punch_angle_velocity * damping
            local spring_force_magnitude = PUNCH_SPRING_CONSTANT * 0.01 -- * ftlerped
            vp_punch_angle_velocity = vp_punch_angle_velocity - vp_punch_angle * spring_force_magnitude
            local x, y, z = vp_punch_angle:Unpack()
            vp_punch_angle = Angle(math.Clamp(x, -89, 89), math.Clamp(y, -179, 179), math.Clamp(z, -89, 89))
        else
            -- Убедитесь, что обнуление происходит корректно
            if vp_punch_angle_velocity:IsZero() then
                vp_punch_angle = Angle()
                vp_punch_angle_velocity = Angle()
            end
        end

        -- Проверка на существование LocalPlayer и его жизни (опционально)
        if not IsValid(LocalPlayer()) or not LocalPlayer():Alive() then
             vp_punch_angle:Zero()
             vp_punch_angle_velocity:Zero()
             vp_punch_angle2:Zero()
             --vp_punch_angle_velocity2:Zero()
             vp_punch_angle_last:Zero()
             vp_punch_angle_last2:Zero()
             return -- Выход из хука, если игрок мертв или невалиден
        end

        local ang = LocalPlayer():EyeAngles() + vp_punch_angle - vp_punch_angle_last
        -- LocalPlayer():SetEyeAngles(ang) -- Обычно не нужно, может вызвать проблемы

        local add = vp_punch_angle - vp_punch_angle_last -- + vp_punch_angle2 - vp_punch_angle_last2
        local new_ang = LocalPlayer():EyeAngles() + add

        -- Не изменяем напрямую углы взгляда через SetEyeAngles в Think, это может привести к багам
        -- Вместо этого, используем хук CalcView или другие методы для изменения камеры

        vp_punch_angle_last = vp_punch_angle
        -- vp_punch_angle_last2 = vp_punch_angle2 -- Если используете вторую систему
    end)

    -- Убедитесь, что функции также находятся внутри CLIENT
    function SetViewPunchAngles(angle)
        if not angle then
            print("[Local Viewpunch] SetViewPunchAngles called without an angle. wtf?")
            return
        end
        vp_punch_angle = angle
    end

    function SetViewPunchVelocity(angle)
        if not angle then
            print("[Local Viewpunch] SetViewPunchVelocity called without an angle. wtf?")
            return
        end
        if not vp_punch_angle_velocity then vp_punch_angle_velocity = Angle() end
        vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 20
    end

    function Viewpunch(angle)
        if not angle then
            print("[Local Viewpunch] Viewpunch called without an angle. wtf?")
            return
        end
        if not vp_punch_angle_velocity then vp_punch_angle_velocity = Angle() end
        vp_punch_angle_velocity = vp_punch_angle_velocity + angle * 20
    end

    function Viewpunch2(angle)
        if not angle then
            print("[Local Viewpunch] Viewpunch2 called without an angle. wtf?")
            return
        end
        if not vp_punch_angle_velocity2 then vp_punch_angle_velocity2 = Angle() end
        vp_punch_angle_velocity2 = vp_punch_angle_velocity2 + angle * 20
    end

    function ViewPunch(angle)
        Viewpunch(angle)
    end

    function ViewPunch2(angle)
        Viewpunch2(angle)
    end

    function GetViewPunchAngles()
        return vp_punch_angle or Angle() -- Возвращаем Angle(), если nil
    end

    function GetViewPunchAngles2()
        return vp_punch_angle2 or Angle() -- Возвращаем Angle(), если nil
    end

    function GetViewPunchVelocity()
        return vp_punch_angle_velocity or Angle() -- Возвращаем Angle(), если nil
    end
end