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
    -- fSubCatPanel.ID = "AutoGratsPartySettings"

    CreateTitleCategory(fSubCat, "AutoGrats - Party settings")

    local customMessageCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
    customMessageCheckbox:SetPoint("TOPLEFT", 10, -50)
    customMessageCheckbox.text = customMessageCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customMessageCheckbox.text:SetPoint("LEFT", customMessageCheckbox, "RIGHT", 5, 0)
    customMessageCheckbox.text:SetText("Use custom message")

    if(autoGratsSavedData["useCustomMessage"] == true) then
        customMessageCheckbox:SetChecked(true)
    end

    local useSoundCheckbox = CreateFrame("CheckButton", "AutoGratsEnableSoundCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
    useSoundCheckbox:SetPoint("TOPLEFT", 180, -50)
    useSoundCheckbox.text = useSoundCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    useSoundCheckbox.text:SetPoint("LEFT", useSoundCheckbox, "RIGHT", 5, 0)
    useSoundCheckbox.text:SetText("Use levelup sound")

    if(autoGratsSavedData["useSoundEffects"] == true) then
        useSoundCheckbox:SetChecked(true)
    end

    -- edit box (custom message area)
    local editBoxTitle = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, -85)
    editBoxTitle:SetText("Custom grats message")
    
    local messageEditBox = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCat, "InputBoxTemplate")
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


    local messageEditBoxInfo = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    messageEditBoxInfo:SetPoint("TOPLEFT", 11, -125)
    messageEditBoxInfo:SetTextColor(1,1,1)
    messageEditBoxInfo:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")

    -- custom message button
    local saveButton = CreateFrame("Button", "customMessageSaveButton", fSubCat, "UIPanelButtonTemplate")
    saveButton:SetPoint("TOPLEFT", 5, -140)
    saveButton:SetSize(75, 25)
    saveButton:SetText("Save")

    -- reset custom message
    local resetButton = CreateFrame("Button", "customMessageResetButton", fSubCat, "UIPanelButtonTemplate")
    resetButton:SetPoint("TOPLEFT", 85, -140)
    resetButton:SetSize(75, 25)
    resetButton:SetText("Reset")

    -- wrong msg message
    local errorMessage = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    errorMessage:SetPoint("TOPLEFT", 11, -168)
    errorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    errorMessage:SetTextColor(1, 0, 0)
    errorMessage:Hide()

    local channelOptionTitle = fSubCat:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    channelOptionTitle:SetPoint("TOPLEFT", 10, -180)
    channelOptionTitle:SetText("Channels to send grats message to:")

    -- checkboxes for chat channels

    local enablePartyChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
    enablePartyChatCheckbox:SetPoint("TOPLEFT", 10, -200)
    enablePartyChatCheckbox.text = enablePartyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enablePartyChatCheckbox.text:SetPoint("LEFT", enablePartyChatCheckbox, "RIGHT", 5, 0)
    enablePartyChatCheckbox.text:SetText("Party chat")

    -- instance chat
    local enableInstanceChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
    enableInstanceChatCheckbox:SetPoint("TOPLEFT", 150, -200)
    enableInstanceChatCheckbox.text = enableInstanceChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableInstanceChatCheckbox.text:SetPoint("LEFT", enableInstanceChatCheckbox, "RIGHT", 5, 0)
    enableInstanceChatCheckbox.text:SetText("Instance chat")


    -- say chat
    local enableSayChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
    enableSayChatCheckbox:SetPoint("TOPLEFT", 150, -230)
    enableSayChatCheckbox.text = enableSayChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableSayChatCheckbox.text:SetPoint("LEFT", enableSayChatCheckbox, "RIGHT", 5, 0)
    enableSayChatCheckbox.text:SetText("Say chat")

    -- yell chat
    local enableYellChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCat, "ChatConfigCheckButtonTemplate")
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

    --test for make subcategory
    -- fTest = CreateFrame("Frame")
    -- test, layout = Settings.RegisterCanvasLayoutSubcategory(autograts_settings_category,fTest, "test")
    -- Settings.RegisterAddOnCategory(autograts_settings_category)

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

    -- local guildOptionsTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- guildOptionsTitle:SetPoint("TOPLEFT", 10, -330)
    -- guildOptionsTitle:SetText("Guild settings")

    CreateTitleCategory(fSubCatGuild, "AutoGrats - Guild settings")

    local startPosition = -50

    local enableGuildGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatGuild, "ChatConfigCheckButtonTemplate")
    enableGuildGrats:SetPoint("TOPLEFT", 10, startPosition)
    enableGuildGrats.text = enableGuildGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableGuildGrats.text:SetPoint("LEFT", enableGuildGrats, "RIGHT", 5, 0)
    enableGuildGrats.text:SetText("Enable grats messages for guild members")

    if(autoGratsSavedData["useGuildGrats"] == true) then
        enableGuildGrats:SetChecked(true)
    end

    startPosition = startPosition - 25

    local guildSettingsCheckBoxWarningText = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildSettingsCheckBoxWarningText:SetPoint("TOPLEFT", 10, startPosition)
    guildSettingsCheckBoxWarningText:SetTextColor(1,1,1)
    guildSettingsCheckBoxWarningText:SetText("Warning: Enabling/disabling this feature requires a reload to take effect.")
    guildSettingsCheckBoxWarningText:SetTextColor(1, 0, 0)

    startPosition = startPosition - 20

    local guildGratsLevelIntervalTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildGratsLevelIntervalTitle:SetPoint("TOPLEFT", 10, startPosition)
    guildGratsLevelIntervalTitle:SetText("Level interval for guild grats messages")

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

    startPosition = startPosition - 35

    local customGuildMessageCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatGuild, "ChatConfigCheckButtonTemplate")
    customGuildMessageCheckbox:SetPoint("TOPLEFT", 10, startPosition)
    customGuildMessageCheckbox.text = customGuildMessageCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customGuildMessageCheckbox.text:SetPoint("LEFT", customGuildMessageCheckbox, "RIGHT", 5, 0)
    customGuildMessageCheckbox.text:SetText("Use custom guild grats message")

    if(autoGratsSavedData["useCustomGuildMessage"] == true) then
        customGuildMessageCheckbox:SetChecked(true)
    end

    startPosition = startPosition - 25

    local guildMessageEditBoxTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildMessageEditBoxTitle:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxTitle:SetText("Custom guild grats message")

    local guildMessageEditBox = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCatGuild, "InputBoxTemplate")
    guildMessageEditBox:SetMultiLine(false)
    guildMessageEditBox:SetAutoFocus(false)
    guildMessageEditBox:SetWidth(300)
    guildMessageEditBox:SetHeight(50)
    guildMessageEditBox:SetFontObject(ChatFontNormal)
    guildMessageEditBox:EnableMouse(true)
    guildMessageEditBox:SetPoint("TOPLEFT", 11, startPosition)

    if(autoGratsSavedData["guildMessage"]) then
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
    end

    guildMessageEditBox:SetCursorPosition(0)

    startPosition = startPosition - 40

    local guildMessageEditBoxInfo = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfo:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxInfo:SetTextColor(1,1,1)
    guildMessageEditBoxInfo:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")

    startPosition = startPosition - 17
    local saveGuildButton = CreateFrame("Button", "customMessageSaveButton", fSubCatGuild, "UIPanelButtonTemplate")
    saveGuildButton:SetPoint("TOPLEFT", 5, startPosition)
    saveGuildButton:SetSize(75, 25)
    saveGuildButton:SetText("Save")

    local resetGuildButton = CreateFrame("Button", "customMessageResetButton", fSubCatGuild, "UIPanelButtonTemplate")
    resetGuildButton:SetPoint("TOPLEFT", 85, startPosition)
    resetGuildButton:SetSize(75, 25)
    resetGuildButton:SetText("Reset")

    startPosition = startPosition - 28

    local guildErrorMessage = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    guildErrorMessage:SetPoint("TOPLEFT", 11, startPosition)
    guildErrorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    guildErrorMessage:SetTextColor(1, 0, 0)
    guildErrorMessage:Hide()   

    -- guild welcome message section
    --todo move that part to its own submenu

    -- startPosition = startPosition -20

    -- local guildWelcomeMessageEditBoxTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- guildWelcomeMessageEditBoxTitle:SetPoint("TOPLEFT", 11, startPosition)
    -- guildWelcomeMessageEditBoxTitle:SetText("Automatic welcome message")

    -- startPosition = startPosition -20

    -- local enableGuildWelcomeCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatGuild, "ChatConfigCheckButtonTemplate")
    -- enableGuildWelcomeCheckbox:SetPoint("TOPLEFT", 10, startPosition)
    -- enableGuildWelcomeCheckbox.text = enableGuildWelcomeCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- enableGuildWelcomeCheckbox.text:SetPoint("LEFT", enableGuildWelcomeCheckbox, "RIGHT", 5, 0)
    -- enableGuildWelcomeCheckbox.text:SetText("Enable automatic welcome message for new guild members")

    -- if(autoGratsSavedData["useGuildWelcomeMessage"] == true) then
    --     enableGuildWelcomeCheckbox:SetChecked(true)
    -- end

    -- startPosition = startPosition - 30

    -- local guildWelcomeMessageEditBoxTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- guildWelcomeMessageEditBoxTitle:SetPoint("TOPLEFT", 11, startPosition)
    -- guildWelcomeMessageEditBoxTitle:SetText("Custom welcome message")

    -- local guildWelcomeMessageEditBox = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCatGuild, "InputBoxTemplate")
    -- guildWelcomeMessageEditBox:SetMultiLine(false)
    -- guildWelcomeMessageEditBox:SetAutoFocus(false)
    -- guildWelcomeMessageEditBox:SetWidth(300)
    -- guildWelcomeMessageEditBox:SetHeight(50)
    -- guildWelcomeMessageEditBox:SetFontObject(ChatFontNormal)
    -- guildWelcomeMessageEditBox:EnableMouse(true)
    -- guildWelcomeMessageEditBox:SetPoint("TOPLEFT", 11, startPosition)

    -- if(autoGratsSavedData["guildWelcomeMessage"]) then
    --     guildWelcomeMessageEditBox:SetText(autoGratsSavedData["guildWelcomeMessage"])
    -- end

    -- guildWelcomeMessageEditBox:SetCursorPosition(0)

    -- startPosition = startPosition - 40

    -- local guildWelcomeMessageEditBoxInfo = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    -- guildWelcomeMessageEditBoxInfo:SetPoint("TOPLEFT", 11, startPosition)
    -- guildWelcomeMessageEditBoxInfo:SetTextColor(1,1,1)
    -- guildWelcomeMessageEditBoxInfo:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff to include username in your welcome message !")

    -- startPosition = startPosition - 17
    -- local saveGuildWelcomeButton = CreateFrame("Button", "customMessageSaveButton", fSubCatGuild, "UIPanelButtonTemplate")
    -- saveGuildWelcomeButton:SetPoint("TOPLEFT", 5, startPosition)
    -- saveGuildWelcomeButton:SetSize(75, 25)
    -- saveGuildWelcomeButton:SetText("Save")

    -- local resetGuildWelcomeButton = CreateFrame("Button", "customMessageResetButton", fSubCatGuild, "UIPanelButtonTemplate")
    -- resetGuildWelcomeButton:SetPoint("TOPLEFT", 85, startPosition)
    -- resetGuildWelcomeButton:SetSize(75, 25)
    -- resetGuildWelcomeButton:SetText("Reset")

    -- startPosition = startPosition - 28

    -- local guildWelcomeErrorMessage = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- guildWelcomeErrorMessage:SetPoint("TOPLEFT", 11, startPosition)
    -- guildWelcomeErrorMessage:SetText("[Message not saved] Invalid message. Message length must be at least 1 character.")
    -- guildWelcomeErrorMessage:SetTextColor(1, 0, 0)
    -- guildWelcomeErrorMessage:Hide()

    -- events
    customGuildMessageCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useCustomGuildMessage"] = true
        else
            autoGratsSavedData["useCustomGuildMessage"] = false
        end
    end)

    -- enableGuildWelcomeCheckbox:SetScript("OnClick", function(self)
    --     local isChecked = self:GetChecked()

    --     if isChecked then
    --         autoGratsSavedData["useGuildWelcomeMessage"] = true
    --     else
    --         autoGratsSavedData["useGuildWelcomeMessage"] = false
    --     end
    -- end)


    enableGuildGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useGuildGrats"] = true
        else
            autoGratsSavedData["useGuildGrats"] = false
        end
    end)

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

    -- saveGuildWelcomeButton:SetScript("OnClick", function(self, button, down)
    --     local editBoxText = guildWelcomeMessageEditBox:GetText()
    --     if(string.len(editBoxText) >= 1) then
    --         autoGratsSavedData["guildWelcomeMessage"] = editBoxText
    --         guildWelcomeErrorMessage:Hide()
    --     else
    --         guildWelcomeErrorMessage:Show()
    --     end

    --     guildMessageEditBox:ClearFocus()
    -- end)

    resetGuildButton:SetScript("OnClick", function(self, button, down)
        guildMessageEditBox:SetText(autoGratsSavedData["guildMessage"])
        guildMessageEditBox:ClearFocus()
        guildErrorMessage:Hide()
    end)

    -- resetGuildWelcomeButton:SetScript("OnClick", function(self, button, down)
    --     guildMessageEditBox:SetText(autoGratsSavedData["guildWelcomeMessage"])
    --     guildMessageEditBox:ClearFocus()
    --     guildWelcomeErrorMessage:Hide()
    -- end)
