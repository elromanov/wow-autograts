local frame = CreateFrame("Frame")
local addon_loaded = false
local groupMembersCount = 0
local autoGratsPlayerTracker = {}
local delayInSeconds = 1 -- Adjust the delay as needed

local addon_version = "3.0.1"

local levelupSound_filepath = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup.mp3"

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_LEVEL")
frame:RegisterEvent("PLAYER_LOGOUT")

if not autoGratsSavedData then
    autoGratsSavedData = {}
end

local function PlayLevelUpSound()
    PlaySoundFile(levelupSound_filepath, "Master")
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

            --SendChatMessage(msg_to_send, "PARTY")
            --SendChatMessage(msg_to_send, "YELL")
            if(autoGratsSavedData["usePartyChat"] == true) then
                SendChatMessage(msg_to_send, "PARTY")
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
    local optionsPanel = CreateFrame("Frame", "AutoGratsOptionsPanel", InterfaceOptionsFramePanelContainer)
    optionsPanel.name = "|TInterface/Addons/AutoGrats/Ressources/Images/logo:16:16|t AutoGrats"

    InterfaceOptions_AddCategory(optionsPanel)

    local title = optionsPanel:CreateFontString("AutoGrats", nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 10, -10)
    title:SetText("AutoGrats")

    local addonVersionAndAuthor = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    addonVersionAndAuthor:SetPoint("TOPLEFT", 11, -26)
    addonVersionAndAuthor:SetText("Version " .. addon_version .. " by Romanov")
    addonVersionAndAuthor:SetTextColor(1,1,1)

    local customMessageCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "OptionsCheckButtonTemplate")
    customMessageCheckbox:SetPoint("TOPLEFT", 10, -50)
    customMessageCheckbox.text = customMessageCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    customMessageCheckbox.text:SetPoint("LEFT", customMessageCheckbox, "RIGHT", 5, 0)
    customMessageCheckbox.text:SetText("Use custom message")

    if(autoGratsSavedData["useCustomMessage"] == true) then
        customMessageCheckbox:SetChecked(true)
    end

    local useSoundCheckbox = CreateFrame("CheckButton", "AutoGratsEnableSoundCheckbox", optionsPanel, "OptionsCheckButtonTemplate")
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

    if(autoGratsSavedData["message"]) then
        messageEditBox:SetText(autoGratsSavedData["message"])
    end

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

    local enablePartyChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "OptionsCheckButtonTemplate")
    enablePartyChatCheckbox:SetPoint("TOPLEFT", 10, -200)
    enablePartyChatCheckbox.text = enablePartyChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enablePartyChatCheckbox.text:SetPoint("LEFT", enablePartyChatCheckbox, "RIGHT", 5, 0)
    enablePartyChatCheckbox.text:SetText("Party chat")

    local enableSayChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "OptionsCheckButtonTemplate")
    enableSayChatCheckbox:SetPoint("TOPLEFT", 150, -200)
    enableSayChatCheckbox.text = enableSayChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableSayChatCheckbox.text:SetPoint("LEFT", enableSayChatCheckbox, "RIGHT", 5, 0)
    enableSayChatCheckbox.text:SetText("Say chat")

    local enableYellChatCheckbox = CreateFrame("CheckButton", "AutoGratsEnableCheckbox", optionsPanel, "OptionsCheckButtonTemplate")
    enableYellChatCheckbox:SetPoint("TOPLEFT", 10, -230)
    enableYellChatCheckbox.text = enableYellChatCheckbox:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    enableYellChatCheckbox.text:SetPoint("LEFT", enableYellChatCheckbox, "RIGHT", 5, 0)
    enableYellChatCheckbox.text:SetText("Yell chat")

    if(autoGratsSavedData["usePartyChat"] == true) then
        enablePartyChatCheckbox:SetChecked(true)
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

    -- discord support link title
    local supportMessageTitle = optionsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    supportMessageTitle:SetPoint("TOPLEFT", 10, -500)
    supportMessageTitle:SetText("Need support or have feedback ? Join our discord server!")

    -- discord support link text box
    local discordLink = CreateFrame("EditBox", "AutoGratsMessageEditBox", optionsPanel, "InputBoxTemplate")
    discordLink:SetMultiLine(false)
    discordLink:SetAutoFocus(false)
    discordLink:SetWidth(150)
    discordLink:SetHeight(50)
    discordLink:SetFontObject(ChatFontNormal)
    discordLink:EnableMouse(true)
    discordLink:SetPoint("TOPLEFT", 11, -500)
    discordLink:SetText("discord.gg/hyhWd6DdUj")
    

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

        CreateSettingsPage()

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
    elseif event == "PLAYER_LOGOUT" then
        autoGratsPlayerTracker = {}
        groupMembersCount = 0
    end
end)

SLASH_OPENSETTINGS1 = "/autograts"
SLASH_OPENSETTINGS2 = "/gz"

-- test command
local function test()
    PlayLevelUpSound()
end
SLASH_TEST1 = "/test"
SlashCmdList["TEST"] = test;

local function OpenSettingsTab()
    InterfaceOptionsFrame_OpenToCategory("|TInterface/Addons/AutoGrats/Ressources/Images/logo:16:16|t AutoGrats")
end

SlashCmdList["OPENSETTINGS"] = OpenSettingsTab;