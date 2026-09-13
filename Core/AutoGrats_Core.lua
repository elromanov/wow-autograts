autogratsFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == AutoGrats.addonName and addon_loaded == false then
        self:UnregisterEvent("ADDON_LOADED")
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Core module loading...")

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

        if(autoGratsSavedData["useRandomMessageForParty"] == nil) then
            autoGratsSavedData["useRandomMessageForParty"] = false
        end

        if(autoGratsSavedData["useRandomMessageForGuild"] == nil) then
            autoGratsSavedData["useRandomMessageForGuild"] = false
        end

        if(autoGratsSavedData["useMilestoneMessageForParty"] == nil) then
            autoGratsSavedData["useMilestoneMessageForParty"] = false
        end

        if(autoGratsSavedData["useMilestoneMessageForGuild"] == nil) then
            autoGratsSavedData["useMilestoneMessageForGuild"] = false
        end

        if(autoGratsSavedData["randomMessages"] == nil) then 
            autoGratsSavedData["randomMessages"] = {}
        end

        if(autoGratsSavedData["milestoneMessages"] == nil) then 
            autoGratsSavedData["milestoneMessages"] = {}
        end

        autoGratsSavedData.guildWelcomeHistory = autoGratsSavedData.guildWelcomeHistory or {}
        if autoGratsSavedData.useGuildWelcomeMessage == nil then
            autoGratsSavedData.useGuildWelcomeMessage = false
        end

        if autoGratsSavedData.defaultGuildWelcomeMessage == nil then
            autoGratsSavedData.defaultGuildWelcomeMessage = "Welcome to the guild [username] :)"
        end

        if autoGratsSavedData.guildWelcomeMessage == nil then
            autoGratsSavedData.guildWelcomeMessage = autoGratsSavedData.guildWelcomeMessage or autoGratsSavedData.defaultGuildWelcomeMessage
        end

        if autoGratsSavedData.useCustomGuildWelcomeMessages == nil then
            autoGratsSavedData.useCustomGuildWelcomeMessages = false
        end

        if autoGratsSavedData.customGuildWelcomeMessages == nil then
            autoGratsSavedData.customGuildWelcomeMessages = {}
        end

        if autoGratsSavedData.useRandomWelcomeMessage == nil then
            autoGratsSavedData.useRandomWelcomeMessage = false
        end

        AutoGrats.guildPlayerTracker = {}
        autoGratsGuildPlayerTracker = AutoGrats.guildPlayerTracker
        guildRosterInitialized = false

        if IsInGuild() then
            C_GuildInfo.GuildRoster()
        end

        CreateSettingsPage()

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Addon successfully loaded!")
        DEFAULT_CHAT_FRAME:AddMessage("|cffedcd4e[AutoGrats] Settings are available in game options, you can also access AutoGrats settings with |cff00ff00/gz |cffedcd4eand |cff00ff00/autograts |cffedcd4ecommands")
        
        addon_loaded = true
        handleGuildRosterUpdate()
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

SLASH_OPENSETTINGS1 = "/autograts"
SLASH_OPENSETTINGS2 = "/gz"

local function OpenSettingsTab()
    if AutoGrats_PartySettingsCategory then
        Settings.OpenToCategory(AutoGrats_PartySettingsCategory:GetID())
    else
        Settings.OpenToCategory(autograts_settings_category:GetID())
    end
end

SlashCmdList["OPENSETTINGS"] = OpenSettingsTab;
