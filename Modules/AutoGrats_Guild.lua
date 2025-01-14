DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading guild module...")

AutoGrats = AutoGrats or {}
AutoGrats.guildPlayerTracker = AutoGrats.guildPlayerTracker or {}
local autoGratsGuildPlayerTracker = AutoGrats.guildPlayerTracker

local autograts_guild_delayed_messages = {}
AutoGrats.GuildDelayedMessages = AutoGrats.GuildDelayedMessages or {}

function SendDelayedGuildMessages(msg, channel)
    if InCombatLockdown() then
        table.insert(autograts_guild_delayed_messages, {msg = msg, channel = channel})
    else
        SendChatMessage(msg, channel)
    end
end

function ProcessAGDelayedMessages()
    for _, message in ipairs(autograts_guild_delayed_messages) do
        SendChatMessage(message.msg, message.channel)
    end
    autograts_guild_delayed_messages = {}
end

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
    if not InCombatLockdown() then
        C_GuildInfo.GuildRoster()
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
                    -- local readable_name = GetName
                    local readable_name = name:gsub("%-.*", "")
    
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
                    -- SendChatMessage(msg_to_send, "GUILD")
                    SendDelayedGuildMessages(msg_to_send, "GUILD")
                end
            end
            autoGratsGuildPlayerTracker[name] = _guildMembers[name]
        end
    end
end

-- Function to start the timer
function StartGuildRosterCheckTimer()
    C_Timer.NewTicker(20, function()
        if InCombatLockdown() or PVEFrame:IsShown() then return end
        handleGuildRosterUpdate()
    end)
end

local AG_guild_eventFrame = CreateFrame("Frame")
AG_guild_eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Combat ends
AG_guild_eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        ProcessAGDelayedMessages()
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Guild module loaded.")