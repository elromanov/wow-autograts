DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading party module...")

function CheckPlayerLevelDelayed(unitName)
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

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Party module loaded.")