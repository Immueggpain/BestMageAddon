
local addonName = 'BestMageAddon'
local spellIDIgnite = 12654
local spellNameIgnite, _, spellIconIgnite = GetSpellInfo(spellIDIgnite)
local igniteHistory = {}
local igniteHistoryForMeter = {}
local meterWindow = 4
local meterWIndowFalloff = 2

--use LibClassicDurations
local LibClassicDurations = LibStub("LibClassicDurations")
LibClassicDurations:Register(addonName)
local UnitAuraMy = LibClassicDurations.UnitAuraWrapper

-- time function
local syncTimeCO, lastSec, inSecBase
local function GetLocalTime()
	if inSecBase then
		return time()+(GetTime()%1+1-inSecBase)%1
	else
		return time()+0.49
	end
end
local function SyncLocalTime()
	syncTimeCO = coroutine.create(function ()
		while true do
			if time() == lastSec then
				coroutine.yield()
			elseif lastSec and time() == lastSec+1 then
				inSecBase = GetTime()%1
				print('time synced', inSecBase)
				return
			else
				lastSec = time()
				coroutine.yield()
			end
		end
	end)
end
SyncLocalTime()


--create icon frames
local iconTemplateName = 'BestMageAddonIconTemplate'

local function clearIcon(icon)
	icon.texture:SetTexture(nil)
	icon.cooldown:Clear()
	icon.text:SetText('')
end

local iconCenter1 = CreateFrame( "Frame", nil, UIParent, iconTemplateName )
iconCenter1:SetPoint("CENTER", UIParent, "CENTER", -36, -100);
iconCenter1.texture:SetTexture(nil)
iconCenter1.cooldown:SetDrawEdge(true)
iconCenter1.cooldown:SetReverse(true)
iconCenter1.cooldown:GetRegions():SetAlpha(0)
iconCenter1.cooldown:HookScript("OnCooldownDone", function(self)
	clearIcon(iconCenter1)
end)

local iconCenter2 = CreateFrame( "Frame", nil, UIParent, iconTemplateName )
iconCenter2:SetPoint("CENTER", UIParent, "CENTER", 36, -100);
iconCenter2.texture:SetTexture(nil)
iconCenter2.cooldown:SetDrawEdge(true)
iconCenter2.cooldown:SetReverse(true)
iconCenter2.cooldown:GetRegions():SetAlpha(0)
iconCenter2.cooldown:HookScript("OnCooldownDone", function(self)
	clearIcon(iconCenter2)
end)

--create threat frame
local threatFrame = CreateFrame( "Frame", nil, UIParent, "BestMageAddonLabelTemplate" )
threatFrame:SetPoint("TOP", UIParent, "CENTER", 0, -140);

--create history frame
local historyFrame = CreateFrame( "Frame", nil, UIParent, "BestMageAddonLogTemplate" )
historyFrame:SetPoint("CENTER", UIParent, "CENTER", 200, 0);
historyFrame.text:SetPoint("BOTTOM", historyFrame, "BOTTOM")


