local name, alerta = ...
alerta.core = {}
alerta.core.settings = {}
local mod = alerta.core
AlertaOptions = {
    ALERTA_NAME = "Alerta",
    COLOR_CODES = {
        Success = "FF00FF0D",
        Info = "FF0085DD"
    }
}


-- Register shared sounds
local LSM = LibStub("LibSharedMedia-3.0")
LSM:Register("sound", "Alerta:Alerta", "Interface\\AddOns\\Alerta\\Sounds\\Alerta.ogg")
LSM:Register("sound", "Alerta:Unexpected", "Interface\\AddOns\\Alerta\\Sounds\\AlertUnexpected.ogg")
LSM:Register("sound", "Alerta:AnotherOne", "Interface\\AddOns\\Alerta\\Sounds\\AnotherOne.ogg")
LSM:Register("sound", "Alerta:HelloThere", "Interface\\AddOns\\Alerta\\Sounds\\HelloThere.ogg")

-- Embed LibDBIcon-1.0
local LibDBIcon = LibStub("LibDBIcon-1.0")
local LibDataBroker = LibStub("LibDataBroker-1.1")
local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local sounds = {}
local channels = {
    Master   = "Master",
    Music    = "Music",
    SFX      = "SFX",
    Ambience = "Ambience",
    Dialog   = "Dialog"
}

-- Create a minimap button
local minimapButton = LibDataBroker:NewDataObject(AlertaOptions.ALERTA_NAME, {
    icon = "Interface\\Icons\\Inv_misc_head_dragon_01", -- Icon for the minimap button
    OnClick = function(_, button)
        if button == "LeftButton" then
            -- Open the AceConfig dialog
            AceConfigDialog:Open(AlertaOptions.ALERTA_NAME)
        elseif button == "RightButton" then
            -- Toggle minimap icon visibility
            AlertaSettings.minimap.hide = not AlertaSettings.minimap.hide
            LibDBIcon:Refresh(AlertaOptions.ALERTA_NAME, AlertaSettings.minimap)
        end
    end,
    OnTooltipShow = function(tooltip)
        tooltip:AddLine(AlertaOptions.ALERTA_NAME)
        tooltip:AddLine("Left-click to open settings.")
        tooltip:AddLine("Right-click to hide the minimap icon.")
    end,
    type = "launcher",
})

-- Initialize minimap icon
function AlertaOptions:InitializeMinimapIcon()
    AlertaSettings.minimap = AlertaSettings.minimap or { hide = false }
    LibStub("LibDBIcon-1.0"):Register(AlertaOptions.ALERTA_NAME, minimapButton, AlertaSettings.minimap)
end

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
    name = AlertaOptions.ALERTA_NAME,
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
                -- customSound = {
                --     type = "input",
                --     order = 13,
                --     name = "Custom Sound Path",
                --     desc =
                --     "Enter the path to a custom sound file.\nExample: Interface\\AddOns\\Alerta\\Sounds\\Custom.ogg",
                --     set = function(_, val)
                --         AlertaSettings.customSound = val
                --     end,
                --     get = function()
                --         return AlertaSettings.customSound or ""
                --     end,
                -- },
                channel = {
                    type = "select",
                    order = 14,
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
                    order = 15,
                    func = function()
                        PlaySoundFile(AlertaSettings.sound, AlertaSettings.channel)
                    end,
                },
                -- Spacer
                spacer1 = {
                    type = "header",
                    name = "",
                    order = 16,
                },
                -- Chat Output Toggle
                printAnotherOne = {
                    type = "toggle",
                    order = 17,
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
        -- Minimap Settings Tab
        minimapSettings = {
            type = "group",
            name = "Minimap",
            order = 3,
            args = {
                -- Minimap Settings Header
                minimapHeader = {
                    type = "header",
                    name = "Minimap Settings",
                    order = 30,
                },
                minimapDesc = {
                    type = "description",
                    name = "Configure the minimap icon settings.",
                    fontSize = "medium",
                    order = 31,
                },
                minimapIcon = {
                    type = "toggle",
                    order = 32,
                    name = "Show Minimap Icon",
                    desc = "Toggle the minimap icon on or off.",
                    get = function()
                        return not AlertaSettings.minimap.hide
                    end,
                    set = function(_, value)
                        AlertaSettings.minimap.hide = not value
                        LibDBIcon:Refresh(AlertaOptions.ALERTA_NAME, AlertaSettings.minimap)
                    end,
                },
            },
        },
        -- Reset to Defaults
        resetSettings = {
            type = "group",
            name = "Reset",
            order = 4,
            args = {
                -- Reset Settings Header
                resetHeader = {
                    type = "header",
                    name = "Reset Settings",
                    order = 40,
                },
                resetDesc = {
                    type = "description",
                    name = "Reset all settings to their default values.",
                    fontSize = "medium",
                    order = 41,
                },
                resetButton = {
                    type = "execute",
                    order = 42,
                    name = "Reset to Defaults",
                    desc = "Reset all settings to default values.",
                    func = function()
                        AlertaSettings = nil
                        ReloadUI()
                    end,
                },
            },
        },
    },
}

-- Setup config
LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(name, mod.options, true)
local _, categoryID = AceConfigDialog:AddToBlizOptions(name)

-- Slash command to open config
SLASH_ALERTA1 = "/alerta"
SlashCmdList["ALERTA"] = function(_)
    LibStub("AceConfigDialog-3.0")
    AceConfigDialog:Open(name)
    AceConfigDialog:SelectGroup(name, categoryID)
end
