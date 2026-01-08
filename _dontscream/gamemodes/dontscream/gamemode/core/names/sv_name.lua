local PLAYER = FindMetaTable('Player')
local name = {
    'John',
    'Michael',
    'David',
    'James',
    'Robert',
    'William',
    'Richard',
    'Joseph',
    'Thomas',
    'Christopher',
    'Daniel',
    'Matthew',
    'Anthony',
    'Mark',
    'Donald',
    'Steven',
    'Paul',
    'Andrew',
    'Joshua',
    'Kenneth',
    'Kevin',
    'Brian',
    'George',
    'Timothy',
    'Roman'
}

local familia = {
    'Smith',
    'Johnson',
    'Williams',
    'Brown',
    'Jones',
    'Garcia',
    'Miller',
    'Davis',
    'Rodriguez',
    'Martinez',
    'Hernandez',
    'Lopez',
    'Gonzalez',
    'Wilson',
    'Anderson',
    'Thomas',
    'Taylor',
    'Kutarumov',
    'Jackson',
    'Shelderov',
    'Lee',
    'Perez',
    'Imperatorov',
    'White',
    'Volkov'
}

function PLAYER:SetRandomNames()
    local rndnamefamilia = name[math.random(1, #name)] .. " " .. familia[math.random(1, #familia)]
    self:SetNWString('rndnames', rndnamefamilia)
end