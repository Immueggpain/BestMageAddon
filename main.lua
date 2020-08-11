
local addonName = 'BestMageAddon'

--use LibClassicDurations
local LibClassicDurations = LibStub("LibClassicDurations")
LibClassicDurations:Register(addonName)
local UnitAuraMy = LibClassicDurations.UnitAuraWrapper

--create icon frames
local iconTemplateName = 'BestMageAddonIconTemplate'

local iconCenter1 = CreateFrame( "Frame", nil, UIParent, iconTemplateName )
iconCenter1:SetPoint("CENTER", UIParent, "CENTER", -36, -100);
iconCenter1.texture:SetTexture(nil)
iconCenter1.cooldown:SetDrawEdge(true)
iconCenter1.cooldown:SetReverse(true)

local iconCenter2 = CreateFrame( "Frame", nil, UIParent, iconTemplateName )
iconCenter2:SetPoint("CENTER", UIParent, "CENTER", 36, -100);
iconCenter2.texture:SetTexture(nil)
iconCenter2.cooldown:SetDrawEdge(true)
iconCenter2.cooldown:SetReverse(true)
					iconCenter1.cooldown:GetRegions():SetAlpha(0)
					iconCenter2.cooldown:GetRegions():SetAlpha(0)


local function onUpdateSlow()
	iconCenter1.texture:SetTexture(nil)
	iconCenter1.cooldown:Clear()
	iconCenter2.texture:SetTexture(nil)
	iconCenter2.cooldown:Clear()
	if UnitIsEnemy("player","target") then
		for i = 1, 40 do
			local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod = UnitAuraMy("target", i, "HARMFUL")
			if name then
				local durLeft
				if expirationTime and expirationTime>0 then
					durLeft = expirationTime - GetTime()
				else
					durLeft = 0
				end
				--print(i, name, '|T'..icon..':16|t', count, source, spellId, castByPlayer, duration, durLeft)
				if spellId == 12654 then --点燃
					iconCenter1.texture:SetTexture(icon)
					iconCenter1.cooldown:SetCooldown(expirationTime-duration, duration)
				elseif spellId == 22959 then --灼烧
					iconCenter2.texture:SetTexture(icon)
					iconCenter2.cooldown:SetCooldown(expirationTime-duration, duration)
				end
			end
		end
	end
end

local timeElapsed = 0
local function onUpdate(self, elapsed)
	timeElapsed = timeElapsed + elapsed
	if (timeElapsed > 0.5) then
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
