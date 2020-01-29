--[[
	~AddOn Engine~
	To load the AddOn engine add this to the top of your file:
		local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB

	To load the AddOn engine inside another addon add this to the top of your file:
		local E, L, V, P, G = unpack(ElvUI); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
]]

--Lua functions
local _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, tcopy = _G, min, format, pairs, gsub, strsplit, unpack, wipe, type, table.copy
local tinsert, sort, ipairs, select = tinsert, sort, ipairs, select
--WoW API / Variables
local CreateFrame = CreateFrame
local GetAddOnEnableState = GetAddOnEnableState
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMetadata = GetAddOnMetadata
local GetLocale = GetLocale
local GetTime = GetTime
local HideUIPanel = HideUIPanel
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local issecurevariable = issecurevariable
local LoadAddOn = LoadAddOn
local DisableAddOn = DisableAddOn
local ReloadUI = ReloadUI

local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local GameMenuButtonAddons = GameMenuButtonAddons
local GameMenuButtonLogout = GameMenuButtonLogout
local GameMenuFrame = GameMenuFrame
local GameTooltip = GameTooltip
-- GLOBALS: ElvCharacterDB, ElvPrivateDB, ElvDB, ElvCharacterData, ElvPrivateData, ElvData

_G.BINDING_HEADER_ELVUI = GetAddOnMetadata(..., 'Title')

local AceAddon, AceAddonMinor = _G.LibStub('AceAddon-3.0')
local CallbackHandler = _G.LibStub('CallbackHandler-1.0')

local AddOnName, Engine = ...
local AddOn = AceAddon:NewAddon(AddOnName, 'AceConsole-3.0', 'AceEvent-3.0', 'AceTimer-3.0', 'AceHook-3.0')
AddOn.version = GetAddOnMetadata('ElvUI', 'Version')
AddOn.callbacks = AddOn.callbacks or CallbackHandler:New(AddOn)
AddOn.DF = {profile = {}, global = {}}; AddOn.privateVars = {profile = {}} -- Defaults
AddOn.Options = {type = 'group', args = {}, childGroups = 'ElvUI_HiddenTree'}

Engine[1] = AddOn
Engine[2] = {}
Engine[3] = AddOn.privateVars.profile
Engine[4] = AddOn.DF.profile
Engine[5] = AddOn.DF.global
_G.ElvUI = Engine

do
	local locale = GetLocale()
	local convert = {enGB = 'enUS', esES = 'esMX', itIT = 'enUS'}
	local gameLocale = convert[locale] or locale or 'enUS'

	function AddOn:GetLocale()
		return gameLocale
	end
end

do
	AddOn.Libs = {}
	AddOn.LibsMinor = {}
	function AddOn:AddLib(name, major, minor)
		if not name then return end

		-- in this case: `major` is the lib table and `minor` is the minor version
		if type(major) == 'table' and type(minor) == 'number' then
			self.Libs[name], self.LibsMinor[name] = major, minor
		else -- in this case: `major` is the lib name and `minor` is the silent switch
			self.Libs[name], self.LibsMinor[name] = _G.LibStub(major, minor)
		end
	end

	AddOn:AddLib('AceAddon', AceAddon, AceAddonMinor)
	AddOn:AddLib('AceDB', 'AceDB-3.0')
	AddOn:AddLib('EP', 'LibElvUIPlugin-1.0')
	AddOn:AddLib('LSM', 'LibSharedMedia-3.0')
	AddOn:AddLib('ACL', 'AceLocale-3.0-ElvUI')
	AddOn:AddLib('LAB', 'LibActionButton-1.0-ElvUI')
	AddOn:AddLib('LDB', 'LibDataBroker-1.1')
	AddOn:AddLib('DualSpec', 'LibDualSpec-1.0')
	AddOn:AddLib('SimpleSticky', 'LibSimpleSticky-1.0')
	AddOn:AddLib('SpellRange', 'SpellRange-1.0')
	AddOn:AddLib('ButtonGlow', 'LibButtonGlow-1.0', true)
	AddOn:AddLib('ItemSearch', 'LibItemSearch-1.2-ElvUI')
	AddOn:AddLib('Compress', 'LibCompress')
	AddOn:AddLib('Base64', 'LibBase64-1.0-ElvUI')
	AddOn:AddLib('Masque', 'Masque', true)
	AddOn:AddLib('Translit', 'LibTranslit-1.0')
	-- added on ElvUI_OptionsUI load: AceGUI, AceConfig, AceConfigDialog, AceConfigRegistry, AceDBOptions

	-- backwards compatible for plugins
	AddOn.LSM = AddOn.Libs.LSM
	AddOn.Masque = AddOn.Libs.Masque
