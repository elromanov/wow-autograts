frame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and addon_loaded == false then
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

        -- CreateSettingsCategory()
        CreateSettingsPage()
        
        if(autoGratsSavedData["useGuildGrats"] == true) then
            GuildRoster()
            autoGratsGuildPlayerTracker = GetGuildMembers()
            StartGuildRosterCheckTimer()
        end

        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Addon successfully loaded!")
        DEFAULT_CHAT_FRAME:AddMessage("|cffedcd4e[AutoGrats] Settings are available in game options, you can also access AutoGrats settings with |cff00ff00/gz |cffedcd4eand |cff00ff00/autograts |cffedcd4ecommands")
        
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

-- local function test()
--     PlayLevelUpSound()
-- end

-- SLASH_TEST1 = "/test"
-- SlashCmdList["TEST"] = test;

SLASH_OPENSETTINGS1 = "/autograts"
SLASH_OPENSETTINGS2 = "/gz"

local function OpenSettingsTab()
    Settings.OpenToCategory("AutoGratsOptionsPanel")
end

SlashCmdList["OPENSETTINGS"] = OpenSettingsTab;