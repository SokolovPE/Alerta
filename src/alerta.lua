local alerta = CreateFrame("Frame")
local mobListSize = 30

-- Tables to track mobs and threats
local mobs = {}
local threats = {}
local playerAwareTargets = {}

-- Event handler
function alerta:OnEvent(event, ...)
    self[event](self, event, ...)
end

-- Addon loaded
function alerta:ADDON_LOADED(_, addOnName)
    if addOnName ~= AlertaOptions.ALERTA_NAME then return end

    -- Default settings
    local dbDefaults = {
        sound = "Interface\\AddOns\\Alerta\\Sounds\\Alerta.ogg",
        eliteSound = "Interface\\AddOns\\Alerta\\Sounds\\AlertUnexpected.ogg",
        channel = "Master",
        printAnotherOne = false,
        eliteSoundOn = false,
        minimap = { hide = false }, -- Default to showing the minimap icon
    }
    AlertaSettings = AlertaSettings or dbDefaults

    -- Initialize minimap icon
    AlertaOptions:InitializeMinimapIcon()

    Output("Loaded " .. WrapTextInColorCode("successfully", AlertaOptions.COLOR_CODES.Success))
end

-- Threat list updated
function alerta:UNIT_THREAT_LIST_UPDATE(_, unitId)
    if not unitId then return end

    local threatStatus = UnitThreatSituation("player", unitId)
    if not threatStatus or threatStatus < 2 then
        self:RemoveThreat(unitId)
    else
        self:AppendThreat(unitId)
    end
end

-- New mob detected via nameplate
function alerta:NAME_PLATE_UNIT_ADDED(_, unitId)
    self:TrackMob(unitId)
end

-- Player exits combat
function alerta:PLAYER_REGEN_ENABLED()
    self:ClearTable(threats)
end

-- Unit casted a spell
function alerta:UNIT_SPELLCAST_SENT(_, unit, target, castGUID, spellID)
    if (target ~= "player" and target ~= nil) then
        local uid = UnitGUID("target")
        self:AppendToTable(playerAwareTargets, uid)
    end
end

-- Mob attacks player (even without nameplates)
function alerta:COMBAT_LOG_EVENT_UNFILTERED()
    local _, subEvent, _, _, _, _, _, destGUID, _, _, _, _ = CombatLogGetCurrentEventInfo()
    if subEvent == "SWING_DAMAGE" or subEvent == "SPELL_DAMAGE" then
        if destGUID == UnitGUID("player") then
            local sourceGUID = select(8, CombatLogGetCurrentEventInfo())
            if sourceGUID and not UnitIsUnit(sourceGUID, "target") then
                self:TrackMob(sourceGUID)
            end
        end
    end
end

-- Track a new mob
function alerta:TrackMob(unitId)
    if not UnitExists(unitId) or UnitIsUnit(unitId, "target") then return end
    self:AppendToTable(mobs, unitId)
end

-- Append unit to threat list
function alerta:AppendThreat(unitId)
    local uid = UnitGUID(unitId)
    if not uid or self:TableContains(playerAwareTargets, uid) or UnitIsUnit(unitId, "target") then return end

    if self:AppendToTable(threats, uid) then
        self:PlaySound(unitId)
        if AlertaSettings.printAnotherOne then
            Output("Another one! " .. WrapTextInColorCode(uid, AlertaOptions.COLOR_CODES.Info))
        end
    end
end

-- Remove unit from threat list
function alerta:RemoveThreat(unitId)
    self:RemoveFromTable(threats, unitId)
end

-- Play sound based on mob type
function alerta:PlaySound(unitId)
    local soundFile = AlertaSettings.sound
    if AlertaSettings.eliteSoundOn and (UnitClassification(unitId) == "elite" or UnitClassification(unitId) == "rareelite") then
        soundFile = AlertaSettings.eliteSound
    end
    PlaySoundFile(soundFile, AlertaSettings.channel)
end

-- Utility functions
function alerta:AppendToTable(table, key)
    if not key or self:TableContains(table, key) then return false end
    if self:GetTableSize(table) >= mobListSize then
        self:PopTable(table)
    end
    table[key] = true
    return true
end

function alerta:RemoveFromTable(table, key)
    table[key] = nil
end

function alerta:TableContains(table, key)
    return table[key] ~= nil
end

function alerta:GetTableSize(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

function alerta:PopTable(table)
    for key in pairs(table) do
        table[key] = nil
        break
    end
end

function alerta:ClearTable(table)
    for key in pairs(table) do
        table[key] = nil
    end
end

-- Output message to chat
function Output(msg)
    local printMsg = WrapTextInColorCode("[", AlertaOptions.COLOR_CODES.Info) ..
        "Alerta |TInterface\\Icons\\Inv_misc_head_dragon_01:12|t" ..
        WrapTextInColorCode("]", AlertaOptions.COLOR_CODES.Info) ..
        " " .. msg
    print(printMsg)
end

-- Register events
alerta:RegisterEvent("ADDON_LOADED")
alerta:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
alerta:RegisterEvent("UNIT_SPELLCAST_SENT")
alerta:RegisterEvent("NAME_PLATE_UNIT_ADDED")
alerta:RegisterEvent("PLAYER_REGEN_ENABLED")
alerta:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
alerta:SetScript("OnEvent", alerta.OnEvent)