end

AddOn.oUF = Engine.oUF
AddOn.ActionBars = AddOn:NewModule('ActionBars','AceHook-3.0','AceEvent-3.0')
AddOn.AFK = AddOn:NewModule('AFK','AceEvent-3.0','AceTimer-3.0')
AddOn.Auras = AddOn:NewModule('Auras','AceHook-3.0','AceEvent-3.0')
AddOn.Bags = AddOn:NewModule('Bags','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.Blizzard = AddOn:NewModule('Blizzard','AceEvent-3.0','AceHook-3.0')
AddOn.Chat = AddOn:NewModule('Chat','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.DataBars = AddOn:NewModule('DataBars','AceEvent-3.0')
AddOn.DataTexts = AddOn:NewModule('DataTexts','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.DebugTools = AddOn:NewModule('DebugTools','AceEvent-3.0','AceHook-3.0')
AddOn.Distributor = AddOn:NewModule('Distributor','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
AddOn.Layout = AddOn:NewModule('Layout','AceEvent-3.0')
AddOn.Minimap = AddOn:NewModule('Minimap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.Misc = AddOn:NewModule('Misc','AceEvent-3.0','AceTimer-3.0')
AddOn.ModuleCopy = AddOn:NewModule('ModuleCopy','AceEvent-3.0','AceTimer-3.0','AceComm-3.0','AceSerializer-3.0')
AddOn.NamePlates = AddOn:NewModule('NamePlates','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')
AddOn.PluginInstaller = AddOn:NewModule('PluginInstaller')
AddOn.RaidUtility = AddOn:NewModule('RaidUtility','AceEvent-3.0')
AddOn.Skins = AddOn:NewModule('Skins','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.Threat = AddOn:NewModule('Threat','AceEvent-3.0')
AddOn.Tooltip = AddOn:NewModule('Tooltip','AceTimer-3.0','AceHook-3.0','AceEvent-3.0')
AddOn.TotemBar = AddOn:NewModule('Totems','AceEvent-3.0')
AddOn.UnitFrames = AddOn:NewModule('UnitFrames','AceTimer-3.0','AceEvent-3.0','AceHook-3.0')
AddOn.WorldMap = AddOn:NewModule('WorldMap','AceHook-3.0','AceEvent-3.0','AceTimer-3.0')

do
	local arg2,arg3 = '([%(%)%.%%%+%-%*%?%[%^%$])','%%%1'
	function AddOn:EscapeString(str)
		return gsub(str,arg2,arg3)
	end
end

do
	DisableAddOn("ElvUI_VisualAuraTimers")
	DisableAddOn("ElvUI_ExtraActionBars")
	DisableAddOn("ElvUI_CastBarOverlay")
	DisableAddOn("ElvUI_EverySecondCounts")
	DisableAddOn("ElvUI_AuraBarsMovers")
	DisableAddOn("ElvUI_CustomTweaks")
end

function AddOn:OnInitialize()
	if not ElvCharacterDB then
		ElvCharacterDB = {}
	end

	ElvCharacterData = nil; --Depreciated
	ElvPrivateData = nil; --Depreciated
	ElvData = nil; --Depreciated

	self.db = tcopy(self.DF.profile, true)
	self.global = tcopy(self.DF.global, true)

	local ElvDB = ElvDB
	if ElvDB then
		if ElvDB.global then
			self:CopyTable(self.global, ElvDB.global)
		end

		local profileKey
		if ElvDB.profileKeys then
			profileKey = ElvDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvDB.profiles and ElvDB.profiles[profileKey] then
			self:CopyTable(self.db, ElvDB.profiles[profileKey])
		end
	end

	self.private = tcopy(self.privateVars.profile, true)

	local ElvPrivateDB = ElvPrivateDB
	if ElvPrivateDB then
		local profileKey
		if ElvPrivateDB.profileKeys then
			profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
		end

		if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
			self:CopyTable(self.private, ElvPrivateDB.profiles[profileKey])
		end
	end

	self.twoPixelsPlease = false
	self.ScanTooltip = CreateFrame('GameTooltip', 'ElvUI_ScanTooltip', _G.UIParent, 'GameTooltipTemplate')
	self.PixelMode = self.twoPixelsPlease or self.private.general.pixelPerfect -- keep this over `UIScale`
	self:UIScale(true)
	self:UpdateMedia()
	self:Contruct_StaticPopups()
	self:InitializeInitialModules()

	if self.private.general.minimap.enable then
		self.Minimap:SetGetMinimapShape()
		_G.Minimap:SetMaskTexture(130937) -- interface/chatframe/chatframebackground.blp
	else
		_G.Minimap:SetMaskTexture(186178) -- textures/minimapmask.blp
	end

	if GetAddOnEnableState(self.myname, 'Tukui') == 2 then
		self:StaticPopup_Show('TUKUI_ELVUI_INCOMPATIBLE')
	end

	local GameMenuButton = CreateFrame('Button', nil, GameMenuFrame, 'GameMenuButtonTemplate')
	GameMenuButton:SetText(format('|cfffe7b2c%s|r', AddOnName))
	GameMenuButton:SetScript('OnClick', function()
		AddOn:ToggleOptionsUI()
		HideUIPanel(GameMenuFrame)
	end)
	GameMenuFrame[AddOnName] = GameMenuButton

	if not IsAddOnLoaded('ConsolePortUI_Menu') then -- #390
		GameMenuButton:Size(GameMenuButtonLogout:GetWidth(), GameMenuButtonLogout:GetHeight())
		GameMenuButton:Point('TOPLEFT', GameMenuButtonAddons, 'BOTTOMLEFT', 0, -1)
		hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', self.PositionGameMenuButton)
	end

	self.loadedtime = GetTime()
end

function AddOn:PositionGameMenuButton()
	GameMenuFrame:SetHeight(GameMenuFrame:GetHeight() + GameMenuButtonLogout:GetHeight() - 4)
	local _, relTo, _, _, offY = GameMenuButtonLogout:GetPoint()
	if relTo ~= GameMenuFrame[AddOnName] then
		GameMenuFrame[AddOnName]:ClearAllPoints()
		GameMenuFrame[AddOnName]:Point('TOPLEFT', relTo, 'BOTTOMLEFT', 0, -1)
		GameMenuButtonLogout:ClearAllPoints()
		GameMenuButtonLogout:Point('TOPLEFT', GameMenuFrame[AddOnName], 'BOTTOMLEFT', 0, offY)
	end
end

local LoadUI=CreateFrame('Frame')
LoadUI:RegisterEvent('PLAYER_LOGIN')
LoadUI:SetScript('OnEvent', function()
	AddOn:Initialize()
end)

function AddOn:ResetProfile()
	local profileKey

	local ElvPrivateDB = ElvPrivateDB
	if ElvPrivateDB.profileKeys then
		profileKey = ElvPrivateDB.profileKeys[self.myname..' - '..self.myrealm]
	end

	if profileKey and ElvPrivateDB.profiles and ElvPrivateDB.profiles[profileKey] then
		ElvPrivateDB.profiles[profileKey] = nil
	end

	ElvCharacterDB = nil
	ReloadUI()
end

function AddOn:OnProfileReset()
	self:StaticPopup_Show('RESET_PROFILE_PROMPT')
end

function AddOn:ResetConfigSettings()
	AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft = nil, nil
	AddOn.global.general.AceGUI = AddOn:CopyTable({}, AddOn.DF.global.general.AceGUI)
end

function AddOn:GetConfigPosition()
	return AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft
end

function AddOn:GetConfigSize()
	return AddOn.global.general.AceGUI.width, AddOn.global.general.AceGUI.height
end

function AddOn:UpdateConfigSize(reset)
	local frame = self.GUIFrame
	if not frame then return end

	local maxWidth, maxHeight = self.UIParent:GetSize()
	frame:SetMinResize(800, 600)
	frame:SetMaxResize(maxWidth-50, maxHeight-50)

	self.Libs.AceConfigDialog:SetDefaultSize(AddOnName, self:GetConfigDefaultSize())

	local status = frame.obj and frame.obj.status
	if status then
		if reset then
			self:ResetConfigSettings()

			status.top, status.left = self:GetConfigPosition()
			status.width, status.height = self:GetConfigDefaultSize()

			frame.obj:ApplyStatus()
		else
			local top, left = self:GetConfigPosition()
			if top and left then
				status.top, status.left = top, left

				frame.obj:ApplyStatus()
			end
		end
	end
end

function AddOn:GetConfigDefaultSize()
	local width, height = AddOn:GetConfigSize()
	local maxWidth, maxHeight = AddOn.UIParent:GetSize()
	width, height = min(maxWidth-50, width), min(maxHeight-50, height)
	return width, height
end

function AddOn:ConfigStopMovingOrSizing()
	if self.obj and self.obj.status then
		AddOn.configSavedPositionTop, AddOn.configSavedPositionLeft = AddOn:Round(self:GetTop(), 2), AddOn:Round(self:GetLeft(), 2)
		AddOn.global.general.AceGUI.width, AddOn.global.general.AceGUI.height = AddOn:Round(self:GetWidth(), 2), AddOn:Round(self:GetHeight(), 2)
	end
end

local function ConfigButton_OnEnter(self)
	if GameTooltip:IsForbidden() or not self.desc then return end

	GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 0, 2)
	GameTooltip:AddLine(self.desc, 1, 1, 1, true)
	GameTooltip:Show()
end

local function ConfigButton_OnLeave()
	if GameTooltip:IsForbidden() then return end

	GameTooltip:Hide()
end

function AddOn:CreateSeparatorLine(frame, lastButton)
	local line = frame.leftHolder.buttons:CreateTexture()
	line:SetTexture(AddOn.Media.Textures.White8x8)
	line:SetVertexColor(.9, .8, 0, .7)
	line:Size(179, 2)
	line:Point("TOP", lastButton, "BOTTOM", 0, -6)
	line.separator = true
	return line
end

function AddOn:SetConfigButtonColor(btn, disabled)
	if disabled then
		btn:Disable()
		btn:SetBackdropBorderColor(1, 1, 1, .5)
	else
		btn:Enable()
		btn:SetBackdropBorderColor(unpack(AddOn.media.bordercolor))
	end
end

function AddOn:CreateOptionFrame(info, frame, unskinned, ...)
	local btn = CreateFrame(...)
	btn:SetScript('OnEnter', ConfigButton_OnEnter)
	btn:SetScript('OnLeave', ConfigButton_OnLeave)
	btn:SetScript('OnClick', info.func)
	btn:SetText(info.name)
	btn:Width(btn:GetTextWidth() + 40)
	btn.frame = frame
	btn.desc = info.desc
	btn.key = info.key

	if not unskinned then
		AddOn.Skins:HandleButton(btn)
	end

	AddOn:SetConfigButtonColor(btn, btn.key == 'general')
	btn.ignoreBorderColors = true

	return btn
end

local function SortOptionButtons(a,b)
	if a[1] and b[1] then
		if a[1] == b[1] and a[3].name and b[3].name then
			return a[3].name < b[3].name
		end
		return a[1] < b[1]
	end
end

local function ConfigSliderOnMouseWheel(self, offset)
	local _, maxValue = self:GetMinMaxValues()
	if maxValue == 0 then return end

	local newValue = self:GetValue() - offset
	if newValue < 0 then newValue = 0 end
	if newValue > maxValue then return end

	self:SetValue(newValue)
	self.buttons:Point("TOPLEFT", 0, newValue * 36)
end

local function ConfigSliderOnValueChanged(self, value)
	self:SetValue(value)
	self.buttons:Point("TOPLEFT", 0, value * 36)
end

function AddOn:UpdateLeftButtons()
	local frame = AddOn.GUIFrame
	if not (frame and frame.leftHolder) then return end

	local selected = frame.obj.status.groups.selected
	for key, btn in pairs(frame.leftHolder.buttons) do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			AddOn:SetConfigButtonColor(btn, key == selected)
		end
	end
end

function AddOn:UpdateLeftScroller()
	if not (self and self.leftHolder) then return end

	local left = self.leftHolder
	local buttons = left.buttons
	local slider = left.slider
	local max = 0
	slider:SetMinMaxValues(0, max)
	slider:SetValue(0)
	left.buttons:Point("TOPLEFT", 0, 0)

	for _, btn in pairs(buttons) do
		if type(btn) == 'table' and btn.IsObjectType and btn:IsObjectType('Button') then
			if buttons:GetBottom() > btn:GetTop() then
				max = max + 1
				slider:SetMinMaxValues(0, max)
			end
		end
	end

	if max == 0 then
		slider.thumb:Hide()
	else
		slider.thumb:Show()
	end
end

function AddOn:CreateLeftButtons(frame, unskinned, ACD, options)
	local opts = {}
	for key, info in pairs(options) do
		tinsert(opts, {info.order, key, info})
	end
	sort(opts, SortOptionButtons)

	local buttons, last = frame.leftHolder.buttons
	for _, opt in ipairs(opts) do
		local info = opt[3]

		info.key = opt[2]
		info.func = function()
			ACD:SelectGroup("ElvUI", info.key)
		end

		local btn = AddOn:CreateOptionFrame(info, frame, unskinned, 'Button', nil, buttons, 'UIPanelButtonTemplate')
		btn:Width(177)

		if not last then
			btn:Point("TOP", buttons, "TOP", 0, 0)
		else
			btn:Point("TOP", last, "BOTTOM", 0, (last.separator and -6) or -4)
		end

		buttons[info.key] = btn
		last = btn

		if info.key == 'unitframe' or (info.key == 'credits' and AddOn.Options.args.plugins) then
			last = AddOn:CreateSeparatorLine(frame, last)
		end
	end
end

function AddOn:CreateBottomButtons(frame, unskinned)
	local L = self.Libs.ACL:GetLocale('ElvUI', self.global.general.locale or 'enUS')

	local last
	for _, info in pairs({
		{
			var = 'RepositionWindow',
			name = L["Reposition Window"],
			desc = L["Reset the size and position of this frame."],
			func = function()
				self:UpdateConfigSize(true)
			end
		},
		{
			var = 'ToggleTutorials',
			name = L["Toggle Tutorials"],
			func = function()
				self:Tutorials(true)
				self:ToggleOptionsUI()
			end
		},
		{
			var = 'Install',
			name = L["Install"],
			desc = L["Run the installation process."],
			func = function()
				self:Install()
				self:ToggleOptionsUI()
			end
		},
		{
			var = 'ResetAnchors',
			name = L["Reset Anchors"],
			desc = L["Reset all frames to their original positions."],
			func = function()
				self:ResetUI()
			end
		},
		{
			var = 'ToggleAnchors',
			name = L["Toggle Anchors"],
			desc = L["Unlock various elements of the UI to be repositioned."],
			func = function()
				self:ToggleMoveMode()
			end
		},
		{
			var = 'Close',
			name = L["Close"],
			func = function(btn)
				btn.frame.closeButton:Click()
			end
		}
	}) do
		local btn = AddOn:CreateOptionFrame(info, frame, unskinned, 'Button', nil, frame.bottomHolder, 'UIPanelButtonTemplate')
		local offset = (unskinned and 14) or 8

		if not last then
			btn:Point("BOTTOMLEFT", frame.bottomHolder, "BOTTOMLEFT", (unskinned and 24) or offset, offset)
			last = btn
		elseif info.var == 'Close' then
			btn:Point("BOTTOMRIGHT", frame.bottomHolder, "BOTTOMRIGHT", -26, offset)
		else
			btn:Point("LEFT", last, "RIGHT", 4, 0)
			last = btn
		end

		frame.bottomHolder[info.var] = btn
	end
end

local pageNodes = {}
function AddOn:ToggleOptionsUI(msg)
	if InCombatLockdown() then
		self:Print(ERR_NOT_IN_COMBAT)
		self.ShowOptionsUI = true
		return
	end

	if not IsAddOnLoaded('ElvUI_OptionsUI') then
		local noConfig
		local _, _, _, _, reason = GetAddOnInfo('ElvUI_OptionsUI')
		if reason ~= 'MISSING' and reason ~= 'DISABLED' then
			self.GUIFrame = false
			LoadAddOn('ElvUI_OptionsUI')

			--For some reason, GetAddOnInfo reason is 'DEMAND_LOADED' even if the addon is disabled.
			--Workaround: Try to load addon and check if it is loaded right after.
			if not IsAddOnLoaded('ElvUI_OptionsUI') then noConfig = true end

			-- version check elvui options if it's actually enabled
			if (not noConfig) and GetAddOnMetadata('ElvUI_OptionsUI', 'Version') ~= '1.07' then
				self:StaticPopup_Show('CLIENT_UPDATE_REQUEST')
			end
		else
			noConfig = true
		end

		if noConfig then
			self:Print('|cffff0000Error -- Addon "ElvUI_OptionsUI" not found or is disabled.|r')
			return
		end
	end

	local ACD = self.Libs.AceConfigDialog
	local ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName]

	local pages, msgStr
	if msg and msg ~= '' then
		pages = {strsplit(',', msg)}
		msgStr = gsub(msg, ',', '\001')
	end

	local mode = 'Close'
	if not ConfigOpen or (pages ~= nil) then
		if pages ~= nil then
			local pageCount, index, mainSel = #pages
			if pageCount > 1 then
				wipe(pageNodes)
				index = 0

				local main, mainNode, mainSelStr, sub, subNode, subSel
				for i = 1, pageCount do
					if i == 1 then
						main = pages[i] and ACD and ACD.Status and ACD.Status.ElvUI
						mainSel = main and main.status and main.status.groups and main.status.groups.selected
						mainSelStr = mainSel and ('^'..AddOn:EscapeString(mainSel)..'\001')
						mainNode = main and main.children and main.children[pages[i]]
						pageNodes[index+1], pageNodes[index+2] = main, mainNode
					else
						sub = pages[i] and pageNodes[i] and ((i == pageCount and pageNodes[i]) or pageNodes[i].children[pages[i]])
						subSel = sub and sub.status and sub.status.groups and sub.status.groups.selected
						subNode = (mainSelStr and msgStr:match(mainSelStr..AddOn:EscapeString(pages[i])..'$') and (subSel and subSel == pages[i])) or ((i == pageCount and not subSel) and mainSel and mainSel == msgStr)
						pageNodes[index+1], pageNodes[index+2] = sub, subNode
					end
					index = index + 2
				end
			else
				local main = pages[1] and ACD and ACD.Status and ACD.Status.ElvUI
				mainSel = main and main.status and main.status.groups and main.status.groups.selected
			end

			if ConfigOpen and ((not index and mainSel and mainSel == msg) or (index and pageNodes and pageNodes[index])) then
				mode = 'Close'
			else
				mode = 'Open'
			end
		else
			mode = 'Open'
		end
	end

	if ACD then
		ACD[mode](ACD, AddOnName)
	end

	if mode == 'Open' then
		ConfigOpen = ACD and ACD.OpenFrames and ACD.OpenFrames[AddOnName]
		if ConfigOpen then
			local frame = ConfigOpen.frame
			if frame and not self.GUIFrame then
				self.GUIFrame = frame
				_G.ElvUIGUIFrame = self.GUIFrame

				self:UpdateConfigSize()
				hooksecurefunc(frame, 'StopMovingOrSizing', AddOn.ConfigStopMovingOrSizing)
				hooksecurefunc(AddOn.Libs.AceConfigRegistry, 'NotifyChange', AddOn.UpdateLeftButtons)
				frame:HookScript('OnSizeChanged', AddOn.UpdateLeftScroller)

				for i=1, frame:GetNumChildren() do
					local child = select(i, frame:GetChildren())
					if child:IsObjectType('Button') and child:GetText() == _G.CLOSE then
						frame.closeButton = child
						child:Hide()
					end
				end

				local unskinned = not self.private.skins.ace3.enable
				if unskinned then
					for i=1, frame:GetNumRegions() do
						local region = select(i, frame:GetRegions())
						if region:IsObjectType('Texture') and region:GetTexture() == 131080 then
							region:SetAlpha(0)
						end
					end
				end

				local bottom = CreateFrame('Frame', nil, frame)
				bottom:Point("BOTTOMLEFT", 2, 2)
				bottom:Point("BOTTOMRIGHT", -2, 2)
				bottom:Height(37)
				frame.bottomHolder = bottom

				local left = CreateFrame('Frame', nil, frame)
				left:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
				left:Point("TOPLEFT", (unskinned and 10) or 2, (unskinned and -6) or -2)
				left:Width(181)
				frame.leftHolder = left

				local logo = left:CreateTexture()
				logo:SetTexture(AddOn.Media.Textures.Logo)
				logo:Point("TOPLEFT", frame, "TOPLEFT", 30, (unskinned and -6) or -2)
				logo:Size(126, 64)
				left.logo = logo

				local version = frame.obj.titletext
				version:ClearAllPoints()
				version:Point("TOP", logo, "BOTTOM", 0, (unskinned and 4) or 2)
				left.version = version

				local buttonsHolder = CreateFrame('Frame', nil, left)
				buttonsHolder:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
				buttonsHolder:Point("TOPLEFT", left, "TOPLEFT", 0, -80)
				buttonsHolder:Width(181)
				buttonsHolder:SetFrameLevel(5)
				buttonsHolder:SetClipsChildren(true)
				left.buttonsHolder = buttonsHolder

				local buttons = CreateFrame('Frame', nil, buttonsHolder)
				buttons:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
				buttons:Point("TOPLEFT", 0, 0)
				buttons:Width(181)
				left.buttons = buttons

				local slider = CreateFrame('Slider', nil, frame)
				slider:SetThumbTexture(AddOn.Media.Textures.White8x8)
				slider:SetScript('OnMouseWheel', ConfigSliderOnMouseWheel)
				slider:SetScript('OnValueChanged', ConfigSliderOnValueChanged)
				slider:SetOrientation("VERTICAL")
				slider:SetObeyStepOnDrag(true)
				slider:SetFrameLevel(4)
				slider:SetValueStep(1)
				slider:SetValue(0)
				slider:Width(192)
				slider:Point("BOTTOMLEFT", frame.bottomHolder, "TOPLEFT", 0, 1)
				slider:Point("TOPLEFT", buttons, "TOPLEFT", 0, 0)
				slider.buttons = buttons
				left.slider = slider

				local thumb = slider:GetThumbTexture()
				thumb:Point("LEFT", left, "RIGHT", 2, 0)
				thumb:SetVertexColor(1, 1, 1, 0.5)
				thumb:SetSize(10, 14)
				left.slider.thumb = thumb

				if not unskinned then
					bottom:SetTemplate("Transparent")
					left:SetTemplate("Transparent")
				end

				self:CreateLeftButtons(frame, unskinned, ACD, AddOn.Options.args)
				self:CreateBottomButtons(frame, unskinned)
				local holderHeight = frame.bottomHolder:GetHeight()
				local offset = (unskinned and 14) or 8

				frame.obj.content:Point("TOPLEFT", frame, "TOPLEFT", offset, -((unskinned and 25) or 15))
				frame.obj.content:Point("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -offset, holderHeight + 3)

				local titlebg = frame.obj.titlebg
				titlebg:ClearAllPoints()
				titlebg:SetPoint("TOPLEFT", frame)
				titlebg:SetPoint("TOPRIGHT", frame)

				AddOn.UpdateLeftScroller(frame)
			end
		end

		if ACD and pages then
			ACD:SelectGroup(AddOnName, unpack(pages))
		end
	end

	_G.GameTooltip:Hide() --Just in case you're mouseovered something and it closes.
end

do --taint workarounds by townlong-yak.com (rearranged by Simpy)
	--CommunitiesUI			- https://www.townlong-yak.com/bugs/Kjq4hm-DisplayModeTaint
	if (_G.UIDROPDOWNMENU_OPEN_PATCH_VERSION or 0) < 1 then _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION = 1 end
	--CommunitiesUI #2		- https://www.townlong-yak.com/bugs/YhgQma-SetValueRefreshTaint
	if (_G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION or 0) < 1 then _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION = 1 end

	--	*NOTE* Simpy: these two were updated to fix an issue which was caused on the dropdowns with submenus
	--HonorFrameLoadTaint	- https://www.townlong-yak.com/bugs/afKy4k-HonorFrameLoadTaint
	if (_G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION or 0) < 1 then _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION = 1 end
	--RefreshOverread		- https://www.townlong-yak.com/bugs/Mx7CWN-RefreshOverread
	if (_G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION or 0) < 1 then _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION = 1 end

	if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 or _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION == 1 or _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
		local function drop(t, k)
			local c = 42
			t[k] = nil
			while not issecurevariable(t, k) do
				if t[c] == nil then
					t[c] = nil
				end
				c = c + 1
			end
		end

		hooksecurefunc('UIDropDownMenu_InitializeHelper', function(frame)
			if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 or _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
				for i=1, _G.UIDROPDOWNMENU_MAXLEVELS do
					local d = _G['DropDownList' .. i]
					if d and d.numButtons then
						for j = d.numButtons+1, _G.UIDROPDOWNMENU_MAXBUTTONS do
							local b, _ = _G['DropDownList' .. i .. 'Button' .. j]
							if _G.ELVUI_UIDROPDOWNMENU_VALUE_PATCH_VERSION == 1 and not (issecurevariable(b, 'value') or b:IsShown()) then
								b.value = nil
								repeat j, b['fx' .. j] = j+1, nil
								until issecurevariable(b, 'value')
							end
							if _G.ELVUI_UIDD_REFRESH_OVERREAD_PATCH_VERSION == 1 then
								_ = issecurevariable(b, 'checked')      or drop(b, 'checked')
								_ = issecurevariable(b, 'notCheckable') or drop(b, 'notCheckable')
							end
						end
					end
				end
			end

			if _G.UIDROPDOWNMENU_OPEN_PATCH_VERSION == 1 then
				if _G.UIDROPDOWNMENU_OPEN_MENU and _G.UIDROPDOWNMENU_OPEN_MENU ~= frame and not issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU, 'displayMode') then
					_G.UIDROPDOWNMENU_OPEN_MENU = nil
					local prefix, i = ' \0', 1
					repeat i, _G[prefix .. i] = i + 1, nil
					until issecurevariable(_G.UIDROPDOWNMENU_OPEN_MENU)
				end
			end
		end)
	end

	if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION == 1 then
		local function CleanDropdowns()
			if _G.COMMUNITY_UIDD_REFRESH_PATCH_VERSION == 1 then
				local f, f2 = _G.FriendsFrame, _G.FriendsTabHeader
				local s = f:IsShown()
				f:Hide()
				f:Show()
				if not f2:IsShown() then
					f2:Show()
					f2:Hide()
				end
				if not s then
					f:Hide()
				end
			end
		end

		hooksecurefunc('Communities_LoadUI', CleanDropdowns)
		hooksecurefunc('SetCVar', function(n)
			if n == 'lastSelectedClubId' then
				CleanDropdowns()
			end
		end)
	end
end
