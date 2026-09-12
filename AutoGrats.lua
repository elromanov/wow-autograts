autogratsFrame = CreateFrame("Frame")
addon_loaded = false
guildRosterInitialized = false

groupMembersCount = 0
autoGratsPlayerTracker = {}
autoGratsGuildPlayerTracker = {}
delayInSeconds = 1 -- Adjust the delay as needed

AutoGrats = AutoGrats or {}
AutoGrats.addonName = ...
AutoGrats.guildPlayerTracker = {}
autoGratsGuildPlayerTracker = AutoGrats.guildPlayerTracker

addon_version = "4.0.5"

autograts_settings_category = nil

autogratsFrame:RegisterEvent("ADDON_LOADED")
autogratsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
autogratsFrame:RegisterEvent("UNIT_LEVEL")
autogratsFrame:RegisterEvent("PLAYER_LOGOUT")
autogratsFrame:RegisterEvent("GUILD_ROSTER_UPDATE")
-- autogratsFrame:RegisterEvent("CHAT_MSG_GUILD")

if not autoGratsSavedData then
    autoGratsSavedData = {}
end
