
local addonName = 'BestMageAddon'

local function onUpdate()
	
end

local function onEvent(self, event, ...)
	if event == "MERCHANT_SHOW" then
		print("MERCHANT_SHOW", GetTime())
	elseif event == "BAG_UPDATE" then
		print("BAG_UPDATE", GetTime())
	elseif event == "BAG_UPDATE_DELAYED" then
		print("BAG_UPDATE_DELAYED", GetTime())
	elseif event == "ITEM_PUSH" then
		print("ITEM_PUSH", GetTime())
	end
end

local function onCmd()
	print('hello this is addon')
end

--create a frame for receiving events
local eventFrame = CreateFrame("FRAME", addonName.."_event_frame")
eventFrame:RegisterEvent("MERCHANT_SHOW")
eventFrame:SetScript("OnUpdate", onUpdate)
eventFrame:SetScript("OnEvent", onEvent)

--create slash command
local cmdName = 'hello'
SlashCmdList[addonName..cmdName] = onCmd
_G['SLASH_'..addonName..cmdName..'1'] = '/dog'
_G['SLASH_'..addonName..cmdName..'1'] = '/cat'
