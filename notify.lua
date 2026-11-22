-- notify: send a desktop notification with notify-send.
--
--   require('plugins/notify')
--
-- Registers the `notify` tool: notify(summary, body?, urgency?). Nothing is
-- hidden when notify-send is missing; the tool answers with the reason instead.

local util = require('sclop.util')

local M = {}

local URGENCIES = { low = true, normal = true, critical = true }

local function have_notify_send()
	return util.has('notify-send')
end

-- argv for one notification; returns nil plus a reason when it cannot be built
local function argv(summary, body, urgency)
	if type(summary) ~= 'string' or summary:match('^%s*$') then
		return nil, 'summary is required'
	end
	if urgency ~= nil and not URGENCIES[urgency] then
		return nil, 'urgency must be low, normal or critical'
	end
	local a = { 'notify-send', '--app-name=sclop' }
	if urgency then
		a[#a + 1] = '--urgency=' .. urgency
	end
	a[#a + 1] = '--'
	a[#a + 1] = summary
	if type(body) == 'string' and body ~= '' then
		a[#a + 1] = body
	end
	return a
end

-- send one notification: done(text, is_error)
function M.send(opts, done)
	if not have_notify_send() then
		return done('notify-send is not installed', true)
	end
	local a, err = argv(opts.summary, opts.body, opts.urgency)
	if not a then
		return done(err, true)
	end
	local timer = nil
	local p = util.capture(a, function(text, code, sig)
		if timer then
			timer:stop()
		end
		if sig ~= 0 then
			return done('notify-send was killed', true)
		elseif code ~= 0 then
			return done('notify-send failed: ' .. (text ~= '' and text or 'exit code ' .. code), true)
		end
		return done('notified: ' .. opts.summary)
	end)
	if p then
		timer = sclop.timer(5000, function()
			p:kill(9)
		end)
	end
	return p
end

sclop.tools.register{
	name = 'notify',
	description = 'Send a desktop notification with notify-send. Use it to tell the user something '
		.. 'when they may not be looking at the terminal. summary is the title and is required; '
		.. 'body is optional detail; urgency is low, normal (default) or critical.',
	schema = {
		type = 'object',
		properties = {
			summary = { type = 'string', description = 'notification title' },
			body = { type = 'string', description = 'optional notification body' },
			urgency = { type = 'string', description = 'low, normal or critical' },
		},
		required = sclop.json.array{ 'summary' },
	},
	summary = function(a)
		return a.summary
	end,
	run = function(a, done)
		return M.send({ summary = a.summary, body = a.body, urgency = a.urgency }, done)
	end,
}

return M
