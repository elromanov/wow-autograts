local frame = CreateFrame("Frame")
local addon_loaded = false
local groupMembersCount = 0
local autoGratsPlayerTracker = {}
local autoGratsGuildPlayerTracker = {}
local delayInSeconds = 1 -- Adjust the delay as needed

local addon_version = "4.0.2"

local levelupSoundEffects = {
    {
        name = "Minecraft",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-minecraft.mp3"
    },
    {
        name = "Pokémon",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-pokemon.mp3"
    },
    {
        name = "Skyrim",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-skyrim.mp3"
    },
    {
        name = "Warcraft 3",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-warcraft3.mp3"
    },
    {
        name = "WoW 1",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-wow-1.mp3"
    },
    {
        name = "WoW 2",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-wow-2.mp3"
    }
}

local autograts_settings_category = nil

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_LEVEL")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")


if not autoGratsSavedData then
    autoGratsSavedData = {}
end

local function GetGuildMembers()
    local members = {}
    for i = 1, GetNumGuildMembers() do 
        local name, _, _, level = GetGuildRosterInfo(i)
        if name and level then
            members[name] = level
        end
    end
    return members
end

local function handleGuildRosterUpdate()
    GuildRoster()
    local _guildMembers = GetGuildMembers()
    local player_name = UnitName("player") .. "-" .. GetRealmName()
    for name, level in pairs(_guildMembers) do
        if not autoGratsGuildPlayerTracker[name] then
            autoGratsGuildPlayerTracker[name] = level
        end
        if name == player_name then
            return
        end
        if autoGratsGuildPlayerTracker[name] < _guildMembers[name] then
            local level_modulo = math.fmod(_guildMembers[name], autoGratsSavedData["guildGratsLevelInterval"])
            if(level_modulo == 0) then
                local msg = name .. " (guild member) has leveled up to level " .. level .. " !"
                DEFAULT_CHAT_FRAME:AddMessage("|cffdded4e" .. msg)

                local msg_to_send = ""
                local readable_name = GetName
                readable_name = name:gsub("%-.*", "")

                if(autoGratsSavedData["guildMessage"] and autoGratsSavedData["useCustomGuildMessage"] == true) then
                    msg_to_send = autoGratsSavedData["guildMessage"]
                    local userNameStringPresent = string.find(msg_to_send, "%[username]")
                    local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                    if userNameStringPresent then
                        msg_to_send = string.gsub(msg_to_send, "%[username]", readable_name)
                    end
    
                    if userLevelStringPresent then
                        msg_to_send = string.gsub(msg_to_send, "%[lvl]", _guildMembers[name])
                    end
                else
                    msg_to_send = "Gz " .. readable_name .. " for reaching lvl" .. _guildMembers[name] .. " !"
                end
                SendChatMessage(msg_to_send, "GUILD")
            end
        end
        autoGratsGuildPlayerTracker[name] = _guildMembers[name]
    end
end

-- Function to start the timer
local function StartGuildRosterCheckTimer()
    C_Timer.NewTicker(20, function()
        handleGuildRosterUpdate()
    end)
end

local function PlayLevelUpSound()
    -- PlaySoundFile(, "Master")
    PlaySoundFile(levelupSoundEffects[autoGratsSavedData["soundEffect"]].path, "Master")
end

