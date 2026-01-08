LANG.cfg = {
    ['russian'] = {
        -- ITEMS
        HANDS = 'Руки',
        HANDSACT = 'ПКМ - Поднять',
        BETABLOCKER = 'Бета блокатор',
        ADRENALYN = 'Усилитель P22',
        DETECTER = 'Детектор',
        AXE = 'Тапор',
        FUEL = 'Топливо',
        FLARE = 'Флаер',
        MEDSHOT = 'Усилитель P32',

        EMPLOOT = 'Пусто!',

        -- CLASS
        SPEC = 'Наблюдатель',
        PLAYER = 'Выживший',
        HUNTER = 'Охотник',
        DEXTER = 'Маньяк',
        PARANORMAL = 'Сущность',
        SHOOTER = 'Стрелок',

        -- ABILKI
        ESP = 'Чутьё',
        CLOAK = 'Тень',
        JUMP = 'Полёт',
        SKIN = 'Кожа',
        
        -- RAUND
        WAITPLY = 'ОЖИДАНИЕ ИГРОКОВ',
        PREP = 'ПОДГОТОВКА',
        ENDRND = 'КОНЕЦ РАУНДА',
        RUUUUN = 'Беги!',
        RNDLOST = 'Выжившие проиграли.',
        SURVIVOR_WIN = 'Выжившие победили.',

        -- GENERATOR
        FUELGEN = 'Топливо: ',
        GENE = 'НАЖМИ E',
        ZAPUSKGEN = 'ЗАПУСК:',
        RABOTAETGEN = 'РАБОТАЕТ',

        -- HUD
        VERSIA = 'ВЕРСИЯ',
        FULLAMMO = 'Полный',
        MNOGAAMMO = 'Более половины',
        POLOVINAAMMO = 'Половина',
        MALOAMMO = 'Менее половины',
        OCHMALOAMMO = 'Почти пусто',
        NETUAMMO = 'Пусто',

        -- UI
        F4MENU = "Don't Scream - Меню",
        F4MENUMAIN = 'Основное',
        F4MENUSETT = 'Настройки',
        F4MENUCONT = 'Контент',
        SELECT_LANGUAGE = 'Язык',
        TABINFO = 'Информация о игроке',
        TABNICK = 'Ник: ',
        TABIDCOPY = 'Копировать Steam ID',
        TABIDCOPY2 = 'Скопировано!',
        TABSTRANA = 'Страна: ',
    },
    ['english'] = {
        -- ITEMS
        HANDS = 'Hands',
        HANDSACT = 'RMB - Pickup',
        BETABLOCKER = 'Beta blocker',
        ADRENALYN = 'Booster P22',
        DETECTER = 'Detector',
        AXE = 'Axe',
        FUEL = 'Fuel',
        FLARE = 'Flare',
        MEDSHOT = 'Booster P32',

        EMPLOOT = 'Empty!',

        -- CLASS
        SPEC = 'Spectator',
        PLAYER = 'Survivor',
        HUNTER = 'Hunter',
        DEXTER = 'Maniac',
        PARANORMAL = 'Entity',
        SHOOTER = 'Shooter',

        -- ABILKI
        ESP = 'X-Ray',
        CLOAK = 'Cloak',
        JUMP = 'Flight',
        SKIN = 'Skin',

        -- RAUND
        WAITPLY = 'WAITING FOR PLAYERS',
        PREP = 'PREPARATION',
        ENDRND = 'END OF ROUND',
        RUUUUN = 'Run!',
        RNDLOST = 'The survivors lost.',
        SURVIVOR_WIN = 'The survivors won.',

        -- GENERATOR
        FUELGEN = 'Fuel: ',
        GENE = 'PRESS E',
        ZAPUSKGEN = 'LAUNCH:',
        RABOTAETGEN = 'WORK',

        -- HUD
        VERSIA = 'VERSION',
        FULLAMMO = 'Full',
        MNOGAAMMO = 'More than half',
        POLOVINAAMMO = 'Half',
        MALOAMMO = 'Less than half',
        OCHMALOAMMO = 'Almost empty',
        NETUAMMO = 'Empty',

        -- UI
        F4MENU = "Don't Scream - Menu",
        F4MENUMAIN = 'Main',
        F4MENUSETT = 'Settings',
        F4MENUCONT = 'Content',
        SELECT_LANGUAGE = 'Language',
        TABINFO = 'Player information',
        TABNICK = 'Nick: ',
        TABIDCOPY = 'Copy Steam ID',
        TABIDCOPY2 = 'Copied!',
        TABSTRANA = 'Country: ',
    },
}

LANG.current = 'english'

function LANG.Get(key)
    local lang = LANG.cfg[LANG.current]
    return lang and lang[key] or key
end

function LANG.Set(lang)
    if LANG.cfg[lang] then
        LANG.current = lang
        cookie.Set('selected_language', lang)
        hook.Run('LanguageChanged', lang)
    end
end

local savedLang = cookie.GetString('selected_language', 'english')
LANG.Set(savedLang)