end

function CreateCustomMessagesSettingsSubcategory(frame)
    fSubCatCustomMsg = CreateFrame("Frame")
    fSubCatCustomMsgPanel, layoutMsg = Settings.RegisterCanvasLayoutSubcategory(frame, fSubCatCustomMsg, "Custom messages")

    -- local guildOptionsTitle = fSubCatGuild:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    -- guildOptionsTitle:SetPoint("TOPLEFT", 10, -330)
    -- guildOptionsTitle:SetText("Guild settings")

    CreateTitleCategory(fSubCatCustomMsg, "AutoGrats - Custom messages")

    local startPosition = -50

    local randMsgTitle = fSubCatCustomMsg:CreateFontString("AutoGrats", nil, "GameFontNormalLarge")
    randMsgTitle:SetPoint("TOPLEFT", 10, startPosition)
    randMsgTitle:SetText("Random messages")

    startPosition = startPosition - 25

    local enableRandomGuildGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatCustomMsg, "ChatConfigCheckButtonTemplate")
    enableRandomGuildGrats:SetPoint("TOPLEFT", 10, startPosition)
    enableRandomGuildGrats.text = enableRandomGuildGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableRandomGuildGrats.text:SetPoint("LEFT", enableRandomGuildGrats, "RIGHT", 5, 0)
    enableRandomGuildGrats.text:SetText("Enable random messages for guild members")

    startPosition = startPosition - 25

    local enableRandomPartyGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatCustomMsg, "ChatConfigCheckButtonTemplate")
    enableRandomPartyGrats:SetPoint("TOPLEFT", 10, startPosition)
    enableRandomPartyGrats.text = enableRandomPartyGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableRandomPartyGrats.text:SetPoint("LEFT", enableRandomPartyGrats, "RIGHT", 5, 0)
    enableRandomPartyGrats.text:SetText("Enable random messages for party members")

    if(autoGratsSavedData["useRandomMessageForParty"] == true) then
        enableRandomPartyGrats:SetChecked(true)
    end

    if(autoGratsSavedData["useRandomMessageForGuild"] == true) then
        enableRandomGuildGrats:SetChecked(true)
    end

    startPosition = startPosition - 40

    -- edit box (custom message area)
    local editBoxTitle = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxTitle:SetPoint("TOPLEFT", 11, startPosition)
    editBoxTitle:SetText("Custom message")
    
    local messageEditBoxRandomMessage = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCatCustomMsg, "InputBoxTemplate")
    messageEditBoxRandomMessage:SetMultiLine(false)
    messageEditBoxRandomMessage:SetAutoFocus(false)
    messageEditBoxRandomMessage:SetWidth(250)
    messageEditBoxRandomMessage:SetHeight(50)
    messageEditBoxRandomMessage:SetFontObject(ChatFontNormal)
    messageEditBoxRandomMessage:EnableMouse(true)
    messageEditBoxRandomMessage:SetPoint("TOPLEFT", 11, startPosition)

    local dropdownTitle = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitle:SetPoint("TOPLEFT", 295, startPosition + 5)
    dropdownTitle:SetText("Remove a message")

    local removeRandMsgDropdown = CreateFrame("Frame", "AutoGratsRemoveRandomMsgDropDown", fSubCatCustomMsg, "UIDropDownMenuTemplate")
    removeRandMsgDropdown:SetPoint("TOPLEFT", 275, startPosition - 10)
    -- UIDropDownMenu_SetWidth(removeRandMsgDropdown, 800)

    --todo rewrite these two function to match what it's supposed to do
    local function OnClickRemoveRandomMessageDropdown(self)
        -- UIDropDownMenu_SetSelectedID(removeRandMsgDropdown, self:GetID())
        -- autoGratsSavedData["soundEffect"] = self:GetID()
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

    local guildMessageEditBoxInfoP1 = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfoP1:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxInfoP1:SetTextColor(1,1,1)
    guildMessageEditBoxInfoP1:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")
     
    startPosition = startPosition - 15

    local saveButton = CreateFrame("Button", "customMessageSaveButton", fSubCatCustomMsg, "UIPanelButtonTemplate")
    saveButton:SetPoint("TOPLEFT", 5, startPosition)
    saveButton:SetSize(75, 25)
    saveButton:SetText("Add")

    startPosition = startPosition - 45

    local milestoneMsgTitle = fSubCatCustomMsg:CreateFontString("AutoGrats", nil, "GameFontNormalLarge")
    milestoneMsgTitle:SetPoint("TOPLEFT", 10, startPosition)
    milestoneMsgTitle:SetText("Milestone messages")

    startPosition = startPosition - 20

    local guildMessageEditBoxInfoP1 = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfoP1:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxInfoP1:SetTextColor(1,1,1)
    guildMessageEditBoxInfoP1:SetText("|cffedcd4eTip:|cffffffff If enabled, milestone messages will always replace other grats messages.")

    startPosition = startPosition - 20

    local enableMilestoneGuildGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatCustomMsg, "ChatConfigCheckButtonTemplate")
    enableMilestoneGuildGrats:SetPoint("TOPLEFT", 10, startPosition)
    enableMilestoneGuildGrats.text = enableMilestoneGuildGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableMilestoneGuildGrats.text:SetPoint("LEFT", enableMilestoneGuildGrats, "RIGHT", 5, 0)
    enableMilestoneGuildGrats.text:SetText("Enable milestone messages for guild members")

    startPosition = startPosition - 25

    local enableMilestonePartyGrats = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", fSubCatCustomMsg, "ChatConfigCheckButtonTemplate")
    enableMilestonePartyGrats:SetPoint("TOPLEFT", 10, startPosition)
    enableMilestonePartyGrats.text = enableMilestonePartyGrats:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableMilestonePartyGrats.text:SetPoint("LEFT", enableMilestonePartyGrats, "RIGHT", 5, 0)
    enableMilestonePartyGrats.text:SetText("Enable milestone messages for party members")

    if(autoGratsSavedData["useMilestoneMessageForParty"] == true) then
        enableMilestonePartyGrats:SetChecked(true)
    end

    if(autoGratsSavedData["useMilestoneMessageForGuild"] == true) then
        enableMilestoneGuildGrats:SetChecked(true)
    end

    startPosition = startPosition - 35

    local editBoxMilestoneLvl = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxMilestoneLvl:SetPoint("TOPLEFT", 11, startPosition)
    editBoxMilestoneLvl:SetText("Level")
    
    local messageEditBoxMilestoneLvl = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCatCustomMsg, "InputBoxTemplate")
    messageEditBoxMilestoneLvl:SetMultiLine(false)
    messageEditBoxMilestoneLvl:SetAutoFocus(false)
    messageEditBoxMilestoneLvl:SetWidth(50)
    messageEditBoxMilestoneLvl:SetHeight(50)
    messageEditBoxMilestoneLvl:SetFontObject(ChatFontNormal)
    messageEditBoxMilestoneLvl:EnableMouse(true)
    messageEditBoxMilestoneLvl:SetPoint("TOPLEFT", 11, startPosition)

    local editBoxMilestoneMessage = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    editBoxMilestoneMessage:SetPoint("TOPLEFT", 71, startPosition)
    editBoxMilestoneMessage:SetText("Message")
    
    local messageEditBoxMilestoneMessage = CreateFrame("EditBox", "AutoGratsMessageEditBox", fSubCatCustomMsg, "InputBoxTemplate")
    messageEditBoxMilestoneMessage:SetMultiLine(false)
    messageEditBoxMilestoneMessage:SetAutoFocus(false)
    messageEditBoxMilestoneMessage:SetWidth(250)
    messageEditBoxMilestoneMessage:SetHeight(50)
    messageEditBoxMilestoneMessage:SetFontObject(ChatFontNormal)
    messageEditBoxMilestoneMessage:EnableMouse(true)
    messageEditBoxMilestoneMessage:SetPoint("TOPLEFT", 71, startPosition)

    startPosition = startPosition - 40

    local guildMessageEditBoxInfoP2 = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfoP2:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxInfoP2:SetTextColor(1,1,1)
    guildMessageEditBoxInfoP2:SetText("|cffedcd4eTip:|cffffffff You can write |cff00ff00[username]|cffffffff & |cff00ff00[lvl]|cffffffff to include username and level in your grats message !")

    startPosition = startPosition - 15

    local guildMessageEditBoxInfoP3 = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    guildMessageEditBoxInfoP3:SetPoint("TOPLEFT", 11, startPosition)
    guildMessageEditBoxInfoP3:SetTextColor(1,1,1)
    guildMessageEditBoxInfoP3:SetText("|cffedcd4eTip:|cffffffff Adding a new message for an existing level will overwrite the old one.")

    startPosition = startPosition - 15

    local saveButtonMilestone = CreateFrame("Button", "customMessageSaveButton", fSubCatCustomMsg, "UIPanelButtonTemplate")
    saveButtonMilestone:SetPoint("TOPLEFT", 5, startPosition)
    saveButtonMilestone:SetSize(125, 25)
    saveButtonMilestone:SetText("Add message")

    startPosition = startPosition - 40

    local dropdownTitleMilestone = fSubCatCustomMsg:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    dropdownTitleMilestone:SetPoint("TOPLEFT", 10, startPosition + 5)
    dropdownTitleMilestone:SetText("Remove a milestone message")

    local removeMilestoneMsgDropdown = CreateFrame("Frame", "AutoGratsRemoveRandomMsgDropDown", fSubCatCustomMsg, "UIDropDownMenuTemplate")
    removeMilestoneMsgDropdown:SetPoint("TOPLEFT", 0, startPosition - 10)
    -- UIDropDownMenu_SetWidth(removeRandMsgDropdown, 800)

    local function OnClickMilestoneDropdown(self)
        -- UIDropDownMenu_SetSelectedID(removeMilestoneMsgDropdown, self:GetID())
        -- table.remove(autoGratsSavedData["milestoneMessages"], self:GetID())
        local id = tonumber(self.value)
        autoGratsSavedData["milestoneMessages"][id] = nil
        -- autoGratsSavedData["soundEffect"] = self:GetID()
    end

    local function InitializeMilestoneDropdown(self, level)
        local info = UIDropDownMenu_CreateInfo()
        for id, msg in pairs(autoGratsSavedData["milestoneMessages"]) do
            -- if (autoGratsSavedData["soundEffect"] == nil and k == 1) then
            --     autoGratsSavedData["soundEffect"] = 1
            -- end
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

    --EVENTS

    --random message
    enableRandomPartyGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useRandomMessageForParty"] = true
        else
            autoGratsSavedData["useRandomMessageForParty"] = false
        end
        print(autoGratsSavedData["useRandomMessageForParty"])
    end)

    enableRandomGuildGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useRandomMessageForGuild"] = true
        else
            autoGratsSavedData["useRandomMessageForGuild"] = false
        end
        print(autoGratsSavedData["useRandomMessageForGuild"])
    end)

    enableMilestonePartyGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useMilestoneMessageForParty"] = true
        else
            autoGratsSavedData["useMilestoneMessageForParty"] = false
        end
        print(autoGratsSavedData["useMilestoneMessageForParty"])
    end)

    enableMilestoneGuildGrats:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()

        if isChecked then
            autoGratsSavedData["useMilestoneMessageForGuild"] = true
        else
            autoGratsSavedData["useMilestoneMessageForGuild"] = false
        end
        print(autoGratsSavedData["useMilestoneMessageForGuild"])
    end)

    saveButton:SetScript("OnClick", function(self, button, down)
        local editBoxText = messageEditBoxRandomMessage:GetText()
        if(string.len(editBoxText) >= 1) then
            -- autoGratsSavedData["guildMessage"] = editBoxText
            table.insert(autoGratsSavedData["randomMessages"], editBoxText)
            -- guildErrorMessage:Hide()
        else
            -- guildErrorMessage:Show()
        end

        messageEditBoxRandomMessage:ClearFocus()
        messageEditBoxRandomMessage:SetText("")
    end)

    saveButtonMilestone:SetScript("OnClick", function(self, button, down)
        local editBoxText = messageEditBoxMilestoneMessage:GetText()
        local editBoxLvl = tonumber(messageEditBoxMilestoneLvl:GetText())
        if(string.len(editBoxText) >= 1 and editBoxLvl > 0 and editBoxLvl <= 60) then
            -- autoGratsSavedData["guildMessage"] = editBoxText
            autoGratsSavedData["milestoneMessages"][editBoxLvl] = editBoxText
            -- guildErrorMessage:Hide()
        else
            -- guildErrorMessage:Show()
        end

        messageEditBoxMilestoneMessage:ClearFocus()
        messageEditBoxMilestoneLvl:ClearFocus()
        messageEditBoxMilestoneMessage:SetText("")
        messageEditBoxMilestoneLvl:SetText("")
    end)
    
     

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
    -- Settings page

    local optionsPanel = CreateFrame("Frame", "AutoGratsOptionsPanel", UIParent)
    optionsPanel.name = "AutoGrats"

    -- Register with the new settings API
    autograts_settings_category = Settings.RegisterCanvasLayoutCategory(optionsPanel, "AutoGrats")
    -- autograts_settings_category.ID = "AutoGratsOptionsPanel";
    Settings.RegisterAddOnCategory(autograts_settings_category)

    CreateTitleCategory(optionsPanel, "AutoGrats")

    AutoGrats_PartySettingsCategory = CreatePartySettingsSubcategory(autograts_settings_category)
    CreateGuildSettingsSubcategory(autograts_settings_category)
    CreateCustomMessagesSettingsSubcategory(autograts_settings_category)

end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Settings module loaded.")