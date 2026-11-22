-- turn-notify: desktop notification when a long agent turn ends.
--
--   require('plugins/turn-notify').setup{ min_seconds = 60 }
--
-- Turns shorter than min_seconds stay silent. Needs notify-send; without it
-- nothing happens. The message is fixed: no turn summary.

local notify = require('plugins/notify')

local M = {}

local started, min_seconds = nil, 60

-- a user text message starts a turn; tool results are user messages too, so
-- only a text first block counts, and only when no turn is already counted
local function on_message(msg)
	if started or msg.role ~= 'user' then
		return
	end
	local first = msg.content and msg.content[1]
	if first and first.type == 'text' then
		started = sclop.core.now()
	end
end

local function on_turn_end()
	local start = started
	started = nil
	if not start then
		return
	end
	if sclop.core.now() - start < min_seconds * 1000 then
		return
	end
	notify.send({ summary = 'sclop: turn finished' }, function() end)
end

function M.setup(opts)
	opts = opts or {}
	min_seconds = tonumber(opts.min_seconds) or min_seconds
	sclop.events.subscribe(sclop.events.MESSAGE, on_message)
	sclop.events.subscribe(sclop.events.TURN_END, on_turn_end)
	return M
end

return M
