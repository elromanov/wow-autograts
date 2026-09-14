DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading settings module...")

function CreateSettingsPageTest()
    local optionsPanel = CreateFrame("Frame", "AutoGratsOptionsPanel", UIParent)
    optionsPanel.name = "AutoGrats"
    autograts_settings_category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "|TInterface/Addons/AutoGrats/Ressources/Images/logo:16:16|t AutoGrats")
    autograts_settings_category.ID = "AutoGratsOptionsPanel";
end

function CreatePartySettingsSubcategory(frame)
    fSubCat = CreateFrame("Frame")
    fSubCatPanel, layout = Settings.RegisterCanvasLayoutSubcategory(frame, fSubCat, "Party settings")

    CreateTitleCategory(fSubCat, "AutoGrats - Party settings")

    local customMessageCheckbox = createSettingsCheckbox(fSubCat, -50, "Use custom message", "useCustomMessage")
    customMessageCheckbox:SetPoint("TOPLEFT", 10, -50)

    local useSoundCheckbox = createSettingsCheckbox(fSubCat, -50, "Use levelup sound", "useSoundEffects")
    useSoundCheckbox:SetPoint("TOPLEFT", 180, -50)

    local messageEditBox = CreateSettingsEditBox(fSubCat, -85, "Custom grats message")
    if autoGratsSavedData and autoGratsSavedData["message"] then
        messageEditBox:SetText(autoGratsSavedData["message"])
    end
    messageEditBox:SetCursorPosition(0)

    local messageEditBoxInfo = CreateTipMessage(fSubCat, -125, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")
    local saveButton = CreateButton(fSubCat, -140, "Save")

    local resetButton = CreateButton(fSubCat, -140, "Reset")
    resetButton:SetPoint("TOPLEFT", 85, -140)

    -- wrong msg message
    local errorMessage = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    errorMessage:SetPoint("TOPLEFT", 11, -168)
    errorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    errorMessage:SetTextColor(1, 0, 0)
    errorMessage:Hide()

    local channelOptionTitle = createSettingsOptionTitle(fSubCat, -180, "Channels to send grats message to:")

    local enablePartyChatCheckbox = createSettingsCheckbox(fSubCat, -200, "Party", "usePartyChat")

    local enableInstanceChatCheckbox = createSettingsCheckbox(fSubCat, -200, "Instance chat", "useInstanceChat")
    enableInstanceChatCheckbox:SetPoint("TOPLEFT", 150, -200)

    local enableYellChatCheckbox = createSettingsCheckbox(fSubCat, -230, "Yell chat", "useYellChat")

    local enableSayChatCheckbox = createSettingsCheckbox(fSubCat, -230, "Say chat", "useSayChat")
    enableSayChatCheckbox:SetPoint("TOPLEFT", 150, -230)

    -- custom sound dropdown menu
    local dropdownTitle = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitle:SetPoint("TOPLEFT", 10, -270)
    dropdownTitle:SetText("Select a sound effect:")

    local dropdown = CreateFrame("Frame", "AutoGratsSoundDropdown", fSubCat, "UIDropDownMenuTemplate")
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

    -- events (buttons click and stuff...)
    customMessageCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useCustomMessage"] = true
        else
            errorMessage:Hide()
            autoGratsSavedData["useCustomMessage"] = false
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

    resetButton:SetScript("OnClick", function(self, button, down)
        messageEditBox:SetText(autoGratsSavedData["message"])
        messageEditBox:ClearFocus()
    end)

    return fSubCatPanel
end

function CreateGuildSettingsSubcategory(frame)
    fSubCatGuild = CreateFrame("Frame")
    fSubCatGuildPanel, layoutGuild = Settings.RegisterCanvasLayoutSubcategory(frame, fSubCatGuild, "Guild settings")

    CreateTitleCategory(fSubCatGuild, "AutoGrats - Guild settings")

    local startPosition = -50

    local enableGuildGrats = createSettingsCheckbox(fSubCatGuild, startPosition, "Enable grats messages for guild members", "useGuildGrats")
    startPosition = startPosition - 25

    local guildSettingsCheckBoxWarningText = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildSettingsCheckBoxWarningText:SetPoint("TOPLEFT", 10, startPosition)
    guildSettingsCheckBoxWarningText:SetTextColor(1,1,1)
    guildSettingsCheckBoxWarningText:SetText("Warning: Enabling/disabling this feature requires a reload to take effect.")
    guildSettingsCheckBoxWarningText:SetTextColor(1, 0, 0)

    startPosition = startPosition - 20

    local guildGratsLevelIntervalTitle = CreateSettingsSubtitle(fSubCatGuild, startPosition, "Level interval for guild grats messages")

    --slider
    local right = MinimalSliderWithSteppersMixin.Label.Right
    local formatters = {}
    formatters[right] = CreateMinimalSliderFormatter(right, FormatPercentageRound)
    
    local slider = CreateFrame("Slider", "AutoGratsSlider", fSubCatGuild, "MinimalSliderWithSteppersTemplate")
    slider:Init(1, 1, 10, 9, formatters)

    startPosition = startPosition - 18
    
    slider:SetMinMaxValues(1, 10)
    slider:SetPoint("TOPLEFT", 10, startPosition)
    slider:SetHeight(26)
    
    local stepValue = 1
    
    local function OnValueChanged(self, value)
        local steppedValue = math.floor((value + (stepValue / 2)) / stepValue) * stepValue
        autoGratsSavedData["guildGratsLevelInterval"] = steppedValue -- doesn't update
    end
    
    slider:RegisterCallback(MinimalSliderWithSteppersMixin.Event.OnValueChanged, OnValueChanged)
    slider:SetValue(autoGratsSavedData["guildGratsLevelInterval"] or 5)
    startPosition = startPosition - 35

    local customGuildMessageCheckbox = createSettingsCheckbox(fSubCatGuild, startPosition, "Use custom guild grats message", "useCustomGuildMessage")
    startPosition = startPosition - 30

    local guildMessageEditBox = CreateSettingsEditBox(fSubCatGuild, startPosition, "Custom guild grats message")
    guildMessageEditBox:SetWidth(300)
    if(autoGratsSavedData["guildMessage"]) then
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
    end
    guildMessageEditBox:SetCursorPosition(0)
    startPosition = startPosition - 40

    local guildMessageEditBoxInfo = CreateTipMessage(fSubCatGuild, startPosition, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")
    startPosition = startPosition - 17

    local saveGuildButton = CreateButton(fSubCatGuild, startPosition, "Save")
    saveGuildButton:SetSize(75, 25)

    local resetGuildButton = CreateButton(fSubCatGuild, startPosition, "Reset")
    resetGuildButton:SetPoint("TOPLEFT", 85, startPosition)
    startPosition = startPosition - 28

    local guildErrorMessage = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildErrorMessage:SetPoint("TOPLEFT", 11, startPosition)
    guildErrorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    guildErrorMessage:SetTextColor(1, 0, 0)
    guildErrorMessage:Hide()

    -- events
    saveGuildButton:SetScript("OnClick", function(self, button, down)
        local editBoxText = guildMessageEditBox:GetText()
        if(string.len(editBoxText) >= 1) then
            autoGratsSavedData["guildMessage"] = editBoxText
            guildErrorMessage:Hide()
        else
            guildErrorMessage:Show()
        end

        guildMessageEditBox:ClearFocus()
    end)

    resetGuildButton:SetScript("OnClick", function(self, button, down)
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
        guildMessageEditBox:ClearFocus()
        guildErrorMessage:Hide()
    end)
end

function CreateCustomMessagesSettingsSubcategory(frame)
    fSubCatCustomMsg = CreateFrame("Frame")
    fSubCatCustomMsgPanel, layoutMsg = Settings.RegisterCanvasLayoutSubcategory(frame, fSubCatCustomMsg, "Custom messages")

    CreateTitleCategory(fSubCatCustomMsg, "AutoGrats - Custom messages")

    local startPosition = -50

    local randMsgTitle = createSettingsOptionTitle(fSubCatCustomMsg, startPosition, "Random Messages")
    startPosition = startPosition - 25

    local enableRandomGuildGrats = createSettingsCheckbox(fSubCatCustomMsg, startPosition, "Enable random messages for guild members", "useRandomMessageForGuild")
    startPosition = startPosition - 25

    local enableRandomPartyGrats = createSettingsCheckbox(fSubCatCustomMsg, startPosition, "Enable random messages for party members", "useRandomMessageForParty")
    startPosition = startPosition - 40

    local messageEditBoxRandomMessage = CreateSettingsEditBox(fSubCatCustomMsg, startPosition, "Custom message")

    local dropdownTitle = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitle:SetPoint("TOPLEFT", 295, startPosition + 5) -- +5 to adjust position
    dropdownTitle:SetText("Remove a message")

    local removeRandMsgDropdown = CreateFrame("Frame", "AutoGratsRemoveRandomMsgDropDown", fSubCatCustomMsg, "UIDropDownMenuTemplate")
    removeRandMsgDropdown:SetPoint("TOPLEFT", 275, startPosition - 10)

    local function OnClickRemoveRandomMessageDropdown(self)
        table.remove(autoGratsSavedData["randomMessages"], self:GetID())
    end

    local function InitializeRandomMessageDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for id, msg in pairs(autoGratsSavedData["randomMessages"]) do
            info = UIDropDownMenu_CreateInfo()
            info.text = msg
            info.value = id
            info.func = OnClickRemoveRandomMessageDropdown
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(removeRandMsgDropdown, InitializeRandomMessageDropdown)

    UIDropDownMenu_SetWidth(removeRandMsgDropdown, 250)
    UIDropDownMenu_SetButtonWidth(removeRandMsgDropdown, 260)
    UIDropDownMenu_JustifyText(removeRandMsgDropdown, "LEFT")
    startPosition = startPosition - 40

    local guildMessageEditBoxInfoP1 = CreateTipMessage(fSubCatCustomMsg, startPosition, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")
    startPosition = startPosition - 15

    local saveButton = CreateButton(fSubCatCustomMsg, startPosition, "Add")
    startPosition = startPosition - 45

    local milestoneMsgTitle = createSettingsOptionTitle(fSubCatCustomMsg, startPosition, "Milestone messages")
    startPosition = startPosition - 20

    local guildMessageEditBoxInfoP1 = CreateTipMessage(fSubCatCustomMsg, startPosition, "|cffedcd4eTip:|cffffffff If enabled, milestone messages will always replace other grats messages.")
    startPosition = startPosition - 20

    local enableMilestoneGuildGrats = createSettingsCheckbox(fSubCatCustomMsg, startPosition, "Enable milestone messages for guild members", "useMilestoneMessageForGuild")
    startPosition = startPosition - 25

    local enableMilestonePartyGrats = createSettingsCheckbox(fSubCatCustomMsg, startPosition, "Enable milestone messages for party members", "useMilestoneMessageForParty")
    startPosition = startPosition - 35

    local messageEditBoxMilestoneLvl = CreateSettingsEditBox(fSubCatCustomMsg, startPosition, "Level")
    messageEditBoxMilestoneLvl:SetWidth(50)

    local editBoxMilestoneMessage = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxMilestoneMessage:SetText("Message")
    editBoxMilestoneMessage:SetPoint("TOPLEFT", 71, startPosition)

    local messageEditBoxMilestoneMessage = CreateSettingsEditBox(fSubCatCustomMsg, startPosition, "")
    messageEditBoxMilestoneMessage:SetPoint("TOPLEFT", 71, startPosition)
    startPosition = startPosition - 40

    local guildMessageEditBoxInfoP2 = CreateTipMessage(fSubCatCustomMsg, startPosition, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")
    startPosition = startPosition - 15

    local guildMessageEditBoxInfoP3 = CreateTipMessage(fSubCatCustomMsg, startPosition, "|cffedcd4eNote:|cffffffff Adding a new message for an existing level will overwrite the old one.")
    startPosition = startPosition - 15

    local saveButtonMilestone = CreateButton(fSubCatCustomMsg, startPosition, "Add message")
    saveButtonMilestone:SetSize(125, 25)
    startPosition = startPosition - 40

    local dropdownTitleMilestone = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitleMilestone:SetPoint("TOPLEFT", 10, startPosition + 5)
    dropdownTitleMilestone:SetText("Remove a milestone message")

    local removeMilestoneMsgDropdown = CreateFrame("Frame", "AutoGratsRemoveRandomMsgDropDown", fSubCatCustomMsg, "UIDropDownMenuTemplate")
    removeMilestoneMsgDropdown:SetPoint("TOPLEFT", 0, startPosition - 10)

    local function OnClickMilestoneDropdown(self)
        local id = tonumber(self.value)
        autoGratsSavedData["milestoneMessages"][id] = nil
    end

    local function InitializeMilestoneDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for id, msg in pairs(autoGratsSavedData["milestoneMessages"]) do
            info = UIDropDownMenu_CreateInfo()
            info.text = "[lvl " .. id .. "] " .. msg
            info.value = id
            info.func = OnClickMilestoneDropdown
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(removeMilestoneMsgDropdown, InitializeMilestoneDropdown)
    UIDropDownMenu_SetWidth(removeMilestoneMsgDropdown, 300)
    UIDropDownMenu_SetButtonWidth(removeMilestoneMsgDropdown, 300)
    UIDropDownMenu_JustifyText(removeMilestoneMsgDropdown, "LEFT")

    -- BUTTON & DROPDOWN EVENTS
    saveButton:SetScript("OnClick", function(self, button, down)
        local editBoxText = messageEditBoxRandomMessage:GetText()
        if(string.len(editBoxText) >= 1) then
            table.insert(autoGratsSavedData["randomMessages"], editBoxText)
        end

        messageEditBoxRandomMessage:ClearFocus()
        messageEditBoxRandomMessage:SetText("")
    end)

    saveButtonMilestone:SetScript("OnClick", function(self, button, down)
        local editBoxText = messageEditBoxMilestoneMessage:GetText()
        local editBoxLvl = tonumber(messageEditBoxMilestoneLvl:GetText())
        if(string.len(editBoxText) >= 1 and editBoxLvl > 0 and editBoxLvl <= 60) then
            autoGratsSavedData["milestoneMessages"][editBoxLvl] = editBoxText
        end

        messageEditBoxMilestoneMessage:ClearFocus()
        messageEditBoxMilestoneLvl:ClearFocus()
        messageEditBoxMilestoneMessage:SetText("")
        messageEditBoxMilestoneLvl:SetText("")
    end)
end

function CreateGuildWelcomeSettingsSubcategory(frame)
    fsubCatGuildWelcome = CreateFrame("Frame")
    fsubCatGWPanel, settingsGWLayout = Settings.RegisterCanvasLayoutSubcategory(frame, fsubCatGuildWelcome, "Guild Welcome")

    CreateTitleCategory(fsubCatGuildWelcome, "AutoGrats - Guild welcome")

    local position = -50

    local enableGuildWelcomeCheckbox = createSettingsCheckbox(fsubCatGuildWelcome, position, "Enable guild welcome messages", "useGuildWelcomeMessage")
    position = position - 25
    
    local warningText = fsubCatGuildWelcome:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    warningText:SetPoint("TOPLEFT", 10, position)
    warningText:SetTextColor(1,1,1)
    warningText:SetText("Warning: Enabling/Disabling this feature requires a reload to take effect.")
    warningText:SetTextColor(1, 0, 0)

    position = position-25

    createSettingsOptionTitle(fsubCatGuildWelcome, position, "Custom mesages")
    position = position-25

    local enableWelcomeCustomMessagesCheckbox = createSettingsCheckbox(fsubCatGuildWelcome, position, "Enable custom welcome messages", "useCustomGuildWelcomeMessages")
    position = position-30

    local customMessageEditBox = CreateSettingsEditBox(fsubCatGuildWelcome, position, "Custom message")
    customMessageEditBox:SetText(autoGratsSavedData.guildWelcomeMessage)
    customMessageEditBox:SetCursorPosition(0)
    position = position - 40

    local customMessageEditBoxTip = CreateTipMessage(fsubCatGuildWelcome, position, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff to include username in your welcome message !")
    position = position - 15

    local addCustomMessageButton = CreateButton(fsubCatGuildWelcome, position, "Save")
    position = position-40

    local randomWelcomeMessageTitle = createSettingsOptionTitle(fsubCatGuildWelcome, position, "Random welcome messages")
    position = position - 25

    local enableGuildRandomMessageWelcomeCheckbox = createSettingsCheckbox(fsubCatGuildWelcome, position, "Enable guild random welcome messages", "useRandomWelcomeMessage")
    position = position - 30

    CreateTipMessage(fsubCatGuildWelcome, position, "|cffedcd4eTip:|cffffffff If enabled, this will always replace other welcome messages.")
    position = position - 30

    local randomCustomMessageEditBox = CreateSettingsEditBox(fsubCatGuildWelcome, position, "Add custom message")
    position = position - 40

    local customMessageEditBoxTip = CreateTipMessage(fsubCatGuildWelcome, position, "|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff to include username in your welcome message !")
    position = position - 20

    local addRandomWelcomeMsgButton = CreateButton(fsubCatGuildWelcome, position, "Add message")
    addRandomWelcomeMsgButton:SetWidth(125)
    position = position - 45

    local removeRandomMessageDropdown = CreateDropDownElement(fsubCatGuildWelcome, position, "Remove a message")
    UIDropDownMenu_SetWidth(removeRandomMessageDropdown, 250)

    -- BUTTON SCRIPTS
    addCustomMessageButton:SetScript("OnClick", function(self, button, down)
        local editBxText = customMessageEditBox:GetText()
        if(string.len(editBxText) >= 1) then
            autoGratsSavedData.guildWelcomeMessage = editBxText
        end

        customMessageEditBox:ClearFocus()
    end)

    addRandomWelcomeMsgButton:SetScript("OnClick", function(self, button, down)
        local editBoxTxt = randomCustomMessageEditBox:GetText()
        if(string.len(editBoxTxt) >= 1 ) then
            table.insert(autoGratsSavedData.customGuildWelcomeMessages, editBoxTxt)
        end
        randomCustomMessageEditBox:ClearFocus()
        randomCustomMessageEditBox:SetText("")
    end)

    -- DROPDOWN SCRIPTS
    local function removeWelcomeCustomMessage(self)
        table.remove(autoGratsSavedData.customGuildWelcomeMessages, self:GetID())
    end

    local function initRandomWelcomeMessageDropdown(self)
        local info = UIDropDownMenu_CreateInfo()
        for id, msg in pairs(autoGratsSavedData.customGuildWelcomeMessages) do
            info = UIDropDownMenu_CreateInfo()
            info.text = msg
            info.value = id
            info.func = removeWelcomeCustomMessage
            UIDropDownMenu_AddButton(info)
        end
    end

    UIDropDownMenu_Initialize(removeRandomMessageDropdown, initRandomWelcomeMessageDropdown)
end

function CreateDropDownElement(settingsFrame, position, dropdownTitle)
    local dropdwnTitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdwnTitle:SetPoint("TOPLEFT", 10, position + 5)
    dropdwnTitle:SetText(dropdownTitle)
    
    local dropDwn = CreateFrame("Frame", nil, settingsFrame, "UIDropDownMenuTemplate")
    dropDwn:SetPoint("TOPLEFT", 0, position - 10)

    return dropDwn
end

function CreateButton(settingsFrame, position, text)
    local btn = CreateFrame("Button", nil, settingsFrame, "UIPanelButtonTemplate")
    btn:SetPoint("TOPLEFT", 5, position)
    btn:SetSize(75, 25)
    btn:SetText(text)

    return btn
end

function CreateTipMessage(settingsFrame, position, text)
    local editBoxTip = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    editBoxTip:SetPoint("TOPLEFT", 11, position)
    editBoxTip:SetTextColor(1,1,1)
    editBoxTip:SetText(text)

    return editBoxTip
end

function CreateSettingsEditBox(settingsFrame, position, title)
    local editBoxTitle = settingsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, position)
    editBoxTitle:SetText(title)

    local editBox = CreateFrame("EditBox", nil, settingsFrame, "InputBoxTemplate")
    editBox:SetMultiLine(false)
    editBox:SetAutoFocus(false)
    editBox:SetWidth(250)
    editBox:SetHeight(50)
    editBox:SetFontObject(ChatFontNormal)
    editBox:EnableMouse(true)
    editBox:SetPoint("TOPLEFT", 11, position)

    return editBox
end

function createSettingsOptionTitle(settingsFrame, position, text)
    local title = settingsFrame:CreateFontString("Autograts", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, position)
    title:SetText(text)

    return title
end

function createSettingsCheckbox(settingsFrame, position, text, settingsVariableName)
    local checkbox = CreateFrame("CheckButton", nil, settingsFrame, "InterfaceOptionsCheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 10, position)
    checkbox.text = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    checkbox.text:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    checkbox.text:SetText(text)
    checkbox:SetChecked(autoGratsSavedData[settingsVariableName])

    checkbox:SetScript("OnClick", function (self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData[settingsVariableName] = true
        else
            autoGratsSavedData[settingsVariableName] = false
        end
    end)

    return checkbox
end

function CreateSettingsSubtitle(frame, position, text)
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("TOPLEFT", 10, position)
    title:SetText(text)

    return title
end

function CreateTitleCategory(frame, titleText)
    local title = frame:CreateFontString("AutoGrats", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText(titleText)

    local addonVersionAndAuthor = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addonVersionAndAuthor:SetPoint("TOPLEFT", 11, -26)
    addonVersionAndAuthor:SetText("Version " .. addon_version .. " by Romanov")
    addonVersionAndAuthor:SetTextColor(1,1,1)

    local supportMessageTitle = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    supportMessageTitle:SetPoint("TOPRIGHT", -10, -10)
    supportMessageTitle:SetText("Need support or have feedback ? Join our discord server!")

    -- discord support link text box
    local discordLink = CreateFrame("EditBox", "AutoGratsMessageEditBox", frame, "InputBoxTemplate")
    discordLink:SetMultiLine(false)
    discordLink:SetAutoFocus(false)
    discordLink:SetWidth(150)
    discordLink:SetHeight(50)
    discordLink:SetFontObject(ChatFontNormal)
    discordLink:EnableMouse(true)
    discordLink:SetPoint("TOPRIGHT", -9, -10)
    discordLink:SetText("discord.gg/hyhWd6DdUj")
    discordLink:SetCursorPosition(0)
end

function CreateSettingsPage()
    local optionsPanel = CreateFrame("Frame", "AutoGratsOptionsPanel", UIParent)
    optionsPanel.name = "AutoGrats"

    autograts_settings_category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "AutoGrats")
    Settings.RegisterAddOnCategory(autograts_settings_category)
    CreateTitleCategory(optionsPanel, "AutoGrats")

    AutoGrats_PartySettingsCategory = CreatePartySettingsSubcategory(autograts_settings_category)
    CreateGuildSettingsSubcategory(autograts_settings_category)
    CreateGuildWelcomeSettingsSubcategory(autograts_settings_category)
    CreateCustomMessagesSettingsSubcategory(autograts_settings_category)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Settings module loaded.")