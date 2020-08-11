
local addonName = 'BestMageAddon'

local function onUpdateSlow()
	if UnitIsEnemy("player","target") then
		for i = 1, 40 do
			local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAura("target", i, "HARMFUL")
			if name then
				print(i, name, '|T'..icon..':16|t', count, source, spellId, castByPlayer)
			end
		end
	end
end

local timeElapsed = 0
local function onUpdate(self, elapsed)
	timeElapsed = timeElapsed + elapsed
	if (timeElapsed > 1) then
		timeElapsed = 0
		onUpdateSlow()
	end
end

local function onEvent(self, event, ...)
	print(event, ...)
end

local function onCmd()
	print('hello this is addon')
end

--create a frame for receiving events
local eventFrame = CreateFrame("FRAME", addonName.."_event_frame")
--eventFrame:RegisterEvent("UNIT_AURA")
eventFrame:SetScript("OnUpdate", onUpdate)
eventFrame:SetScript("OnEvent", onEvent)

--create slash command
local cmdName = 'hello'
SlashCmdList[addonName..cmdName] = onCmd
_G['SLASH_'..addonName..cmdName..'1'] = '/dog'
_G['SLASH_'..addonName..cmdName..'1'] = '/cat'
