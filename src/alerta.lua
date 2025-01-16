ALERTA_NAME = "Alerta"
COLOR_CODES = {
	Success = "FF00FF0D",
	Info = "FF0085DD"
}
local alerta = CreateFrame("Frame")
local mobListSize = 30

-- TODOS
-- custom sound for elite mobs
-- allow to select multiple sounds
-- allow to set sound path manually
-- send addon event message to let other addons to communicate
local mobs = {}
local threats = {}
local playerAwareTargets = {}

function alerta:OnEvent(event, ...)
	self[event](self, event, ...)
end

function alerta:OnUpdate()
	-- for each mob detected
	for value in pairs(mobs) do
		if (not UnitExists(value) or UnitIsUnit(value, "target")) then alerta:removeFromTable(mobs, value) end
		local threatStatus = UnitThreatSituation("player", value)
		if (threatStatus ~= nil and threatStatus >= 2) then
			-- print("threat")
			alerta:appendThreat(value)
		end
	end

	-- local statusAny = UnitThreatSituation("player")
	-- -- if state is still same - do nothing
	-- if (lastThreatSituation == statusAny) then return end;
	-- -- update last threat situation
	-- lastThreatSituation = statusAny
	-- if (statusAny == nil) then
	-- 	print("Out of combat")
	-- elseif (statusAny >= 2) then
	-- 	print("Entered combat")
	-- end
	-- DEFAULT_CHAT_FRAME:AddMessage(statusAny, 1, 1, 1)
end

function alerta:ADDON_LOADED(_, addOnName)
	if (addOnName ~= ALERTA_NAME) then return end

	local dbDefaults = {
		sound = "Interface\\AddOns\\Alerta\\Sounds\\Alerta.ogg",
		channel = "Master",
		printAnotherOne = false
	}
	AlertaSettings = AlertaSettings or dbDefaults
	Output("Loaded " .. WrapTextInColorCode("successfully", COLOR_CODES.Success))
end

function alerta:UNIT_THREAT_LIST_UPDATE(_, unitId)
	if (unitId == nil) then return end
	-- local uid = UnitGUID(unitId)
	local threatStatus = UnitThreatSituation("player", unitId)
	if (threatStatus == nil or threatStatus < 2) then
		-- print("Mob "..uid.." is no longer a danger")
		alerta:removeThreat(unitId)
	elseif (threatStatus >= 2) then
		-- print("Mob "..uid.." changed threat level to "..threatStatus)
		alerta:appendThreat(unitId)
	end
	-- DEFAULT_CHAT_FRAME:AddMessage("UnitId: "..unitId, 1, 1, 1);
end

-- New mob detected
function alerta:NAME_PLATE_UNIT_ADDED(_, unitId)
	alerta:appendToTable(mobs, unitId)
end

-- Out of combat event
function alerta:PLAYER_REGEN_ENABLED(_)
	alerta:clearTable(threats)
end

-- Unit combat event (alsao detects AOE hits)
function alerta:UNIT_COMBAT(_, unitTarget, event, flagText, amount, schoolMask)
	if (unitTarget ~= "player" and unitTarget ~= nil) then
		local uid = UnitGUID(unitTarget)
		-- print(uid)
		-- print("[COMBAT] Player is now aware of "..uid)
		alerta:appendToTable(playerAwareTargets, uid)
	end
end

-- Unit casted a spell
function alerta:UNIT_SPELLCAST_SENT(_, unit, target, castGUID, spellID)
	if (target ~= "player" and target ~= nil) then
		local uid = UnitGUID("target")
		-- print("[SPELL] Player is now aware of "..uid)
		alerta:appendToTable(playerAwareTargets, uid)
	end
end

alerta:RegisterEvent("ADDON_LOADED")
alerta:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
alerta:RegisterEvent("NAME_PLATE_UNIT_ADDED")
alerta:RegisterEvent("PLAYER_REGEN_ENABLED")
alerta:RegisterEvent("UNIT_COMBAT")
alerta:RegisterEvent("UNIT_SPELLCAST_SENT")
alerta:SetScript("OnEvent", alerta.OnEvent)
alerta:SetScript("OnUpdate", alerta.OnUpdate)

-- Append unit to threat list
function alerta:appendThreat(unitId)
	local uid = UnitGUID(unitId)
	if (uid == nil) then return end
	-- if player is aware of threat - do not append
	if (alerta:tableContains(playerAwareTargets, uid) or UnitIsUnit(unitId, "target")) then return end

	local newThreat = alerta:appendToTable(threats, uid)
	-- alerta:printTable(threats)
	-- print(newThreat)
	if (newThreat == true) then
		-- print("Another "..uid)
		alerta:playSound()
		if ((AlertaSettings.printAnotherOne or false) == true) then
			Output("Another one! " .. WrapTextInColorCode(uid, COLOR_CODES.Info))
		end
	end
end

-- Remove unit from threat list
function alerta:removeThreat(unitId)
	-- local uid = UnitGUID(unitId)
	-- print("Mob "..uid.." is no longer a danger")
	alerta:removeFromTable(threats, unitId)
	-- alerta:printTable(threats)
end

-- Play sound
function alerta:playSound()
	PlaySoundFile(AlertaSettings.sound, AlertaSettings.channel)
end

function alerta:appendToTable(table, targetId)
	if targetId == nil then return false end
	if not alerta:tableContains(table, targetId) then
		-- print("Before")
		-- alerta:printTable(table)
		if alerta:getTableSize(table) >= mobListSize then
			alerta:popTable(table)
		end
		-- local uid = UnitGUID(targetId)
		alerta:addToTable(table, targetId, true)
		-- print("After")
		-- alerta:printTable(table)
		return true
	else
		return false
	end
end

function alerta:addToTable(table, key, value)
	table[key] = value
end

function alerta:getFromTable(table, key)
	return table[key]
end

function alerta:removeFromTable(table, key)
	-- print("Before")
	-- alerta:printTable(table)
	table[key] = nil
	-- print("After")
	-- alerta:printTable(table)
end

function alerta:tableContains(table, key)
	return table[key] ~= nil
end

function alerta:getTableSize(table)
	local count = 0

	for _ in pairs(table) do
		count = count + 1
	end

	return count
end

function alerta:popTable(table)
	for value in pairs(table) do
		-- print("alerta:popTableped: "..value)
		table[value] = nil
		break
	end
end

function alerta:printTable(table)
	local count = 0

	for value in pairs(table) do
		print(value)
	end

	return count
end

function alerta:clearTable(table)
	for value in pairs(table) do
		table[value] = nil
	end
end

function Output(msg)
	local printMsg = WrapTextInColorCode("[", COLOR_CODES.Info) ..
		"Alerta |TInterface\\Icons\\Inv_misc_head_dragon_01:12|t" ..
		WrapTextInColorCode("]", COLOR_CODES.Info) ..
		" " .. msg
	print(printMsg)
end