local function CheckPlayerLevelDelayed(unitName)
    C_Timer.After(delayInSeconds, function()
        local unitLevel = UnitLevel(unitName)

        if unitLevel > 0 and autoGratsPlayerTracker[unitName] and autoGratsPlayerTracker[unitName] < unitLevel then
            local unitClass = UnitClass(unitName)
            local msg = unitName .. " (Level " .. unitLevel .. " " .. unitClass .. ") has leveled up!"
            DEFAULT_CHAT_FRAME:AddMessage("|cffdded4e" .. msg)

            local msg_to_send = ""

            if autoGratsSavedData["message"] and autoGratsSavedData["useCustomMessage"] == true then
                msg_to_send = autoGratsSavedData["message"]

                local userNameStringPresent = string.find(msg_to_send, "%[username]")
                local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                if userNameStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[username]", unitName)
                end

                if userLevelStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[lvl]", unitLevel)
                end

            else 
                msg_to_send = "GRATS " .. unitName .. " !!!!"
            end

            if(autoGratsSavedData["usePartyChat"] == true) then
                SendChatMessage(msg_to_send, "PARTY")
            end

            if(autoGratsSavedData["useInstanceChat"] == true) then
                SendChatMessage(msg_to_send, "INSTANCE_CHAT")
            end

            if(autoGratsSavedData["useSayChat"] == true) then
                SendChatMessage(msg_to_send, "SAY")
            end

            if(autoGratsSavedData["useYellChat"] == true) then
                SendChatMessage(msg_to_send, "YELL")
            end

            if autoGratsSavedData["useSoundEffects"] == true then
                PlayLevelUpSound()
            end

            autoGratsPlayerTracker[unitName] = unitLevel
        end
    end)
end

