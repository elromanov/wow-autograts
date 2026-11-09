DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading party module...")

local function IsSecret(value)
    return issecretvalue and issecretvalue(value)
end

local function PartyIdentity(unit)
    local guid = UnitGUID(unit)
    if IsSecret(guid) or not guid then return end
    local level = UnitLevel(unit)
    if IsSecret(level) or not level or level <= 0 then return end
    return guid, level
end

local function PartyChatRestricted()
    if InCombatLockdown() then return true end
    if C_RestrictedActions and C_RestrictedActions.GetAddOnRestrictionState
        and Enum and Enum.AddOnRestrictionType and Enum.AddOnRestrictionState then
        return C_RestrictedActions.GetAddOnRestrictionState(Enum.AddOnRestrictionType.Chat)
            ~= Enum.AddOnRestrictionState.Inactive
    end
    return false
end

function AutoGrats.RefreshPartyRoster()
    groupMembersCount = GetNumGroupMembers()
    if groupMembersCount == 0 or IsInRaid() then
        autoGratsPlayerTracker = {}
        return
    end
    for i = 1, 4 do
        local unit = "party" .. i
        local guid, level = PartyIdentity(unit)
        if guid then
            if autoGratsPlayerTracker[guid] then
                CheckPlayerLevelDelayed(guid)
            else
                autoGratsPlayerTracker[guid] = level
            end
        end
    end
end

function CheckPlayerLevelDelayed(guid)
    C_Timer.After(delayInSeconds, function()
        if IsInRaid() or PartyChatRestricted() then return end
        -- Resolve again: party slots can change while this timer is pending.
        local unit, unitLevel
        for i = 1, 4 do
            local candidate = "party" .. i
            local candidateGUID, level = PartyIdentity(candidate)
            if candidateGUID == guid then
                unit, unitLevel = candidate, level
                break
            end
        end
        if not unit then return end

        if autoGratsPlayerTracker[guid] and autoGratsPlayerTracker[guid] < unitLevel then
            local unitName = UnitName(unit)
            local unitClass = UnitClass(unit)
            if IsSecret(unitName) or IsSecret(unitClass) or not unitName or not unitClass then return end
            local msg = unitName .. " (Level " .. unitLevel .. " " .. unitClass .. ") has leveled up!"
            DEFAULT_CHAT_FRAME:AddMessage("|cffdded4e" .. msg)

            local msg_to_send = ""

            if(autoGratsSavedData["useMilestoneMessageForParty"] and autoGratsSavedData["milestoneMessages"][unitLevel]) then
                msg_to_send = autoGratsSavedData["milestoneMessages"][unitLevel]
                local userNameStringPresent = string.find(msg_to_send, "%[username]")
                local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                if userNameStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[username]", unitName)
                end

                if userLevelStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[lvl]", unitLevel)
                end
            elseif(autoGratsSavedData["useRandomMessageForParty"] and #autoGratsSavedData["randomMessages"] > 0) then
                local randomIndex = math.random(1, #autoGratsSavedData["randomMessages"])
                local randomGzMessage = autoGratsSavedData["randomMessages"][randomIndex]

                msg_to_send = randomGzMessage
                local userNameStringPresent = string.find(msg_to_send, "%[username]")
                local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                if userNameStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[username]", unitName)
                end

                if userLevelStringPresent then
                    msg_to_send = string.gsub(msg_to_send, "%[lvl]", unitLevel)
                end
            elseif autoGratsSavedData["message"] and autoGratsSavedData["useCustomMessage"] == true then
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

            autoGratsPlayerTracker[guid] = unitLevel
        end
    end)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Party module loaded.")
