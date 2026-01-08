if SERVER then
	AddCSLuaFile()
	return
end

eChat = {}

eChat.config = {
	timeStamps = true,
	position = 1,	
	fadeTime = 6,
}

surface.CreateFont( "eChat_18", {
	font = "Ithaca",
	size = 18,
	weight = 500,
	antialias = true,
	shadow = true,
	extended = true,
} )

surface.CreateFont( "eChat_16", {
	font = "Ithaca",
	size = 16,
	weight = 500,
	antialias = true,
	shadow = true,
	extended = true,
} )

hook.Remove("Initialize", "echat_init")
hook.Add("Initialize", "echat_init", function()
	eChat.buildBox()
end)

function eChat.buildBox()
	eChat.frame = vgui.Create("DFrame")
	eChat.frame:SetSize( ScrW()*0.375, ScrH()*0.25 )
	eChat.frame:SetTitle("")
	eChat.frame:ShowCloseButton( false )
	eChat.frame:SetDraggable( true )
	eChat.frame:SetSizable( true )
	eChat.frame:SetPos( ScrW()*0.0116, (ScrH() - eChat.frame:GetTall()) - ScrH()*0.177)
	eChat.frame:SetMinWidth( 300 )
	eChat.frame:SetMinHeight( 100 )
	eChat.frame.Paint = function( self, w, h )
		draw.Blur(self)
		-- draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 210) )
		draw.Box(0, 0, w, h, 15, 3, 0)
		
		-- draw.RoundedBoxEx( 8, 0, 0, w, 25, Color( 75, 75, 75, 100), true, true, false, false)
	end
	eChat.oldPaint = eChat.frame.Paint
	eChat.frame.Think = function()
		if input.IsKeyDown( KEY_ESCAPE ) then
			eChat.hideBox()
		end
	end
	
	local serverName = vgui.Create("DLabel", eChat.frame)
	serverName:SetText( GetHostName() )
	serverName:SetFont( "eChat_18" )
	serverName:SizeToContents()
	serverName:SetPos( (eChat.frame:GetWide() - serverName:GetWide()) / 2, 7 )
	
	eChat.entry = vgui.Create("DTextEntry", eChat.frame) 
	eChat.entry:SetSize( eChat.frame:GetWide() - 50, 20 )
	eChat.entry:SetTextColor( color_white )
	eChat.entry:SetFont("eChat_18")
	eChat.entry:SetDrawBorder( false )
	eChat.entry:SetDrawBackground( false )
	eChat.entry:SetCursorColor( color_white )
	eChat.entry:SetHighlightColor( Color(52, 152, 219) )
	eChat.entry:SetPos( 45, eChat.frame:GetTall() - eChat.entry:GetTall() - 5 )
	eChat.entry.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, Color( 82, 82, 82, 100) )
		derma.SkinHook( "Paint", "TextEntry", self, w, h )
	end

	eChat.entry.OnTextChanged = function( self )
		if self and self.GetText then 
			gamemode.Call( "ChatTextChanged", self:GetText() or "" )
		end
	end

	eChat.entry.OnKeyCodeTyped = function( self, code )
		local types = {"", "teamchat"}

		if code == KEY_ESCAPE then

			eChat.hideBox()
			gui.HideGameUI()

		elseif code == KEY_TAB then
			
			eChat.TypeSelector = (eChat.TypeSelector and eChat.TypeSelector + 1) or 1
			
			if eChat.TypeSelector > 3 then eChat.TypeSelector = 1 end
			if eChat.TypeSelector < 1 then eChat.TypeSelector = 3 end
			
			eChat.ChatType = types[eChat.TypeSelector]

			timer.Simple(0.001, function() eChat.entry:RequestFocus() end)

		elseif code == KEY_ENTER then
			-- Replicate the client pressing enter
			
			if string.Trim( self:GetText() ) != "" then
				if eChat.ChatType == types[2] then
					LocalPlayer():ConCommand("say_team \"" .. (self:GetText() or "") .. "\"")
				elseif eChat.ChatType == types[3] then
					LocalPlayer():ConCommand(self:GetText() or "")
				else
					LocalPlayer():ConCommand("say \"" .. self:GetText() .. "\"")
				end
			end

			eChat.TypeSelector = 1
			eChat.hideBox()
		end
	end

	eChat.chatLog = vgui.Create("RichText", eChat.frame) 
	eChat.chatLog:SetSize( eChat.frame:GetWide() - 10, eChat.frame:GetTall() - 60 )
	eChat.chatLog:SetPos( 5, 30 )
	eChat.chatLog.Paint = function( self, w, h )
		draw.RoundedBox( 6, 0, 0, w, h, Color( 82, 82, 82, 100) )
	end
	eChat.chatLog.Think = function( self )
		if eChat.lastMessage then
			if CurTime() - eChat.lastMessage > eChat.config.fadeTime then
				self:SetVisible( false )
			else
				self:SetVisible( true )
			end
		end
		self:SetSize( eChat.frame:GetWide() - 10, eChat.frame:GetTall() - eChat.entry:GetTall() - serverName:GetTall() - 20 )
	end
	eChat.chatLog.PerformLayout = function( self )
		self:SetFontInternal("eChat_18")
		self:SetFGColor( color_white )
	end
	eChat.oldPaint2 = eChat.chatLog.Paint
	
	local text = "Say :"

	local say = vgui.Create("DLabel", eChat.frame)
	say:SetText("")
	surface.SetFont( "eChat_18")
	local w, h = surface.GetTextSize( text )
	say:SetSize( w + 5, 20 )
	say:SetPos( 5, eChat.frame:GetTall() - eChat.entry:GetTall() - 5 )
	
	say.Paint = function( self, w, h )
		draw.DrawText( text, "eChat_18", 2, 1, color_white )
	end

	say.Think = function( self )
		local types = {"", "teamchat"}
		local s = {}

		if eChat.ChatType == types[2] then 
			text = "Say (TEAM) :"	
		else
			text = "Say :"
			s.pw = 45
			s.sw = eChat.frame:GetWide() - 50
		end

		if s then
			if not s.pw then s.pw = self:GetWide() + 10 end
			if not s.sw then s.sw = eChat.frame:GetWide() - self:GetWide() - 15 end
		end

		local w, h = surface.GetTextSize( text )
		self:SetSize( w + 5, 20 )
		self:SetPos( 5, eChat.frame:GetTall() - eChat.entry:GetTall() - 5 )

		eChat.entry:SetSize( s.sw, 20 )
		eChat.entry:SetPos( s.pw, eChat.frame:GetTall() - eChat.entry:GetTall() - 5 )
	end	
	
	eChat.hideBox()
