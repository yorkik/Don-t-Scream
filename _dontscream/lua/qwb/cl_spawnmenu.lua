local lang = GetConVar('gmod_language'):GetString()

language.Add('qwb.tab', 'QWB')

if lang == 'ru' then
	language.Add('qwb.options', 'Настройки')
	language.Add('qwb.clientSettings', 'Клиентские настройки')
	language.Add('qwb.serverSettings', 'Серверные настройки')
	language.Add('qwb.firstPersonSelector.slider', 'Режим первого лица (от бедра)')
	language.Add('qwb.firstPersonZNear.slider', 'Ограничение рендера от первого лица (ZNear)')
	language.Add('qwb.realisticDamage.checkbox', 'Включить реалистичный урон')
	language.Add('qwb.realisticDamage.checkbox.tooltip', 'Урон будет масштабироваться в зависимости от части тела, куда попадает пуля')
elseif lang == 'en' then
	language.Add('qwb.options', 'Options')
	language.Add('qwb.clientSettings', 'Client Settings')
	language.Add('qwb.serverSettings', 'Server Settings')
	language.Add('qwb.firstPersonSelector.slider', 'First person mode (from the hip)')
	language.Add('qwb.firstPersonZNear.slider', 'Clipping a first person render (ZNear)')
	language.Add('qwb.realisticDamage.checkbox', 'Enable realistic damage')
	language.Add('qwb.realisticDamage.checkbox.tooltip', 'Damage will scale based on the part of the body the bullet hits')
end

hook.Remove('AddToolMenuTabs', 'qwb', function()
	spawnmenu.AddToolTab('qwb', '#qwb.tab', 'icon16/user_edit.png')
	spawnmenu.AddToolCategory('qwb', 'qwb.options', '#qwb.options')

	spawnmenu.AddToolMenuOption('qwb', 'qwb.options', 'qwb.clientSettings', '#qwb.clientSettings', '', '', function(pnl)
		pnl:ClearControls()
		pnl:NumSlider('#qwb.firstPersonSelector.slider', 'qwb_firstperson', 0, 2, 0):SetTooltip('#qwb.firstPersonSelector.slider')
		pnl:NumSlider('#qwb.firstPersonZNear.slider', 'qwb_firstperson_znear', 1, 5, 2):SetTooltip('#qwb.firstPersonZNear.slider')
	end)

	spawnmenu.AddToolMenuOption('qwb', 'qwb.options', 'qwb.serverSettings', '#qwb.serverSettings', '', '', function(pnl)
		pnl:ClearControls()
		pnl:CheckBox('#qwb.realisticDamage.checkbox', 'qwb_realisticdamage'):SetTooltip('#qwb.realisticDamage.checkbox.tooltip')
	end)
end)