local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
local pairs, select, unpack = pairs, select, unpack
local GetItemInfo = GetItemInfo
local GetItemQualityColor = GetItemQualityColor
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

--[[
TO DO:
* Fix Icon borders
* Skin Multisell .ProgressBar
]]

-- Credits: siweia (AuroraClassic)

local function SkinEditBoxes(Frame)
	S:HandleEditBox(Frame.MinLevel)
	S:HandleEditBox(Frame.MaxLevel)
end

local function SkinFilterButton(Button)
	SkinEditBoxes(Button.LevelRangeFrame)

	S:HandleCloseButton(Button.ClearFiltersButton)
	S:HandleButton(Button)
end

local function HandleSearchBarFrame(Frame)
	SkinFilterButton(Frame.FilterButton)

	S:HandleButton(Frame.SearchButton)
	S:HandleEditBox(Frame.SearchBox)
	S:HandleButton(Frame.FavoritesSearchButton)
	Frame.FavoritesSearchButton:SetSize(22, 22)
end

local function HandleListIcon(frame)
	if not frame.tableBuilder then return end

	for i = 1, 22 do
		local row = frame.tableBuilder.rows[i]
		if row then
			for j = 1, 4 do
				local cell = row.cells and row.cells[j]
				if cell and cell.Icon and not cell.IsSkinned then
					S:HandleIcon(cell.Icon)
					if cell.IconBorder then
						cell.IconBorder:SetAlpha(0)
					end

					cell.IsSkinned = true
				end
			end
		end
	end
end

local function HandleSummaryIcons(frame)
	for i = 1, 23 do
		local child = select(i, frame.ScrollFrame.scrollChild:GetChildren())
		if child and child.Icon and not child.IsSkinned then
			S:HandleIcon(child.Icon)

			child.IsSkinned = true
		end
	end
end

local function HandleHeaders(frame)
	local maxHeaders = frame.HeaderContainer:GetNumChildren()
	for i = 1, maxHeaders do
		local header = select(i, frame.HeaderContainer:GetChildren())
		if header and not header.IsSkinned then
			header:DisableDrawLayer("BACKGROUND")
			if not header.backdrop then
				header:CreateBackdrop("Transparent")
			end

			header.IsSkinned = true
		end

		if header.backdrop then
			header.backdrop:SetPoint("BOTTOMRIGHT", i < maxHeaders and -5 or 0, -2)
		end
	end

	HandleListIcon(frame)
end

local function HandleAuctionButtons(button)
	S:HandleButton(button)
	button:SetSize(22,22)
end

local function HandleSellFrame(frame)
	frame:StripTextures()

	local ItemDisplay = frame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	if ItemButton.IconMask then ItemButton.IconMask:Hide() end
	if ItemButton.IconBorder then ItemButton.IconBorder:SetAlpha(0) end

	ItemButton.EmptyBackground:Hide()
	ItemButton:SetPushedTexture("")
	ItemButton.Highlight:SetColorTexture(1, 1, 1, .25)
	ItemButton.Highlight:SetAllPoints(ItemButton.Icon)

	S:HandleIcon(ItemButton.Icon, true)
	hooksecurefunc(ItemButton.IconBorder, "SetVertexColor", function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	hooksecurefunc(ItemButton.IconBorder, "Hide", function() ItemButton.Icon.backdrop:SetBackdropBorderColor(0, 0, 0) end)

	S:HandleEditBox(frame.QuantityInput.InputBox)
	S:HandleButton(frame.QuantityInput.MaxButton)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.GoldBox)
	S:HandleEditBox(frame.PriceInput.MoneyInputFrame.SilverBox)

	if frame.SecondaryPriceInput then
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.GoldBox)
		S:HandleEditBox(frame.SecondaryPriceInput.MoneyInputFrame.SilverBox)
	end

	S:HandleDropDownBox(frame.DurationDropDown.DropDown)
	S:HandleButton(frame.PostButton)

	if frame.BuyoutModeCheckButton then
		S:HandleCheckBox(frame.BuyoutModeCheckButton)
		frame.BuyoutModeCheckButton:SetSize(20, 20)
	end
end

