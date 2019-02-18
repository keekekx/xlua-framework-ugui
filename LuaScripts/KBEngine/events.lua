--[[
Auth:E_Ye
like Unity Brocast Event System in lua.
]]

local EventLib = require "KBEngine/eventlib"

local Event = {}
-- local events = {}
local inEvents = {}  --kbe 监听实体事件列表
local outEvents = {} --实体 监听kbe事件列表
local uiEvents = {} --ui事件列表  业务逻辑间使用

-- 监听ui发往kbe事件
function Event.AddInListener(event, handler, obj)
	Event.AddListener(event, handler, obj, inEvents)
end

--监听kbe发往ui事件
function Event.AddKbeListener(event, handler, obj)
	Event.AddListener(event, handler, obj, outEvents)
end

function Event.RemoveInListener(event, handler)
	Event.RemoveListener(event, handler, inEvents)
end

function Event.RemoveKbeListener(event, handler)
	Event.RemoveListener(event, handler, outEvents)
end

function Event.BroadcastIn(eventName, sender, ...)
	Event.Broadcast(eventName, inEvents, sender, ...)
end

function Event.BroadcastOut(eventName, sender, ...)
	Event.Broadcast(eventName, outEvents, sender, ...)
end

--ui事件
--监听kbe发往ui事件
function Event.AddUIListener(event, handler, obj)
	Event.AddListener(event, handler, obj, uiEvents)
end

function Event.RemoveUIListener(obj)
	Event.RemoveListenerByObject(obj, uiEvents)
end

function Event.BroadcastUI(eventName, sender, ...)
	Event.Broadcast(eventName, uiEvents, sender, ...)
end


function Event.AddListener(event, handler, obj, events)
	if not event or type(event) ~= "string" then
		error("event parameter in AddListener function has to be string, " .. type(event) .. " not right.")
	end
	if not handler or type(handler) ~= "function" then
		error("handler parameter in AddListener function has to be function, " .. type(handler) .. " not right")
	end

	if not events[event] then
		--create the Event with name
		events[event] = EventLib:new(event)
		events[event].listener = obj
	end
	--conn this handler
	events[event]:connect(handler)
end

function Event.Broadcast(eventName, events, sender, ...)
	if not events[eventName] then
		error("brocast " .. eventName .. " has no event.")
	else
		events[eventName]:Fire(sender, ...)
	end
end

function Event.RemoveListener(event, handler, events)
	if not events[event] then
		error("remove " .. event .. " has no event.")
	else
		events[event]:disconnect(handler)
	end
end

--根据监听对象移除相同对象的Listener
function Event.RemoveListenerByObject(obj, events)
	---@param v EventLib
	for i, v in pairs(events) do
		if v.listener == obj then
			events[i]:disconnect(v.handler)
		end
	end
end

return Event