end

--// Hides the chat box but not the messages
function eChat.hideBox()
	if not IsValid(eChat.frame) then return end
	eChat.frame.Paint = function() end
	eChat.chatLog.Paint = function() end

	eChat.chatLog:SetVerticalScrollbarEnabled( false )
	eChat.chatLog:GotoTextEnd()
	
	eChat.lastMessage = eChat.lastMessage or CurTime() - eChat.config.fadeTime
	
	-- Hide the chatbox except the log
	local children = eChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == eChat.frame.btnMaxim or pnl == eChat.frame.btnClose or pnl == eChat.frame.btnMinim then continue end
		
		if pnl != eChat.chatLog then
			pnl:SetVisible( false )
		end
	end
	
	-- Give the player control again
	eChat.frame:SetMouseInputEnabled( false )
	eChat.frame:SetKeyboardInputEnabled( false )
	gui.EnableScreenClicker( false )
	
	-- We are done chatting
	gamemode.Call("FinishChat")
	
	-- Clear the text entry
	eChat.entry:SetText( "" )
	gamemode.Call( "ChatTextChanged", "" )
end

--// Shows the chat box
function eChat.showBox()
	-- Draw the chat box again
	eChat.frame.Paint = eChat.oldPaint
	eChat.chatLog.Paint = eChat.oldPaint2
	
	eChat.chatLog:SetVerticalScrollbarEnabled( true )
	eChat.lastMessage = nil
	
	-- Show any hidden children
	local children = eChat.frame:GetChildren()
	for _, pnl in pairs( children ) do
		if pnl == eChat.frame.btnMaxim or pnl == eChat.frame.btnClose or pnl == eChat.frame.btnMinim then continue end
		
		pnl:SetVisible( true )
	end
	
	-- MakePopup calls the input functions so we don't need to call those
	eChat.frame:MakePopup()
	eChat.entry:RequestFocus()
	
	-- Make sure other addons know we are chatting
	gamemode.Call("StartChat")
