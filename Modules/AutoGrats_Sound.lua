DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Loading sounds module...")

levelupSoundEffects = {
    {
        name = "Minecraft",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-minecraft.mp3"
    },
    {
        name = "Pokémon",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-pokemon.mp3"
    },
    {
        name = "Skyrim",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-skyrim.mp3"
    },
    {
        name = "Warcraft 3",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-warcraft3.mp3"
    },
    {
        name = "WoW 1",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-wow-1.mp3"
    },
    {
        name = "WoW 2",
        path = "Interface\\AddOns\\AutoGrats\\Ressources\\Sounds\\levelup-wow-2.mp3"
    }
}

function PlayLevelUpSound()
    PlaySoundFile(levelupSoundEffects[autoGratsSavedData["soundEffect"]].path, "Master")
end

DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[AutoGrats] Sounds module loaded.")