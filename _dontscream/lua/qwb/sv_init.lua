util.AddNetworkString('qwb.setIronsight')
util.AddNetworkString('qwb.setAttachment')
util.AddNetworkString('qwb.removeAttachment')
util.AddNetworkString('qwb.muzzleFlashLight')

local realisticDamage = CreateConVar('qwb_realisticdamage', 1, FCVAR_NOTIFY, '', 0, 1)

local hitgroups = {
    [HITGROUP_HEAD] = 10000,
    [HITGROUP_STOMACH] = 1.5,
    [HITGROUP_LEFTARM] = 0.2,
    [HITGROUP_RIGHTARM] = 0.2,
    [HITGROUP_LEFTLEG] = 0.3,
    [HITGROUP_RIGHTLEG] = 0.3,
}

hook.Add('ScalePlayerDamage', 'qwb.damage', function( ply, hitgroup, dmginfo )
    if not realisticDamage:GetBool() then return end

    local attacker = dmginfo:GetAttacker()
    if not IsValid(attacker) or not IsValid(attacker:GetActiveWeapon()) then return end

    local weap = attacker:GetActiveWeapon()
    if not weap.IsQWB then return end

    local scale = hitgroups[hitgroup]
    if scale then dmginfo:ScaleDamage(scale) end
end)