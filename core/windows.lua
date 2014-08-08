--> this file controls the window position, size and others panels
	
	local _detalhes =	_G._detalhes
	local Loc =			LibStub ("AceLocale-3.0"):GetLocale ( "Details" )
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> local pointers
	
	local _math_floor = math.floor --lua local
	local _type = type --lua local
	local _math_abs = math.abs --lua local
	local _ipairs = ipairs --lua local
	
	local _GetScreenWidth = GetScreenWidth --wow api local
	local _GetScreenHeight = GetScreenHeight --wow api local
	local _UIParent = UIParent --wow api local
	
	local gump = _detalhes.gump --details local

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> constants

	local end_window_spacement = 0
	
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> core

	function _detalhes:AnimarSplit (barra, goal)
		barra.inicio = barra.split.barra:GetValue()
		barra.fim = goal
		barra.proximo_update = 0
		barra.tem_animacao = true
		barra:SetScript ("OnUpdate", self.FazerAnimacaoSplit)
	end

	function _detalhes:FazerAnimacaoSplit (elapsed)
		local velocidade = 0.8
		
		if (self.fim > self.inicio) then
			self.inicio = self.inicio+velocidade
			self.split.barra:SetValue (self.inicio)

			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio+1 >= self.fim) then
				self.tem_animacao = false
				self:SetScript ("OnUpdate", nil)
			end
		else
			self.inicio = self.inicio-velocidade
			self.split.barra:SetValue (self.inicio)
			
			self.split.div:SetPoint ("left", self.split.barra, "left", self.split.barra:GetValue()* (self.split.barra:GetWidth()/100) - 4, 0)
			
			if (self.inicio-1 <= self.fim) then
				self.tem_animacao = false
				self:SetScript ("OnUpdate", nil)
			end
		end
		self.proximo_update = 0
	end

	function _detalhes:fazer_animacoes()
		
		--[
		for i = 2, self.rows_fit_in_window do
			--local row_anterior = self.barras [i-1]
			local row = self.barras [i]
			local row_proxima = self.barras [i+1]
			
			if (row_proxima) then
				local v = row.statusbar:GetValue()
				local v_proxima = row_proxima.statusbar:GetValue()
				
				if (v_proxima > v) then
					if (row.animacao_fim >= v_proxima) then
						row.statusbar:SetValue (v_proxima)
					else
						row.statusbar:SetValue (row.animacao_fim)
						row_proxima.statusbar:SetValue (row.animacao_fim)
					end
				end
			end
		end
		--]]
		
		for i = 2, self.rows_fit_in_window do
			local row = self.barras [i]
			if (row.animacao_ignorar) then
				row.animacao_ignorar = nil
				if (row.tem_animacao) then
					row.tem_animacao = false
					row:SetScript ("OnUpdate", nil)
				end
			else
				if (row.animacao_fim ~= row.animacao_fim2) then
					_detalhes:AnimarBarra (row, row.animacao_fim)
					row.animacao_fim2 = row.animacao_fim
				end
			end
		end
		
	end
	
	function _detalhes:AnimarBarra (esta_barra, fim)
		esta_barra.inicio = esta_barra.statusbar:GetValue()
		esta_barra.fim = fim
		esta_barra.tem_animacao = true
		
		if (esta_barra.fim > esta_barra.inicio) then
			esta_barra:SetScript ("OnUpdate", self.FazerAnimacao_Direita)
		else
			esta_barra:SetScript ("OnUpdate", self.FazerAnimacao_Esquerda)
		end
	end

	function _detalhes:FazerAnimacao_Esquerda (elapsed)
		self.inicio = self.inicio - 1
		self.statusbar:SetValue (self.inicio)
		if (self.inicio-1 <= self.fim) then
			self.tem_animacao = false
			self:SetScript ("OnUpdate", nil)
		end
	end
	
	function _detalhes:FazerAnimacao_Direita (elapsed)
		self.inicio = self.inicio + 1
		self.statusbar:SetValue (self.inicio)
		if (self.inicio+1 >= self.fim) then
			self.tem_animacao = false
			self:SetScript ("OnUpdate", nil)
		end
	end

	function _detalhes:AtualizaPontos()
		local xOfs, yOfs = self.baseframe:GetCenter()
		
		if (not xOfs) then
			return
		end
		
		-- credits to ckknight (http://www.curseforge.com/profiles/ckknight/) 
		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = _UIParent:GetScale()
		xOfs = xOfs*_scale - _GetScreenWidth()*_UIscale/2
		yOfs = yOfs*_scale - _GetScreenHeight()*_UIscale/2
		local _x = xOfs/_UIscale
		local _y = yOfs/_UIscale
		local _w = self.baseframe:GetWidth()
		local _h = self.baseframe:GetHeight()
		
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14
		end
		
		self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
		self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
		self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
		self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
	end

	function _detalhes:SaveMainWindowPosition (instance)
		
		if (instance) then
			self = instance
		end
		local mostrando = self.mostrando
		
		--
		local baseframe_width = self.baseframe:GetWidth()
		local baseframe_height = self.baseframe:GetHeight()
		if (not baseframe_width) then
			return _detalhes:ScheduleTimer ("SaveMainWindowPosition", 1, self)
		end
		--
		local xOfs, yOfs = self.baseframe:GetCenter()
		if (not xOfs) then
			return _detalhes:ScheduleTimer ("SaveMainWindowPosition", 1, self)
		end
		--
		local _scale = self.baseframe:GetEffectiveScale()
		local _UIscale = _UIParent:GetScale()
		--
		xOfs = xOfs*_scale - _GetScreenWidth()*_UIscale/2
		yOfs = yOfs*_scale - _GetScreenHeight()*_UIscale/2
		
		local _w = baseframe_width
		local _h = baseframe_height
		local _x = xOfs/_UIscale
		local _y = yOfs/_UIscale
		
		self.posicao[mostrando].x = _x
		self.posicao[mostrando].y = _y
		self.posicao[mostrando].w = _w
		self.posicao[mostrando].h = _h
		
		local metade_largura = _w/2
		local metade_altura = _h/2
		
		local statusbar_y_mod = 0
		if (not self.show_statusbar) then
			statusbar_y_mod = 14
		end
		
		self.ponto1 = {x = _x - metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topleft
		self.ponto2 = {x = _x - metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomleft
		self.ponto3 = {x = _x + metade_largura, y = _y - metade_altura + statusbar_y_mod} --bottomright
		self.ponto4 = {x = _x + metade_largura, y = _y + metade_altura + (statusbar_y_mod*-1)} --topright
		
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espa�o para o final da janela
		
		return {altura = self.baseframe:GetHeight(), largura = self.baseframe:GetWidth(), x = xOfs/_UIscale, y = yOfs/_UIscale}
	end

	function _detalhes:RestoreMainWindowPosition (pre_defined)

		local _scale = self.baseframe:GetEffectiveScale() 
		local _UIscale = _UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale
		
		if (pre_defined) then --> overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
		end

		self.baseframe:SetWidth (self.posicao[self.mostrando].w)
		self.baseframe:SetHeight (self.posicao[self.mostrando].h)
		
		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint ("CENTER", _UIParent, "CENTER", novo_x, novo_y)

		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espa�o para o final da janela
	end

	function _detalhes:RestoreMainWindowPositionNoResize (pre_defined, x, y)

		x = x or 0
		y = y or 0

		local _scale = self.baseframe:GetEffectiveScale() 
		local _UIscale = _UIParent:GetScale()

		local novo_x = self.posicao[self.mostrando].x*_UIscale/_scale
		local novo_y = self.posicao[self.mostrando].y*_UIscale/_scale
		
		if (pre_defined) then --> overwrite
			novo_x = pre_defined.x*_UIscale/_scale
			novo_y = pre_defined.y*_UIscale/_scale
			self.posicao[self.mostrando].w = pre_defined.largura
			self.posicao[self.mostrando].h = pre_defined.altura
		end

		self.baseframe:ClearAllPoints()
		self.baseframe:SetPoint ("CENTER", _UIParent, "CENTER", novo_x + x, novo_y + y)
		self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement --> espa�o para o final da janela
	end

	function _detalhes:ResetaGump (instancia, tipo, segmento)
		if (not instancia or _type (instancia) == "boolean") then
			segmento = tipo
			tipo = instancia
			instancia = self
		end
		
		if (tipo and tipo == 0x1) then --> entrando em combate
			if (instancia.segmento == -1) then --> esta mostrando a tabela overall
				return
			end
		end
		
		if (segmento and instancia.segmento ~= segmento) then
			return
		end

		instancia.barraS = {nil, nil} --> zera o iterator
		instancia.rows_showing = 0 --> resetou, ent�o n�o esta mostranho nenhuma barra
		
		for i = 1, instancia.rows_created, 1 do --> limpa a refer�ncia do que estava sendo mostrado na barra
			local esta_barra= instancia.barras[i]
			esta_barra.minha_tabela = nil
			esta_barra.animacao_fim = 0
			esta_barra.animacao_fim2 = 0
		end
		
		if (instancia.rolagem) then
			instancia:EsconderScrollBar() --> hida a scrollbar
		end
		instancia.need_rolagem = false
		instancia.bar_mod = nil

	end

	function _detalhes:ReajustaGump()
		
		if (self.mostrando == "normal") then --> somente alterar o tamanho das barras se tiver mostrando o gump normal
		
			if (not self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				if (self.eh_horizontal or self.eh_tudo or (self.verticalSnap and not self.eh_vertical)) then
					for _, instancia in _ipairs (self.stretchToo) do 
						instancia.baseframe:SetWidth (self.baseframe:GetWidth())
						local mod = (self.baseframe:GetWidth() - instancia.baseframe._place.largura) / 2
						instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, mod, nil)
						instancia:BaseFrameSnap()
					end
				end
				if ( (self.eh_vertical or self.eh_tudo or not self.eh_horizontal) and (not self.verticalSnap or self.eh_vertical)) then
					for _, instancia in _ipairs (self.stretchToo) do 
						if (instancia.baseframe) then --> esta criada
							instancia.baseframe:SetHeight (self.baseframe:GetHeight())
							local mod
							if (self.eh_vertical) then
								mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							else
								mod = - (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
							end
							instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
							instancia:BaseFrameSnap()
						end
					end
				end
			elseif (self.baseframe.isStretching and self.stretchToo and #self.stretchToo > 0) then
				for _, instancia in _ipairs (self.stretchToo) do 
					instancia.baseframe:SetHeight (self.baseframe:GetHeight())
					local mod = (self.baseframe:GetHeight() - instancia.baseframe._place.altura) / 2
					instancia:RestoreMainWindowPositionNoResize (instancia.baseframe._place, nil, mod)
				end
			end
			
			if (self.stretch_button_side == 2) then
				self:StretchButtonAnchor (2)
			end
			
			--> reajusta o freeze
			if (self.freezed) then
				_detalhes:Freeze (self)
			end
		
			-- -4 difere a precis�o de quando a barra ser� adicionada ou apagada da barra
			self.baseframe.BoxBarrasAltura = self.baseframe:GetHeight() - end_window_spacement

			local T = self.rows_fit_in_window
			if (not T) then --> primeira vez que o gump esta sendo reajustado
				T = _math_floor (self.baseframe.BoxBarrasAltura / self.row_height)
			end
			
			--> reajustar o local do rel�gio
			local meio = self.baseframe:GetWidth() / 2
			local novo_local = meio - 25
			
			self.rows_fit_in_window = _math_floor ( self.baseframe.BoxBarrasAltura / self.row_height)

			--> verifica se precisa criar mais barras
			if (self.rows_fit_in_window > #self.barras) then--> verifica se precisa criar mais barras
				for i  = #self.barras+1, self.rows_fit_in_window, 1 do
					gump:CriaNovaBarra (self, i) --> cria nova barra
				end
				self.rows_created = #self.barras
			end
			
			--> seta a largura das barras
			if (self.bar_mod and self.bar_mod ~= 0) then
				for index = 1, self.rows_fit_in_window do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.bar_mod)
				end
			else
				for index = 1, self.rows_fit_in_window do
					self.barras [index]:SetWidth (self.baseframe:GetWidth()+self.row_info.space.right)
				end
			end

			--> verifica se precisa esconder ou mostrar alguma barra
			local A = self.barraS[1]
			if (not A) then --> primeira vez que o resize esta sendo usado, no caso no startup do addon ou ao criar uma nova inst�ncia
				--> hida as barras n�o usadas
				for i = 1, self.rows_created, 1 do
					gump:Fade (self.barras [i], 1)
					self.barras [i].on = false
				end
				return
			end
			
			local X = self.rows_showing
			local C = self.rows_fit_in_window

			--> novo iterator
			local barras_diff = C - T --> aqui pega a quantidade de barras, se aumentou ou diminuiu
			if (barras_diff > 0) then --> ganhou barras_diff novas barras
				local fim_iterator = self.barraS[2] --> posi��o atual
				fim_iterator = fim_iterator+barras_diff --> nova posi��o
				local excedeu_iterator = fim_iterator - X --> total que ta sendo mostrado - fim do iterator
				if (excedeu_iterator > 0) then --> extrapolou
					fim_iterator = X --> seta o fim do iterator pra ser na ultima barra
					self.barraS[2] = fim_iterator --> fim do iterator setado
					
					local inicio_iterator = self.barraS[1]
					if (inicio_iterator-excedeu_iterator > 0) then --> se as barras que sobraram preenchem o inicio do iterator
						inicio_iterator = inicio_iterator-excedeu_iterator --> pega o novo valor do iterator
						self.barraS[1] = inicio_iterator
					else
						self.barraS[1] = 1 --> se ganhou mais barras pra cima, ignorar elas e mover o iterator para a poci��o inicial
					end
				else
					--> se n�o extrapolou esta okey e esta mostrando a quantidade de barras correta
					self.barraS[2] = fim_iterator
				end
				
				for index = T+1, C do
					local barra = self.barras[index]
					if (barra) then
						if (index <= X) then
							gump:Fade (barra, "out")
						else
							if (self.baseframe.isStretching or self.auto_resize) then
								gump:Fade (barra, 1)
							else
								gump:Fade (barra, "in", 0.1)
							end
						end
					end
				end
				
			elseif (barras_diff < 0) then --> perdeu barras_diff barras
				local fim_iterator = self.barraS[2] --> posi��o atual
				if (not (fim_iterator == X and fim_iterator < C)) then --> calcula primeiro as barras que foram perdidas s�o barras que n�o estavam sendo usadas
					--> perdi X barras, diminui X posi��es no iterator
					local perdeu = _math_abs (barras_diff)
					
					if (fim_iterator == X) then --> se o iterator tiver na ultima posi��o
						perdeu = perdeu - (C - X)
					end
					
					fim_iterator = fim_iterator - perdeu
					
					if (fim_iterator < C) then
						fim_iterator = C
					end
					
					self.barraS[2] = fim_iterator
					
					for index = T, C+1, -1 do
						local barra = self.barras[index]
						if (barra) then
							if (self.baseframe.isStretching or self.auto_resize) then
								gump:Fade (barra, 1)
							else	
								gump:Fade (barra, "in", 0.1)
							end
						end
					end
				end
			end

			if (X <= C) then --> desligar a rolagem
				if (self.rolagem and not self.baseframe.isStretching) then
					self:EsconderScrollBar()
				end
				self.need_rolagem = false
			else --> ligar ou atualizar a rolagem
				if (not self.rolagem and not self.baseframe.isStretching) then
					self:MostrarScrollBar()
				end
				self.need_rolagem = true
			end
			
			--> verificar o tamanho dos nomes
			local qual_barra = 1
			for i = self.barraS[1], self.barraS[2], 1 do
				local esta_barra = self.barras [qual_barra]
				local tabela = esta_barra.minha_tabela
				
				if (tabela) then --> a barra esta mostrando alguma coisa
				
					if (tabela._custom) then 
						tabela (esta_barra, self)
					elseif (tabela._refresh_window) then
						tabela:_refresh_window (esta_barra, self)
					else
						tabela:RefreshBarra (esta_barra, self, true)
					end

				end
				
				qual_barra = qual_barra+1
			end
			
			--> for�a o pr�ximo refresh
			self.showing[self.atributo].need_refresh = true

		end	
	end

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--> panels

--> cooltip presets
	function _detalhes:CooltipPreset (preset)
		local GameCooltip = GameCooltip
	
		GameCooltip:Reset()
		
		if (preset == 1) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 12)
			GameCooltip:SetOption ("ButtonsYMod", -4)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)
			
		elseif (preset == 2) then
			GameCooltip:SetOption ("TextFont", "Friz Quadrata TT")
			GameCooltip:SetOption ("TextColor", "orange")
			GameCooltip:SetOption ("TextSize", 12)
			GameCooltip:SetOption ("FixedWidth", 220)
			GameCooltip:SetOption ("ButtonsYMod", -4)
			GameCooltip:SetOption ("YSpacingMod", -4)
			GameCooltip:SetOption ("IgnoreButtonAutoHeight", true)
			GameCooltip:SetColor (1, 0.5, 0.5, 0.5, 0.5)
			
		end
	end

--> yes no panel

	do
		_detalhes.yesNo = _detalhes.gump:NewPanel (UIParent, _, "DetailsYesNoWindow", _, 500, 80)
		_detalhes.yesNo:SetPoint ("center", UIParent, "center")
		_detalhes.gump:NewLabel (_detalhes.yesNo, _, "$parentAsk", "ask", "")
		_detalhes.yesNo ["ask"]:SetPoint ("center", _detalhes.yesNo, "center", 0, 25)
		_detalhes.yesNo ["ask"]:SetWidth (480)
		_detalhes.yesNo ["ask"]:SetJustifyH ("center")
		_detalhes.yesNo ["ask"]:SetHeight (22)
		_detalhes.gump:NewButton (_detalhes.yesNo, _, "$parentNo", "no", 100, 30, function() _detalhes.yesNo:Hide() end, nil, nil, nil, Loc ["STRING_NO"])
		_detalhes.gump:NewButton (_detalhes.yesNo, _, "$parentYes", "yes", 100, 30, nil, nil, nil, nil, Loc ["STRING_YES"])
		_detalhes.yesNo ["no"]:SetPoint (10, -45)
		_detalhes.yesNo ["yes"]:SetPoint (390, -45)
		_detalhes.yesNo ["no"]:InstallCustomTexture()
		_detalhes.yesNo ["yes"]:InstallCustomTexture()
		_detalhes.yesNo ["yes"]:SetHook ("OnMouseUp", function() _detalhes.yesNo:Hide() end)
		function _detalhes:Ask (msg, func, ...)
			_detalhes.yesNo ["ask"].text = msg
			local p1, p2 = ...
			_detalhes.yesNo ["yes"]:SetClickFunction (func, p1, p2)
			_detalhes.yesNo:Show()
		end
		_detalhes.yesNo:Hide()
	end
	
--> cria o frame de wait for plugin
	function _detalhes:CreateWaitForPlugin()
	
		local WaitForPluginFrame = CreateFrame ("frame", "DetailsWaitForPluginFrame" .. self.meu_id, UIParent)
		local WaitTexture = WaitForPluginFrame:CreateTexture (nil, "overlay")
		WaitTexture:SetTexture ("Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame")
		WaitTexture:SetPoint ("center", WaitForPluginFrame)
		WaitTexture:SetWidth (180)
		WaitTexture:SetHeight (180)
		WaitForPluginFrame.wheel = WaitTexture
		local RotateAnimGroup = WaitForPluginFrame:CreateAnimationGroup()
		local rotate = RotateAnimGroup:CreateAnimation ("Rotation")
		rotate:SetDegrees (360)
		rotate:SetDuration (60)
		RotateAnimGroup:SetLooping ("repeat")
		
		local bgpanel = gump:NewPanel (UIParent, UIParent, "DetailsWaitFrameBG"..self.meu_id, nil, 120, 30, false, false, false)
		bgpanel:SetPoint ("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop ({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor (.2, .2, .2, 1)
		
		local label = gump:NewLabel (UIParent, UIParent, nil, nil, Loc ["STRING_WAITPLUGIN"]) --> localize-me
		label.color = "silver"
		label:SetPoint ("center", WaitForPluginFrame, "center")
		label:SetJustifyH ("center")
		label:Hide()

		WaitForPluginFrame:Hide()	
		self.wait_for_plugin_created = true
		
		function self:WaitForPlugin()
		
			self:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])
		
			if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == self.baseframe) then
				self.waiting_pid = self:ScheduleTimer ("ExecDelayedPlugin1", 5, self)
			end
		
			WaitForPluginFrame:SetParent (self.baseframe)
			WaitForPluginFrame:SetAllPoints (self.baseframe)
			local size = math.max (self.baseframe:GetHeight()* 0.35, 100) 
			WaitForPluginFrame.wheel:SetWidth (size)
			WaitForPluginFrame.wheel:SetHeight (size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()
			
			self.waiting_raid_plugin = true
			
			self.waiting_pid = self:ScheduleTimer ("ExecDelayedPlugin1", 5, self)
		end
		
		function self:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
		end
		
		function self:ExecDelayedPlugin1()
		
			self.waiting_raid_plugin = nil
			self.waiting_pid = nil
		
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
			
			if (self.meu_id == _detalhes.solo) then
				_detalhes.SoloTables:switch (nil, _detalhes.SoloTables.Mode)
				
			elseif (self.modo == _detalhes._detalhes_props["MODO_RAID"]) then
				_detalhes.RaidTables:EnableRaidMode (self)
				
			end
		end	
	end
	
	do
		local WaitForPluginFrame = CreateFrame ("frame", "DetailsWaitForPluginFrame", UIParent)
		local WaitTexture = WaitForPluginFrame:CreateTexture (nil, "overlay")
		WaitTexture:SetTexture ("Interface\\UNITPOWERBARALT\\Mechanical_Circular_Frame")
		WaitTexture:SetPoint ("center", WaitForPluginFrame)
		WaitTexture:SetWidth (180)
		WaitTexture:SetHeight (180)
		WaitForPluginFrame.wheel = WaitTexture
		local RotateAnimGroup = WaitForPluginFrame:CreateAnimationGroup()
		local rotate = RotateAnimGroup:CreateAnimation ("Rotation")
		rotate:SetDegrees (360)
		rotate:SetDuration (60)
		RotateAnimGroup:SetLooping ("repeat")
		
		local bgpanel = gump:NewPanel (UIParent, UIParent, "DetailsWaitFrameBG", nil, 120, 30, false, false, false)
		bgpanel:SetPoint ("center", WaitForPluginFrame, "center")
		bgpanel:SetBackdrop ({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background"})
		bgpanel:SetBackdropColor (.2, .2, .2, 1)
		
		local label = gump:NewLabel (UIParent, UIParent, nil, nil, Loc ["STRING_WAITPLUGIN"]) --> localize-me
		label.color = "silver"
		label:SetPoint ("center", WaitForPluginFrame, "center")
		label:SetJustifyH ("center")
		label:Hide()

		WaitForPluginFrame:Hide()	
		
		function _detalhes:WaitForSoloPlugin (instancia)
		
			instancia:ChangeIcon ([[Interface\GossipFrame\ActiveQuestIcon]])
		
			if (WaitForPluginFrame:IsShown() and WaitForPluginFrame:GetParent() == instancia.baseframe) then
				return _detalhes:ScheduleTimer ("ExecDelayedPlugin", 5, instancia)
			end
		
			WaitForPluginFrame:SetParent (instancia.baseframe)
			WaitForPluginFrame:SetAllPoints (instancia.baseframe)
			local size = math.max (instancia.baseframe:GetHeight()* 0.35, 100) 
			WaitForPluginFrame.wheel:SetWidth (size)
			WaitForPluginFrame.wheel:SetHeight (size)
			WaitForPluginFrame:Show()
			label:Show()
			bgpanel:Show()
			RotateAnimGroup:Play()
			
			return _detalhes:ScheduleTimer ("ExecDelayedPlugin", 5, instancia)
		end
		
		function _detalhes:CancelWaitForPlugin()
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
		end
		
		function _detalhes:ExecDelayedPlugin (instancia)
		
			RotateAnimGroup:Stop()
			WaitForPluginFrame:Hide()	
			label:Hide()
			bgpanel:Hide()
			
			if (instancia.meu_id == _detalhes.solo) then
				_detalhes.SoloTables:switch (nil, _detalhes.SoloTables.Mode)
				
			elseif (instancia.meu_id == _detalhes.raid) then
				_detalhes.RaidTables:switch (nil, _detalhes.RaidTables.Mode)
				
			end
		end	
	end

--> tutorial bubbles
	do
		--[1] criar nova instancia
		--[2] esticar janela
		--[3] resize e trava
		--[4] shortcut frame
		--[5] micro displays
		--[6] snap windows
	
		function _detalhes:run_tutorial()
		
			local lower_instance = _detalhes:GetLowerInstanceNumber()
				if (lower_instance) then
				local instance = _detalhes:GetInstance (lower_instance)
			
				_detalhes.times_of_tutorial = _detalhes.times_of_tutorial + 1
				if (_detalhes.times_of_tutorial > 20) then
					return
				end
			
				if (_detalhes.MicroButtonAlert:IsShown()) then
					return _detalhes:ScheduleTimer ("delay_tutorial", 2)
				end

				if (not _detalhes.tutorial.alert_frames [1]) then
				
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_1"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe.cabecalho.novo, "top", 0, 16)
					_detalhes.MicroButtonAlert:SetHeight (200)
					_detalhes.MicroButtonAlert:Show()
					_detalhes.tutorial.alert_frames [1] = true
					
				elseif (not _detalhes.tutorial.alert_frames [2]) then
				
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_2"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe.button_stretch, "top", 0, 15)
					instance.baseframe.button_stretch:Show()
					instance.baseframe.button_stretch:SetAlpha (1)
					_detalhes.MicroButtonAlert:Show()
					_detalhes.tutorial.alert_frames [2] = true
				
				elseif (not _detalhes.tutorial.alert_frames [3]) then
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_3"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe.resize_direita, "top", -8, 16)
					
					_detalhes.OnEnterMainWindow (instance)
					instance.baseframe.button_stretch:SetAlpha (0)
					
					_detalhes.MicroButtonAlert:Show()
					_detalhes.tutorial.alert_frames [3] = true
				
				elseif (not _detalhes.tutorial.alert_frames [4]) then
				
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_4"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe, "center", 0, 16)
					_detalhes.MicroButtonAlert:Show()
					_detalhes.tutorial.alert_frames [4] = true
					
				elseif (not _detalhes.tutorial.alert_frames [5]) then
				
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_5"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe.rodape.top_bg, "top", 0, 16)
					_detalhes.MicroButtonAlert:Show()
					_detalhes.MicroButtonAlert:SetHeight (220)
					_detalhes.tutorial.alert_frames [5] = true
					
				elseif (not _detalhes.tutorial.alert_frames [6]) then
				
					_detalhes.MicroButtonAlert.Text:SetText (Loc ["STRING_MINITUTORIAL_6"])
					_detalhes.MicroButtonAlert:SetPoint ("bottom", instance.baseframe.barra_direita, "center", -24, 16)
					_detalhes.MicroButtonAlert:SetHeight (200)
					_detalhes.MicroButtonAlert:Show()
					_detalhes.tutorial.alert_frames [6] = true
				
					return --> colocando return pra nao rodar o schedule infinitamente
				end
			end
			--
			_detalhes:ScheduleTimer ("delay_tutorial", 2)
		end
	
		-- [1] criar nova instancia
		-- [2] esticar janela
		-- [3] resize e trava
		-- [4] shortcut frame
		-- [5] micro displays
		-- [6] snap windows
	
		function _detalhes:delay_tutorial()
			if (_detalhes.character_data.logons < 2) then
				_detalhes:run_tutorial()
			end
		end
		
		function _detalhes:StartTutorial()
			--
			if (_G ["DetailsWelcomeWindow"] and _G ["DetailsWelcomeWindow"]:IsShown()) then
				return _detalhes:ScheduleTimer ("StartTutorial", 10)
			end
			--
			_detalhes.times_of_tutorial = 0 
			_detalhes:ScheduleTimer ("delay_tutorial", 5)
		end
	
	end

	
--> create bubble
	do 
		local f = CreateFrame ("frame", "DetailsBubble", UIParent)
		f:SetPoint ("center", UIParent, "center")
		f:SetSize (100, 100)
		f:SetFrameStrata ("TOOLTIP")
		f.isHorizontalFlipped = false
		f.isVerticalFlipped = false
		
		local t = f:CreateTexture (nil, "artwork")
		t:SetTexture ([[Interface\AddOns\Details\images\icons]])
		t:SetSize (131 * 1.2, 81 * 1.2)
		--377 328 508 409  0.0009765625
		t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
		t:SetPoint ("center", f, "center")
		
		local line1 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line1:SetPoint ("topleft", t, "topleft", 24, -10)
		_detalhes:SetFontSize (line1, 9)
		line1:SetTextColor (.9, .9, .9, 1)
		line1:SetSize (110, 12)
		line1:SetJustifyV ("center")
		line1:SetJustifyH ("center")

		local line2 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line2:SetPoint ("topleft", t, "topleft", 11, -20)
		_detalhes:SetFontSize (line2, 9)
		line2:SetTextColor (.9, .9, .9, 1)
		line2:SetSize (140, 12)
		line2:SetJustifyV ("center")
		line2:SetJustifyH ("center")
		
		local line3 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line3:SetPoint ("topleft", t, "topleft", 7, -30)
		_detalhes:SetFontSize (line3, 9)
		line3:SetTextColor (.9, .9, .9, 1)
		line3:SetSize (144, 12)
		line3:SetJustifyV ("center")
		line3:SetJustifyH ("center")
		
		local line4 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line4:SetPoint ("topleft", t, "topleft", 11, -40)
		_detalhes:SetFontSize (line4, 9)
		line4:SetTextColor (.9, .9, .9, 1)
		line4:SetSize (140, 12)
		line4:SetJustifyV ("center")
		line4:SetJustifyH ("center")

		local line5 = f:CreateFontString (nil, "overlay", "GameFontHighlightSmall")
		line5:SetPoint ("topleft", t, "topleft", 24, -50)
		_detalhes:SetFontSize (line5, 9)
		line5:SetTextColor (.9, .9, .9, 1)
		line5:SetSize (110, 12)
		line5:SetJustifyV ("center")
		line5:SetJustifyH ("center")
		
		f.lines = {line1, line2, line3, line4, line5}
		
		function f:FlipHorizontal()
			if (not f.isHorizontalFlipped) then
				if (f.isVerticalFlipped) then
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
				end
				f.isHorizontalFlipped = true
			else
				if (f.isVerticalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
				end
				f.isHorizontalFlipped = false
			end
		end
		
		function f:FlipVertical()
		
			if (not f.isVerticalFlipped) then
				if (f.isHorizontalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.7978515625, 0.6416015625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.7978515625, 0.6416015625)
				end
				f.isVerticalFlipped = true
			else
				if (f.isHorizontalFlipped) then
					t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
				else
					t:SetTexCoord (0.9912109375, 0.7373046875, 0.6416015625, 0.7978515625)
				end
				f.isVerticalFlipped = false
			end
		end
		
		function f:TextConfig (fontsize, fontface, fontcolor)
			for i = 1, 5 do
			
				local line = f.lines [i]
				
				_detalhes:SetFontSize (line, fontsize or 9)
				_detalhes:SetFontFace (line, fontface or [[Fonts\FRIZQT__.TTF]])
				_detalhes:SetFontColor (line, fontcolor or {.9, .9, .9, 1})

			end
		end
		
		function f:SetBubbleText (line1, line2, line3, line4, line5)
			if (not line1) then
				for _, line in ipairs (f.lines) do
					line:SetText ("")
				end
				return
			end
			
			if (line1:find ("\n")) then
				line1, line2, line3, line4, line5 = strsplit ("\n", line1)
			end
			
			f.lines[1]:SetText (line1)
			f.lines[2]:SetText (line2)
			f.lines[3]:SetText (line3)
			f.lines[4]:SetText (line4)
			f.lines[5]:SetText (line5)
		end
		
		function f:SetOwner (frame, myPoint, hisPoint, x, y, alpha)
			f:ClearAllPoints()
			f:TextConfig()
			f:SetBubbleText (nil)
			t:SetTexCoord (0.7373046875, 0.9912109375, 0.6416015625, 0.7978515625)
			f.isHorizontalFlipped = false
			f.isVerticalFlipped = false
			f:SetPoint (myPoint or "bottom", frame, hisPoint or "top", x or 0, y or 0)
			t:SetAlpha (alpha or 1)
		end
		
		function f:ShowBubble()
			f:Show()
		end
		
		function f:HideBubble()
			f:Hide()
		end
		
		f:SetBubbleText (nil)
		
		f:Hide()
	end
	
--> feed back request
	
	function _detalhes:ShowFeedbackRequestWindow()
	
		local feedback_frame = CreateFrame ("FRAME", "DetailsFeedbackWindow", UIParent, "ButtonFrameTemplate")
		tinsert (UISpecialFrames, "DetailsFeedbackWindow")
		feedback_frame:SetPoint ("center", UIParent, "center")
		feedback_frame:SetSize (512, 200)
		feedback_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
		
		feedback_frame.TitleText:SetText ("Details! Need Your Help!")
		
		feedback_frame.uppertext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
		feedback_frame.uppertext:SetText ("Tell us about your experience using Details!, what you liked most, where we could improve, what things you want to see in the future?")
		feedback_frame.uppertext:SetPoint ("topleft", feedback_frame, "topleft", 60, -32)
		local font, _, flags = feedback_frame.uppertext:GetFont()
		feedback_frame.uppertext:SetFont (font, 10, flags)
		feedback_frame.uppertext:SetTextColor (1, 1, 1, .8)
		feedback_frame.uppertext:SetWidth (440)

		local editbox = _detalhes.gump:NewTextEntry (feedback_frame, nil, "$parentTextEntry", "text", 387, 14)
		editbox:SetPoint (20, -106)
		editbox:SetAutoFocus (false)
		editbox:SetHook ("OnEditFocusGained", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
			editbox:HighlightText()
		end)
		editbox:SetHook ("OnEditFocusLost", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks" 
			editbox:HighlightText()
		end)
		editbox:SetHook ("OnChar", function() 
			editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
			editbox:HighlightText()
		end)
		editbox.text = "http://www.mmo-champion.com/threads/1480721-New-damage-meter-%28Details!%29-need-help-with-tests-and-feedbacks"
		
		
		feedback_frame.midtext = feedback_frame:CreateFontString (nil, "artwork", "GameFontNormal")
		feedback_frame.midtext:SetText ("visit the link above and let's make Details! stronger!")
		feedback_frame.midtext:SetPoint ("center", editbox.widget, "center")
		feedback_frame.midtext:SetPoint ("top", editbox.widget, "bottom", 0, -2)
		feedback_frame.midtext:SetJustifyH ("center")
		local font, _, flags = feedback_frame.midtext:GetFont()
		feedback_frame.midtext:SetFont (font, 10, flags)
		--feedback_frame.midtext:SetTextColor (1, 1, 1, 1)
		feedback_frame.midtext:SetWidth (440)
		
		
		feedback_frame.gnoma = feedback_frame:CreateTexture (nil, "artwork")
		feedback_frame.gnoma:SetPoint ("topright", feedback_frame, "topright", -1, -59)
		feedback_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
		feedback_frame.gnoma:SetSize (105*1.05, 107*1.05)
		feedback_frame.gnoma:SetTexCoord (0.2021484375, 0, 0.7919921875, 1)

		feedback_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", feedback_frame, "OptionsButtonTemplate")
		feedback_frame.close:SetPoint ("bottomleft", feedback_frame, "bottomleft", 8, 4)
		feedback_frame.close:SetText ("Close")
		feedback_frame.close:SetScript ("OnClick", function (self)
			editbox:ClearFocus()
			feedback_frame:Hide()
		end)
		
		feedback_frame.postpone = CreateFrame ("Button", "DetailsFeedbackWindowPostPoneButton", feedback_frame, "OptionsButtonTemplate")
		feedback_frame.postpone:SetPoint ("bottomright", feedback_frame, "bottomright", -10, 4)
		feedback_frame.postpone:SetText ("Remind-me Later")
		feedback_frame.postpone:SetScript ("OnClick", function (self)
			editbox:ClearFocus()
			feedback_frame:Hide()
			_detalhes.tutorial.feedback_window1 = false
		end)
		feedback_frame.postpone:SetWidth (130)
		
		feedback_frame:SetScript ("OnHide", function() 
			editbox:ClearFocus()
		end)
		
		--0.0009765625 512
		function _detalhes:FeedbackSetFocus()
			DetailsFeedbackWindow:Show()
			DetailsFeedbackWindowTextEntry.MyObject:SetFocus()
			DetailsFeedbackWindowTextEntry.MyObject:HighlightText()
		end
		_detalhes:ScheduleTimer ("FeedbackSetFocus", 5)
	
	end
	
--> interface menu
	local f = CreateFrame ("frame", "DetailsInterfaceOptionsPanel", UIParent)
	f.name = "Details"
	f.logo = f:CreateTexture (nil, "overlay")
	f.logo:SetPoint ("center", f, "center", 0, 0)
	f.logo:SetPoint ("top", f, "top", 25, 56)
	f.logo:SetTexture ([[Interface\AddOns\Details\images\logotipo]])
	f.logo:SetSize (256, 128)
	InterfaceOptions_AddCategory (f)
	
		--> open options panel
		f.options_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.options_button:SetText (Loc ["STRING_INTERFACE_OPENOPTIONS"])
		f.options_button:SetPoint ("topleft", f, "topleft", 10, -100)
		f.options_button:SetWidth (170)
		f.options_button:SetScript ("OnClick", function (self)
			local lower_instance = _detalhes:GetLowerInstanceNumber()
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end)
		
		--> create new window
		f.new_window_button = CreateFrame ("button", nil, f, "OptionsButtonTemplate")
		f.new_window_button:SetText (Loc ["STRING_MINIMAPMENU_NEWWINDOW"])
		f.new_window_button:SetPoint ("topleft", f, "topleft", 10, -125)
		f.new_window_button:SetWidth (170)
		f.new_window_button:SetScript ("OnClick", function (self)
			_detalhes:CriarInstancia (_, true)
		end)	
	
--> row text editor
	local panel = _detalhes.gump:NewPanel (UIParent, nil, "DetailsWindowOptionsBarTextEditor", nil, 650, 200)
	panel:SetPoint ("center", UIParent, "center")
	panel:Hide()
	panel:SetFrameStrata ("FULLSCREEN")
	panel:SetBackdrop ({	bgFile = [[Interface\AddOns\Details\images\background]], tile = true, tileSize = 64, insets = {left=3, right=3, top=3, bottom=3}})
	panel:DisableGradient()
	panel:SetBackdropColor (0, 0, 0, 0)
	panel.locked = false
	
	local bg_texture = _detalhes.gump:NewImage (panel, [[Interface\AddOns\Details\images\welcome]], 1, 1, "background")
	bg_texture:SetPoint ("topleft", panel, "topleft")
	bg_texture:SetPoint ("bottomright", panel, "bottomright")
	
	function panel.widget:Open (text, callback, host, default)
		if (host) then
			panel:SetPoint ("center", host, "center")
		end
		
		text = text:gsub ("||", "|")
		panel.default_text = text
		panel.widget.editbox:SetText (text)
		panel.callback = callback
		panel.default = default or ""
		panel:Show()
	end
	
	local textentry = _detalhes.gump:NewSpecialLuaEditorEntry (panel.widget, 450, 180, "editbox", "$parentEntry", true)
	textentry:SetPoint ("topleft", panel.widget, "topleft", 10, -10)
	
	local arg1_button = _detalhes.gump:NewButton (panel, nil, "$parentButton1", nil, 80, 20, function() textentry.editbox:Insert ("{data1}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "1"), 1)
	local arg2_button = _detalhes.gump:NewButton (panel, nil, "$parentButton2", nil, 80, 20, function() textentry.editbox:Insert ("{data2}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "2"), 1)
	local arg3_button = _detalhes.gump:NewButton (panel, nil, "$parentButton3", nil, 80, 20, function() textentry.editbox:Insert ("{data3}") end, nil, nil, nil, string.format (Loc ["STRING_OPTIONS_TEXTEDITOR_DATA"], "3"), 1)
	arg1_button:SetPoint ("topright", panel, "topright", -10, -14)
	arg2_button:SetPoint ("topright", panel, "topright", -10, -36)
	arg3_button:SetPoint ("topright", panel, "topright", -10, -58)
	arg1_button:InstallCustomTexture()
	arg2_button:InstallCustomTexture()
	arg3_button:InstallCustomTexture()
	
	arg1_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	arg2_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	arg3_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DATA_TOOLTIP"]
	
	-- code author Saiket from  http://www.wowinterface.com/forums/showpost.php?p=245759&postcount=6
	--- @return StartPos, EndPos of highlight in this editbox.
	local function GetTextHighlight ( self )
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		self:Insert( "" ); -- Delete selected text
		local TextNew, CursorNew = self:GetText(), self:GetCursorPosition();
		-- Restore previous text
		self:SetText( Text );
		self:SetCursorPosition( Cursor );
		local Start, End = CursorNew, #Text - ( #TextNew - CursorNew );
		self:HighlightText( Start, End );
		return Start, End;
	end
      
	local StripColors;
	do
		local CursorPosition, CursorDelta;
		--- Callback for gsub to remove unescaped codes.
		local function StripCodeGsub ( Escapes, Code, End )
			if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
				if ( CursorPosition and CursorPosition >= End - 1 ) then
					CursorDelta = CursorDelta - #Code;
				end
				return Escapes;
			end
		end
		--- Removes a single escape sequence.
		local function StripCode ( Pattern, Text, OldCursor )
			CursorPosition, CursorDelta = OldCursor, 0;
			return Text:gsub( Pattern, StripCodeGsub ), OldCursor and CursorPosition + CursorDelta;
		end
		--- Strips Text of all color escape sequences.
		-- @param Cursor  Optional cursor position to keep track of.
		-- @return Stripped text, and the updated cursor position if Cursor was given.
		function StripColors ( Text, Cursor )
			Text, Cursor = StripCode( "(|*)(|c%x%x%x%x%x%x%x%x)()", Text, Cursor );
			return StripCode( "(|*)(|r)()", Text, Cursor );
		end
	end
	
	local COLOR_END = "|r";
	--- Wraps this editbox's selected text with the given color.
	local function ColorSelection ( self, ColorCode )
		local Start, End = GetTextHighlight( self );
		local Text, Cursor = self:GetText(), self:GetCursorPosition();
		if ( Start == End ) then -- Nothing selected
			--Start, End = Cursor, Cursor; -- Wrap around cursor
			return; -- Wrapping the cursor in a color code and hitting backspace crashes the client!
		end
		-- Find active color code at the end of the selection
		local ActiveColor;
		if ( End < #Text ) then -- There is text to color after the selection
			local ActiveEnd;
			local CodeEnd, _, Escapes, Color = 0;
			while ( true ) do
				_, CodeEnd, Escapes, Color = Text:find( "(|*)(|c%x%x%x%x%x%x%x%x)", CodeEnd + 1 );
				if ( not CodeEnd or CodeEnd > End ) then
					break;
				end
				if ( #Escapes % 2 == 0 ) then -- Doesn't escape Code
					ActiveColor, ActiveEnd = Color, CodeEnd;
				end
			end
       
			if ( ActiveColor ) then
				-- Check if color gets terminated before selection ends
				CodeEnd = 0;
				while ( true ) do
					_, CodeEnd, Escapes = Text:find( "(|*)|r", CodeEnd + 1 );
					if ( not CodeEnd or CodeEnd > End ) then
						break;
					end
					if ( CodeEnd > ActiveEnd and #Escapes % 2 == 0 ) then -- Terminates ActiveColor
						ActiveColor = nil;
						break;
					end
				end
			end
		end
     
		local Selection = Text:sub( Start + 1, End );
		-- Remove color codes from the selection
		local Replacement, CursorReplacement = StripColors( Selection, Cursor - Start );
     
		self:SetText( ( "" ):join(
			Text:sub( 1, Start ),
			ColorCode, Replacement, COLOR_END,
			ActiveColor or "", Text:sub( End + 1 )
		) );
     
		-- Restore cursor and highlight, adjusting for wrapper text
		Cursor = Start + CursorReplacement;
		if ( CursorReplacement > 0 ) then -- Cursor beyond start of color code
			Cursor = Cursor + #ColorCode;
		end
		if ( CursorReplacement >= #Replacement ) then -- Cursor beyond end of color
			Cursor = Cursor + #COLOR_END;
		end
		
		self:SetCursorPosition( Cursor );
		-- Highlight selection and wrapper
		self:HighlightText( Start, #ColorCode + ( #Replacement - #Selection ) + #COLOR_END + End );
	end
	
	local color_func = function (_, r, g, b, a)
		local hex = _detalhes:hex (a*255).._detalhes:hex (r*255).._detalhes:hex (g*255).._detalhes:hex (b*255)
		ColorSelection ( textentry.editbox, "|c" .. hex)
	end
	
	local func_button = _detalhes.gump:NewButton (panel, nil, "$parentButton4", nil, 80, 20, function() textentry.editbox:Insert ("{func local player = ...; return 0;}") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC"], 1)
	local color_button = _detalhes.gump:NewColorPickButton (panel, "$parentButton5", nil, color_func)
	color_button:SetSize (80, 20)
	func_button:SetPoint ("topright", panel, "topright", -10, -80)
	color_button:SetPoint ("topright", panel, "topright", -10, -102)
	func_button:InstallCustomTexture()
	
	color_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COLOR_TOOLTIP"]
	func_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_FUNC_TOOLTIP"]
	
	--color_button:InstallCustomTexture()
	
	--local comma_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonComma", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:comma_value ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA"])
	--local tok_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonTok", nil, 80, 20, function() textentry.editbox:Insert ("_detalhes:ToK2 ( )") end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_TOK"])
	--comma_button:InstallCustomTexture()
	--tok_button:InstallCustomTexture()
	--comma_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_COMMA_TOOLTIP"]
	--tok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_TOK_TOOLTIP"]
	
	--comma_button:SetPoint ("topright", panel, "topright", -100, -14)
	--tok_button:SetPoint ("topright", panel, "topright", -100, -36)
	
	local done = function()
		local text = panel.widget.editbox:GetText()
		text = text:gsub ("\n", "")
		
		local test = text
	
		local function errorhandler(err)
			return geterrorhandler()(err)
		end
	
		local code = [[local str = "STR"; str = str:ReplaceData (100, 50, 75, {nome = "you", total = 10, total_without_pet = 5, damage_taken = 7, last_dps = 1, friendlyfire_total = 6, totalover = 2, totalabsorb = 4, totalover_without_pet = 6, healing_taken = 1, heal_enemy_amt = 2});]]
		code = code:gsub ("STR", test)

		local f = loadstring (code)
		local err, two = xpcall (f, errorhandler)
		
		if (not err) then
			return
		end
		
		panel.callback (text)
		panel:Hide()
	end
	
	local ok_button = _detalhes.gump:NewButton (panel, nil, "$parentButtonOk", nil, 80, 20, done, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_DONE"], 1)
	ok_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_DONE_TOOLTIP"]
	ok_button:InstallCustomTexture()
	ok_button:SetPoint ("topright", panel, "topright", -10, -174)
	
	local reset_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultOk", nil, 80, 20, function() textentry.editbox:SetText (panel.default) end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_RESET"], 1)
	reset_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_RESET_TOOLTIP"]
	reset_button:InstallCustomTexture()
	reset_button:SetPoint ("topright", panel, "topright", -100, -152)
	
	local cancel_button = _detalhes.gump:NewButton (panel, nil, "$parentDefaultCancel", nil, 80, 20, function() textentry.editbox:SetText (panel.default_text); done(); end, nil, nil, nil, Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL"], 1)
	cancel_button.tooltip = Loc ["STRING_OPTIONS_TEXTEDITOR_CANCEL_TOOLTIP"]
	cancel_button:InstallCustomTexture()
	cancel_button:SetPoint ("topright", panel, "topright", -100, -174)	
	
	--update window
	function _detalhes:OpenUpdateWindow()
	
		if (not _G.DetailsUpdateDialog) then
			local updatewindow_frame = CreateFrame ("frame", "DetailsUpdateDialog", UIParent, "ButtonFrameTemplate")
			updatewindow_frame:SetFrameStrata ("LOW")
			tinsert (UISpecialFrames, "DetailsUpdateDialog")
			updatewindow_frame:SetPoint ("center", UIParent, "center")
			updatewindow_frame:SetSize (512, 200)
			updatewindow_frame.portrait:SetTexture ([[Interface\CHARACTERFRAME\TEMPORARYPORTRAIT-FEMALE-GNOME]])
			
			updatewindow_frame.TitleText:SetText ("A New Version Is Available!")

			updatewindow_frame.midtext = updatewindow_frame:CreateFontString (nil, "artwork", "GameFontNormal")
			updatewindow_frame.midtext:SetText ("Good news everyone!\nA new version has been forged and is waiting to be looted.")
			updatewindow_frame.midtext:SetPoint ("topleft", updatewindow_frame, "topleft", 10, -90)
			updatewindow_frame.midtext:SetJustifyH ("center")
			updatewindow_frame.midtext:SetWidth (370)
			
			updatewindow_frame.gnoma = updatewindow_frame:CreateTexture (nil, "artwork")
			updatewindow_frame.gnoma:SetPoint ("topright", updatewindow_frame, "topright", -3, -59)
			updatewindow_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
			updatewindow_frame.gnoma:SetSize (105*1.05, 107*1.05)
			updatewindow_frame.gnoma:SetTexCoord (0.2021484375, 0, 0.7919921875, 1)
			
			local editbox = _detalhes.gump:NewTextEntry (updatewindow_frame, nil, "$parentTextEntry", "text", 387, 14)
			editbox:SetPoint (20, -136)
			editbox:SetAutoFocus (false)
			editbox:SetHook ("OnEditFocusGained", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook ("OnEditFocusLost", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox:SetHook ("OnChar", function() 
				editbox.text = "http://www.curse.com/addons/wow/details"
				editbox:HighlightText()
			end)
			editbox.text = "http://www.curse.com/addons/wow/details"
			
			updatewindow_frame.close = CreateFrame ("Button", "DetailsUpdateDialogCloseButton", updatewindow_frame, "OptionsButtonTemplate")
			updatewindow_frame.close:SetPoint ("bottomleft", updatewindow_frame, "bottomleft", 8, 4)
			updatewindow_frame.close:SetText ("Close")
			
			updatewindow_frame.close:SetScript ("OnClick", function (self)
				DetailsUpdateDialog:Hide()
				editbox:ClearFocus()
			end)
			
			updatewindow_frame:SetScript ("OnHide", function()
				editbox:ClearFocus()
			end)
			
			function _detalhes:UpdateDialogSetFocus()
				DetailsUpdateDialog:Show()
				DetailsUpdateDialogTextEntry.MyObject:SetFocus()
				DetailsUpdateDialogTextEntry.MyObject:HighlightText()
			end
			_detalhes:ScheduleTimer ("UpdateDialogSetFocus", 1)
			
		end
		
	end	
	
	--> minimap icon and hotcorner
	function _detalhes:RegisterMinimapAndHotCorner()
		local LDB = LibStub ("LibDataBroker-1.1", true)
		local LDBIcon = LDB and LibStub ("LibDBIcon-1.0", true)
		
		if LDB then

			local databroker = LDB:NewDataObject ("Details!", {
				type = "launcher",
				icon = [[Interface\AddOns\Details\images\minimap]],
				text = "0",
				
				HotCornerIgnore = true,
				
				OnClick = function (self, button)
				
					if (button == "LeftButton") then
					
						--> 1 = open options panel
						if (_detalhes.minimap.onclick_what_todo == 1) then
							local lower_instance = _detalhes:GetLowerInstanceNumber()
							if (not lower_instance) then
								local instance = _detalhes:GetInstance (1)
								_detalhes.CriarInstancia (_, _, 1)
								_detalhes:OpenOptionsWindow (instance)
							else
								_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
							end
						
						--> 2 = reset data
						elseif (_detalhes.minimap.onclick_what_todo == 2) then
							_detalhes.tabela_historico:resetar()
						
						--> 3 = unknown
						elseif (_detalhes.minimap.onclick_what_todo == 3) then
						
						end
						
					elseif (button == "RightButton") then
					
						GameTooltip:Hide()
						local GameCooltip = GameCooltip
						
						GameCooltip:Reset()
						GameCooltip:SetType ("menu")
						GameCooltip:SetOption ("ButtonsYMod", -5)
						GameCooltip:SetOption ("HeighMod", 5)
						GameCooltip:SetOption ("TextSize", 10)

						--344 427 200 268 0.0009765625
						--0.672851, 0.833007, 0.391601, 0.522460
						
						GameCooltip:SetBannerImage (1, [[Interface\AddOns\Details\images\icons]], 83*.5, 68*.5, {"bottomleft", "topleft", 1, -4}, {0.672851, 0.833007, 0.391601, 0.522460}, nil)
						GameCooltip:SetBannerImage (2, "Interface\\PetBattles\\Weather-Windy", 512*.35, 128*.3, {"bottomleft", "topleft", -25, -4}, {0, 1, 1, 0})
						GameCooltip:SetBannerText (1, "Mini Map Menu", {"left", "right", 2, -5}, "white", 10)
						
						--> reset
						GameCooltip:AddMenu (1, _detalhes.tabela_historico.resetar, true, nil, nil, Loc ["STRING_MINIMAPMENU_RESET"], nil, true)
						GameCooltip:AddIcon ([[Interface\COMMON\VOICECHAT-MUTED]], 1, 1, 14, 14)
						
						GameCooltip:AddLine ("$div")
						
						--> nova instancai
						GameCooltip:AddMenu (1, _detalhes.CriarInstancia, true, nil, nil, Loc ["STRING_MINIMAPMENU_NEWWINDOW"], nil, true)
						GameCooltip:AddIcon ([[Interface\ICONS\Spell_ChargePositive]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
						
						--> reopen window 64: 0.0078125
						local reopen = function()
							for _, instance in ipairs (_detalhes.tabela_instancias) do 
								if (not instance:IsAtiva()) then
									_detalhes:CriarInstancia (instance.meu_id)
									return
								end
							end
						end
						GameCooltip:AddMenu (1, reopen, nil, nil, nil, Loc ["STRING_MINIMAPMENU_REOPEN"], nil, true)
						GameCooltip:AddIcon ([[Interface\ICONS\Ability_Priest_VoidShift]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
						
						GameCooltip:AddMenu (1, _detalhes.ReabrirTodasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_REOPENALL"], nil, true)
						GameCooltip:AddIcon ([[Interface\ICONS\Ability_Priest_VoidShift]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "#ffb400")

						GameCooltip:AddLine ("$div")
						
						--> lock
						GameCooltip:AddMenu (1, _detalhes.TravasInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_LOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125)
						
						GameCooltip:AddMenu (1, _detalhes.DestravarInstancias, true, nil, nil, Loc ["STRING_MINIMAPMENU_UNLOCK"], nil, true)
						GameCooltip:AddIcon ([[Interface\PetBattles\PetBattle-LockIcon]], 1, 1, 14, 14, 0.0703125, 0.9453125, 0.0546875, 0.9453125, "gray")
						
						GameCooltip:SetOwner (self, "topright", "bottomleft")
						GameCooltip:ShowCooltip()
						

					end
				end,
				OnTooltipShow = function (tooltip)
					tooltip:AddLine ("Details!", 1, 1, 1)
					if (_detalhes.minimap.onclick_what_todo == 1) then
						tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP1"])
					elseif (_detalhes.minimap.onclick_what_todo == 2) then
						tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP11"])
					end
					tooltip:AddLine (Loc ["STRING_MINIMAP_TOOLTIP2"])
				end,
			})
			
			if (databroker and not LDBIcon:IsRegistered ("Details!")) then
				LDBIcon:Register ("Details!", databroker, self.minimap)
			end
			
			_detalhes.databroker = databroker
			
		end

		--register lib-hotcorners
		local on_click_on_hotcorner_button = function (frame, button) 
			if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
				local lower_instance = _detalhes:GetLowerInstanceNumber()
				if (not lower_instance) then
					local instance = _detalhes:GetInstance (1)
					_detalhes.CriarInstancia (_, _, 1)
					_detalhes:OpenOptionsWindow (instance)
				else
					_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
				end
				
			elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
				_detalhes.tabela_historico:resetar()
			end
		end
		
		local on_click_on_quickclick_button = function (frame, button) 
			if (_detalhes.hotcorner_topleft.quickclick_what_todo == 1) then
				local lower_instance = _detalhes:GetLowerInstanceNumber()
				if (not lower_instance) then
					local instance = _detalhes:GetInstance (1)
					_detalhes.CriarInstancia (_, _, 1)
					_detalhes:OpenOptionsWindow (instance)
				else
					_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
				end
				
			elseif (_detalhes.hotcorner_topleft.quickclick_what_todo == 2) then
				_detalhes.tabela_historico:resetar()
			end
		end
		
		local tooltip_hotcorner = function()
			GameTooltip:AddLine ("Details!", 1, 1, 1, 1)
			if (_detalhes.hotcorner_topleft.onclick_what_todo == 1) then
				GameTooltip:AddLine ("|cFF00FF00Left Click:|r open options panel.", 1, 1, 1, 1)
				
			elseif (_detalhes.hotcorner_topleft.onclick_what_todo == 2) then
				GameTooltip:AddLine ("|cFF00FF00Left Click:|r clear all segments.", 1, 1, 1, 1)
				
			end
		end
		
		if (_G.HotCorners) then
			_G.HotCorners:RegisterHotCornerButton (
				--> absolute name
				"Details!",
				--> corner
				"TOPLEFT", 
				--> config table
				_detalhes.hotcorner_topleft,
				--> frame _G name
				"DetailsLeftCornerButton", 
				--> icon
				[[Interface\AddOns\Details\images\minimap]], 
				--> tooltip
				tooltip_hotcorner,
				--> click function
				on_click_on_hotcorner_button, 
				--> menus
				nil, 
				--> quick click
				on_click_on_quickclick_button
			)
		end
	end
	
	--old versions dialog
	--[[
	--print ("Last Version:", _detalhes_database.last_version, "Last Interval Version:", _detalhes_database.last_realversion)

	local resetwarning_frame = CreateFrame ("FRAME", "DetailsResetConfigWarningDialog", UIParent, "ButtonFrameTemplate")
	resetwarning_frame:SetFrameStrata ("LOW")
	tinsert (UISpecialFrames, "DetailsResetConfigWarningDialog")
	resetwarning_frame:SetPoint ("center", UIParent, "center")
	resetwarning_frame:SetSize (512, 200)
	resetwarning_frame.portrait:SetTexture ("Interface\\CHARACTERFRAME\\TEMPORARYPORTRAIT-FEMALE-GNOME")
	resetwarning_frame:SetScript ("OnHide", function()
		DetailsBubble:HideBubble()
	end)
	
	resetwarning_frame.TitleText:SetText ("Noooooooooooo!!!")

	resetwarning_frame.midtext = resetwarning_frame:CreateFontString (nil, "artwork", "GameFontNormal")
	resetwarning_frame.midtext:SetText ("A pack of murlocs has attacked Details! tech center, our gnomes engineers are working on fixing the damage.\n\n If something is messed in your Details!, especially the close, instance and reset buttons, you can either 'Reset Skin' or access the options panel.")
	resetwarning_frame.midtext:SetPoint ("topleft", resetwarning_frame, "topleft", 10, -90)
	resetwarning_frame.midtext:SetJustifyH ("center")
	resetwarning_frame.midtext:SetWidth (370)
	
	resetwarning_frame.gnoma = resetwarning_frame:CreateTexture (nil, "artwork")
	resetwarning_frame.gnoma:SetPoint ("topright", resetwarning_frame, "topright", -3, -80)
	resetwarning_frame.gnoma:SetTexture ("Interface\\AddOns\\Details\\images\\icons2")
	resetwarning_frame.gnoma:SetSize (89*1.00, 97*1.00)
	--resetwarning_frame.gnoma:SetTexCoord (0.212890625, 0.494140625, 0.798828125, 0.99609375) -- 109 409 253 510
	resetwarning_frame.gnoma:SetTexCoord (0.17578125, 0.001953125, 0.59765625, 0.787109375) -- 1 306 90 403
	
	resetwarning_frame.close = CreateFrame ("Button", "DetailsFeedbackWindowCloseButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.close:SetPoint ("bottomleft", resetwarning_frame, "bottomleft", 8, 4)
	resetwarning_frame.close:SetText ("Close")
	resetwarning_frame.close:SetScript ("OnClick", function (self)
		resetwarning_frame:Hide()
	end)

	resetwarning_frame.see_updates = CreateFrame ("Button", "DetailsResetWindowSeeUpdatesButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.see_updates:SetPoint ("bottomright", resetwarning_frame, "bottomright", -10, 4)
	resetwarning_frame.see_updates:SetText ("Update Info")
	resetwarning_frame.see_updates:SetScript ("OnClick", function (self)
		_detalhes.OpenNewsWindow()
		DetailsBubble:HideBubble()
		--resetwarning_frame:Hide()
	end)
	resetwarning_frame.see_updates:SetWidth (130)
	
	resetwarning_frame.reset_skin = CreateFrame ("Button", "DetailsResetWindowResetSkinButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.reset_skin:SetPoint ("right", resetwarning_frame.see_updates, "left", -5, 0)
	resetwarning_frame.reset_skin:SetText ("Reset Skin")
	resetwarning_frame.reset_skin:SetScript ("OnClick", function (self)
		--do the reset
		for index, instance in ipairs (_detalhes.tabela_instancias) do 
			if (not instance.iniciada) then
				instance:RestauraJanela()
				local skin = instance.skin
				instance:ChangeSkin ("Default Skin")
				instance:ChangeSkin ("Minimalistic")
				instance:ChangeSkin (skin)
				instance:DesativarInstancia()
			else
				local skin = instance.skin
				instance:ChangeSkin ("Default Skin")
				instance:ChangeSkin ("Minimalistic")
				instance:ChangeSkin (skin)
			end
		end
	end)
	resetwarning_frame.reset_skin:SetWidth (130)
	
	resetwarning_frame.open_options = CreateFrame ("Button", "DetailsResetWindowOpenOptionsButton", resetwarning_frame, "OptionsButtonTemplate")
	resetwarning_frame.open_options:SetPoint ("right", resetwarning_frame.reset_skin, "left", -5, 0)
	resetwarning_frame.open_options:SetText ("Options Panel")
	resetwarning_frame.open_options:SetScript ("OnClick", function (self)
		local lower_instance = _detalhes:GetLowerInstanceNumber()
		if (not lower_instance) then
			local instance = _detalhes:GetInstance (1)
			_detalhes.CriarInstancia (_, _, 1)
			_detalhes:OpenOptionsWindow (instance)
		else
			_detalhes:OpenOptionsWindow (_detalhes:GetInstance (lower_instance))
		end
	end)
	resetwarning_frame.open_options:SetWidth (130)

	function _detalhes:ResetWarningDialog()
		DetailsResetConfigWarningDialog:Show()
		DetailsBubble:SetOwner (resetwarning_frame.gnoma, "bottomright", "topleft", 30, -37, 1)
		DetailsBubble:FlipHorizontal()
		DetailsBubble:SetBubbleText ("", "", "WWHYYYYYYYYY!!!!", "", "")
		DetailsBubble:TextConfig (14, nil, "deeppink")
		DetailsBubble:ShowBubble()


	end
	_detalhes:ScheduleTimer ("ResetWarningDialog", 7)
--]]

--[[
	local background_up = f:CreateTexture (nil, "background")
	background_up:SetPoint ("topleft", f, "topleft")
	background_up:SetSize (250, 150)
	background_up:SetTexture ("Interface\\QuestionFrame\\Question-Main")
	background_up:SetTexCoord (0, 420/512, 320/512, 475/512)
	
	local background_down = f:CreateTexture (nil, "background")
	background_down:SetPoint ("topleft", background_up, "bottomleft")
	background_down:SetSize (250, 150)
	background_down:SetTexture ("Interface\\QuestionFrame\\Question-Main")
	background_down:SetTexCoord (0, 420/512, 156/512, 308/512)
	
	background_up:SetDesaturated (true)
	background_down:SetDesaturated (true)
--]]