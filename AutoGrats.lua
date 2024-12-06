frame = CreateFrame("Frame")
addon_loaded = false
groupMembersCount = 0
autoGratsPlayerTracker = {}
autoGratsGuildPlayerTracker = {}
delayInSeconds = 1 -- Adjust the delay as needed

addon_version = "5.0.0"

autograts_settings_category = nil

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("UNIT_LEVEL")
frame:RegisterEvent("PLAYER_LOGOUT")
frame:RegisterEvent("GUILD_ROSTER_UPDATE")


if not autoGratsSavedData then
    autoGratsSavedData = {}
end