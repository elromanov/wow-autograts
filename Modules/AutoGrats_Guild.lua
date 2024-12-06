DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading guild module...")

function GetGuildMembers()
    local members = {}
    for i = 1, GetNumGuildMembers() do 
        local name, _, _, level = GetGuildRosterInfo(i)
        if name and level then
            members[name] = level
        end
    end
    return members
end

function handleGuildRosterUpdate()
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
function StartGuildRosterCheckTimer()
    C_Timer.NewTicker(20, function()
        handleGuildRosterUpdate()
    end)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Guild module loaded.")