local function CreateSettingsPage()
    -- Settings page

    local optionsPanel = CreateFrame("Frame", "AutoGratsOptionsPanel", UIParent)
    optionsPanel.name = "AutoGrats"

    -- Register with the new settings API
    autograts_settings_category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "|TInterface/Addons/AutoGrats/Ressources/Images/logo:16:16|t AutoGrats")
    autograts_settings_category.ID = "AutoGratsOptionsPanel";
    Settings.RegisterAddOnCategory(autograts_settings_category)

    local title = optionsPanel:CreateFontString("AutoGrats", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("AutoGrats")

    local addonVersionAndAuthor = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addonVersionAndAuthor:SetPoint("TOPLEFT", 11, -26)
    addonVersionAndAuthor:SetText("Version " .. addon_version .. " by Romanov")
    addonVersionAndAuthor:SetTextColor(1,1,1)

    local customMessageCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    customMessageCheckbox:SetPoint("TOPLEFT", 10, -50)
    customMessageCheckbox.text = customMessageCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customMessageCheckbox.text:SetPoint("LEFT", customMessageCheckbox, "RIGHT", 5, 0)
    customMessageCheckbox.text:SetText("Use custom message")

    if(autoGratsSavedData["useCustomMessage"] == true) then
        customMessageCheckbox:SetChecked(true)
    end

    local useSoundCheckbox = CreateFrame("CheckButton", "AutoGratsEnableSoundCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    useSoundCheckbox:SetPoint("TOPLEFT", 180, -50)
    useSoundCheckbox.text = useSoundCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    useSoundCheckbox.text:SetPoint("LEFT", useSoundCheckbox, "RIGHT", 5, 0)
    useSoundCheckbox.text:SetText("Use levelup sound")

    if(autoGratsSavedData["useSoundEffects"] == true) then
        useSoundCheckbox:SetChecked(true)
    end

    -- edit box (custom message area)
    local editBoxTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, -85)
    editBoxTitle:SetText("Custom grats message")
    
    local messageEditBox = CreateFrame("EditBox", "AutoGratsMessageEditBox", optionsPanel, "InputBoxTemplate")
    messageEditBox:SetMultiLine(false)
    messageEditBox:SetAutoFocus(false)
    messageEditBox:SetWidth(300)
    messageEditBox:SetHeight(50)
    messageEditBox:SetFontObject(ChatFontNormal)
    messageEditBox:EnableMouse(true)
    messageEditBox:SetPoint("TOPLEFT", 11, -86)
    
    -- Set text after creation
    if autoGratsSavedData and autoGratsSavedData["message"] then
        messageEditBox:SetText(autoGratsSavedData["message"])
    end

    messageEditBox:SetCursorPosition(0)


    local messageEditBoxInfo = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    messageEditBoxInfo:SetPoint("TOPLEFT", 11, -125)
    messageEditBoxInfo:SetTextColor(1,1,1)
    messageEditBoxInfo:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")

    -- custom message button
    local saveButton = CreateFrame("Button", "customMessageSaveButton", optionsPanel, "UIPanelButtonTemplate")
    saveButton:SetPoint("TOPLEFT", 5, -140)
    saveButton:SetSize(75, 25)
    saveButton:SetText("Save")

    -- reset custom message
    local resetButton = CreateFrame("Button", "customMessageResetButton", optionsPanel, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", 85, -140)
    resetButton:SetSize(75, 25)
    resetButton:SetText("Reset")

    -- wrong msg message
    local errorMessage = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    errorMessage:SetPoint("TOPLEFT", 11, -168)
    errorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    errorMessage:SetTextColor(1, 0, 0)
    errorMessage:Hide()

    local channelOptionTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelOptionTitle:SetPoint("TOPLEFT", 10, -180)
    channelOptionTitle:SetText("Channels to send grats message to:")

    -- checkboxes for chat channels

    local enablePartyChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    enablePartyChatCheckbox:SetPoint("TOPLEFT", 10, -200)
    enablePartyChatCheckbox.text = enablePartyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enablePartyChatCheckbox.text:SetPoint("LEFT", enablePartyChatCheckbox, "RIGHT", 5, 0)
    enablePartyChatCheckbox.text:SetText("Party chat")

    -- instance chat
    local enableInstanceChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    enableInstanceChatCheckbox:SetPoint("TOPLEFT", 150, -200)
    enableInstanceChatCheckbox.text = enableInstanceChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableInstanceChatCheckbox.text:SetPoint("LEFT", enableInstanceChatCheckbox, "RIGHT", 5, 0)
    enableInstanceChatCheckbox.text:SetText("Instance chat")


    -- say chat
    local enableSayChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    enableSayChatCheckbox:SetPoint("TOPLEFT", 150, -230)
    enableSayChatCheckbox.text = enableSayChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableSayChatCheckbox.text:SetPoint("LEFT", enableSayChatCheckbox, "RIGHT", 5, 0)
    enableSayChatCheckbox.text:SetText("Say chat")

    -- yell chat
    local enableYellChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    enableYellChatCheckbox:SetPoint("TOPLEFT", 10, -230)
    enableYellChatCheckbox.text = enableYellChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableYellChatCheckbox.text:SetPoint("LEFT", enableYellChatCheckbox, "RIGHT", 5, 0)
    enableYellChatCheckbox.text:SetText("Yell chat")

    if(autoGratsSavedData["usePartyChat"] == true) then
        enablePartyChatCheckbox:SetChecked(true)
    end

    if(autoGratsSavedData["useInstanceChat"] == true) then
        enableInstanceChatCheckbox:SetChecked(true)
    end

    if(autoGratsSavedData["useSayChat"] == true) then
        enableSayChatCheckbox:SetChecked(true)
    end

    if(autoGratsSavedData["useYellChat"] == true) then
        enableYellChatCheckbox:SetChecked(true)
    end


    if(autoGratsSavedData["useCustomMessage"] == true) then
        editBoxTitle:Show()
        messageEditBox:Show()
        saveButton:Show()
        resetButton:Show()
        messageEditBoxInfo:Show()
    else
        editBoxTitle:Hide()
        messageEditBox:Hide()
        saveButton:Hide()
        resetButton:Hide()
        messageEditBoxInfo:Hide()
    end

    -- custom sound dropdown menu
    local dropdownTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitle:SetPoint("TOPLEFT", 10, -270)
    dropdownTitle:SetText("Select a sound effect:")

    local dropdown = CreateFrame("Frame", "AutoGratsSoundDropdown", optionsPanel, "UIDropDownMenuTemplate")
    dropdown:SetPoint("TOPLEFT", 0, -285)

    local function OnClick(self)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        autoGratsSavedData["soundEffect"] = self:GetID()
    end

    local function Initialize(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for k, v in pairs(levelupSoundEffects) do
            if (autoGratsSavedData["soundEffect"] == nil and k == 1) then
                autoGratsSavedData["soundEffect"] = 1
            end
            info = UIDropDownMenu_CreateInfo()
            info.text = v.name
            info.value = k
            info.func = OnClick
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(dropdown, Initialize)
    UIDropDownMenu_SetWidth(dropdown, 180)
    UIDropDownMenu_SetButtonWidth(dropdown, 180)
    UIDropDownMenu_SetText(dropdown, levelupSoundEffects[autoGratsSavedData["soundEffect"]].name)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")
    UIDropDownMenu_SetSelectedID(dropdown, autoGratsSavedData["soundEffect"])

    local guildOptionsTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildOptionsTitle:SetPoint("TOPLEFT", 10, -330)
    guildOptionsTitle:SetText("Guild settings")

    local enableGuildGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    enableGuildGrats:SetPoint("TOPLEFT", 10, -350)
    enableGuildGrats.text = enableGuildGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableGuildGrats.text:SetPoint("LEFT", enableGuildGrats, "RIGHT", 5, 0)
    enableGuildGrats.text:SetText("Enable grats messages for guild members")

    if(autoGratsSavedData["useGuildGrats"] == true) then
        enableGuildGrats:SetChecked(true)
    end

    local guildSettingsCheckBoxWarningText = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildSettingsCheckBoxWarningText:SetPoint("TOPLEFT", 10, -375)
    guildSettingsCheckBoxWarningText:SetTextColor(1,1,1)
    guildSettingsCheckBoxWarningText:SetText("Warning: Enabling/disabling this feature requires a reload to take effect.")
    guildSettingsCheckBoxWarningText:SetTextColor(1, 0, 0)

    local guildGratsLevelIntervalTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildGratsLevelIntervalTitle:SetPoint("TOPLEFT", 10, -395)
    guildGratsLevelIntervalTitle:SetText("Level interval for guild grats messages")

    --slider
    local right = MinimalSliderWithSteppersMixin.Label.Right
    local formatters = {}
    formatters[right] = CreateMinimalSliderFormatter(right, FormatPercentageRound)
    
    local slider = CreateFrame("Slider", "AutoGratsSlider", optionsPanel, "MinimalSliderWithSteppersTemplate")
    slider:Init(1, 1, 10, 9, formatters)
    
    slider:SetMinMaxValues(1, 10)
    slider:SetPoint("TOPLEFT", 10, -418)
    slider:SetHeight(26)
    
    -- Set the value manually since SetValueStep is not working
    local stepValue = 1
    
    -- Register the OnValueChanged callback
    local function OnValueChanged(self, value)
        local steppedValue = math.floor((value + (stepValue / 2)) / stepValue) * stepValue
        autoGratsSavedData["guildGratsLevelInterval"] = steppedValue -- doesn't update
    end
    
    -- Register the custom callback for MinimalSliderWithSteppersMixin
    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnValueChanged)
    
    -- Initialize the slider's value
    slider:SetValue(autoGratsSavedData["guildGratsLevelInterval"] or 5)


    local customGuildMessageCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "ChatConfigCheckButtonTemplate")
    customGuildMessageCheckbox:SetPoint("TOPLEFT", 10, -450)
    customGuildMessageCheckbox.text = customGuildMessageCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customGuildMessageCheckbox.text:SetPoint("LEFT", customGuildMessageCheckbox, "RIGHT", 5, 0)
    customGuildMessageCheckbox.text:SetText("Use custom guild grats message")

    if(autoGratsSavedData["useCustomGuildMessage"] == true) then
        customGuildMessageCheckbox:SetChecked(true)
    end

    local guildMessageEditBoxTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildMessageEditBoxTitle:SetPoint("TOPLEFT", 11, -480)
    guildMessageEditBoxTitle:SetText("Custom guild grats message")

    local guildMessageEditBox = CreateFrame("EditBox", "AutoGratsMessageEditBox", optionsPanel, "InputBoxTemplate")
    guildMessageEditBox:SetMultiLine(false)
    guildMessageEditBox:SetAutoFocus(false)
    guildMessageEditBox:SetWidth(300)
    guildMessageEditBox:SetHeight(50)
    guildMessageEditBox:SetFontObject(ChatFontNormal)
    guildMessageEditBox:EnableMouse(true)
    guildMessageEditBox:SetPoint("TOPLEFT", 11, -481)

    if(autoGratsSavedData["guildMessage"]) then
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
    end

    guildMessageEditBox:SetCursorPosition(0)

    local guildMessageEditBoxInfo = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfo:SetPoint("TOPLEFT", 11, -520)
    guildMessageEditBoxInfo:SetTextColor(1,1,1)
    guildMessageEditBoxInfo:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")

    local saveGuildButton = CreateFrame("Button", "customMessageSaveButton", optionsPanel, "UIPanelButtonTemplate")
    saveGuildButton:SetPoint("TOPLEFT", 5, -540)
    saveGuildButton:SetSize(75, 25)
    saveGuildButton:SetText("Save")

    local resetGuildButton = CreateFrame("Button", "customMessageResetButton", optionsPanel, "UIPanelButtonTemplate")
    resetGuildButton:SetPoint("TOPLEFT", 85, -540)
    resetGuildButton:SetSize(75, 25)
    resetGuildButton:SetText("Reset")

    local guildErrorMessage = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildErrorMessage:SetPoint("TOPLEFT", 11, -568)
    guildErrorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    guildErrorMessage:SetTextColor(1, 0, 0)
    guildErrorMessage:Hide()

    local supportMessageTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    supportMessageTitle:SetPoint("TOPRIGHT", -10, -10)
    supportMessageTitle:SetText("Need support or have feedback ? Join our discord server!")

    -- discord support link text box
    local discordLink = CreateFrame("EditBox", "AutoGratsMessageEditBox", optionsPanel, "InputBoxTemplate")
    discordLink:SetMultiLine(false)
    discordLink:SetAutoFocus(false)
    discordLink:SetWidth(150)
    discordLink:SetHeight(50)
    discordLink:SetFontObject(ChatFontNormal)
    discordLink:EnableMouse(true)
    discordLink:SetPoint("TOPRIGHT", -9, -10)
    discordLink:SetText("discord.gg/hyhWd6DdUj")
    discordLink:SetCursorPosition(0)
    

    -- Managing events
    customMessageCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            editBoxTitle:Show()
            messageEditBox:Show()
            saveButton:Show()
            resetButton:Show()
            messageEditBoxInfo:Show()
            autoGratsSavedData["useCustomMessage"] = true
        else
            editBoxTitle:Hide()
            messageEditBox:Hide()
            saveButton:Hide()
            resetButton:Hide()
            messageEditBoxInfo:Hide()
            errorMessage:Hide()
            autoGratsSavedData["useCustomMessage"] = false
        end
    end)

    customGuildMessageCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useCustomGuildMessage"] = true
        else
            autoGratsSavedData["useCustomGuildMessage"] = false
        end
    end)

    useSoundCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useSoundEffects"] = true
        else
            autoGratsSavedData["useSoundEffects"] = false
        end
    end)

    enablePartyChatCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["usePartyChat"] = true
        else
            autoGratsSavedData["usePartyChat"] = false
        end
    end)

    enableInstanceChatCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        if isChecked then
            autoGratsSavedData["useInstanceChat"] = true
        else
            autoGratsSavedData["useInstanceChat"] = false
        end
    end)

    enableSayChatCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useSayChat"] = true
        else
            autoGratsSavedData["useSayChat"] = false
        end
    end)

    enableYellChatCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useYellChat"] = true
        else
            autoGratsSavedData["useYellChat"] = false
        end
    end)

    enableGuildGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useGuildGrats"] = true
        else
            autoGratsSavedData["useGuildGrats"] = false
        end
    end)

    messageEditBox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)

    saveButton:SetScript("OnClick", function(self, button, down)
        local editBoxText = messageEditBox:GetText()
        if(string.len(editBoxText) >= 1) then
            autoGratsSavedData["message"] = editBoxText
        else
            errorMessage:Show()
        end

        messageEditBox:ClearFocus()
    end)

    saveGuildButton:SetScript("OnClick", function(self, button, down)
        local editBoxText = guildMessageEditBox:GetText()
        if(string.len(editBoxText) >= 1) then
            autoGratsSavedData["guildMessage"] = editBoxText
        else
            guildErrorMessage:Show()
        end

        guildMessageEditBox:ClearFocus()
    end)
    
    resetButton:SetScript("OnClick", function(self, button, down)
        messageEditBox:SetText(autoGratsSavedData["message"])
        messageEditBox:ClearFocus()
    end)

    resetGuildButton:SetScript("OnClick", function(self, button, down)
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
        guildMessageEditBox:ClearFocus()
    end)