local function HandleSellList(frame, hasHeader)
	frame:StripTextures()

	if frame.RefreshFrame then
		HandleAuctionButtons(frame.RefreshFrame.RefreshButton)
	end

	S:HandleScrollBar(frame.ScrollFrame.scrollBar)

	if hasHeader then
		frame.ScrollFrame:CreateBackdrop("Transparent")
		hooksecurefunc(frame, "RefreshScrollFrame", HandleHeaders)
	else
		hooksecurefunc(frame, "RefreshScrollFrame", HandleSummaryIcons)
	end
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.auctionhouse ~= true then return end

	--[[ Main Frame | TAB 1]]--
	local Frame = _G.AuctionHouseFrame
	S:HandlePortraitFrame(Frame)

	local Tabs = {
		_G.AuctionHouseFrameBuyTab,
		_G.AuctionHouseFrameSellTab,
		_G.AuctionHouseFrameAuctionsTab,
	}

	for _, tab in pairs(Tabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	_G.AuctionHouseFrameBuyTab:ClearAllPoints()
	_G.AuctionHouseFrameBuyTab:SetPoint("BOTTOMLEFT", Frame, "BOTTOMLEFT", 0, -32)

	-- SearchBar Frame
	HandleSearchBarFrame(Frame.SearchBar)

	Frame.MoneyFrameBorder:StripTextures()
	Frame.MoneyFrameInset:StripTextures()

	--[[ Categorie List ]]--
	local Categories = Frame.CategoriesList
	Categories.ScrollFrame:StripTextures()
	Categories.Background:Hide()
	Categories.NineSlice:Hide()

	S:HandleScrollBar(_G.AuctionHouseFrameScrollBar)

	for i = 1, _G.NUM_FILTERS_TO_DISPLAY do
		local button = Categories.FilterButtons[i]

		button:StripTextures(true)
		button:StyleButton()

		button.SelectedTexture:SetAlpha(0)
	end

	--[[ Browse Frame ]]--
	local Browse = Frame.BrowseResultsFrame

	local ItemList = Browse.ItemList
	ItemList:StripTextures()
	hooksecurefunc(ItemList, "RefreshScrollFrame", HandleHeaders)

	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)

	--[[ BuyOut Frame]]
	local CommoditiesBuyFrame = Frame.CommoditiesBuyFrame
	CommoditiesBuyFrame.BuyDisplay:StripTextures()
	S:HandleButton(CommoditiesBuyFrame.BackButton)

	local ItemList = Frame.CommoditiesBuyFrame.ItemList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)

	local BuyDisplay = Frame.CommoditiesBuyFrame.BuyDisplay
	S:HandleEditBox(BuyDisplay.QuantityInput.InputBox)
	S:HandleButton(_G.BuyButton)

	local ItemDisplay = BuyDisplay.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	-- FIX ME
	--hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	--hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.CircleMask:Hide()
	ItemButton.IconBorder:SetAlpha(0)

	--[[ ItemBuyOut Frame]]
	local ItemBuyFrame = Frame.ItemBuyFrame
	S:HandleButton(ItemBuyFrame.BackButton)
	S:HandleButton(ItemBuyFrame.BuyoutFrame.BuyoutButton)

	local ItemDisplay = ItemBuyFrame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	-- FIX ME
	--hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	--hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.CircleMask:Hide()
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.IconOverlay:Hide()

	local ItemList = ItemBuyFrame.ItemList
	ItemList:StripTextures()
	ItemList:CreateBackdrop("Transparent")
	S:HandleScrollBar(ItemList.ScrollFrame.scrollBar)
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)
	hooksecurefunc(ItemList, "RefreshScrollFrame", HandleHeaders)

	local EditBoxes = {
		_G.AuctionHouseFrameGold,
		_G.AuctionHouseFrameSilver,
	}

	for _, EditBox in pairs(EditBoxes) do
		S:HandleEditBox(EditBox)
		EditBox:SetTextInsets(1, 1, -1, 1)
	end

	S:HandleButton(ItemBuyFrame.BidFrame.BidButton)

	--[[ Item Sell Frame | TAB 2 ]]--
	local SellFrame = Frame.ItemSellFrame
	HandleSellFrame(SellFrame)

	local ItemList = Frame.ItemSellList
	HandleSellList(ItemList, true)

	local CommoditiesSellFrame = Frame.CommoditiesSellFrame
	HandleSellFrame(CommoditiesSellFrame)

	local ItemList = Frame.CommoditiesSellList
	HandleSellList(ItemList, true)

	--[[ Auctions Frame | TAB 3 ]]--
	local AuctionsFrame = _G.AuctionHouseFrameAuctionsFrame
	AuctionsFrame:StripTextures()

	local ItemDisplay = AuctionsFrame.ItemDisplay
	ItemDisplay:StripTextures()
	ItemDisplay:CreateBackdrop("Transparent")

	local ItemButton = ItemDisplay.ItemButton
	S:HandleIcon(ItemButton.Icon, true)

	-- FIX ME
	--hooksecurefunc(ItemButton.IconBorder, 'SetVertexColor', function(_, r, g, b) ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b) end)
	--hooksecurefunc(ItemButton.IconBorder, 'Hide', function() ItemButton.Icon.backdrop:SetBackdropBorderColor(unpack(E.media.bordercolor)) end)
	ItemButton.IconBorder:SetAlpha(0)
	ItemButton.CircleMask:Hide()

	local CommoditiesList = AuctionsFrame.CommoditiesList
	HandleSellList(CommoditiesList, true)
	S:HandleButton(CommoditiesList.RefreshFrame.RefreshButton)

	local ItemList = AuctionsFrame.ItemList
	HandleSellList(ItemList, true)
	S:HandleButton(ItemList.RefreshFrame.RefreshButton)

	local Tabs = {
		_G.AuctionHouseFrameAuctionsFrameAuctionsTab,
		_G.AuctionHouseFrameAuctionsFrameBidsTab,
	}

	for _, tab in pairs(Tabs) do
		if tab then
			S:HandleTab(tab)
		end
	end

	local SummaryList = AuctionsFrame.SummaryList
	HandleSellList(SummaryList)
	S:HandleButton(AuctionsFrame.CancelAuctionButton)

	local AllAuctionsList = AuctionsFrame.AllAuctionsList
	HandleSellList(AllAuctionsList, true)
	S:HandleButton(AllAuctionsList.RefreshFrame.RefreshButton)

	local BidsList = AuctionsFrame.BidsList
	HandleSellList(BidsList, true)
	S:HandleButton(BidsList.RefreshFrame.RefreshButton)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameGold)
	S:HandleEditBox(_G.AuctionHouseFrameAuctionsFrameSilver)
	S:HandleButton(AuctionsFrame.BidFrame.BidButton)
	S:HandleButton(AuctionsFrame.BuyoutFrame.BuyoutButton)

	--[[ ProgressBars ]]--

	--[[ WoW Token Category ]]--
	local TokenFrame = Frame.WoWTokenResults
	TokenFrame:StripTextures()
	S:HandleButton(TokenFrame.Buyout)
	S:HandleScrollBar(TokenFrame.DummyScrollBar) --MONITOR THIS

	local Token = TokenFrame.TokenDisplay
	Token:StripTextures()
	Token:CreateBackdrop("Transparent")

	local ItemButton = Token.ItemButton
	S:HandleIcon(ItemButton.Icon, true)
	local _, _, itemRarity = GetItemInfo(_G.WOW_TOKEN_ITEM_ID)
	local r, g, b
	if itemRarity then
		r, g, b = GetItemQualityColor(itemRarity)
	end
	ItemButton.Icon.backdrop:SetBackdropBorderColor(r, g, b)
	ItemButton.IconBorder:SetAlpha(0)

	--WoW Token Tutorial Frame
	local WowTokenGameTimeTutorial = Frame.WoWTokenResults.GameTimeTutorial
	WowTokenGameTimeTutorial.TitleBg:SetAlpha(0)
	WowTokenGameTimeTutorial:CreateBackdrop("Transparent")
	S:HandleCloseButton(WowTokenGameTimeTutorial.CloseButton)
	S:HandleButton(WowTokenGameTimeTutorial.RightDisplay.StoreButton)
	WowTokenGameTimeTutorial.Bg:SetAlpha(0)

	--[[ Dialogs ]]--
	Frame.BuyDialog:StripTextures()
	Frame.BuyDialog:CreateBackdrop("Transparent")
	S:HandleButton(Frame.BuyDialog.BuyNowButton)
	S:HandleButton(Frame.BuyDialog.CancelButton)
end

S:AddCallbackForAddon("Blizzard_AuctionHouseUI", "AuctionHouse", LoadSkin)
