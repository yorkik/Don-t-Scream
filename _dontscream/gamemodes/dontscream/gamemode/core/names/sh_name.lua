local PLAYER = FindMetaTable('Player')

function PLAYER:GetRandomNames()
    return self:GetNWString('rndnames', 'Fuzzy')
end