end

frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and addon_loaded == false then
        -- Unregister ADDON_LOADED event to avoid unnecessary calls
        self:UnregisterEvent("ADDON_LOADED")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AutoGrats addon loading...")

        if(autoGratsSavedData["useCustomMessage"] == nil) then
            autoGratsSavedData["useCustomMessage"] = false
        end

        if(autoGratsSavedData["useSoundEffects"] == nil) then
            autoGratsSavedData["useSoundEffects"] = true
        end

        if(autoGratsSavedData["usePartyChat"] == nil) then
            autoGratsSavedData["usePartyChat"] = true
        end

        if(autoGratsSavedData["guildGratsLevelInterval"] == nil) then
            autoGratsSavedData["guildGratsLevelInterval"] = 5
        end

        if(autoGratsSavedData["useGuildGrats"] == nil) then
            autoGratsSavedData["useGuildGrats"] = true
        end

        if(autoGratsSavedData["useCustomGuildMessage"] == nil) then
            autoGratsSavedData["useCustomGuildMessage"] = false
        end

        if(autoGratsSavedData["guildMessage"] == nil) then
            autoGratsSavedData["guildMessage"] = "Gz [username] for leveling up to lvl [lvl] !"
        end

        if(autoGratsSavedData["message"] == nil) then
            autoGratsSavedData["message"] = "Gz, [username] !"
        end

        CreateSettingsPage()
        if(autoGratsSavedData["useGuildGrats"] == true) then
            GuildRoster()
            autoGratsGuildPlayerTracker = GetGuildMembers()
            StartGuildRosterCheckTimer()
        end

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00AutoGrats addon successfully loaded!")
        DEFAULT_CHAT_FRAME:AddMessage("|cffedcd4eAutoGrats settings are available in game options, you can also access AutoGrats settings with |cff00ff00/gz |cffedcd4eand |cff00ff00/autograts |cffedcd4ecommands")
        
        addon_loaded = true
    elseif event == "UNIT_LEVEL" then
        local unitName = UnitName(arg1)
        local unitIsPlayer = UnitIsPlayer(arg1)

        if unitIsPlayer and UnitInParty(arg1) and unitName ~= UnitName("player") then
            local unitLevel = UnitLevel(unitName)
            if unitLevel > 0 then
                CheckPlayerLevelDelayed(unitName)
            end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        local groupCount = GetNumGroupMembers()

        if groupCount == 0 then
            -- If there are no group members, clear the tracker
            autoGratsPlayerTracker = {}
        else
            for i = 1, groupCount do
                local unitName = UnitName("party" .. i)
                local unitLevel = UnitLevel("party" .. i)

                if unitName ~= UnitName("player") and unitLevel > 0 then
                    if autoGratsPlayerTracker[unitName] then
                        CheckPlayerLevelDelayed(unitName)
                    else
                        autoGratsPlayerTracker[unitName] = unitLevel
                    end
                end
            end
        end

        groupMembersCount = groupCount

    elseif event == "GUILD_ROSTER_UPDATE" then
        handleGuildRosterUpdate()
    elseif event == "PLAYER_LOGOUT" then
        autoGratsPlayerTracker = {}
        autoGratsGuildPlayerTracker = {}
        groupMembersCount = 0
    end
end)

SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = test;

SLASH_OPENSETTINGS1 = "/autograts"
SLASH_OPENSETTINGS2 = "/gz"

local function OpenSettingsTab()
    Settings.OpenToCategory("AutoGratsOptionsPanel")
end

SlashCmdList["OPENSETTINGS"] = OpenSettingsTab;