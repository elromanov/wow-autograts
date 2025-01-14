autogratsFrame = CreateFrame("Frame")
addon_loaded = false
groupMembersCount = 0
autoGratsPlayerTracker = {}
autoGratsGuildPlayerTracker = {}
delayInSeconds = 1 -- Adjust the delay as needed

addon_version = "4.0.3"

autograts_settings_category = nil

autogratsFrame:RegisterEvent("ADDON_LOADED")
autogratsFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
autogratsFrame:RegisterEvent("UNIT_LEVEL")
autogratsFrame:RegisterEvent("PLAYER_LOGOUT")
autogratsFrame:RegisterEvent("GUILD_ROSTER_UPDATE")

if not autoGratsSavedData then
    autoGratsSavedData = {}
end