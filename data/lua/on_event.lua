local utils = wesnoth.require "lua/wml-utils.lua"
-- registers an event handler. note that, like all lua variables this is not persitent in savefiles,
-- so you have to call this function from a toplevel lua tag or from a preload event.
-- It is also not possible to use this for first_time_only=yes events.

local event_handlers = {}
local old_on_event = wesnoth.game_events.on_event or function(eventname) end
wesnoth.game_events.on_event = function(eventname)
	old_on_event(eventname)
	local context = nil
	for k,v in pairs(event_handlers[eventname] or {}) do
		if context == nil then
			context = wesnoth.current.event_context
		end
		v.h(context)
	end
end

local function on_event(eventname, arg1, arg2)
	if string.match(eventname, ",") then
		for elem in utils.split(eventname or "") do
			on_event(elem, arg1, arg2)
		end
	end
	local priority = 0
	local handler = nil
	if type(arg1) == "function" then
		handler = arg1	
	else
		priority = arg1
		handler = arg2
	end
	eventname = string.gsub(eventname, " ", "_")
	event_handlers[eventname] = event_handlers[eventname] or {}
	table.insert(event_handlers[eventname], { h = handler, p = priority})
	-- sort it.
	for i = #event_handlers - 1, 1, -1 do
		if event_handlers[i].p < event_handlers[i + 1].p then
			event_handlers[i], event_handlers[i + 1] = event_handlers[i + 1], event_handlers[i]
		end
	end
end

return on_event
