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
    args = {
        sound = {
            type = "select",
            order = 1,
            values = sounds,
            name = "Sound",
            desc = "Set sound of alert",
            set = function(_, val)
                AlertaSettings.sound = val
            end,
            get = function(_)
                return AlertaSettings.sound
            end
        },
        channel = {
            type = "select",
            order = 2,
            values = channels,
            name = "Channel",
            desc = "Channel to play sound at",
            set = function(_, val)
                AlertaSettings.channel = val
            end,
            get = function(_)
                return AlertaSettings.channel
            end
        },
        test = {
            type = "execute",
            name = "Preview",
            order = 3,
            func = function()
                PlaySoundFile(AlertaSettings.sound, AlertaSettings.channel)
            end
        },
        printAnotherOne = {
            type = "toggle",
            order = 4,
            width = "full",
            name = "Print aggro to chat",
            desc = "Output new mob alert to chat",
            set = function(_, val)
                AlertaSettings.printAnotherOne = val
            end,
            get = function(_)
                return AlertaSettings.printAnotherOne
            end
        }
    }
}

-- Setup config
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(name, mod.options, true)
local _, categoryID = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(name)

SLASH_ALERTA1 = "/alerta"
SlashCmdList["ALERTA"] = function(_)
    LibStub("AceConfigDialog-3.0"):Open(name)
    LibStub("AceConfigDialog-3.0"):SelectGroup(name, categoryID)
end