end

--// Panel based blur function by Chessnut from NutScript
local blur = Material( "pp/blurscreen" )
function eChat.blur( panel, layers, density, alpha )
	-- Its a scientifically proven fact that blur improves a script
	local x, y = panel:LocalToScreen(0, 0)

	surface.SetDrawColor( 255, 255, 255, alpha )
	surface.SetMaterial( blur )

	for i = 1, 3 do
		blur:SetFloat( "$blur", ( i / layers ) * density )
		blur:Recompute()

		render.UpdateScreenEffectTexture()
		surface.DrawTexturedRect( -x, -y, ScrW(), ScrH() )
	end
end

local oldAddText = chat.AddText

--// Overwrite chat.AddText to detour it into my chatbox
function chat.AddText(...)
	if not eChat.chatLog then
		eChat.buildBox()
	end
	
	local msg = {}
	
	-- Iterate through the strings and colors
	for _, obj in pairs( {...} ) do
		if type(obj) == "table" then
			eChat.chatLog:InsertColorChange( obj.r, obj.g, obj.b, obj.a )
			table.insert( msg, Color(obj.r, obj.g, obj.b, obj.a) )
		elseif type(obj) == "string"  then
			eChat.chatLog:AppendText( obj )
			table.insert( msg, obj )
		elseif obj:IsPlayer() then
			local ply = obj
			
			if eChat.config.timeStamps then
				eChat.chatLog:InsertColorChange( 255, 255, 255, 255 )
				eChat.chatLog:AppendText( "["..os.date("%X").."] ")
			end
			
			if eChat.config.seeChatTags and ply:GetNWBool("eChat_tagEnabled", false) then
				local col = ply:GetNWString("eChat_tagCol", "255 255 255")
				local tbl = string.Explode(" ", col )
				eChat.chatLog:InsertColorChange( tbl[1], tbl[2], tbl[3], 255 )
				eChat.chatLog:AppendText( "["..ply:GetNWString("eChat_tag", "N/A").."] ")
			end
			
			local col = GAMEMODE:GetTeamColor( obj )
			eChat.chatLog:InsertColorChange( col.r, col.g, col.b, 255 )
			eChat.chatLog:AppendText( obj:Nick() )
			table.insert( msg, obj:Nick() )
		end
	end
	eChat.chatLog:AppendText("\n")
	
	eChat.chatLog:SetVisible( true )
	eChat.lastMessage = CurTime()
	eChat.chatLog:InsertColorChange( 255, 255, 255, 255 )
end

--// Write any server notifications
hook.Remove( "ChatText", "echat_joinleave")
hook.Add( "ChatText", "echat_joinleave", function( index, name, text, type )
	if not eChat.chatLog then
		eChat.buildBox()
	end
	
	if type != "chat" then
		eChat.chatLog:InsertColorChange( 0, 128, 255, 255 )
		eChat.chatLog:AppendText( text.."\n" )
		eChat.chatLog:SetVisible( true )
		eChat.lastMessage = CurTime()
		return true
	end
end)

--// Stops the default chat box from being opened
hook.Remove("PlayerBindPress", "echat_hijackbind")
hook.Add("PlayerBindPress", "echat_hijackbind", function(ply, bind, pressed)
	if string.sub( bind, 1, 11 ) == "messagemode" then
		if bind == "messagemode2" then 
			eChat.ChatType = "teamchat"
		else
			eChat.ChatType = ""
		end
		
		if IsValid( eChat.frame ) then
			eChat.showBox()
		else
			eChat.buildBox()
			eChat.showBox()
		end
		return true
	end
end)

--// Hide the default chat too in case that pops up
hook.Remove("HUDShouldDraw", "echat_hidedefault")
hook.Add("HUDShouldDraw", "echat_hidedefault", function( name )
	if name == "CHudChat" then
		return false
	end
end)

 --// Modify the Chatbox for align.
local oldGetChatBoxPos = chat.GetChatBoxPos
function chat.GetChatBoxPos()
	return eChat.frame:GetPos()
end

function chat.GetChatBoxSize()
	return eChat.frame:GetSize()
end

chat.Open = eChat.showBox
function chat.Close(...) 
	if IsValid( eChat.frame ) then 
		eChat.hideBox(...)
	else
		eChat.buildBox()
		eChat.showBox()
	end
end