local function onUpdateSlow()
	clearIcon(iconCenter1)
	clearIcon(iconCenter2)
	local threatStr = ''
	
	if UnitIsEnemy("player","target") then
		for i = 1, 40 do
			local name, icon, count, debuffType, duration, expirationTime, source, isStealable, nameplateShowPersonal, spellId, canApplyAura, isBossDebuff, castByPlayer, nameplateShowAll, timeMod, arg1, arg2 = UnitAuraMy("target", i, "HARMFUL")
			if name then
				local durLeft
				if expirationTime and expirationTime>0 then
					durLeft = expirationTime - GetTime()
				else
					durLeft = 0
				end
				--print(i, name, '|T'..icon..':16|t', count, source, spellId, castByPlayer, duration, durLeft)
				if spellId == spellIDIgnite then --点燃
					iconCenter1.texture:SetTexture(icon)
					iconCenter1.cooldown:SetCooldown(expirationTime-duration, duration)
					iconCenter1.text:SetText(count)
				elseif spellId == 22959 then --灼烧
					iconCenter2.texture:SetTexture(icon)
					iconCenter2.cooldown:SetCooldown(expirationTime-duration, duration)
					iconCenter2.text:SetText(count)
				end
			end
		end
		
		--thread monitor
		local isTanking, status, scaledPercentage, rawPercentage, threatValue = UnitDetailedThreatSituation("player","target")
		if isTanking ~= nil then
			--print(isTanking, status, scaledPercentage, rawPercentage, threatValue)
			local statusInfo
			if status == 0 then
				statusInfo = '安全'
			elseif status == 1 then
				statusInfo = '仇恨超过T啦! 幸好还未OT!'
			elseif status == 2 then
				statusInfo = '有人仇恨超过你啦! 但怪还在看你!'
			elseif status == 3 then
				statusInfo = '你仇恨爆表! 怪不会放过你的!'
			end
			if rawPercentage == 255 then rawPercentage='主要目标!' else rawPercentage=rawPercentage..'%' end
			threatStr = string.format('仇恨：%s %s', rawPercentage, statusInfo)
		end
	end
	
	threatFrame.text:SetText(threatStr)
	
	--update ignite history frame
	local histStr = ''
	for i, igniteProc in ipairs(igniteHistory) do
		local spellIconIgnite, sourceName, amount = unpack(igniteProc)
		histStr =  histStr .. "|T"..spellIconIgnite..":0|t " .. "|cff3fc6ea" .. sourceName .. "|r " .. amount .. "\n"
	end
	
	local totalDamage = 0
	local now = time()
	for i, v in pairs(igniteHistoryForMeter) do
		local _, _, amount, timestamp = unpack(v)
		
		if timestamp <= now - meterWindow - meterWIndowFalloff then
			igniteHistoryForMeter[i] = nil
		elseif timestamp > now - meterWindow then
			totalDamage = totalDamage + amount
		else
			totalDamage = totalDamage + amount*(timestamp-(now - meterWindow - meterWIndowFalloff))/meterWIndowFalloff
		end
	end
local dpsIgnite = totalDamage/(meterWindow+meterWIndowFalloff/2)
	histStr =  histStr .. string.format("团队点燃DPS: %.2f", dpsIgnite)
	
	historyFrame.text:SetText(histStr)
end

local timeElapsed = 0
local function onUpdate(self, elapsed)
	if syncTimeCO ~= nil then
		local canResume, errMsg = coroutine.resume(syncTimeCO)
		if canResume == false then
			syncTimeCO = nil
		end
	end
	
	timeElapsed = timeElapsed + elapsed
	if (timeElapsed > 0.1) then
		timeElapsed = 0
		onUpdateSlow()
	end
end

local function onEvent(self, event, ...)
	if event == 'COMBAT_LOG_EVENT_UNFILTERED' then
		local cleuPack = {CombatLogGetCurrentEventInfo()}
		local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = unpack(cleuPack)
		local spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
		
		--print((timestamp-GetTime())%1)
		
		if subevent == "SPELL_PERIODIC_DAMAGE" then
			spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand = select(12, unpack(cleuPack))
		end
		
		if spellName == spellNameIgnite then
			--print(string.format("%s %s %s %d", sourceName, spellName, destName, amount))
			
			local igniteProc = {spellIconIgnite, sourceName, amount, timestamp}
			table.insert(igniteHistory, igniteProc)
			while #igniteHistory > 20 do
				table.remove(igniteHistory, 1)
			end
			
			igniteHistoryForMeter[destGUID..timestamp] = igniteProc
		end
	end
end

local function onCmd()
	print('hello this is addon')
end

--create a frame for receiving events
local eventFrame = CreateFrame("FRAME", addonName.."_event_frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnUpdate", onUpdate)
eventFrame:SetScript("OnEvent", onEvent)

--create slash command
local cmdName = 'hello'
SlashCmdList[addonName..cmdName] = onCmd
_G['SLASH_'..addonName..cmdName..'1'] = '/dog'
_G['SLASH_'..addonName..cmdName..'1'] = '/cat'
