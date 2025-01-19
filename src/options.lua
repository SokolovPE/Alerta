local name, alerta = ...
alerta.core = {}
alerta.core.settings = {}
local mod = alerta.core

-- Register shared sounds
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Alerta:Alerta", "Interface\\AddOns\\Alerta\\Sounds\\Alerta.ogg")
LSM:Register("sound", "Alerta:Unexpected", "Interface\\AddOns\\Alerta\\Sounds\\AlertUnexpected.ogg")
LSM:Register("sound", "Alerta:AnotherOne", "Interface\\AddOns\\Alerta\\Sounds\\AnotherOne.ogg")
LSM:Register("sound", "Alerta:HelloThere", "Interface\\AddOns\\Alerta\\Sounds\\HelloThere.ogg")

local sounds = {}
local channels = {
    Master   = "Master",
    Music    = "Music",
    SFX      = "SFX",
    Ambience = "Ambience",
    Dialog   = "Dialog"
}

for sndName, path in next, LSM:HashTable("sound") do
    sounds[path] = sndName
end

LSM.RegisterCallback(alerta.core, "LibSharedMedia_Registered", function(_, mediatype, key)
    if mediatype == "sound" then
        local path = LSM:Fetch(mediatype, key)
        if path then
            sounds[path] = key
        end
    end
end)

mod.options = {
    type = "group",
    name = ALERTA_NAME,
    childGroups = "tab", -- Use tabs for better organization
    args = {
        -- General Settings Tab
        generalSettings = {
            type = "group",
            name = "General",
            order = 1,
            args = {
                -- Sound Settings Header
                soundHeader = {
                    type = "header",
                    name = "Sound Settings",
                    order = 10,
                },
                soundDesc = {
                    type = "description",
                    name = "Configure the sound settings for alerts.",
                    fontSize = "medium",
                    order = 11,
                },
                sound = {
                    type = "select",
                    order = 12,
                    values = sounds,
                    name = "Alert Sound",
                    desc = "Choose the sound to play for alerts.",
                    set = function(_, val)
                        AlertaSettings.sound = val
                    end,
                    get = function(_)
                        return AlertaSettings.sound
                    end,
                },
                channel = {
                    type = "select",
                    order = 13,
                    values = channels,
                    name = "Sound Channel",
                    desc = "Choose the channel to play the alert sound.",
                    set = function(_, val)
                        AlertaSettings.channel = val
                    end,
                    get = function(_)
                        return AlertaSettings.channel
                    end,
                },
                testSound = {
                    type = "execute",
                    name = "Preview Alert Sound",
                    order = 14,
                    func = function()
                        PlaySoundFile(AlertaSettings.sound, AlertaSettings.channel)
                    end,
                },
                -- Spacer
                spacer1 = {
                    type = "header",
                    name = "",
                    order = 15,
                },
                -- Chat Output Toggle
                printAnotherOne = {
                    type = "toggle",
                    order = 16,
                    width = "full",
                    name = "Print Aggro to Chat",
                    desc = "Output a message to chat when a new mob gains aggro.",
                    set = function(_, val)
                        AlertaSettings.printAnotherOne = val
                    end,
                    get = function(_)
                        return AlertaSettings.printAnotherOne
                    end,
                },
            },
        },
        -- Elite Mob Settings Tab
        eliteSettings = {
            type = "group",
            name = "Elite Mobs",
            order = 2,
            args = {
                -- Elite Settings Header
                eliteHeader = {
                    type = "header",
                    name = "Elite Mob Settings",
                    order = 20,
                },
                eliteDesc = {
                    type = "description",
                    name = "Configure settings for elite mob alerts.",
                    fontSize = "medium",
                    order = 21,
                },
                eliteSoundOn = {
                    type = "toggle",
                    order = 22,
                    width = "full",
                    name = "Enable Elite Sound",
                    desc = "Use a different sound for elite mobs.",
                    set = function(_, val)
                        AlertaSettings.eliteSoundOn = val
                    end,
                    get = function(_)
                        return AlertaSettings.eliteSoundOn
                    end,
                },
                eliteSound = {
                    type = "select",
                    order = 23,
                    values = sounds,
                    name = "Elite Alert Sound",
                    desc = "Choose the sound to play for elite mob alerts.",
                    set = function(_, val)
                        AlertaSettings.eliteSound = val
                    end,
                    get = function(_)
                        return AlertaSettings.eliteSound
                    end,
                    disabled = function()
                        return not AlertaSettings.eliteSoundOn
                    end,
                    hidden = function()
                        return not AlertaSettings.eliteSoundOn
                    end,
                },
                testEliteSound = {
                    type = "execute",
                    name = "Preview Elite Sound",
                    order = 24,
                    func = function()
                        PlaySoundFile(AlertaSettings.eliteSound, AlertaSettings.channel)
                    end,
                    disabled = function()
                        return not AlertaSettings.eliteSoundOn
                    end,
                    hidden = function()
                        return not AlertaSettings.eliteSoundOn
                    end,
                },
            },
        },
    },
}

-- Setup config
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(name, mod.options, true)
local _, categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(name)

-- Slash command to open config
SLASH_ALERTA1 = "/alerta"
SlashCmdList["ALERTA"] = function(_)
    LibStub("AceConfigDialog-3.0"):Open(name)
    LibStub("AceConfigDialog-3.0"):SelectGroup(name, categoryID)
end