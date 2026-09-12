DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading guild welcome module...")

function HandleGuildNewMember(unitName)
    -- Compatibility entry point: use the same persisted guard as roster welcomes.
    AutoGrats.WelcomeGuildMember(unitName)
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Guild welcome module loaded.")