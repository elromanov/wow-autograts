DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading guild module...")



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

local rosterCheckPending = false
local currentGuildKey

local function FullPlayerName(name)
    local player, realm = name:match("^([^%-]+)%-(.+)$")
    return (player or name) .. "-" .. (realm or GetRealmName()):gsub("%s+", "")
end

local function GuildKey()
    if not IsInGuild() then return nil end
    local guildName, _, _, guildRealm = GetGuildInfo("player")
    if not guildName then return nil end
    return (guildRealm or GetRealmName()):gsub("%s+", "") .. ":" .. guildName
end

-- Shared by all welcome entry points. Record before sending to prevent re-entry.
function AutoGrats.WelcomeGuildMember(name)
    if not addon_loaded or not guildRosterInitialized or InCombatLockdown()
        or autoGratsSavedData.useGuildWelcomeMessage ~= true then return end
    local key = GuildKey()
    if not key or key ~= currentGuildKey then return end
    name = FullPlayerName(name)
    if not autoGratsGuildPlayerTracker[name]
        or name == FullPlayerName(UnitName("player")) then return end
    local history = autoGratsSavedData.guildWelcomeHistory[key]
    if not history or history[name] then return end

    local message = ""
    if autoGratsSavedData.useRandomWelcomeMessage == true and #autoGratsSavedData.customGuildWelcomeMessages > 0 then
        local randomIndex = math.random(1, #autoGratsSavedData.customGuildWelcomeMessages)
        local randomWelcomeMessage = autoGratsSavedData.customGuildWelcomeMessages[randomIndex]
        message = randomWelcomeMessage
    elseif autoGratsSavedData.useCustomGuildWelcomeMessages == true then
        message = autoGratsSavedData.guildWelcomeMessage
    else
        message = autoGratsSavedData.defaultGuildWelcomeMessage
    end

    history[name] = true

    C_Timer.After(8, function()
        SendChatMessage(message:gsub("%[username%]", function() return name:match("^[^%-]+") end), "GUILD")
    end)
end

function GetGuildMembers()
    local members = {}
    local count = GetNumGuildMembers()
    if count == 0 then return nil end
    for i = 1, count do
        local name, _, _, level = GetGuildRosterInfo(i)
        -- Never initialize or diff an incomplete cache.
        if not name or not level or level <= 0 then return nil end
        members[FullPlayerName(name)] = level
    end
    if not members[FullPlayerName(UnitName("player"))] then return nil end
    return members
end

local function CheckGuildRoster()
    if not addon_loaded then return end
    local key = GuildKey()
    if key ~= currentGuildKey then
        currentGuildKey = key
        guildRosterInitialized = false
        AutoGrats.guildPlayerTracker = {}
        autoGratsGuildPlayerTracker = AutoGrats.guildPlayerTracker
    end
    if not key then return end
    if not InCombatLockdown() then
        local _guildMembers = GetGuildMembers()
        if not _guildMembers then return end
        local history = autoGratsSavedData.guildWelcomeHistory
        history[key] = history[key] or {}
        -- A welcome belongs to the current membership, not to the player forever.
        -- Only a valid roster can clear it; empty/partial caches returned above.
        -- Also prune old lifetime history when establishing the login baseline.
        for name in pairs(history[key]) do
            if not _guildMembers[name] then history[key][name] = nil end
        end
        local previous = autoGratsGuildPlayerTracker
        -- Commit the complete snapshot before any messages can trigger another event.
        AutoGrats.guildPlayerTracker = _guildMembers
        autoGratsGuildPlayerTracker = _guildMembers
        if not guildRosterInitialized then
            -- Existing members on login are suppressed, including after reload/relog.
            for name in pairs(_guildMembers) do history[key][name] = true end
            guildRosterInitialized = true
            return
        end
        local player_name = FullPlayerName(UnitName("player"))
        for name, level in pairs(_guildMembers) do
            if not previous[name] and name ~= player_name then
                AutoGrats.WelcomeGuildMember(name)
                -- Do not greet these members later if welcomes were disabled on join.
                history[key][name] = true
            end
            if name ~= player_name and previous[name] and previous[name] < level then
                if autoGratsSavedData["useGuildGrats"] == true then
                    local level_modulo = math.fmod(_guildMembers[name], autoGratsSavedData["guildGratsLevelInterval"])
                    if(level_modulo == 0) then
                        local msg = name .. " (guild member) has leveled up to level " .. level .. " !"
                        DEFAULT_CHAT_FRAME:AddMessage("|cffdded4e" .. msg)

                        local msg_to_send = ""
                        -- local readable_name = GetName
                        local readable_name = name:gsub("%-.*", "")

                        --todo refactor condition: it will send message if custom message is set to FALSE
                        if(autoGratsSavedData["useMilestoneMessageForGuild"] and autoGratsSavedData["milestoneMessages"][_guildMembers[name]]) then
                            msg_to_send = autoGratsSavedData["milestoneMessages"][_guildMembers[name]]
                            local userNameStringPresent = string.find(msg_to_send, "%[username]")
                            local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                            if userNameStringPresent then
                                msg_to_send = string.gsub(msg_to_send, "%[username]", readable_name)
                            end

                            if userLevelStringPresent then
                                msg_to_send = string.gsub(msg_to_send, "%[lvl]", _guildMembers[name])
                            end
                        elseif(autoGratsSavedData["useRandomMessageForGuild"] == true and #autoGratsSavedData["randomMessages"] > 0) then
                            local randomIndex = math.random(1, #autoGratsSavedData["randomMessages"])
                            local randomGzMessage = autoGratsSavedData["randomMessages"][randomIndex]

                            msg_to_send = randomGzMessage
                            local userNameStringPresent = string.find(msg_to_send, "%[username]")
                            local userLevelStringPresent = string.find(msg_to_send, "%[lvl]")

                            if userNameStringPresent then
                                msg_to_send = string.gsub(msg_to_send, "%[username]", readable_name)
                            end

                            if userLevelStringPresent then
                                msg_to_send = string.gsub(msg_to_send, "%[lvl]", _guildMembers[name])
                            end
                        elseif(autoGratsSavedData["guildMessage"] and autoGratsSavedData["useCustomGuildMessage"] == true) then
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
            end
        end
    end
end

function handleGuildRosterUpdate()
    if not addon_loaded or rosterCheckPending then return end
    rosterCheckPending = true
    C_Timer.After(1, function()
        rosterCheckPending = false
        CheckGuildRoster()
    end)
end

-- Function to start the timer
function StartGuildRosterCheckTimer()
    C_Timer.NewTicker(60, function()
        if InCombatLockdown() or PVEFrame:IsShown() then return end
        handleGuildRosterUpdate()
    end)
end

local AG_guild_eventFrame = CreateFrame("Frame")
AG_guild_eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED") -- Combat ends
AG_guild_eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_REGEN_ENABLED" then
        ProcessAGDelayedMessages()
        handleGuildRosterUpdate()
    end
end)

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Guild module loaded.")
